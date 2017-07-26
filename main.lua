--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 22.02.17
-- Time: 18:35
-- To change this template use File | Settings | File Templates.
--
gamestate = require("hump.gamestate")
signal = require("hump.signal")
require("persistent_storage")
require("common")
require("scaling")
require("background_music")
require("spacy3_love_extensions")

local MAXIMUM_HIGHSCORE_COUNT = 5

local function highscore_dialog_finished(result, entered_text, score)
    local highscores = persistent_storage.get("highscores", {})

    -- pop the "killed" music
    background_music.pop()

    -- insert new table with name and score in highscores table
    table.insert(highscores, { entered_text, score })

    table.sort(highscores,
        function(hs_a, hs_b)
            return hs_a[2] > hs_b[2]
        end)

    while (#highscores > MAXIMUM_HIGHSCORE_COUNT) do
        highscores[#highscores] = nil
    end

    -- store highscore data
    local success = persistent_storage.set("highscores", highscores) and
            persistent_storage.set("lowest_highscore", highscores[#highscores])

    if not success then
        print("could not store data")
    end

    -- pop highscore entering dialog
    gamestate.pop()
end

function player_wants_to_quit(_)
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
    quit_confirmation.on_escape_pressed = function()
        gamestate.pop()
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
    quit_confirmation.on_escape_pressed = function()
        gamestate.pop()
    end
end

function player_died(score)
    local quit_confirmation = dofile("menu.lua")
    --pop game now, will remove music from stack
    gamestate.pop()
    gamestate.push(quit_confirmation)
    quit_confirmation:add_button("back to main")

    -- push fallback music for returning to main menu
    background_music.push("main_menu")

    -- play u dead music
    background_music.push("killscreen")

    local hs_entry_ok = #persistent_storage.get("highscores", {}) < MAXIMUM_HIGHSCORE_COUNT or score > persistent_storage.get("lowest_highscore", { "", 0 })[2]
    if hs_entry_ok then
        quit_confirmation:add_button("enter highscore")
    end

    quit_confirmation:add_button("quit")
    quit_confirmation:set_title("you made " .. score .. " points.\nyou also horrifically failed your colony.")
    quit_confirmation.on_button_clicked = function(button_txt)
        if button_txt == "back to main" then
            gamestate.pop() -- pop warning
            background_music.pop() -- pop u dead music
        elseif button_txt == "enter highscore" then
            gamestate.pop() -- pop warning

            -- show highscore entry thingy
            local highscore_entry = dofile("highscore_entry.lua")
            gamestate.push(highscore_entry)
            highscore_entry:set_title("enter your score of " .. score .. " points")
            highscore_entry:set_score(score)
            highscore_entry:set_callback(highscore_dialog_finished)
        elseif button_txt == "quit" then
            love.event.push("quit")
        end
    end
    quit_confirmation.on_escape_pressed = function()
        gamestate.pop() -- pop warning
        background_music.pop()
    end
end


local function push_game_mode_menu()
    --- push main menu onto stack
    local mode_menu = dofile("menu.lua")
    gamestate.push(mode_menu)

    --- configure main menu
    mode_menu:set_title("select game mode")
    mode_menu:add_button("endless game")
    mode_menu:add_button("asteroid rush")
    mode_menu:add_button("back")

    --- set main menu callback
    mode_menu.on_button_clicked = function(button_text)
        if (button_text == "back") then
            gamestate.pop()
        else
            gamestate.pop() -- pop mode menu
            scaling.gamemode = button_text
            -- push game on gamestate stack with desired gamemode==button text
            gamestate.push(dofile("game_gamestate.lua"), button_text)
        end
    end
end

local function push_main_menu()
    --- push main menu onto stack
    local main_menu = dofile("menu.lua")
    gamestate.push(main_menu)

    --- configure main menu
    main_menu:add_button("new game")
    main_menu:add_button("view highscores")
    main_menu:add_button("settings")
    main_menu:add_button("quit")
    main_menu:set_title("spacy3")

    --- set main menu callback
    main_menu.on_button_clicked = function(button_text)
        if (button_text == "new game") then
            push_game_mode_menu()
        elseif (button_text == "view highscores") then
            gamestate.push(dofile("highscore_view.lua"))
        elseif button_text == "settings" then
            gamestate.push(dofile("settings.lua"))
        elseif button_text == "quit" then
            love.event.quit()
        end
    end
end

function love.load(arg)
    --- enable zerobrane ide debugging
    if arg[#arg] == "-debug" then require("mobdebug").start() end

    --- unshittify (technical term) random numbers
    math.randomseed(os.time())

    --- load gamepad mapping and hope it is useful
    love.joystick.loadGamepadMappings("gamecontrollerdb.txt")

    --- apply settings (or default)
    local settings = require("settings")
    settings:init()
    settings:graphics_mode_changed()
    settings:audio_mode_changed()

    -- hump.gamestate will call this even after registerEvents
    love.update = background_music.update

    --- register event callbacks
    gamestate.registerEvents()

    -- create main menu and push onto stack
    push_main_menu()

    -- make background music
    background_music.push("main_menu")

    local splash_screen = dofile("splashscreen.lua")
    gamestate.push(splash_screen)
end
