--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 19.02.17
-- Time: 13:43
-- To change this template use File | Settings | File Templates.
--

local functions = {}

local enemies = {}
functions.enemies = enemies
local hc = require("hc")
local enemy_speed = 200

local function create_enemy()
    local new_enemy = {}

    --- load texture
    new_enemy.texture = love.graphics.newImage("img/enemy_ship_2_body.png")

    --- store width and height
    local width, height = new_enemy.texture:getDimensions()
    new_enemy.width, new_enemy.height = width, height

    --- no scaling
    new_enemy.scale = 1

    --- find free position
    position_found = false
    
    while not position_found do
        new_enemy.x = math.random(love.graphics.getWidth(), love.graphics.getWidth() + 100)
        new_enemy.y = math.random(love.graphics.getHeight() - height)
        new_enemy.shape = hc.rectangle(new_enemy.x, new_enemy.y, width, height)
        new_enemy.shape.object_type = "enemy"
        
        position_found = true
        
        for _,_ in pairs(hc.collisions(new_enemy.shape)) do
            -- if we found a collision, that enemy will not be added; its shape must be deleted
            position_found = false
            hc.remove(new_enemy.shape)
        end
        
    end
    

    table.insert(enemies, new_enemy)
end
functions.create_enemy = create_enemy



local function update_enemies(dt)
    for index, enemy in ipairs(enemies) do
        enemy.x = enemy.x - (dt * enemy_speed)
        enemy.shape:move(-dt * enemy_speed, 0)

        if enemy.x + enemy.width < 0 then
            hc.remove(enemy.shape)
            table.remove(enemies, index)
        end
    end

    while #enemies < 3 do
        create_enemy()
    end
end
functions.update = update_enemies

local function draw()
    for _, item in ipairs(enemies) do
        love.graphics.draw(item.texture, item.x, item.y, 0, item.scale)
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
    for i, enemy in ipairs(enemies) do 
        if enemy.shape:collidesWith(shape) then
            table.remove(enemies, i)
            hc.remove(enemy.shape)
            had_collision = true
            on_kill(enemy)
        end
    end
    
    return had_collision
end

functions.leave = function()
    enemies = {}
    functions.enemies = enemies
end

return functions
