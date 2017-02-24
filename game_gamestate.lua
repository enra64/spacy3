local game = {}

--- collections required in multiple requires
explosions = {}
bullets = {}
enemies = {}
player = {}

--- some constants
maximum_explosion_age = .2
bullet_speed = 1000
enemy_speed = 200
speed = 400

score = 0



local bg = require("background")
local player = require("player")
local explosions = require("explosions")
local weapons = require("weapons")
local enemies = require("enemies")
local control = require("player_control")

function on_kill(_, killed_enemy)
    score = score + 10

    --- make explody thing over enemy
    explosions.create_explosion(killed_enemy.x, killed_enemy.y)
end

function game:update(dt)
    weapons.update(dt)
    player.update(dt)
    enemies.update(dt, on_kill)
    explosions.update(dt)
    bg.update(dt)
end

function game:draw()
    bg.draw()
    enemies.draw()
    weapons.draw()
    player.draw()
    explosions.draw()
    control.draw()

    --- score
    love.graphics.print(score .. " points", 0, 0, 0, 2)
end

function game:enter()
    --- load background textures
    bg.load()

    --- initialise control
    control.load()

    --- initialise the player
    player.load()

    --- create some enemies to get started
    for i = 1, 3 do enemies.create_enemy() end
end

return game