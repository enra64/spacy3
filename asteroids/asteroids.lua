asteroids = {}

local asteroid_storage = {}

local hc = require("hc")
local explosions = require("explosions")
require("difficulty_handler")
require("drops")
require("flyapartomatic")
local enemies = require("enemies")

local FRAGMENT_SPEED = 2
local FRAGMENT_SCALE

local random_asteroid_start_function = require("asteroids.random_asteroids")
local asteroid_labyrinth_start_function = require("asteroids.asteroid_labyrinth")

asteroids.init = function()

end

local function get_index_of_asteroid_by_shape(shape)
    for i, ast in ipairs(asteroid_storage) do
        if ast.shape == shape then
            return i
        end
    end
end

local function handle_player_collision(player_hit_callback, asteroid, asteroid_storage_index)
    player_hit_callback(
        asteroid.x + asteroid.width / 2,
        asteroid.y + asteroid.height / 2
    )
    flyapartomatic.spawn(
        asteroid.fragments,
        asteroid.x,
        asteroid.y,
        FRAGMENT_SCALE,
        FRAGMENT_SPEED)
    table.remove(asteroid_storage, asteroid_storage_index)
    hc.remove(asteroid.shape)
end

asteroids.update = function(dt, player_hit_callback)
    for i, asteroid in ipairs(asteroid_storage) do
        asteroid:update(dt)

        -- determine whether an asteroid ever was within the viewport
        local asteroid_in_viewport = asteroid:is_in_viewport()
        if asteroid_in_viewport then
            asteroid.was_in_viewport = true
        end
        
        -- remove if asteroid went through viewport and is not within 
        if asteroid.was_in_viewport and not asteroid_in_viewport then
            table.remove(asteroid_storage, i)
            hc.remove(asteroid.shape)
        end
        
        --- remove asteroids that collided with an enemy or another asteroid
        
    end
end

asteroids.draw = function()
    for _, asteroid in ipairs(asteroid_storage) do
        love.graphics.drawObjectCentered(asteroid)
    end
end

asteroids.handle_projectile = function(projectile_shape, callback)
    -- removes all asteroids colliding with the projectile shape, and calls the callback for each of them
    local has_collision = false

    for i, asteroid in ipairs(asteroid_storage) do
        if asteroid.shape:collidesWith(projectile_shape) then
            -- call back
            callback(asteroid, asteroid.asteroid_type)
            -- breakup animation
            flyapartomatic.spawn(asteroid.fragments, asteroid.x, asteroid.y, FRAGMENT_SPEED, FRAGMENT_SCALE)
            -- clean asteroid table and collider
            table.remove(asteroid_storage, i)
            hc.remove(asteroid.shape)
            -- set collision flag
            has_collision = true
        end
    end
    
    return has_collision
end

asteroids.enter = function(asteroid_mode)
    asteroid_mode = asteroid_mode or "random"
    local asteroid_base_scale = scaling.get("asteroid_base_scale")
    FRAGMENT_SCALE = scaling.get("asteroid_fragment_scale")

    if asteroid_mode == "random" then
        random_asteroid_start_function(asteroid_storage, asteroid_base_scale)
    elseif asteroid_mode == "labyrinth" then
        asteroid_labyrinth_start_function(asteroid_storage, asteroid_base_scale)
    else
        print("UNKNOWN ASTEROID MODE")
    end
end

asteroids.resume = function() end

asteroids.leave = function()
    asteroid_storage = {}
end