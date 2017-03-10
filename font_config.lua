--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 10.03.17
-- Time: 14:43
-- To change this template use File | Settings | File Templates.
--

local functions = {}
local is_touch = require("is_touch")()

local fonts = {}

functions.init = function()
    --- load custom fonts in different sizes
    if is_touch then
        fonts.ingame = love.graphics.newFont("spacy3font.otf", 40)
        fonts.menu = love.graphics.newFont("spacy3font.otf", 80)
    else
        fonts.ingame = love.graphics.newFont("spacy3font.otf", 20)
        fonts.menu = love.graphics.newFont("spacy3font.otf", 40)
    end
end

functions.get_font = function(font_type) return fonts[font_type] end

return functions