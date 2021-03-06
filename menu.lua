--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 22.02.17
-- Time: 18:46
-- To change this template use File | Settings | File Templates.
--

local lume = require("lume.lume")

local menu = {}
menu.horizontal_button_distance = 15

menu.hc_world = require("hc").new()
menu.control = require("player_control")
menu.font_config = require("font_config")

menu.button_texts = {}
menu.button_rectangles = {}
menu.button_texture = love.graphics.newImage("img/ui/button_texture.png")

--- store possible title
menu.title = ""

local click_sound = love.audio.newSource("sounds/button_click.ogg", "stream")
local hovered_button = nil

local function refresh_size_and_location()
    --- store the target menu size and position
    menu.menu_width = math.floor(love.graphics.getWidth() * 0.65)
    menu.menu_height = math.floor(love.graphics.getHeight() * 0.65)
    menu.menu_x = (love.graphics.getWidth() - menu.menu_width) / 2
    menu.menu_y = (love.graphics.getHeight() - menu.menu_height) * 0.75
end

refresh_size_and_location()

function menu:invalidate_buttons()
    refresh_size_and_location()
    self:add_button()
end

function menu:add_button(text)
    if text ~= nil then
        table.insert(self.button_texts, text)
    end

    --- re-calculate all button rectangles
    self.button_rectangles = {}
    self.button_rectangle_x_scale = self.menu_width / self.button_texture:getWidth()
    self.button_rectangle_y_scale = ((self.menu_height - self.horizontal_button_distance * #self.button_texts) / self.button_texture:getHeight()) / #self.button_texts

    --- clear the collider spatial hash
    self.hc_world = require("hc").new()

    for i = 1, #self.button_texts do
        local button_rect = {}

        button_rect.width = self.menu_width
        button_rect.height = self.button_rectangle_y_scale * self.button_texture:getHeight()
        button_rect.x = self.menu_x
        button_rect.y = self.menu_y + ((i - 1) * (button_rect.height + self.horizontal_button_distance)) + button_rect.height / 5

        button_rect.collider = self.hc_world:rectangle(button_rect.x, button_rect.y, button_rect.width, button_rect.height)
        button_rect.collider.text = self.button_texts[i]

        table.insert(self.button_rectangles, button_rect)
    end
end

function menu:clear_buttons()
    self.button_texts = {}
    self.button_rectangles = {}

    --- clear the collider spatial hash
    self.hc_world = require("hc").new()
end

function menu:enter()
    click_sound:setVolume(1.5)
end

function menu:draw()
    self.font_config.load_font("menu_title")
    --- draw title in white
    love.graphics.setColor(255, 255, 255)
    love.graphics.printf_fitting(self.title,
        0,
        (self.menu_y - love.graphics.getFont():getHeight()) / 2,
        love.graphics.getWidth(),
        self.menu_y,
        "center")

    self.font_config.load_font("menu")
    --- draw buttons
    for i, button_rect in ipairs(self.button_rectangles) do
        love.graphics.setColor(255, 255, 255, 200)

        if hovered_button == self.button_texts[i] then
            love.graphics.setColor(255, 255, 255, 255)
        end

        love.graphics.draw(self.button_texture, button_rect.x, button_rect.y, 0, self.button_rectangle_x_scale, self.button_rectangle_y_scale)

        love.graphics.setColor(0, 0, 0)
        love.graphics.printf(self.button_texts[i],
            self.menu_x,
            button_rect.y + button_rect.height / 2 - self.font_config.get_font("menu"):getHeight() / 2,
            self.menu_width,
            "center",
            0, 1)
    end

    -- reset font color
    love.graphics.setColor(255, 255, 255)
end

function menu:button_clicked(button_text)
    click_sound:play()
    self.on_button_clicked(button_text)
end

function menu:gamepadreleased(_, button)
    local index
    if hovered_button == nil then
        if button == "dpdown" then
            index = 1
        elseif button == "dpup" then
            index = #self.button_texts
        end
    else
        if button == "dpdown" then
            index = lume.find(self.button_texts, hovered_button) + 1
        elseif button == "dpup" then
            index = lume.find(self.button_texts, hovered_button) - 1
        elseif button == "a" then
            self:button_clicked(hovered_button)
        end
    end
    if index then
        hovered_button = self.button_texts[index % (#self.button_texts + 1) + 0]
    end
end

function menu:mousemoved(x, y)
    local mouse_point = self.hc_world:point(x, y)
    for button, _ in pairs(self.hc_world:collisions(mouse_point)) do
        hovered_button = button.text
    end
    self.hc_world:remove(mouse_point)
end

function menu:mousepressed(x, y)
    local mouse_point = self.hc_world:point(x, y)
    for button, _ in pairs(self.hc_world:collisions(mouse_point)) do
        self:button_clicked(button.text)
    end
    self.hc_world:remove(mouse_point)
end

function menu:set_title(title)
    self.title = title
end

function menu:resume()
    self:invalidate_buttons()
end

function menu:keypressed(key)
    if key == "escape" and self.on_escape_pressed then
        self.on_escape_pressed()
    end
end

return menu
