--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 21.02.17
-- Time: 17:21
-- To change this template use File | Settings | File Templates.
--

local functions = {}

local collision = require("collisions")

-- contains "return function() return <false|true> end"
local is_touch = require("is_touch")

--- touch only stuff
local opacity = 150
local touch_controls = {}
local dpad_background = {}

--- the current control state
local control_state = {}

local function handle_dpad_touch(x, y)
    --- position of touch relative to dpad background, negative if the touch is left of/above center
    x = x - dpad_background.x - dpad_background.width / 2
    y = y - dpad_background.y - dpad_background.height / 2

    --- scale to dt, update control state
    control_state.x = (x / dpad_background.width) * 0.06
    control_state.y = (y / dpad_background.height) * 0.06

    print(x..","..y)

    --- set control knob position
    touch_controls.dpad.x = dpad_background.x + x + 2 * touch_controls.dpad.width / 2
    touch_controls.dpad.y = dpad_background.y + y + 2 * touch_controls.dpad.height / 2
end

local function update_touch()
    local touches = love.touch.getTouches()
    local dpad_touched = false
    control_state.button_a_pressed = false
    control_state.button_b_pressed = false
    control_state.x = 0
    control_state.y = 0

    for _, touch_id in ipairs(touches) do
        local x, y = love.touch.getPosition(touch_id)

        --- handle button clicks
        for type, touch_control in pairs(touch_controls) do
            if collision.has_collision_point_rectangle(x, y, touch_control) then
                if type == "button_a" then
                    control_state.button_a_pressed = true
                elseif type == "button_b" then
                    control_state.button_b_pressed = true
                end
            end
        end

        --- handle dpad separately, because we want to check for touches in the background texture
        if collision.has_collision_point_rectangle(x, y, dpad_background) then
            handle_dpad_touch(x, y)
            dpad_touched = true
        end
    end

    if not dpad_touched then
        touch_controls.dpad.x = dpad_background.x + dpad_background.width / 2 - touch_controls.dpad.width / 2
        touch_controls.dpad.y = dpad_background.y + dpad_background.height / 2 - touch_controls.dpad.height / 2
    end
end

local function update_keyboard(dt)
    --- reset direction vector
    control_state.x = 0
    control_state.y = 0

    --- check direction keys
    if love.keyboard.isDown("d") and player.x + player.width < love.graphics.getWidth() then
        control_state.x = dt
    end
    if love.keyboard.isDown("a") and player.x > 0 then
        control_state.x = -dt
    end
    if love.keyboard.isDown("w") and player.y > 0 then
        control_state.y = -dt
    end
    if love.keyboard.isDown("s") and player.y + player.height < love.graphics.getHeight() then
        control_state.y = dt
    end

    --- shooting
    control_state.button_a_pressed = love.keyboard.isDown("q")
    control_state.button_b_pressed = love.keyboard.isDown("space")
end

local function update(dt)
    if is_touch() then
        update_touch(dt)
    else
        update_keyboard(dt)
    end
end
functions.update = update

local function draw()
    if is_touch() then
        love.graphics.setColor(255, 255, 255, opacity)
        love.graphics.draw(dpad_background.texture, dpad_background.x, dpad_background.y)
        for _, control in pairs(touch_controls) do
            love.graphics.draw(control.texture, control.x, control.y)
        end
        love.graphics.setColor(255, 255, 255, 255)
    end
end
functions.draw = draw

function load()
    control_state.button_a_pressed = false
    control_state.button_b_pressed = false
    control_state.x = 0
    control_state.y = 0


    if is_touch() then
        dpad_background.texture = love.graphics.newImage("img/touch_controls/dpad_background.png")
        dpad_background.x = 0
        dpad_background.y = love.graphics.getHeight() - dpad_background.texture:getHeight()
        dpad_background.width = dpad_background.texture:getWidth()
        dpad_background.height = dpad_background.texture:getHeight()
        dpad_background.opacity = 50

        local control_textures = {
            dpad = "img/touch_controls/dpad_knob.png",
            button_a = "img/touch_controls/button_a.png",
            button_b = "img/touch_controls/button_b.png"
        }

        for control_type, texture_location in pairs(control_textures) do
            local new_control = {}
            new_control.texture = love.graphics.newImage(texture_location)
            new_control.width = new_control.texture:getWidth()
            new_control.height = new_control.texture:getHeight()

            if control_type == "dpad" then
                new_control.default_x = (dpad_background.width - new_control.width) / 2
                new_control.default_y = (dpad_background.height - new_control.height) / 2
                new_control.x = new_control.default_x
                new_control.y = new_control.default_y
            elseif control_type == "button_a" then
                new_control.x = love.graphics.getWidth() - 2 * new_control.width
                new_control.y = love.graphics.getHeight() - new_control.height
            elseif control_type == "button_b" then
                new_control.x = love.graphics.getWidth() - new_control.width
                new_control.y = love.graphics.getHeight() - 2 * new_control.height
            else
                print("unknown control type")
            end

            touch_controls[control_type] = new_control
        end
    end
end
functions.load = load

local function is_button_pressed(button)
    if button == "a_button" then
        return control_state.button_a_pressed
    elseif button == "b_button" then
        return control_state.button_b_pressed
    else
        print("bad button identifier")
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

return functions