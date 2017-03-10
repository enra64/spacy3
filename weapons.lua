--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 19.02.17
-- Time: 13:44
-- To change this template use File | Settings | File Templates.
--

local functions = {}



--- constants
local missile_speed = 800
local laser_speed = 1300
local laser_cooling_speed = .3
local overheat_bar_y_scale = .5

--- requires
local collisions = require("collisions")
local enemies = require("enemies")

--- list of current projectiles
local projectiles = {}

--- 0 - 1 of laser overheating bar - much fuzzy
local laser_overheat = 0
local missile_count = 10

local function shoot_missile(x, y)
    if missile_count <= 0 then
        return
    end

    local new_missile = {}

    new_missile.texture = love.graphics.newImage("img/missile_with_propulsion.png")

    --- store scaling factor
    new_missile.scale = .6

    --- store width and height
    local width = new_missile.texture:getWidth()
    local height = new_missile.texture:getHeight()
    new_missile.width = width * new_missile.scale
    new_missile.height = height * new_missile.scale

    --- init pos
    new_missile.x = x
    new_missile.y = y

    --- set speed
    new_missile.speed = missile_speed

    --- add new bullet to list
    table.insert(projectiles, new_missile)

    --- play firing sound
    local fire_sound = love.audio.newSource("sounds/rocket_fire.ogg", "static")
    fire_sound:setVolume(1.5)
    fire_sound:play()

    --- reduce missile count
    missile_count = missile_count - 1
end

functions.shoot_missile = shoot_missile

functions.get_missile_count = function() return missile_count end
functions.get_laser_heat = function() return laser_overheat end

local function shoot_laser(x, y)
    if laser_overheat >= .75 then
        return
    end

    local new_laser = {}

    new_laser.texture = love.graphics.newImage("img/green_laser.png")

    --- store scaling factor
    new_laser.scale = .6

    --- store width and height
    local width = new_laser.texture:getWidth()
    local height = new_laser.texture:getHeight()
    new_laser.width = width * new_laser.scale
    new_laser.height = height * new_laser.scale

    --- init pos
    new_laser.x = x
    new_laser.y = y

    --- set speed
    new_laser.speed = laser_speed

    --- add new bullet to list
    table.insert(projectiles, new_laser)

    --- play firing sound
    local fire_sound = love.audio.newSource("sounds/laser.ogg", "static")
    fire_sound:setVolume(.3)
    fire_sound:play()

    --- make the laser hotter
    laser_overheat = math.clamp(laser_overheat + .23, 0, 1)
end

functions.shoot_laser = shoot_laser

functions.update = function(dt)
    --- reduce laser overheat
    laser_overheat = math.clamp(laser_overheat - dt * laser_cooling_speed, 0, 1)

    --- move the bullets
    for i, bullet in ipairs(projectiles) do
        bullet.x = bullet.x + (bullet.speed * dt)

        if bullet.x > love.graphics.getWidth() then
            table.remove(projectiles, i)
        end

        if collisions.remove_all_colliding(enemies.enemies, bullet, on_kill) then
            table.remove(projectiles, i)
        end
    end
end

functions.draw = function()
    for _, item in ipairs(projectiles) do
        love.graphics.draw(item.texture, item.x, item.y, 0, item.scale)
    end
end

functions.leave = function()
    projectiles = {}
end

return functions