local keyboard_control = {}

keyboard_control.new = function(bindings)
    local ctrl = {}
    ctrl.bindings = bindings
    ctrl.state = {x = 0, y = 0, button_a_pressed = false, button_b_pressed = false, button_escape_pressed = false, button_store_pressed = false}

    ctrl.type = "keyboard"

    ctrl.store_button_help = {
        text = "press " .. bindings.button_store.." for store",
        y = love.graphics.getHeight() - love.graphics.getFont():getHeight()
    }

    ctrl.draw = function(control, store_triggered)
        if store_triggered then
            love.graphics.printf(control.store_button_help.text, 0, control.store_button_help.y, love.graphics.getWidth(), "center")
        end
    end
    ctrl.update = function(control, dt)
        --- reset direction vector
        control.state.x = 0
        control.state.y = 0

        --- check direction keys
        if love.keyboard.isDown(control.bindings.right) then control.state.x = dt end
        if love.keyboard.isDown(control.bindings.left) then control.state.x = -dt end
        if love.keyboard.isDown(control.bindings.up) then control.state.y = -dt end
        if love.keyboard.isDown(control.bindings.down) then control.state.y = dt end

        --- other buttons
        control.state.button_a_pressed = love.keyboard.isDown(control.bindings.button_a)
        control.state.button_b_pressed = love.keyboard.isDown(control.bindings.button_b)
        control.state.button_escape_pressed = love.keyboard.isDown(control.bindings.button_escape)
        control.state.button_store_pressed = love.keyboard.isDown(control.bindings.button_store)
        
        return control.state
    end
    return ctrl
end

return keyboard_control