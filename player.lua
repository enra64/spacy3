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
local hc = require("hc")
local difficulty_handler = require("difficulty_handler")
require("asteroids")
require("drops")

local player = {}

local a_button_lock = false
local b_button_lock = false

local speed = difficulty.get("player_speed")

local function move_player(dx, dy) 
    player.x = player.x + dx
    player.y = player.y + dy
    player.shape:move(dx, dy)
end

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
        move_player(dir.x * speed, 0)
    elseif player.x + player.width < love.graphics.getWidth() and dir.x > .0001 then
        move_player(dir.x * speed, 0)
    end

    if player.y > 0 and dir.y < -.0001 then
        move_player(0, dir.y * speed)
    elseif player.y + player.height < love.graphics.getHeight() and dir.y > .0001 then
        move_player(0, dir.y * speed)
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
    
    if drops.remove_colliding_drops(player.shape) then
        score = score + 50
    end
end
functions.update = update_player

functions.player_is_alive = function()
    return not enemies.has_enemy_collision(player) and not asteroids.has_collision(player.shape)
end

local function draw_player()
    --- the propulsion images are larger than the main ship body, so the must be drawn slightly up left from it
    local x_prop_offset = player.propulsion_texture.right:getWidth() * player.scale - player.width
    local y_prop_offset = (player.propulsion_texture.right:getHeight() * player.scale - player.height) / 2

    --- draw the available bodies
    for direction, direction_enabled in pairs(player.movement) do
        if direction_enabled then
            love.graphics.draw(player.propulsion_texture[direction], player.x - x_prop_offset, player.y - y_prop_offset, NO_ROTATION, player.scale)
        end
    end

    love.graphics.draw(player.texture, player.x, player.y, NO_ROTATION, player.scale)
end

functions.draw = draw_player

local function create_player()
    player.x = 50
    player.y = love.graphics.getHeight() / 2
    player.texture = love.graphics.newImage("img/ship_main.png")

    player.scale = difficulty.get("ship_scale")

    player.width, player.height = player.texture:getDimensions()

    --- store all four propulsion textures
    player.propulsion_texture = {
        right = love.graphics.newImage("img/ship_flame_back.png"),
        left = love.graphics.newImage("img/ship_flame_front.png"),
        up = love.graphics.newImage("img/ship_flame_down.png"),
        down = love.graphics.newImage("img/ship_flame_up.png")
    }
    
    --- player collision shape
    player.shape = hc.polygon(41,87,41,75,9,74,9,59,1,59,2,27,8,26,10,15,39,15,41,1,77,1,79,15,99,15,111,19,123,18,147,39,155,41,165,42,166,51,147,54,144,58,139,59,127,70,111,70,101,75,78,75,79,87)
    
    --- move player collision shape so that it is above the ships initial coordinates
    player.shape:move(player.x, player.y)

    --- hc scales from the center, so we need to move the shape some more
    player.shape:scale(player.scale)
    player.shape:move(-(player.width - player.width * player.scale) / 2, -(player.height - player.height * player.scale) / 2)

    -- adjust stored player size for scaling
    player.width, player.height = player.width * player.scale, player.height * player.scale

    --- player audio
    player.thruster_sound = love.audio.newSource("sounds/thrusters2.ogg")
    player.thruster_sound:setLooping(true)
end

functions.load = create_player



return functions

