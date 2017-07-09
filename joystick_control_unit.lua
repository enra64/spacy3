require("common")
local timer = require("hump.timer")

local joystick_control = {}

joystick_control.new = function(joystick, bindings, store_button_name)
    local ctrl = {}
    ctrl.joystick = joystick
    ctrl.bindings = bindings
    
    -- "public" members
    ctrl.type = "joystick"
    ctrl.state = {x = 0, y = 0, button_a_pressed = false, button_b_pressed = false, button_escape_pressed = false, button_store_pressed = false}
    ctrl.xoff = joystick:getAxis(bindings.x_axis)
    ctrl.yoff = joystick:getAxis(bindings.y_axis)


    -- subscribe to rumble events
    signal.register("explosion", function()
        if joystick:isVibrationSupported() then
            joystick:setVibration(0.3, 0.3)
            timer.after(0.2, function() joystick:setVibration(0, 0) end)
        end
    end)

    if store_button_name then
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
        --- reset direction vector
        control.state.x = (control.joystick:getAxis(control.bindings.x_axis) - control.xoff) * dt
        control.state.y = (control.joystick:getAxis(control.bindings.y_axis) - control.yoff) * dt

        --- other buttons
        control.state.button_a_pressed = control.joystick:isDown(control.bindings.button_a)
        control.state.button_b_pressed = control.joystick:isDown(control.bindings.button_b)
        control.state.button_escape_pressed = control.joystick:isDown(control.bindings.button_escape)
        control.state.button_store_pressed = control.joystick:isDown(control.bindings.button_store)
        
        return control.state
    end
    return ctrl
end

return joystick_control