--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 22.02.17
-- Time: 18:35
-- To change this template use File | Settings | File Templates.
--
gamestate = require "hump.gamestate"

--- remove annoying 0 parameter in draw calls
NO_ROTATION = 0

--- overwrite luas "dofile" to work on android
function dofile(file)
    return love.filesystem.load(file)()
end

function math.clamp(val, lower, upper)
    assert(val and lower and upper, "missing argument for math.clamp")
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

function math.scale_from_to(from, to)
    return to / from
end

function on_pause_button_clicked(button_text)
    -- for when i get confused: print(function_location() .. ": " .. button_text)
    if (button_text == "new game") then
        --- push game on gamestate stack
        gamestate.push(dofile("game_gamestate.lua"))
    elseif (button_text == "highscore") then
        print "not yet implemented"
    end
end

function function_location()
    local w = debug.getinfo(2, "S")
    return w.short_src .. ":" .. w.linedefined
end

function player_wants_to_quit(score)
    local quit_confirmation = dofile("menu.lua")
    gamestate.push(quit_confirmation)
    quit_confirmation:add_button("really quit")
    quit_confirmation:add_button("abort quitting")
    quit_confirmation:set_title("confirm quitting")
    quit_confirmation.on_button_clicked = function(button_txt)
        if button_txt == "really quit" then
            love.event.push("quit")
        elseif button_txt == "abort quitting" then
            gamestate.pop()
        end
    end
end

function player_wants_back_to_main(score)
    local quit_confirmation = dofile("menu.lua")
    gamestate.push(quit_confirmation)
    quit_confirmation:add_button("really back to main")
    quit_confirmation:add_button("abort going to main")
    quit_confirmation:set_title("confirm back to main menu")
    quit_confirmation.on_button_clicked = function(button_txt)
        if button_txt == "really back to main" then
            gamestate.pop() -- pop warning
            gamestate.pop() -- pop game
        elseif button_txt == "abort going to main" then
            gamestate.pop()
        end
    end
end

function player_died(score)
    local quit_confirmation = dofile("menu.lua")
    gamestate.push(quit_confirmation)
    quit_confirmation:add_button("back to main")
    quit_confirmation:add_button("quit")
    quit_confirmation:set_title("you made " .. score .. " points.\nyou also horifically failed your colony.")
    quit_confirmation.on_button_clicked = function(button_txt)
        if button_txt == "back to main" then
            gamestate.pop() -- pop warning
            gamestate.pop() -- pop game
        elseif button_txt == "quit" then
            love.event.push("quit")
        end
    end
end

function love.load()
    --- unshittify random numbers
    math.randomseed(os.time())

    --- set some window size
    love.window.setMode(1366, 768)

    --love.window.setMode(1920, 1080)
    --love.window.setFullscreen(true)

    --- initialise all fonts
    require("font_config").init()

    --- register event callbacks
    gamestate.registerEvents()

    --- push main menu onto stack
    local main_menu = dofile("menu.lua")
    gamestate.push(main_menu)

    --- configure main menu
    main_menu:add_button("new game")
    main_menu:set_title("main menu")

    --- set main menu callback
    main_menu.on_button_clicked = on_pause_button_clicked
end