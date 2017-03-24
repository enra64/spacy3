--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 22.02.17
-- Time: 18:35
-- To change this template use File | Settings | File Templates.
--
gamestate = require "hump.gamestate"
require("persistent_storage")
require("common")

function on_pause_button_clicked(button_text)
    -- for when i get confused: print(function_location() .. ": " .. button_text)
    if (button_text == "new game") then
        --- push game on gamestate stack
        gamestate.push(dofile("game_gamestate.lua"))
    elseif (button_text == "view highscores") then
        gamestate.push(dofile("highscore_view.lua"))
    elseif button_text == "settings" then
        gamestate.push(dofile("settings.lua"))
    elseif button_text == "quit" then
        love.event.quit()
    end
end

local function highscore_dialog_finished(result, entered_text, score)
    local highscores = persistent_storage.get("highscores", {})
    
    -- insert new table with name and score in highscores table
    table.insert(highscores, {entered_text, score})

    success = true

    -- store sorted highscores
    if not persistent_storage.set("highscores", highscores) then
        success = false
    end

    -- also store lowest value
    if not persistent_storage.set("lowest_highscore", highscores[#highscores]) then
        success = false
    end

    if not success then
        print("could not store data")
    end

    -- pop highscore entering dialog
    gamestate.pop()
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

    if score > persistent_storage.get("lowest_highscore", {"", 0})[2] then
        quit_confirmation:add_button("enter highscore")
    end 

    quit_confirmation:add_button("quit")
    quit_confirmation:set_title("you made " .. score .. " points.\nyou also horifically failed your colony.")
    quit_confirmation.on_button_clicked = function(button_txt)
        if button_txt == "back to main" then
            gamestate.pop() -- pop warning
            gamestate.pop() -- pop game
        elseif button_txt == "enter highscore" then
            gamestate.pop() -- pop warning
            gamestate.pop() -- pop game

            -- show highscore entry thingy
            local highscore_entry = dofile("highscore_entry.lua")
            gamestate.push(highscore_entry)
            highscore_entry:set_title("enter your score of "..score.." points")
            highscore_entry:set_score(score)
            highscore_entry:set_callback(highscore_dialog_finished)
        elseif button_txt == "quit" then
            love.event.push("quit")
        end
    end
end

function love.load(arg)
    --- enable zerobrane ide debugging
    if arg[#arg] == "-debug" then require("mobdebug").start() end
    
    --- unshittify random numbers
    math.randomseed(os.time())

    --- apply settings (or default)
    settings = dofile("settings.lua")
    settings:init()
    settings:graphics_mode_changed()

    --- initialise all fonts
    require("font_config").init()

    --- register event callbacks
    gamestate.registerEvents()

    --- push main menu onto stack
    local main_menu = dofile("menu.lua")
    gamestate.push(main_menu)

    --- configure main menu
    main_menu:add_button("new game")
    main_menu:add_button("view highscores")
    main_menu:add_button("settings")
    main_menu:add_button("quit")
    main_menu:set_title("main menu")

    --- set main menu callback
    main_menu.on_button_clicked = on_pause_button_clicked
end