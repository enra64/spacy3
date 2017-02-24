--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 22.02.17
-- Time: 18:46
-- To change this template use File | Settings | File Templates.
--

local pause = {}
pause.button_rectangles = {}
pause.button_texts = {}

local function add_button(text)
    table.insert(pause.button_texts, text)
end

function pause:update()
end

function pause:draw()
    for i=1,#pause.button_rectangles do
        love.graphics.print(score .. " points", 0, 0, 0, 2)
    end
end

function pause:init()
end

function pause:mousepressed(x, y, button)
end

return pause
