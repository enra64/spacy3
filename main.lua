--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 22.02.17
-- Time: 18:35
-- To change this template use File | Settings | File Templates.
--
gamestate = require "hump.gamestate"
fonts = {}

local game = require "game_gamestate"
local pause = require "pause"

function on_pause_button_clicked(button_text)
    if (button_text == "continue" or button_text == "start game") then
        gamestate.switch(game)
    elseif (button_text == "highscore") then
        print "not yet implemented"
    end
end

local function load_fonts()
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

    --- set pause menu callback
    pause.on_button_clicked = on_pause_button_clicked

    gamestate.registerEvents()
    gamestate.switch(pause)
end