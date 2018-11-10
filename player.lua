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
local timer = require("hump.timer")
require("difficulty_handler")
require("asteroids.asteroids")
require("drops")
require("scaling")

local player = {}

local a_button_lock = false
local b_button_lock = false
local store_button_lock = false

local THRUSTER_MAX_VOLUME = 0.7
local last_ship_hull_state = 1
local ship_life

local drop_collect_sound = love.audio.newSource("sounds/drop_collect.ogg", "static")
drop_collect_sound:setVolume(2)

local function move_player(dx, dy)
    player.x = player.x + dx
    player.y = player.y + dy
    player.shape:move(dx, dy)
end

functions.update = function(dt, station)
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
    
    if control.is_button_pressed("button_store") and not store_button_lock then
        station.store_button_pressed = true
        store_button_lock = true
    elseif not control.is_button_pressed("button_store") then
        station.store_button_pressed = false
        store_button_lock = false
    end

    -- move player horizontally
    local dir = control.get_direction()
    local EPSILON = 0.0001
    if player.x > player.width / 2 and dir.x < -EPSILON then
        move_player(dir.x * player.speed, 0)
    elseif player.x + player.width / 2< love.graphics.getWidth() and dir.x > EPSILON then
        move_player(dir.x * player.speed, 0)
    end
    
    -- move player vertically
    if player.y > player.height / 2 and dir.y < -EPSILON then
        move_player(0, dir.y * player.speed)
    elseif player.y + player.height / 2 < love.graphics.getHeight() and dir.y > EPSILON then
        move_player(0, dir.y * player.speed)
    end
    
    local SWITCH_ON_DURATION = 0.08
    local SWITCH_OFF_DURATION = 0.3
    local is_moving = dir.y < -EPSILON or dir.y > EPSILON or dir.x < -EPSILON or dir.x > EPSILON
    -- turn on engine
    if is_moving and not player.previous_moving then
        if player.engine_switch_tweener then timer.cancel(player.engine_switch_tweener) end
        player.engine_switch_tweener = timer.tween(
            SWITCH_ON_DURATION, 
            player, 
            {engine_opacity = 100}, 
            'in-linear',
            function() player.engine_switch_tweener = nil end
        )
    -- turn off engine
    elseif not is_moving and player.previous_moving then
        if player.engine_switch_tweener then timer.cancel(player.engine_switch_tweener) end
        player.engine_switch_tweener = timer.tween(
            SWITCH_OFF_DURATION, 
            player, 
            {engine_opacity = 0}, 
            'in-linear',
            function() player.engine_switch_tweener = nil end
        )
    end
    player.previous_moving = is_moving

    --- adjust thruster sound volume
    local thruster_count = 0
    for _, thruster_activated in pairs(player.movement) do
        if thruster_activated then
            thruster_count = thruster_count + 1
        end
    end

    -- play thruster sound
    local thruster_scale = math.normalize(math.abs(dir.x) + math.abs(dir.y), 0, 2 * dt)
    player.thruster_sound:setVolume(THRUSTER_MAX_VOLUME * thruster_scale)
    if thruster_count > 0 then
        player.thruster_sound:play()
    else
        player.thruster_sound:pause()
    end
    
    -- check for drop collisions
    if drops.remove_colliding_drops(player.shape) then
        player_ship_upgrade_state.increase_credits(difficulty.get("asteroid_drop_credits"))
        drop_collect_sound:play()
    end
    
    -- check for enemy collisions
    enemies.remove_colliding_enemies(player.shape, functions.enemy_hit)
end

functions.player_is_alive = function()
    return false or ship_life > 0
end

functions.draw = function()
    -- draw ship
    love.graphics.draw(
        player.texture, 
        player.x, 
        player.y, 
        NO_ROTATION, 
        player.scale,
        player.scale,
        player.texture:getWidth() / 2,
        player.texture:getHeight() / 2)
    
    --- draw the activated propulsion textures
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
    
    -- draw engine
    love.graphics.setColor(255, 255, 255, player.engine_opacity)
    love.graphics.draw(
        player.engine_activated_texture, 
        player.x, 
        player.y, 
        NO_ROTATION, 
        player.scale,
        player.scale,
        player.texture:getWidth() / 2,
        player.texture:getHeight() / 2)
    love.graphics.setColor(255, 255, 255, 255)
    
    -- draw player shape for testing
    --player.shape:draw()
end




functions.asteroid_hit = function(x, y)
    ship_life = ship_life - 1
end

functions.enemy_hit = function()
    ship_life = ship_life - 1
end

local function create_ship_hull()
    local state = player_ship_upgrade_state.get_state("ship_hull")
    local path = "img/player_ships/upgrade_"..(state - 1).."/"
    
    -- for turning the engine on/off
    player.previous_moving = false
    
    --- load all textures
    player.texture = love.graphics.newImage(path.."main.png")
    player.engine_activated_texture = love.graphics.newImage(path.."engine_activated.png")
    player.propulsion_texture = {
        right = love.graphics.newImage(path.."left_flame.png"),
        left = love.graphics.newImage(path.."right_flame.png"),
        up = love.graphics.newImage(path.."bottom_flame.png"),
        down = love.graphics.newImage(path.."top_flame.png")
    }
    
    --- remove old collision shape
    if player.shape then
        hc.remove(player.shape)
    end
    
    --- load speed according to ship lvl
    player.speed = scaling.get("speed_player_ship_upgrade_"..(state-1))
    
    -- load collision polygon
    local polygon_table = read_csv(path.."collision_polygon.csv")
    player.shape = hc.polygon(unpack(polygon_table))
    player.shape.object_type = "player"
    
    --- move player collision shape so that it is above the ships coordinates
    player.shape:moveTo(player.x, player.y)

    --- scale shape to player size
    player.shape:scale(player.scale * 0.95)

    -- adjust stored player size for scaling
    player.width, player.height = player.texture:getDimensions()
    player.width, player.height = player.width * player.scale, player.height * player.scale
    
    -- load weapon spawn points
    local msp = read_csv(path.."missile_spawn_point.csv")
    player.missile_spawn_point = {
        x = msp[1] * player.scale - player.width / 2, 
        y = msp[2] * player.scale - player.height / 2
    }
    local lsp = read_csv(path.."laser_spawn_point.csv")
    player.laser_spawn_point = {
        x = lsp[1] * player.scale - player.width / 2, 
        y = lsp[2] * player.scale - player.height / 2
    }
end

functions.resume = function()
    local new_state = player_ship_upgrade_state.get_state("ship_hull")
    if last_ship_hull_state ~= new_state then
        ship_life = difficulty.get("health_player_ship_upgrade_"..(new_state-1))
    end
    create_ship_hull()
end

functions.load = function()
    --print("init player")
    player.x = 100
    player.y = love.graphics.getHeight() / 2
    
    player.scale = scaling.get("ship_scale")
    
    player.engine_opacity = 0
    player.engine_switch_tweener = nil
    
    ship_life = difficulty.get("health_player_ship_upgrade_0")
    create_ship_hull()

    --- player audio file
    player.thruster_sound = love.audio.newSource("sounds/thrusters2.ogg", "static")
    player.thruster_sound:setLooping(true)
    
    -- handle being backgrounded
    signal.register("backgrounded", 
        function() 
            -- save current ship hull
            last_ship_hull_state = player_ship_upgrade_state.get_state("ship_hull")
            
            -- avoid thruster sound in store
            love.audio.stop(player.thruster_sound)
        end)
end

functions.get_player_shape = function()
    return player.shape
end

return functions

