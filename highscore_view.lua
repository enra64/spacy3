local this = {}

this.is_touch = require("is_touch")()
local font_config = require("font_config")
require("persistent_storage")

local title_font = font_config.get_font("menu_title")
local text_font = font_config.get_font("menu")

function this:draw()
    love.graphics.setFont(title_font)
    love.graphics.printf("highscores", 0, 10, love.graphics.getWidth(), "center")

    love.graphics.setFont(text_font)
    for _, label in ipairs(self.highscore_labels) do
        love.graphics.printf(label.text, label.x, label.y, label.width, "center")
    end

    --- button
    love.graphics.draw(self.back_button.texture, self.back_button.x, self.back_button.y, NO_ROTATION, self.back_button.scale_x, self.back_button.scale_y)

    --- text
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(self.back_text.text, self.back_text.x, self.back_text.y, self.back_text.width, "center")
    love.graphics.setColor(255, 255, 255)
end

function this:init()
    --- title stuff
    self.title = {}
    self.title.x = 0
    self.title.y = 10
    self.title.text = "highscores"

    --- init list of highscores
    self.highscore_labels = {}
    local list_y = 70
    local highscores = persistent_storage.get("highscores", {})
    
    local position = 1
    for i, score in spairs(highscores, function(t,a,b) return t[b][2] < t[a][2] end) do
        local new = {}
        new.x = 0
        new.y = (position - 1) * (text_font:getHeight() * 1.5) + list_y
        new.width = love.graphics.getWidth()
        new.text = score[2].." points : "..score[1]
        table.insert(self.highscore_labels, new)
        position = position + 1
    end 

    -- back button
    self.back_button = {}
    self.back_button.x = love.graphics.getWidth() / 4
    self.back_button.y = love.graphics.getHeight() - 2 * title_font:getHeight() - 10
    self.back_button.width = love.graphics.getWidth() / 2
    self.back_button.height = 2 * text_font:getHeight()
    self.back_button.texture = love.graphics.newImage("img/ui/button_texture.png")
    self.back_button.scale_x = math.scale_from_to(self.back_button.texture:getWidth(), self.back_button.width)
    self.back_button.scale_y = math.scale_from_to(self.back_button.texture:getHeight(), self.back_button.height)

    self.back_text = {}
    self.back_text.text = "back"
    self.back_text.x = self.back_button.x
    self.back_text.y = self.back_button.y + self.back_button.height / 2 - text_font:getHeight() / 2
    self.back_text.width = self.back_button.width
end

function this:mousepressed(x, y)
    if y > self.back_button.y and y < self.back_button.y + self.back_button.height then
        if x > self.back_button.x and x < self.back_button.x + self.back_button.width then
            gamestate.pop()
        end
    end
end 

function this:keypressed(key)
    if key == "escape" then
        gamestate.pop()
    end
end

return this