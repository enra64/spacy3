--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 19.02.17
-- Time: 13:44
-- To change this template use File | Settings | File Templates.
--

local functions = {}


local collisions = require("collisions")

local function update_bullets(dt)
    for i, bullet in ipairs(bullets) do
        bullet.x = bullet.x + (bullet_speed * dt)

        if bullet.x > love.graphics.getWidth() then
            table.remove(bullets, i)
        end

        if collisions.remove_all_colliding(enemies, bullet, on_kill) then
            table.remove(bullets, i)
        end
    end
end
functions.update = update_bullets

local function draw()
    for _, item in ipairs(bullets) do
        love.graphics.draw(item.texture, item.x, item.y, 0, item.scale)
    end
end
functions.draw = draw

return functions