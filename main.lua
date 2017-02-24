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

function love.load()
    --- unshittify random numbers
    math.randomseed(os.time())

    --- set some window size
    love.window.setMode(1024, 768)

    gamestate.registerEvents()
    gamestate.switch(pause)
end