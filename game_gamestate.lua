local game = {}

--- some constants
maximum_explosion_age = .2

local bg = require("background")
local player = require("player")
local explosions = require("explosions")
local weapons = require("weapons")
local enemies = require("enemies")
local control = require("player_control")
local pause_menu = dofile "menu.lua"
local ingame_status = require("ingame_status")
local difficulty_handler = require("difficulty_handler")
require("asteroids")
local timer = require("hump.timer")
require("flyapartomatic")
require("player_ship_upgrade_state")

local level_thresholds = difficulty.get("level_threshold")
local level = 1

score = 0

local function on_kill(killed_enemy)
    score = score + killed_enemy.score
    
    --- make explody thing over enemy
    explosions.create_explosion(killed_enemy.x, killed_enemy.y)
end

local function on_asteroid_kill(asteroid, asteroid_type) 
    score = score + 1

    --- make explody thing over enemy
    explosions.create_explosion(asteroid.x, asteroid.y)
    
    --- let the asteroid drop something
    drops.make_drop("asteroid_drop", asteroid.x, asteroid.y)
end

function current_level()
    return level
end

function game:update(dt)
    timer.update(dt)
    control.update(dt)
    flyapartomatic.update(dt)
    weapons.update(dt, on_kill, on_asteroid_kill)
    drops.update(dt)
    player.update(dt)
    enemies.update(dt)
    explosions.update(dt)
    bg.update(dt)
    ingame_status.update(score)
    asteroids.update(dt)
    
    
    if score > level_thresholds[level] then
        level = math.clamp(level + 1, 1, 5)
    end


    if control.is_button_pressed("button_escape") then
        gamestate.push(pause_menu)
    end

    if not player.player_is_alive() then
        --- stop all sounds
        love.audio.stop()

        --- play one last explosion sound
        --- make explosion sound
        local explosion_sound = love.audio.newSource("sounds/explosion.ogg", "static")
        explosion_sound:setVolume(.8)
        explosion_sound:play()

        --- callback for main control
        player_died(score)
    end
end

function game:draw()
    bg.draw()
    flyapartomatic.draw()
    enemies.draw()
    
    drops.draw()
    asteroids.draw()
    weapons.draw()
    player.draw()
    explosions.draw()
    
    control.draw()
    ingame_status.draw()
end

function game:resume()
    weapons.resume()
    control.on_resume()
    asteroids.resume()
    player.resume()
end

function game:init()
    --- reset score
    score = 0
    --- load background textures
    bg.load()

    --- init all
    player_ship_upgrade_state.init()
    flyapartomatic.init()
    drops.init()
    weapons.init()
    control.load()
    player.load()
    ingame_status.init()
    asteroids.init()

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

function game:enter()
    ingame_status.enter()
    asteroids.enter()
    bg.enter()
end

function game:leave()
    bg.leave()
    enemies.leave()
    weapons.leave()
    explosions.leave()
    asteroids.leave()
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

function game:joystickpressed(joystick, button)
    control.joystickpressed(joystick, button, 0.016)
end

function game:joystickreleased(joystick, button)
    control.joystickreleased(joystick, button, 0.016)
end

function game:joystickadded(joystick)
    control.joystickadded(joystick)
end

function game:joystickremoved(joystick)
    control.joystickremoved(joystick)
end

return game