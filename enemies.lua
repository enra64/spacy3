--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 19.02.17
-- Time: 13:43
-- To change this template use File | Settings | File Templates.
--

local functions = {}

local simple_enemies = {}
functions.enemies = simple_enemies
local hc = require("hc")
require("difficulty_handler")


local function create_enemy()
    local new_enemy = {}

    --- load texture
    new_enemy.texture = love.graphics.newImage("img/enemy_ship_2_body.png")

    --- store width and height
    new_enemy.width, new_enemy.height = new_enemy.texture:getDimensions()

    --- no scaling
    new_enemy.scale = difficulty.get("enemy_simple_scale")
    new_enemy.score = difficulty.get("enemy_simple_score", current_level())
    new_enemy.type = "simple"

    --- find free position
    position_found = false
    
    while not position_found do
        new_enemy.x = math.random(love.graphics.getWidth(), love.graphics.getWidth() + 100)
        new_enemy.y = math.random(new_enemy.height, love.graphics.getHeight() - 2 * new_enemy.height)
        new_enemy.shape = hc.rectangle(new_enemy.x, new_enemy.y, new_enemy.width * new_enemy.scale, new_enemy.height * new_enemy.scale)
        new_enemy.shape.object_type = "enemy"
        
        position_found = true
        
        for _,_ in pairs(hc.collisions(new_enemy.shape)) do
            -- if we found a collision, that enemy will not be added; its shape must be deleted from the collision system
            position_found = false
            hc.remove(new_enemy.shape)
        end
    end
    

    table.insert(simple_enemies, new_enemy)
end
functions.create_enemy = create_enemy

local function create_simple_enemies()
    while #simple_enemies < difficulty.get("enemy_simple_count", current_level()) do
        create_enemy()
    end
end

local function update_enemies(dt)
    create_simple_enemies()
    
    for index, enemy in ipairs(simple_enemies) do
        local enemy_speed = difficulty.get("enemy_"..enemy.type.."_speed", current_level())
        enemy.x = enemy.x - (dt * enemy_speed)
        enemy.shape:move(-dt * enemy_speed, 0)

        if enemy.x + enemy.width < 0 then
            hc.remove(enemy.shape)
            table.remove(simple_enemies, index)
        end
    end
end
functions.update = update_enemies

local function draw()
    for _, item in ipairs(simple_enemies) do
        love.graphics.draw(item.texture, item.x, item.y, NO_ROTATION, item.scale)
    end
end
functions.draw = draw

functions.has_enemy_collision = function(object)
    has_collision = false
    for shape, _ in pairs(hc.collisions(object.shape)) do
        if shape.object_type == "enemy" then
            has_collision = true
        end
    end
    return has_collision
end

functions.remove_colliding_enemies = function(shape, on_kill)
    had_collision = false
    for i, enemy in ipairs(simple_enemies) do 
        if enemy.shape:collidesWith(shape) then
            table.remove(simple_enemies, i)
            hc.remove(enemy.shape)
            had_collision = true
            on_kill(enemy)
        end
    end
    
    return had_collision
end

functions.leave = function()
    simple_enemies = {}
    functions.enemies = simple_enemies
end

return functions
