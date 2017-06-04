--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 21.02.17
-- Time: 17:21
-- To change this template use File | Settings | File Templates.
--

local functions = {}


-- contains "return function() return <false|true> end"
local is_touch = require("is_touch")()
require("common")

--- touch only stuff
local touch_collider
local touch_controls = {}
local dpad_background = {}
local store_button = {}

-- non-touch only
local store_button_help = {}

--- the current control state
local control_state = {}

local joystick_list = {}

local function set_dpad_position(x, y)
    --- set control knob position
    touch_controls.dpad.x = dpad_background.x + x - touch_controls.dpad.width / 2 + dpad_background.width / 2
    touch_controls.dpad.y = dpad_background.y + y - touch_controls.dpad.height / 2 + dpad_background.height / 2

    --- limit max movement
    if touch_controls.dpad.y < dpad_background.y then
        touch_controls.dpad.y = dpad_background.y
    end
    if touch_controls.dpad.y > dpad_background.bottom_border then
        touch_controls.dpad.y = dpad_background.bottom_border - touch_controls.dpad.height
    end
    if touch_controls.dpad.x < 0 then
        touch_controls.dpad.x = 0
    end
    if touch_controls.dpad.x + touch_controls.dpad.width > dpad_background.right_border then
        touch_controls.dpad.x = dpad_background.right_border - touch_controls.dpad.width
    end
end

local function handle_dpad_touch(x, y)
    --- position of touch relative to dpad background, negative if the touch is left of/above center
    x = x - dpad_background.x - dpad_background.width / 2
    y = y - dpad_background.y - dpad_background.height / 2

    --- scale to dt, update control state
    control_state.x = math.min((x / dpad_background.width) * 0.04, .05)
    control_state.y = math.min((y / dpad_background.height) * 0.04, .05)

    --- set control knob position
    set_dpad_position(x, y)
end

functions.touchreleased = function(id)
    --- handle releases
    if id == touch_controls.button_a.touch_id then
        control_state.button_a_pressed = false
        touch_controls.button_a.touch_id = nil
    elseif id == touch_controls.button_b.touch_id then
        control_state.button_b_pressed = false
        touch_controls.button_b.touch_id = nil
    elseif id == touch_controls.button_escape.touch_id then
        control_state.button_escape_pressed = false
        touch_controls.button_escape.touch_id = nil
    elseif id == touch_controls.button_store.touch_id then
        control_state.button_store_pressed = false
        store_button.touch_id = nil
    elseif id == touch_controls.dpad.touch_id then
        control_state.x = 0
        control_state.y = 0
        set_dpad_position(0, 0)
        touch_controls.dpad.touch_id = nil
    end
end

functions.touchmoved = function(id, x, y)
    if id == touch_controls.dpad.touch_id then
        handle_dpad_touch(x, y)
    end
end

functions.touchpressed = function(id, x, y)
    local touch_point = touch_collider:point(x, y)
    
    --- handle button clicks
    for shape, _ in pairs(touch_collider:collisions(touch_point)) do
        --- retrieve the control type stored in the collision shape
        local ctrl_type = shape.control_type
        
        --- update stored touch id
        touch_controls[ctrl_type].touch_id = id

        --- update control state
        if ctrl_type == "button_a" then
            control_state.button_a_pressed = true
        elseif ctrl_type == "button_b" then
            control_state.button_b_pressed = true
        elseif ctrl_type == "button_escape" then
            control_state.button_escape_pressed = true
        elseif ctrl_type == "button_store" then
            control_state.button_store_pressed = true
        end
    end
end

functions.update_keyboard = function(dt)
    --- reset direction vector
    control_state.x = 0
    control_state.y = 0

    --- check direction keys
    if love.keyboard.isDown("d") then
        control_state.x = dt
    end
    if love.keyboard.isDown("a") then
        control_state.x = -dt
    end
    if love.keyboard.isDown("w") then
        control_state.y = -dt
    end
    if love.keyboard.isDown("s") then
        control_state.y = dt
    end

    --- shooting
    control_state.button_a_pressed = love.keyboard.isDown("q")
    control_state.button_b_pressed = love.keyboard.isDown("space")
    control_state.button_escape_pressed = love.keyboard.isDown("escape")
    control_state.button_store_pressed = love.keyboard.isDown("e")
end

functions.update = function(dt)
    for _, joystick in ipairs(joystick_list) do
        local axis_x, axis_y = joystick:getAxes()
        control_state.x = axis_x * dt
        control_state.y = axis_y * dt
    end
end

functions.joystickadded = function(joystick)
    print("added joystick "..joystick:getGUID())
    table.insert(joystick_list, joystick)
end

functions.joystickremoved = function(joystick)    
    for i, it_joystick in ipairs(joystick_list) do
        if it_joystick == joystick then
            table.remove(joystick_list, i)
        end
    end
end

functions.joystickpressed = function(joystick, button)
    if button == 2 then
        control_state.button_a_pressed = true
    elseif button == 1 then
        control_state.button_b_pressed = true
    elseif button == 9 then
        control_state.button_store_pressed = true
    elseif button == 10 then
        control_state.button_escape_pressed = true
    end
end

functions.joystickreleased = function(joystick, button)
    if button == 2 then
        control_state.button_a_pressed = false
    elseif button == 1 then
        control_state.button_b_pressed = false
    elseif button == 9 then
        control_state.button_store_pressed = false
    elseif button == 10 then
        control_state.button_escape_pressed = false
    end
