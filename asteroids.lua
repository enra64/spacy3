asteroids = {}

local asteroid_storage = {}

local hc = require("hc")
local explosions = require("explosions")
local timer = require("hump.timer")
require("difficulty_handler")
local enemies = require("enemies")

local function load_random_asteroid()
    local textures = {"img/asteroid_brown.png", "img/asteroid_grey.png"}
    local polygons = {
        {59,163,29,143,29,137,3,105,1,83,6,36,17,22,36,9,56,1,86,5,93,10,108,9,119,16,
        134,25,144,34,148,51,162,68,163,90,166,113,161,127,152,129,151,134,142,135,134,152,96,168,67,165}, 
        {31,149,31,142,18,123,7,114,7,107,4,96,5,83,2,74,20,45,21,36,29,25,43,20,47,15,61,5,81,2,88,5,107,2,114,4,115,
        12,145,21,143,27,170,41,162,59,171,79,175,102,172,122,165,143,141,158,118,169,92,172,66,171,52,168,31,150,31,149}
    }

    assert(#textures == #polygons, "bad texture/shape mapping count")

    local choice = math.random(#textures)

    -- return the texture, the polygon, and the choice
    return love.graphics.newImage(textures[choice]), polygons[choice], string.sub(textures[choice], 5, -5)
end

local function add_asteroid()
    local new = {}
    
    --- load some asteroid
    new.texture, asteroid_collision_coordinates, new.asteroid_type = load_random_asteroid()
    new.width, new.height = new.texture:getDimensions()
    
    --- positioning, movement
    new.x = math.random(love.graphics.getWidth() * 0.75, love.graphics.getWidth() + 100)
    new.gradient = math.random() + 0.3
    
    -- position asteroid above or below game field, store information
    if math.random() > 0.5 then
        new.y = -new.height - 10
    else
        new.y = love.graphics.getHeight() + 10 + new.height
        -- a smaller y value means going up
        new.gradient = -new.gradient
    end
    
    --- set random speed -- "speed" should be horizontal speed
    new.speed = difficulty.get("asteroid_speed", current_level())
    new.speed = new.speed + math.random(0, new.speed / 10)
    
    if math.random() > .6 then
        new.speed = -new.speed
    end

    -- if the asteroid is going left, the gradient value need to be inverted to avoid sending it into nirvana
    if new.speed < 0 then
        new.gradient = -new.gradient
    end
    
    --- calculate y axis intersection given our position and the random gradient
    new.y_intersection = new.y - new.gradient * new.x
    
    new.rotation_speed = math.random(7, 7 + new.speed / 80) / 100
    new.rotation = math.random(2 * math.pi)
    
    --- collision shape
    new.shape = hc.polygon(unpack(asteroid_collision_coordinates))

    new.scale = math.random(40, 70) / 100

    -- move to "position of asteroid" + "center of asteroid"
    new.shape:move(new.x - new.width / 2, new.y - new.height / 2)
    new.shape:scale(new.scale)
    new.shape.object_type = "asteroid"
    
    --print("new asteroid at "..new.x..","..new.y..", going "..new.speed..","..new.gradient.." from "..new.y_intersection)
    
    table.insert(asteroid_storage, new)
end

local function get_next_asteroid_delay()
    return math.random() * .8 + difficulty.get("asteroid_period", current_level())
end

local function on_asteroid_timer()
    add_asteroid()
    --DEBUG: only add a single asteroid
    --return
    timer.after(get_next_asteroid_delay(), on_asteroid_timer)
end

asteroids.init = function()
    --for i=1, 5 do add_asteroid() end
    timer.after(get_next_asteroid_delay(), on_asteroid_timer)
end

local function move(asteroid, dx)
    --print("asteroid currently at "..asteroid.x..","..asteroid.y.." moving with dx "..dx)
    asteroid.x = asteroid.x + dx
    
    local new_y = asteroid.y_intersection + asteroid.x * asteroid.gradient
    
    local dy = new_y - asteroid.y
    asteroid.y = new_y
    asteroid.shape:move(dx, dy)
end

local function get_index_of_asteroid_by_shape(shape)
    for i, ast in ipairs(asteroid_storage) do
        if ast.shape == shape then
            return i
        end
    end
end

asteroids.update = function(dt)
    for i, asteroid in ipairs(asteroid_storage) do
        move(asteroid, dt * asteroid.speed)
        asteroid.rotation = asteroid.rotation + asteroid.rotation_speed
        asteroid.shape:rotate(asteroid.rotation_speed)
        
        -- the following calculations include some safety margins
        if not (asteroid.x + 2 * asteroid.width < 0 or asteroid.x - asteroid.width > love.graphics.getWidth() or
            asteroid.y + 2 * asteroid.height < 0 or asteroid.y - 2 * asteroid.height > love.graphics.getHeight()) then
            asteroid.was_in_viewport = true
        end
        
        if asteroid.was_in_viewport and (asteroid.x + 2 * asteroid.width < 0 or asteroid.x - asteroid.width > love.graphics.getWidth() or
            asteroid.y + 2 * asteroid.height < 0 or asteroid.y - 2 * asteroid.height > love.graphics.getHeight()) then
            table.remove(asteroid_storage, i)
            hc.remove(asteroid.shape)
        end
        
        for other, collision_vector in pairs(hc.collisions(asteroid.shape)) do
            if other.object_type == "enemy" or other.object_type == "asteroid" then
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
                
                explosions.create_explosion(center_x, center_y)
                
                table.remove(asteroid_storage, i)
                hc.remove(asteroid.shape)
                
                if other.object_type == "enemy" then
                    enemies.remove_colliding_enemies(asteroid.shape, function() end)
                elseif other.object_type == "asteroid" then
                    local ast_index = get_index_of_asteroid_by_shape(other)
                    table.remove(asteroid_storage, ast_index)
                    hc.remove(other)
                end
            end
        end
    end
end

asteroids.draw = function()
    for _, asteroid in ipairs(asteroid_storage) do
        love.graphics.draw(asteroid.texture, asteroid.x, asteroid.y, asteroid.rotation, asteroid.scale, asteroid.scale, asteroid.width / 2, asteroid.height / 2)
    end
end

asteroids.has_collision = function(shape) 
    has_collision = false
    
    for shape_, _ in pairs(hc.collisions(shape)) do
        if shape_.object_type == "asteroid" then
            has_collision = true
        end
    end
    
    return has_collision
end

asteroids.handle_projectile = function(projectile_shape, callback)
    local has_collision = false

    for i, asteroid in ipairs(asteroid_storage) do
        if asteroid.shape:collidesWith(projectile_shape) then
            callback(asteroid, asteroid.asteroid_type)

            table.remove(asteroid_storage, i)
            hc.remove(asteroid.shape)

            has_collision = true
        end
    end
    
    return has_collision
end

asteroids.enter = function()
    
end

asteroids.resume = function()
    
end

asteroids.leave = function()
    asteroid_storage = {}
end