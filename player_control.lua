--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 21.02.17
-- Time: 17:21
-- To change this template use File | Settings | File Templates.
--

local functions = {}
local touch_control = require("touch_control_unit")
local joystick_control = require("joystick_control_unit")
local keyboard_control = require("keyboard_control_unit")
local gamepad_control = require("gamepad_control_unit")

-- contains "return function() return <false|true> end"
local is_touch = require("is_touch")()
local touch_accel_control

require("common")
-- actual nes mapping: local NES_CONTROL_MAPPING = {x_axis = 1, y_axis = 2, button_a = 1, button_b = 2, button_escape = 10, button_store = 9}
-- xbox mapping:
local NES_CONTROL_MAPPING = { x_axis = 1, y_axis = 2, button_a = 1, button_b = 2, button_escape = 3, button_store = 4 }
local TOUCH_CONTROL_MAPPING = { x_axis = 1, y_axis = 2, button_a = 2, button_b = 1, button_escape = 10, button_store = 9 }
local KEYBOARD_CONTROL_MAPPINGS = {
    { up = "w", down = "s", left = "a", right = "d", button_a = "q", button_b = "space", button_escape = "escape", button_store = "e" },
    { up = "8", down = "2", left = "4", right = "6", button_a = "0", button_b = "enter", button_escape = "escape", button_store = "-" }
}


--- return function that returns true if control type is "type"
local control_type_equals = function(type) return function(control) return control.type == type end end

local controls = {}

functions.touchreleased = function(id) table.each_if(controls, "touchreleased", control_type_equals("touch"), id) end
functions.touchmoved = function(id, x, y) table.each_if(controls, "touchmoved", control_type_equals("touch"), id, x, y) end
functions.touchpressed = function(id, x, y) table.each_if(controls, "touchpressed", control_type_equals("touch"), id, x, y) end
functions.joystickpressed = function(js, btn) table.each_if(controls, "joystickpressed", control_type_equals("joystick"), js, btn) end
functions.joystickreleased = function(js, btn) table.each_if(controls, "joystickreleased", control_type_equals("joystick"), js, btn) end
functions.gamepadpressed = function(js, btn) table.each_if(controls, "gamepadpressed", control_type_equals("gamepad"), js, btn) end
functions.gamepadreleased = function(js, btn) table.each_if(controls, "gamepadreleased", control_type_equals("gamepad"), js, btn) end


functions.update = function(dt)
    for _, ctrl_unit in ipairs(controls) do
        ctrl_unit:update(dt)
    end
end
functions.on_resume = function() functions.update(0.016) end

functions.draw = function()
    for _, ctrl_unit in ipairs(controls) do
        ctrl_unit:draw(functions.store_triggered)
    end
end

local function get_control_unit_for_joystick(joystick)
    if joystick:isGamepad() then
        log.debug("added gamepad")
        return gamepad_control.new(joystick)
    else
        log.debug("added joystick")
        return joystick_control.new(joystick, NES_CONTROL_MAPPING, "SELECT")
    end

end

functions.joystickadded = function(joystick)
    -- replace the first keyboard player with the new joystick
    for i = 1, #controls do
        if controls[i].type == "keyboard" then
            controls[i] = get_control_unit_for_joystick(joystick)
        end
    end
end

functions.joystickremoved = function(joystick)
    for i = #controls, 1, -1 do
        if (controls[i].type == "joystick" or controls[i].type == "gamepad") and controls[i].joystick == joystick then
            controls[i] = keyboard_control.new(KEYBOARD_CONTROL_MAPPINGS[i])
        end
    end
end

functions.load = function(player_count)
    player_count = player_count or 1

    -- find available joysticks
    local joystick_list = love.joystick.getJoysticks()

    if is_touch then
        if player_count > 1 then
            print("touch devices do not support >1 players")
            love.event.push('quit')
        end

        local enable_accelerometer_control = require("settings"):get_current_value("control") == "accelerometer"

        if enable_accelerometer_control then
            table.insert(controls, touch_control.new(false))
            table.insert(controls, joystick_control.new(joystick_list[1], TOUCH_CONTROL_MAPPING))
        else
            table.insert(controls, touch_control.new(true))
        end
    end

    for i = 1, player_count do
        if joystick_list[i] then
            controls[i] = get_control_unit_for_joystick(joystick_list[i])
        else
            table.insert(controls, keyboard_control.new(KEYBOARD_CONTROL_MAPPINGS[i]))
        end
    end

    functions.store_triggered = false
    functions.store_locked = false

    signal.register("store_trigger_area_reached", function() functions.store_triggered = true and not functions.store_locked end)
    signal.register("store_closed", function() functions.store_triggered = false; functions.store_locked = true end)
    signal.register("store_trigger_area_left", function() functions.store_triggered = false; functions.store_locked = false end)
end

functions.is_button_pressed = function(button, player)
    player = player or 1
    if button == "a_button" then
        return controls[player].state.button_a_pressed
    elseif button == "b_button" then
        return controls[player].state.button_b_pressed
    elseif button == "button_escape" then
        return controls[player].state.button_escape_pressed
    elseif button == "button_store" then
        return controls[player].state.button_store_pressed
    else
        print("bad button identifier: " .. button .. " in " .. function_location())
    end
end

functions.get_direction = function(player)
    player = player or 1
    return { x = controls[player].state.x, y = controls[player].state.y }
end

functions.get_movement_table = function(player)
    player = player or 1

    local movement = {}
    local threshold = .0001
    if controls[player].state.x > threshold then
        movement.right = true
    elseif controls[player].state.x < -threshold then
        movement.left = true
    else
        movement.right = false
        movement.left = false
    end

    if controls[player].state.y > threshold then
        movement.down = true
    elseif controls[player].state.y < -threshold then
        movement.up = true
    else
        movement.down = false
        movement.up = false
    end

    return movement
end

return functions