end

functions.draw = function()
    if is_touch then
        love.graphics.setColor(255, 255, 255, dpad_background.opacity)
        love.graphics.draw(dpad_background.texture, dpad_background.x, dpad_background.y)

        for control_type, control in pairs(touch_controls) do
            local opacity_touch = control.opacity
            if not control.touch_id == nil then
                opacity_touch = 230
            end
            
            -- if the store button is not triggered, do not show it by setting opacity to zero
            if control_type == "button_store" and not functions.store_triggered then
                opacity_touch = 0
            end
            
            love.graphics.setColor(255, 255, 255, opacity_touch)
            love.graphics.draw(control.texture, control.x, control.y)
        end
        love.graphics.setColor(255, 255, 255, 255)
    elseif functions.store_triggered then
        love.graphics.printf(store_button_help.text, 0, store_button_help.y, love.graphics.getWidth(), "center")
    end
end

local function reset_control_state()
    control_state.button_a_pressed = false
    control_state.button_b_pressed = false
    control_state.button_escape_pressed = false
    control_state.button_store_pressed = false
    control_state.x = 0
    control_state.y = 0
end

functions.load = function()
    -- load already connected joysticks
    joystick_list = love.joystick.getJoysticks()
    
    -- initialise control state
    reset_control_state()

    functions.store_triggered = false
    functions.store_locked = false

    signal.register("store_trigger_area_reached", function() functions.store_triggered = true and not functions.store_locked end)
    signal.register("store_closed", function() functions.store_triggered = false; functions.store_locked = true end)
    signal.register("store_trigger_area_left", function() functions.store_triggered = false; functions.store_locked = false end)

    if is_touch then
        touch_collider = require("hc").new()
        
        dpad_background.texture = love.graphics.newImage("img/touch_controls/dpad_background.png")
        dpad_background.x = 50
        dpad_background.y = love.graphics.getHeight() - dpad_background.texture:getHeight() - 50
        dpad_background.width = dpad_background.texture:getWidth()
        dpad_background.height = dpad_background.texture:getHeight()
        dpad_background.opacity = 100
        dpad_background.right_border = dpad_background.width + dpad_background.x
        dpad_background.bottom_border = dpad_background.height + dpad_background.y
        dpad_background.shape = touch_collider:rectangle(dpad_background.x, dpad_background.y, dpad_background.width, dpad_background.height)
        dpad_background.shape.control_type = "dpad"

        local control_textures = {
            dpad = love.graphics.newImage("img/touch_controls/dpad_knob.png"),
            button_a = love.graphics.newImage("img/touch_controls/button_a.png"),
            button_b = love.graphics.newImage("img/touch_controls/button_b.png"),
            button_escape = love.graphics.newImage("img/touch_controls/button_escape.png"),
            button_store = love.graphics.newImage("img/touch_controls/button_store.png")
        }

        for control_type, texture in pairs(control_textures) do
            local new_control = {}
            new_control.touch_id = nil
            new_control.texture = texture
            new_control.width = new_control.texture:getWidth()
            new_control.height = new_control.texture:getHeight()
            new_control.opacity = 150

            touch_controls[control_type] = new_control

            if control_type == "dpad" then
                set_dpad_position(0, 0)
            elseif control_type == "button_a" then
                new_control.x = love.graphics.getWidth() - 2 * new_control.width
                new_control.y = love.graphics.getHeight() - new_control.height
            elseif control_type == "button_b" then
                new_control.x = love.graphics.getWidth() - new_control.width
                new_control.y = love.graphics.getHeight() - 2 * new_control.height
            elseif control_type == "button_escape" then
                new_control.x = love.graphics.getWidth() - new_control.width
                new_control.y = 0
            elseif control_type == "button_store" then
                -- note: this is, sadly, highly dependent on not changing the above formulas because pairs is not guaranteed to iterate in input order
                new_control.x = love.graphics.getWidth() - 2 * control_textures["button_a"]:getHeight()
                new_control.y = love.graphics.getHeight() - 2 * control_textures["button_b"]:getHeight()
            else
                print("unknown control type")
            end
            
            new_control.shape = touch_collider:rectangle(new_control.x, new_control.y, new_control.width, new_control.height)
            new_control.shape.control_type = control_type
        end
    else
        store_button_help.text = "e for store"
        store_button_help.y = love.graphics.getHeight() - love.graphics.getFont():getHeight()
    end
end

local function is_button_pressed(button)
    if button == "a_button" then
        return control_state.button_a_pressed
    elseif button == "b_button" then
        return control_state.button_b_pressed
    elseif button == "button_escape" then
        return control_state.button_escape_pressed
    elseif button == "button_store" then
        return control_state.button_store_pressed
    else
        print("bad button identifier: " .. button .. " in " .. function_location())
    end
end
functions.is_button_pressed = is_button_pressed

local function get_direction()
    return { x = control_state.x, y = control_state.y }
end
functions.get_direction = get_direction

local function get_movement_table()
    local movement = {}
    local threshold = .0001
    if control_state.x > threshold then
        movement.right = true
    elseif control_state.x < -threshold then
        movement.left = true
    else
        movement.right = false
        movement.left = false
    end

    if control_state.y > threshold then
        movement.down = true
    elseif control_state.y < -threshold then
        movement.up = true
    else
        movement.down = false
        movement.up = false
    end

    return movement
end
functions.get_movement_table = get_movement_table

functions.on_resume = reset_control_state

return functions