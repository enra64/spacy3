local game = {}

--- some constants
maximum_explosion_age = .2
bullet_speed = 1000
enemy_speed = 200
speed = 400



local bg = require("background")
local player = require("player")
local explosions = require("explosions")
local weapons = require("weapons")
local enemies = require("enemies")
local control = require("player_control")
local pause_menu = dofile "menu.lua"
local score = 0

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

    if control.is_button_pressed("button_escape") then
        gamestate.push(pause_menu)
    end

    if not player.player_is_alive then
        player_died(score)
    end
end

function game:draw()
    bg.draw()
    enemies.draw()
    weapons.draw()
    player.draw()
    explosions.draw()
    control.draw()

    --- score
    love.graphics.print(score .. " points", 0, 0, 0, 1)
end

function game:init()
    --- load background textures
    bg.load()

    --- initialise control
    control.load()

    --- initialise the player
    player.load()

    --- create some enemies to get started
    for i = 1, 3 do enemies.create_enemy() end

    --- create pause menu
    pause_menu:add_button("resume")
    pause_menu:add_button("back to main menu")
    pause_menu:add_button("quit game")

    --- set pause menu callback handler
    pause_menu.on_button_clicked = function(button_text)
        print(function_location()..": "..button_text)
        if button_text == "resume" then
            gamestate.pop() -- pop pause only
        elseif button_text == "back to main menu" then
            gamestate.pop() -- pop pause
            player_wants_back_to_main(score)
        elseif button_text == "quit game" then
            gamestate.pop()-- pop pause
            player_wants_to_quit(score)
        end
    end
end

function game:leave()
    bg.leave()
    enemies.leave()
    weapons.leave()
    explosions.leave()
end

--- forward relevant input events
function game:touchpressed(id, x, y)
    control.touchpressed(id, x, y)
end

function game:touchmoved(id, x, y)
    control.touchmoved(id, x, y)
end

function game:touchreleased(id)
    control.touchreleased(id)
end

function game:keypressed()
    control.update_keyboard(0.016)
end

function game:keyreleased()
    control.update_keyboard(0.016)
end

return game