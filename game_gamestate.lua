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
local station = require("station")
require("asteroids.asteroids")
require("common")
local timer = require("hump.timer")
require("flyapartomatic")
require("player_ship_upgrade_state")
require("background_music")

local level_thresholds = difficulty.get("level_threshold")
local level_count = difficulty.level_count()
local level = 1
local mode = ""

local explosion_sound = love.audio.newSource("sounds/explosion.ogg", "static")
explosion_sound:setVolume(.4)

score = 0

function game:create_pause_menu()
    --- create pause menu
    pause_menu:add_button("resume")
    pause_menu:add_button("back to main menu")
    pause_menu:add_button("quit game")
    pause_menu:set_title("paused")

    --- set pause menu callback handler
    pause_menu.on_button_clicked = function(button_text)
        if button_text == "resume" then
            gamestate.pop() -- pop pause
        elseif button_text == "back to main menu" then
            gamestate.pop() -- pop pause
            player_wants_back_to_main(score)
        elseif button_text == "quit game" then
            gamestate.pop()-- pop pause
            player_wants_to_quit(score)
        end
    end
    pause_menu.on_escape_pressed = function()
        gamestate.pop()
    end
end

function game:init()
    --- reset score
    score = 0

    --- init all
    bg.load()
    player_ship_upgrade_state.init()
    flyapartomatic.init()
    drops.init()
    weapons.init()
    control.load()
    player.load()
    ingame_status.init()
    asteroids.init()
    station:init()

    game:create_pause_menu()
    
    background_music.push("ingame")
end

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
    local score = score + asteroids.get_score()


    timer.update(dt)
    control.update(dt)
    flyapartomatic.update(dt)
    weapons.update(dt, on_kill, on_asteroid_kill)
    drops.update(dt)
    player.update(dt, station)
    station:update(player.get_player_shape(), dt)
    enemies.update(dt)
    explosions.update(dt)
    bg.update(dt)
    ingame_status.update(score)
    asteroids.update(dt, player.get_player_shape(), player.asteroid_hit)

    if score > level_thresholds[level] then
        local oldlevel = level
        level = math.clamp(level + 1, 1, level_count)

        if level > oldlevel then
            signal.emit("levelup", level)
        end
    end


    if control.is_button_pressed("button_escape") then
        gamestate.push(pause_menu)
        signal.emit('backgrounded')
    end

    if not player.player_is_alive() then
        --- stop all sound effects
        love.audio.stop()

        --- play one last explosion sound
        --- make explosion sound
        explosion_sound:play()

        --- callback for main control
        player_died(score)
    end
end

function game:draw()
    bg.draw()
    flyapartomatic.draw()
    enemies.draw()
    station:draw()
    
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

function game:enter(_, chosen_gamemode)
    mode = chosen_gamemode
    
    if mode == "asteroid rush" then
        enemies.set_enemies_spawning(false)
        asteroids.enter("labyrinth")
    else
        enemies.set_enemies_spawning(true)
        asteroids.enter("random")
    end

    enemies.enter()
    ingame_status.enter()
    bg.enter()
end

function game:leave()
    bg.leave()
    player_ship_upgrade_state.leave()
    enemies.leave()
    weapons.leave()
    explosions.leave()
    asteroids.leave()
    
    -- pop ingame music
    background_music.pop()
end

--- forward relevant input events
function game:touchpressed(id, x, y) control.touchpressed(id, x, y) end
function game:touchmoved(id, x, y) control.touchmoved(id, x, y) end
function game:touchreleased(id) control.touchreleased(id) end
function game:joystickpressed(joystick, button) control.joystickpressed(joystick, button) end
function game:joystickreleased(joystick, button) control.joystickreleased(joystick, button) end
function game:gamepadpressed(joystick, button) control.gamepadpressed(joystick, button) end
function game:gamepadreleased(joystick, button) control.gamepadreleased(joystick, button) end
function game:joystickadded(joystick) control.joystickadded(joystick) end
function game:joystickremoved(joystick) control.joystickremoved(joystick) end

return game