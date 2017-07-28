require("common")
local timer = require("hump.timer")


local gamepad_control = {}

gamepad_control.new = function(joystick, store_button_name)
    local enable_rumble = require("settings"):get_current_value("rumble") == "on"
    local ctrl = {}
    ctrl.joystick = joystick
    ctrl.bindings = {
        x_axis = "leftx",
        y_axis = "lefty",
        button_b = "triggerright",
        button_a = "triggerleft",
        button_escape = "back",
        button_store = "start"
    }

    log.trace("new gamepad '"..joystick:getName().."' with GUID "..joystick:getGUID())

    -- "public" members
    ctrl.type = "gamepad"
    ctrl.state = {x = 0, y = 0, button_a_pressed = false, button_b_pressed = false, button_escape_pressed = false, button_store_pressed = false}
    ctrl.xoff = joystick:getGamepadAxis(ctrl.bindings.x_axis)
    ctrl.yoff = joystick:getGamepadAxis(ctrl.bindings.y_axis)


    -- subscribe to rumble events
    if enable_rumble and joystick:isVibrationSupported() then
        signal.register("explosion", function()
            if joystick:isVibrationSupported() then
                joystick:setVibration(0.5, 0.5)
                timer.after(0.2, function() joystick:setVibration(0, 0) end)
            end
        end)
    end

    if store_button_name then
        -- use uuid to find name

        ctrl.store_button_help = {
            text = store_button_name.." for store",
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
        control.state.x = (control.joystick:getGamepadAxis(control.bindings.x_axis) - control.xoff) * dt
        control.state.y = (control.joystick:getGamepadAxis(control.bindings.y_axis) - control.yoff) * dt

        control.state.button_a_pressed = control.joystick:getGamepadAxis(control.bindings.button_b)
        control.state.button_b_pressed = control.joystick:getGamepadAxis(control.bindings.button_a)

        return control.state
    end

    ctrl.gamepadpressed = function(control, joystick, button)
        local inputtype, inputindex, hatdirection = joystick:getGamepadMapping(button)
        inputtype = inputtype or "nil"
        inputindex = inputindex or "nil"
        hatdirection = hatdirection or "nil"

        log.trace("pressed "..button.." with type "..inputtype..", index "..inputindex..", hatdir "..hatdirection.." on gamepad "..joystick:getGUID())

        if joystick == control.joystick then
            if button == control.bindings.button_escape then
                control.state.button_escape_pressed = true
            elseif button == control.bindings.button_store then
                control.state.button_store_pressed = true
            end
        end
    end

    ctrl.gamepadreleased = function(control, joystick, button)
        log.trace("released "..button)
        if joystick == control.joystick then
            if button == control.bindings.button_escape then
                control.state.button_escape_pressed = false
            elseif button == control.bindings.button_store then
                control.state.button_store_pressed = false
            end
        end
    end
    return ctrl
end

return gamepad_control