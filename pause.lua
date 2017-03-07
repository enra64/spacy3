--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 22.02.17
-- Time: 18:46
-- To change this template use File | Settings | File Templates.
--

local pause = {}
pause.horizontal_button_distance = 20
pause.collisions = require("collisions")

local function add_button(pause, text)
    table.insert(pause.button_texts, text)

    --- re-calculate all button rectangles
    pause.button_rectangles = {}
    pause.button_rectangle_x_scale = pause.menu_width / pause.button_texture:getWidth()
    pause.button_rectangle_y_scale = ((pause.menu_height - pause.horizontal_button_distance * #pause.button_texts) / pause.button_texture:getHeight()) / #pause.button_texts

    for i = 1, #pause.button_texts do
        local button_rect = {}
        button_rect.width = pause.menu_width
        button_rect.height = pause.button_rectangle_y_scale * pause.button_texture:getHeight()
        button_rect.x = pause.menu_x
        button_rect.y = pause.menu_y + ((i - 1) * (button_rect.height + pause.horizontal_button_distance)) + button_rect.height / 5
        table.insert(pause.button_rectangles, button_rect)
    end
end

function pause:update()
end

function pause:enter()
    love.graphics.setFont(fonts[40])
end

function pause:draw()
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

function pause:init()
    self.button_texts = {}
    self.button_rectangles = {}

    --- store the target menu size and position
    self.menu_width = love.graphics.getWidth() / 2
    self.menu_height = 2 * love.graphics.getHeight() / 4
    self.menu_x = love.graphics.getWidth() / 4
    self.menu_y = love.graphics.getHeight() / 4

    --- load the button texture
    self.button_texture = love.graphics.newImage("img/ui/button_texture.png")

    --- construct appropriate buttons
    add_button(pause, "continue")
    add_button(pause, "back to menu")
end

function pause:mousepressed(x, y)
    for i, button_rect in ipairs(self.button_rectangles) do
        if self.collisions.has_collision_point_rectangle(x, y, button_rect) then
            self.on_button_clicked(self.button_texts[i])
        end
    end
end

return pause
