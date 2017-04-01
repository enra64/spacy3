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
local store_trigger_shape = nil

local function move_player(dx, dy) 
    player.x = player.x + dx
    player.y = player.y + dy
    player.shape:move(dx, dy)
end

local function update_player()
    player.movement = control.get_movement_table()

    -- fire weapons
    if control.is_button_pressed("a_button") and not a_button_lock then
        weaponry.shoot_missile(
            player.x + player.missile_spawn_point.x, 
            player.y + player.missile_spawn_point.y)
        a_button_lock = true
    elseif not control.is_button_pressed("a_button") then
        a_button_lock = false
    end

    if control.is_button_pressed("b_button") and not b_button_lock then
        weaponry.shoot_laser(
            player.x + player.laser_spawn_point.x, 
            player.y + player.laser_spawn_point.y)
        b_button_lock = true
    elseif not control.is_button_pressed("b_button") then
        b_button_lock = false
    end

    -- move player horizontally
    local dir = control.get_direction()
    if player.x > 0 and dir.x < -.0001 then
        move_player(dir.x * speed, 0)
    elseif player.x + player.width / 2< love.graphics.getWidth() and dir.x > .0001 then
        move_player(dir.x * speed, 0)
    end
    
    -- move player vertically
    if player.y > 0 and dir.y < -.0001 then
        move_player(0, dir.y * speed)
    elseif player.y + player.height / 2 < love.graphics.getHeight() and dir.y > .0001 then
        move_player(0, dir.y * speed)
    end

    --- adjust thruster sound volume
    local thruster_count = 0
    for _, thruster_activated in pairs(player.movement) do
        if thruster_activated then
            thruster_count = thruster_count + 1
        end
    end

    -- play thruster sound
    player.thruster_sound:setVolume(.25 * thruster_count)
    if thruster_count > 0 then
        player.thruster_sound:play()
    else
        player.thruster_sound:pause()
    end
    
    -- check for drop collisions
    if drops.remove_colliding_drops(player.shape) then
        score = score + 50
    end
    
    -- check store trigger
    if player.shape:collidesWith(store_trigger_shape) then
        if not player.store_lock then
            gamestate.push(dofile("store.lua"))
            player.store_lock = true
        end
    else
        player.store_lock = false
    end
end
functions.update = update_player

functions.player_is_alive = function()
    return not enemies.has_enemy_collision(player) and not asteroids.has_collision(player.shape)
end

functions.draw = function()
    --- draw the available bodies
    for direction, direction_enabled in pairs(player.movement) do
        if direction_enabled then
            love.graphics.draw(
                player.propulsion_texture[direction], 
                player.x, 
                player.y, 
                NO_ROTATION, 
                player.scale, 
                player.scale, 
                player.propulsion_texture[direction]:getWidth() / 2,
                player.propulsion_texture[direction]:getHeight() / 2)
        end
    end

    love.graphics.draw(
        player.texture, 
        player.x, 
        player.y, 
        NO_ROTATION, 
        player.scale,
        player.scale,
        player.texture:getWidth() / 2,
        player.texture:getHeight() / 2)
end

functions.load = function()
    player.x = 50
    player.y = love.graphics.getHeight() / 2
    player.texture = love.graphics.newImage("img/player_ships/upgrade_0/main.png")

    player.scale = difficulty.get("ship_scale")

    --- store all four propulsion textures
    player.propulsion_texture = {
        right = love.graphics.newImage("img/player_ships/upgrade_0/right_flame.png"),
        left = love.graphics.newImage("img/player_ships/upgrade_0/left_flame.png"),
        up = love.graphics.newImage("img/player_ships/upgrade_0/top_flame.png"),
        down = love.graphics.newImage("img/player_ships/upgrade_0/bottom_flame.png")
    }
    
    --- player collision shape
    player.shape = hc.polygon(173,124,291,124,296,71,445,71,447,122,525,124,578,142,627,139,696,202,723,219,723,230,756,229,759,238,782,242,784,235,797,236,798,269,787,270,785,261,761,261,761,275,723,278,719,296,693,300,637,345,585,345,535,366,445,365,447,416,296,414,294,367,170,364,171,304,141,304,145,176,170,173,170,174)
    
    --- move player collision shape so that it is above the ships initial coordinates
    player.shape:moveTo(player.x, player.y)

    --- scale shape to player size
    player.shape:scale(player.scale)

    -- adjust stored player size for scaling
    player.width, player.height = player.texture:getDimensions()
    player.width, player.height = player.width * player.scale, player.height * player.scale

    player.missile_spawn_point = {
        x = 450 * player.scale - player.width / 2, 
        y = 100 * player.scale - player.height / 2}
    player.laser_spawn_point = {
        x = 800 * player.scale - player.width / 2, 
        y = 250 * player.scale - player.height / 2}

    --- player audio file
    player.thruster_sound = love.audio.newSource("sounds/thrusters2.ogg")
    player.thruster_sound:setLooping(true)
    
    -- define area where store is triggered
    store_trigger_shape = hc.rectangle(500, 200, 50, 50)
    store_trigger_shape.object_type = "store_trigger"
    player.store_lock = false
end

return functions

