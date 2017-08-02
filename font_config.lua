--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 10.03.17
-- Time: 14:43
-- To change this template use File | Settings | File Templates.
--

local functions = {}
require("scaling")

local font_storage = {}
local current_font_size

-- get a font object by the size, without doing anything with scaling.lua
function functions.get_font_by_size(size)
    if not font_storage[size] then
        font_storage[size] = love.graphics.newFont("spacy3font.otf", size)
    end
    return font_storage[size]
end

-- get the currently set font object as well as the current font size
function functions.get_current_font()
    return font_storage[current_font_size], current_font_size
end

-- load a font for the given font_type with the size given in scaling.lua
function functions.load_font(font_type)
    current_font_size = scaling.get("fonts_"..font_type)
    local font = functions.get_font_by_size(current_font_size)
    love.graphics.setFont(font)
    return font
end

-- values are stored in scaling.lua
functions.get_font = function(font_type)
    return functions.get_font_by_size(scaling.get("fonts_"..font_type))
end

return functions