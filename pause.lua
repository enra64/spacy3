--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 22.02.17
-- Time: 18:46
-- To change this template use File | Settings | File Templates.
--

local pause = {}
pause.horizontal_button_distance = 20


local function add_button(pause, text)
    table.insert(pause.button_texts, text)
end

function pause:update()
end

function pause:draw()
    local x_scale = self.menu_width / self.button_texture:getWidth()
    local y_scale = ((self.menu_height - self.horizontal_button_distance * #self.button_texts) / self.button_texture:getHeight()) / #self.button_texts
    local button_height = y_scale * self.button_texture:getHeight()

    for i = 1, #self.button_texts do
        local y_pos = self.menu_y + ((i - 1) * (button_height + self.horizontal_button_distance))
        love.graphics.draw(self.button_texture, self.menu_x, y_pos, 0, x_scale, y_scale)
        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(self.button_texts[i], self.menu_x + self.menu_width / 4, self.menu_y + ((i - 1) * (button_height + self.horizontal_button_distance)) + button_height / 4, self.menu_width / 2, "left", 0, 3)
        love.graphics.setColor(255, 255, 255)
    end
end

function pause:init()
    self.button_texts = {}

    --- store the target menu size and position
    self.menu_width = love.graphics.getWidth() / 2
    self.menu_height = 2 * love.graphics.getHeight() / 4
    self.menu_x = love.graphics.getWidth() / 4
    self.menu_y = love.graphics.getHeight() / 4

    --- load the button texture
    self.button_texture = love.graphics.newImage("img/ui/button_texture.png")

    --- construct appropriate buttons
    add_button(self, "continue")
    add_button(self, "back to menu")
end

function pause:mousepressed(x, y, button)
end

return pause
