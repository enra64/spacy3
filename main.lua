--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 22.02.17
-- Time: 18:35
-- To change this template use File | Settings | File Templates.
--
gamestate = require "hump.gamestate"

local game = ""
local pause = require("pause")

function on_pause_button_clicked(button_text)
    print(button_text.." clicked")
end

function love.load()
    --- unshittify random numbers
    math.randomseed(os.time())

    --- set some window size
    love.window.setMode(1024, 768)

    --- set pause menu callback
    pause.on_button_clicked = on_pause_button_clicked

    gamestate.registerEvents()
    gamestate.switch(pause)
end