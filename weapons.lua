--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 19.02.17
-- Time: 13:44
-- To change this template use File | Settings | File Templates.
--

local functions = {}


local collisions = require("collisions")
local enemies = require "enemies"
local bullets = {}

local function shoot_missile(x, y)
    local new_bullet = {}

    new_bullet.texture = love.graphics.newImage("img/missile_with_propulsion.png")

    --- store scaling factor
    new_bullet.scale = .6

    --- store width and height
    local width = new_bullet.texture:getWidth()
    local height = new_bullet.texture:getHeight()
    new_bullet.width = width * new_bullet.scale
    new_bullet.height = height * new_bullet.scale

    --- init pos
    new_bullet.x = x
    new_bullet.y = y

    --- add new bullet to list
    table.insert(bullets, new_bullet)

    --- play firing sound
    local fire_sound = love.audio.newSource("sounds/rocket_fire.ogg", "static")
    fire_sound:setVolume(1.5)
    fire_sound:play()
end
functions.shoot_missile = shoot_missile


local function shoot_laser(x, y)
    local new_bullet = {}

    new_bullet.texture = love.graphics.newImage("img/green_laser.png")

    --- store scaling factor
    new_bullet.scale = .6

    --- store width and height
    local width = new_bullet.texture:getWidth()
    local height = new_bullet.texture:getHeight()
    new_bullet.width = width * new_bullet.scale
    new_bullet.height = height * new_bullet.scale

    --- init pos
    new_bullet.x = x
    new_bullet.y = y

    --- add new bullet to list
    table.insert(bullets, new_bullet)

    --- play firing sound
    local fire_sound = love.audio.newSource("sounds/laser.ogg", "static")
    fire_sound:setVolume(.3)
    fire_sound:play()
end
functions.shoot_laser = shoot_laser

functions.update = function(dt)
    for i, bullet in ipairs(bullets) do
        bullet.x = bullet.x + (bullet_speed * dt)

        if bullet.x > love.graphics.getWidth() then
            table.remove(bullets, i)
        end

        if collisions.remove_all_colliding(enemies.enemies, bullet, on_kill) then
            table.remove(bullets, i)
        end
    end
end

functions.draw = function()
    for _, item in ipairs(bullets) do
        love.graphics.draw(item.texture, item.x, item.y, 0, item.scale)
    end
end

functions.leave = function()
    bullets = {}
end

return functions