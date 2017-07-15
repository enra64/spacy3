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
local mode

asteroids.init = function()
end

local function get_index_of_asteroid_by_shape(shape)
    for i, ast in ipairs(asteroid_storage) do
        if ast.shape == shape then
            return i
        end
    end
end

local function handle_player_collision(player_hit_callback, asteroid)
    player_hit_callback(asteroid.x + asteroid.width / 2,
        asteroid.y + asteroid.height / 2)
    flyapartomatic.spawn(asteroid.fragments,
        asteroid.x,
        asteroid.y,
        FRAGMENT_SCALE,
        FRAGMENT_SPEED)
    asteroid:on_destroyed()
end

local function check_collisions_for_asteroid(i, asteroid)
    --- remove asteroids that collided with an enemy or another asteroid
    for other, _ in pairs(hc.collisions(asteroid.shape)) do
        if (other.object_type == "enemy" or other.object_type == "asteroid") then
            local ast_bbox = {}
            local oth_bbox = {}
            ast_bbox.x1, ast_bbox.y1, ast_bbox.x2, ast_bbox.y2 = asteroid.shape:bbox()
            oth_bbox.x1, oth_bbox.y1, oth_bbox.x2, oth_bbox.y2 = other:bbox()

            local center_x, center_y
            if oth_bbox.x1 < ast_bbox.x2 then
                center_x = oth_bbox.x1 + (ast_bbox.x2 - oth_bbox.x1) / 2
            else
                center_x = ast_bbox.x1 + (oth_bbox.x2 - ast_bbox.x1) / 2
            end
            if oth_bbox.y1 < ast_bbox.y2 then
                center_y = oth_bbox.y1 + (ast_bbox.y2 - oth_bbox.y1) / 2
            else
                center_y = ast_bbox.y1 + (oth_bbox.y2 - ast_bbox.y1) / 2
            end

            asteroid:on_destroyed()

            if other.object_type == "enemy" then
                enemies.remove_colliding_enemies(asteroid.shape, function() end)
                explosions.create_explosion(center_x, center_y)
            elseif other.object_type == "asteroid" then
                local other_asteroid = other.asteroid_reference
                if other_asteroid then
                    flyapartomatic.spawn(other_asteroid.fragments, other_asteroid.x, other_asteroid.y, FRAGMENT_SCALE, FRAGMENT_SPEED)
                end
                other:on_destroyed()
            end

            flyapartomatic.spawn(asteroid.fragments, asteroid.x, asteroid.y, FRAGMENT_SCALE, FRAGMENT_SPEED)
        end
    end
end

local function check_player_collisions(player_shape, player_hit_callback)
    for other, _ in pairs(hc.collisions(player_shape)) do
        if other.object_type == "asteroid" then
            local asteroid = other.asteroid_reference
            handle_player_collision(player_hit_callback, asteroid, i)
        end
    end
end

asteroids.update = function(dt, player_shape, player_hit_callback)
    for i, asteroid in ipairs(asteroid_storage) do
        asteroid:update(dt)

        -- determine whether an asteroid ever was within the viewport
        local asteroid_in_viewport = asteroid:is_in_viewport()
        if asteroid_in_viewport then
            asteroid.was_in_viewport = true
        end

        -- remove if asteroid went through viewport and is not within 
        if asteroid.was_in_viewport and not asteroid_in_viewport then
            asteroid:on_destroyed()
        end



        local check_for_asteroid_collisions = mode ~= "labyrinth"
        if check_for_asteroid_collisions then
            check_collisions_for_asteroid(i, asteroid)
        end
    end

    check_player_collisions(player_shape, player_hit_callback)
end

local function draw_asteroid_centers(asteroid)
    local x1, y1, x2, y2 = asteroid.shape:bbox()
    print("shape size "..(x2-x1).."x"..(y2-y1).." and ast size"..asteroid.width.."x"..asteroid.height)
    local cx, cy = asteroid.shape:center()

    love.graphics.rectangle("fill", asteroid.x, asteroid.y, 10, 10)
    love.graphics.setColor(255, 0, 0)
    love.graphics.rectangle("fill", cx, cy, 10, 10)

    love.graphics.setColor(255, 255, 255)
end

asteroids.draw = function()
    for _, asteroid in ipairs(asteroid_storage) do
        love.graphics.drawObjectCentered(asteroid)
        asteroid.shape:draw()
    end
end

asteroids.handle_projectile = function(projectile_shape, callback)
    -- removes all asteroids colliding with the projectile shape, and calls the callback for each of them
    local has_collision = false

    for other_shape, _ in ipairs(hc:collisions(projectile_shape)) do
        if other_shape.shape.object_type == "asteroid" then
            local asteroid = other_shape.asteroid_reference

            -- call back
            callback(asteroid, asteroid.asteroid_type)
            -- breakup animation
            flyapartomatic.spawn(asteroid.fragments, asteroid.x, asteroid.y, FRAGMENT_SPEED, FRAGMENT_SCALE)
            -- clean up asteroid
            asteroid:on_destroyed()
            -- set collision flag
            has_collision = true
        end
    end

    return has_collision
end

asteroids.enter = function(asteroid_mode)
    asteroid_mode = asteroid_mode or "random"
    mode = asteroid_mode
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
    lume.each(asteroid_storage, function (ast)
        ast:on_destroyed()
    end)

    asteroid_storage = {}
end