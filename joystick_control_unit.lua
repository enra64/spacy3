require("common")
local timer = require("hump.timer")


local joystick_control = {}

joystick_control.new = function(joystick, bindings)
    local enable_rumble = require("settings"):get_current_value("rumble") == "on"
    local ctrl = {}
    ctrl.joystick = joystick
    ctrl.bindings = bindings

    -- "public" members
    ctrl.type = "joystick"
    ctrl.state = {x = 0, y = 0, button_a_pressed = false, button_b_pressed = false, button_escape_pressed = false, button_store_pressed = false}
    ctrl.xoff = joystick:getAxis(bindings.x_axis)
    ctrl.yoff = joystick:getAxis(bindings.y_axis)


    -- subscribe to rumble events
    if enable_rumble and joystick:isVibrationSupported() then
        signal.register("explosion", function()
            if joystick:isVibrationSupported() then
                joystick:setVibration(0.5, 0.5)
                timer.after(0.2, function() joystick:setVibration(0, 0) end)
            end
        end)
    end

    local store_button_name = bindings.store_button_name
    if store_button_name then
        ctrl.store_button_help = {
            text = "press " .. store_button_name.." for store",
            y = love.graphics.getHeight() - love.graphics.getFont():getHeight()
        }
    end

    ctrl.draw = function(control, store_triggered)
        if store_triggered and control.store_button_help then
            love.graphics.printf(control.store_button_help.text, 0, control.store_button_help.y, love.graphics.getWidth(), "center")
        end
    end

    ctrl.update = function(control, dt)
        --- load direction vector
        control.state.x = (control.joystick:getAxis(control.bindings.x_axis) - control.xoff) * dt
        control.state.y = (control.joystick:getAxis(control.bindings.y_axis) - control.yoff) * dt
        return control.state
    end

    ctrl.joystickpressed = function(control, joystick, button)
        --log.trace("pressed "..button)
        if joystick == control.joystick then
            if button == control.bindings.button_a then
                control.state.button_a_pressed = true
            elseif button == control.bindings.button_b then
                control.state.button_b_pressed = true
            elseif button == control.bindings.button_escape then
                control.state.button_escape_pressed = true
            elseif button == control.bindings.button_store then
                control.state.button_store_pressed = true
            end
        end
    end

    ctrl.joystickreleased = function(control, joystick, button)
        if joystick == control.joystick then
            if button == control.bindings.button_a then
                control.state.button_a_pressed = false
            elseif button == control.bindings.button_b then
                control.state.button_b_pressed = false
            elseif button == control.bindings.button_escape then
                control.state.button_escape_pressed = false
            elseif button == control.bindings.button_store then
                control.state.button_store_pressed = false
            end
        end
    end
    return ctrl
end

return joystick_control