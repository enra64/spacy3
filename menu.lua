--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 22.02.17
-- Time: 18:46
-- To change this template use File | Settings | File Templates.
--

local menu = {}
menu.horizontal_button_distance = 20
menu.collisions = require("collisions")
menu.control = require("player_control")
menu.button_texts = {}
menu.button_rectangles = {}
menu.button_texture = love.graphics.newImage("img/ui/button_texture.png")

--- store the target menu size and position
menu.menu_width = love.graphics.getWidth() / 2
menu.menu_height = 2 * love.graphics.getHeight() / 4
menu.menu_x = love.graphics.getWidth() / 4
menu.menu_y = love.graphics.getHeight() / 4

function menu:add_button(text)
    table.insert(self.button_texts, text)

    --- re-calculate all button rectangles
    self.button_rectangles = {}
    self.button_rectangle_x_scale = self.menu_width / self.button_texture:getWidth()
    self.button_rectangle_y_scale = ((self.menu_height - self.horizontal_button_distance * #self.button_texts) / self.button_texture:getHeight()) / #self.button_texts

    for i = 1, #self.button_texts do
        local button_rect = {}
        button_rect.width = self.menu_width
        button_rect.height = self.button_rectangle_y_scale * self.button_texture:getHeight()
        button_rect.x = self.menu_x
        button_rect.y = self.menu_y + ((i - 1) * (button_rect.height + self.horizontal_button_distance)) + button_rect.height / 5
        table.insert(self.button_rectangles, button_rect)
    end
end

function menu:update()
end

function menu:enter()
    love.graphics.setFont(fonts[40])
end

function menu:draw()
    for i, button_rect in ipairs(self.button_rectangles) do
        love.graphics.draw(self.button_texture, button_rect.x, button_rect.y, 0, self.button_rectangle_x_scale, self.button_rectangle_y_scale)

        love.graphics.setColor(255, 0, 0)
        love.graphics.printf(self.button_texts[i],
            self.menu_x,
            button_rect.y + button_rect.height / 2,
            self.menu_width,
            "center",
            0, 1)
        love.graphics.setColor(255, 255, 255)
    end
end

function menu:mousepressed(x, y)
    for i, button_rect in ipairs(self.button_rectangles) do
        if self.collisions.has_collision_point_rectangle(x, y, button_rect) then
            self.on_button_clicked(self.button_texts[i])
        end
    end
end

--- forward release input events to player control so it realizes that the pause button is no longer pressed

function menu:touchreleased(id)
    self.control.touchreleased(id)
end

function menu:keyreleased()
    self.control.update_keyboard(0.016)
end

return menu
