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
local collisions = require("collisions")

local function create_enemy()
    local new_enemy = {}

    --- load texture
    new_enemy.texture = love.graphics.newImage("img/enemy_ship_2_body.png")

    --- store width and height
    local width = new_enemy.texture:getWidth()
    local height = new_enemy.texture:getHeight()
    new_enemy.width = width
    new_enemy.height = height

    --- no scaling
    new_enemy.scale = 1

    --- find free position
    repeat
        new_enemy.x = math.random(love.graphics.getWidth(), love.graphics.getWidth() + 100)
        new_enemy.y = math.random(love.graphics.getHeight() - height)
    until (not collisions.has_rect_collision(new_enemy, enemies))

    table.insert(enemies, new_enemy)
end
functions.create_enemy = create_enemy



local function update_enemies(dt)
    for index, enemy in ipairs(enemies) do
        enemy.x = enemy.x - (dt * enemy_speed)

        if enemy.x + enemy.width < 0 then
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
    return collisions.has_rect_collision(object, enemies)
end

functions.leave = function()
    enemies = {}
    functions.enemies = enemies
end

return functions
