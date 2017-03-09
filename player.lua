--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 19.02.17
-- Time: 13:04
-- To change this template use File | Settings | File Templates.
--

local functions = {}

local enemies = require("enemies")
local weaponry = require("weapons")
local control = require("player_control")
local player = {}

local a_button_lock = false
local b_button_lock = false

local function update_player()
    player.movement = control.get_movement_table()

    if control.is_button_pressed("a_button") and not a_button_lock then
        weaponry.shoot_missile(player.x + player.width / 2 - 30, player.y + 2)
        a_button_lock = true
    elseif not control.is_button_pressed("a_button") then
        a_button_lock = false
    end

    if control.is_button_pressed("b_button") and not b_button_lock then
        weaponry.shoot_laser(player.x + player.width, player.y + player.height / 2)
        b_button_lock = true
    elseif not control.is_button_pressed("b_button") then
        b_button_lock = false
    end

    local dir = control.get_direction()
    if player.x > 0 and dir.x < -.0001 then
        player.x = player.x + dir.x * speed
    elseif player.x + player.width < love.graphics.getWidth() and dir.x > .0001 then
        player.x = player.x + dir.x * speed
    end

    if player.y > 0 and dir.y < -.0001 then
        player.y = player.y + dir.y * speed
    elseif player.y + player.height < love.graphics.getHeight() and dir.y > .0001 then
        player.y = player.y + dir.y * speed
    end

    --- adjust thruster sound volume
    local thruster_count = 0
    for _, thruster_activated in pairs(player.movement) do
        if thruster_activated then
            thruster_count = thruster_count + 1
        end
    end

    player.thruster_sound:setVolume(.25 * thruster_count)

    if thruster_count > 0 then
        player.thruster_sound:play()
    else
        player.thruster_sound:pause()
    end
end
functions.update = update_player

functions.player_is_alive = function()
    return not enemies.has_enemy_collision(player)
end

local function draw_player()
    --- the propulsion images are larger than the main ship body, so the must be drawn slightly up left from it
    local x_prop_offset = (player.propulsion_texture.right:getWidth() - player.texture:getWidth()) / 1
    local y_prop_offset = (player.propulsion_texture.right:getHeight() - player.texture:getHeight()) / 2

    --- draw the available bodies
    for direction, direction_enabled in pairs(player.movement) do
        if direction_enabled then
            love.graphics.draw(player.propulsion_texture[direction], player.x - x_prop_offset, player.y - y_prop_offset, 0, 1, 1)
        end
    end

    love.graphics.draw(player.texture, player.x, player.y, 0, 1, 1)
end

functions.draw = draw_player

local function create_player()
    player.x = 50
    player.y = love.graphics.getHeight() / 2
    player.texture = love.graphics.newImage("img/ship_main.png")

    player.width = player.texture:getWidth()
    player.height = player.texture:getHeight()

    --- store all four propulsion textures
    player.propulsion_texture = {
        right = love.graphics.newImage("img/ship_flame_back.png"),
        left = love.graphics.newImage("img/ship_flame_front.png"),
        up = love.graphics.newImage("img/ship_flame_down.png"),
        down = love.graphics.newImage("img/ship_flame_up.png")
    }

    --- player audio
    player.thruster_sound = love.audio.newSource("sounds/thrusters2.ogg")
    player.thruster_sound:setLooping(true)
end

functions.load = create_player



return functions

