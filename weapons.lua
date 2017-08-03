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
local overheat_bar_y_scale = .5
local laser_cooling_speed = .3
local laser_texture

-- images
local missile_texture = love.graphics.newImage("img/missile_with_propulsion.png")
local laser_textures = {
    love.graphics.newImage("img/green_laser.png"),
    love.graphics.newImage("img/yellow_laser.png"),
    love.graphics.newImage("img/blue_laser.png")
}

local laser_sound_data = love.sound.newSoundData("sounds/laser.ogg")
local rocket_sound_data = love.sound.newSoundData("sounds/rocket_fire.ogg")

--- requires
local hc = require("hc")
local enemies = require("enemies")
require("asteroids.asteroids")

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

    new_missile.texture = missile_texture

    --- store scaling factor
    new_missile.scale = scaling.get("missile_scale")

    --- store width and height
    local width, height = new_missile.texture:getDimensions()
    new_missile.width = width * new_missile.scale
    new_missile.height = height * new_missile.scale

    --- init pos
    new_missile.x = x
    new_missile.y = y
    
    --- store shape in collider
    new_missile.shape = hc.rectangle(x, y, new_missile.width, new_missile.height)

    --- set speed
    new_missile.speed = missile_speed

    --- add new bullet to list
    table.insert(projectiles, new_missile)

    --- play firing sound
    local sound = love.audio.newSource(rocket_sound_data)
    sound:setVolume(0.23)
    sound:play()

    signal.emit("weapon_fired", "rocket")

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

    new_laser.texture = laser_texture

    --- store scaling factor
    new_laser.scale = .6

    --- store width and height
    local width, height = new_laser.texture:getDimensions()
    new_laser.width = width * new_laser.scale
    new_laser.height = height * new_laser.scale

    --- init pos
    new_laser.x = x
    new_laser.y = y

    --- set speed
    new_laser.speed = laser_speed
    
    --- store shape in collider
    new_laser.shape = hc.rectangle(x, y, new_laser.width, new_laser.height)

    --- add new bullet to list
    table.insert(projectiles, new_laser)

    --- play firing sound
    local laser_sound = love.audio.newSource(laser_sound_data)
    laser_sound:setVolume(.3)
    laser_sound:play()

    signal.emit("weapon_fired", "laser")

    --- make the laser hotter
    laser_overheat = math.clamp(laser_overheat + .23, 0, 1)
end
functions.shoot_laser = shoot_laser

functions.update = function(dt, on_kill, on_asteroid_kill, game_mode)
    --- reduce laser cooldown times for labyrinth mode
    if game_mode == "asteroid rush" then
        laser_cooling_speed = laser_cooling_speed * 1.5
    end

    --- reduce laser overheat
    laser_overheat = math.clamp(laser_overheat - dt * laser_cooling_speed, 0, 1)

    --- move the bullets
    for i, projectile in ipairs(projectiles) do
        projectile.x = projectile.x + (projectile.speed * dt)

        projectile.shape:move(projectile.speed * dt, 0)

        -- remove offscreen bullets
        if projectile.x > love.graphics.getWidth() then
            table.remove(projectiles, i)
            hc.remove(projectile.shape)
        end

        -- remove colliding enemies
        if enemies.remove_colliding_enemies(projectile.shape, on_kill) then
            table.remove(projectiles, i)
            hc.remove(projectile.shape)
        end

        -- let asteroids handle the bullet
        if asteroids.handle_projectile(projectile.shape, on_asteroid_kill) then
            table.remove(projectiles, i)
            hc.remove(projectile.shape)
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

local function load_upgrade_level_dependent_information()
    local heat_diff_state = player_ship_upgrade_state.get_state("heat_diffuser")
    laser_cooling_speed = difficulty.get("heat_diffuser_resulting_speeds")[heat_diff_state]
    laser_texture = laser_textures[heat_diff_state]
end

functions.init = load_upgrade_level_dependent_information

functions.resume = load_upgrade_level_dependent_information

return functions