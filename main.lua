--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 22.02.17
-- Time: 18:35
-- To change this template use File | Settings | File Templates.
--
gamestate = require "hump.gamestate"

local main_menu = dofile "menu.lua"


function on_pause_button_clicked(button_text)
    print(function_location() .. ": " .. button_text)
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
end

local function load_fonts()
    --- create global fonts object
    fonts = {}

    --- load custom fonts in different sizes
    table.insert(fonts, 14, love.graphics.newFont("spacy3font.otf", 14))
    table.insert(fonts, 16, love.graphics.newFont("spacy3font.otf", 16))
    table.insert(fonts, 20, love.graphics.newFont("spacy3font.otf", 20))
    table.insert(fonts, 30, love.graphics.newFont("spacy3font.otf", 30))
    table.insert(fonts, 40, love.graphics.newFont("spacy3font.otf", 40))
    table.insert(fonts, 50, love.graphics.newFont("spacy3font.otf", 50))

    --- load default custom font
    love.graphics.setFont(fonts[20])
end

function love.load()
    load_fonts()

    --- unshittify random numbers
    math.randomseed(os.time())

    --- set some window size
    love.window.setMode(1024, 768)

    --- register event callbacks
    gamestate.registerEvents()

    --- push main menu onto stack
    gamestate.push(main_menu)

    --- add main menu buttons
    main_menu:add_button("new game")

    --- set main menu callback
    main_menu.on_button_clicked = on_pause_button_clicked
end