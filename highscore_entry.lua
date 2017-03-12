local this = {}

local utf8 = require("utf8")
this.is_touch = require("is_touch")()
this.font = require("font_config").get_font("menu")
this.timer = require("hump.timer")

function this:draw()
    love.graphics.draw(self.input_field.texture, self.input_field.x, self.input_field.y, NO_ROTATION, self.input_field.scale_x, self.input_field.scale_y)
    love.graphics.print(self.entered_text.text, self.entered_text.x, self.entered_text.y)
    love.graphics.printf(self.title.text, self.title.x, self.title.y, self.title.width, "center")

    if self.cursor.draw_currently then
        love.graphics.print("_", self.cursor.get_x(#self.entered_text), self.cursor.y)
    end

    --- buttons
    love.graphics.draw(self.cancel_button.texture, self.cancel_button.x, self.cancel_button.y, NO_ROTATION, self.cancel_button.scale_x, self.cancel_button.scale_y)
    love.graphics.draw(self.accept_button.texture, self.accept_button.x, self.accept_button.y, NO_ROTATION, self.accept_button.scale_x, self.accept_button.scale_y)

    --- texts
    love.graphics.setColor(0, 0, 0)
    love.graphics.printf(self.cancel_text.text, self.cancel_text.x, self.cancel_text.y, self.cancel_text.width, "center")
    love.graphics.printf(self.accept_text.text, self.accept_text.x, self.accept_text.y, self.accept_text.width, "center")
    love.graphics.setColor(255, 255, 255)
end

function this:init()
    --- input field symbol
    self.input_field = {}
    self.input_field.x = love.graphics.getWidth() / 4
    if self.is_touch then
        self.input_field.y = love.graphics.getHeight() / 8 - self.font:getHeight() / 2
    else
        self.input_field.y = love.graphics.getHeight() / 2 - self.font:getHeight() / 2
    end
    self.input_field.texture = love.graphics.newImage("img/ui/laser_overheating_bar_background.png")
    self.input_field.scale_x = math.scale_from_to(self.input_field.texture:getWidth(), love.graphics.getWidth() / 2)
    self.input_field.scale_y = math.scale_from_to(self.input_field.texture:getHeight(), self.font:getHeight() + 40)
    self.input_field.width = self.input_field.texture:getWidth() * self.input_field.scale_x
    self.input_field.height = self.input_field.texture:getHeight() * self.input_field.scale_y

    --- title
    self.title = {}
    self.title.text = ""
    self.title.x = self.input_field.x
    self.title.y = self.input_field.y - 2 * self.font:getHeight()
    self.title.width = love.graphics.getWidth() / 2

    --- text config
    self.entered_text = {}
    self.entered_text.text = ""
    self.entered_text.x = self.input_field.x + 10
    self.entered_text.y = self.input_field.y + self.input_field.height / 2 - self.font:getHeight() / 2

    --- cursor
    self.cursor = {}
    self.cursor.draw_currently = false
    self.cursor.get_x = function(length) return self.font:getWidth(length) + self.entered_text.x end
    self.cursor.y = self.entered_text.y + self.font:getHeight() + 2
    self.cursor.timer = self.timer.every(.5, function() self.cursor.draw_currently = not self.cursor.draw_currently end)

    --- cancel, accept buttons
    self.accept_button = {}
    self.accept_button.x = self.input_field.x
    self.accept_button.y = self.input_field.y + self.input_field.height * 2
    self.accept_button.width = self.input_field.width / 2 - 20
    self.accept_button.height = self.input_field.height
    self.accept_button.texture = love.graphics.newImage("img/ui/button_texture.png")
    self.accept_button.scale_x = math.scale_from_to(self.accept_button.texture:getWidth(), self.accept_button.width)
    self.accept_button.scale_y = math.scale_from_to(self.accept_button.texture:getHeight(), self.accept_button.height)

    self.accept_text = {}
    self.accept_text.text = "accept"
    self.accept_text.x = self.accept_button.x
    self.accept_text.y = self.accept_button.y + self.accept_button.height / 2 - self.font:getHeight() / 2
    self.accept_text.width = self.accept_button.width

    self.cancel_button = {}
    self.cancel_button.x = self.input_field.x + self.input_field.width - self.accept_button.width
    self.cancel_button.y = self.accept_button.y
    self.cancel_button.width = self.accept_button.width
    self.cancel_button.height = self.accept_button.height
    self.cancel_button.texture = love.graphics.newImage("img/ui/button_texture.png")
    self.cancel_button.scale_x = math.scale_from_to(self.cancel_button.texture:getWidth(), self.cancel_button.width)
    self.cancel_button.scale_y = math.scale_from_to(self.cancel_button.texture:getHeight(), self.cancel_button.height)

    self.cancel_text = {}
    self.cancel_text.text = "cancel"
    self.cancel_text.x = self.cancel_button.x
    self.cancel_text.y = self.cancel_button.y + self.cancel_button.height / 2 - self.font:getHeight() / 2
    self.cancel_text.width = self.cancel_button.width
end

function this:set_title(title)
    self.title.text = ""
end

function this:set_callback(callback)
    self.callback = callback
end

function this:set_score(score)
    self.score = score
end  

function this:mousepressed(x, y)
    if y > self.accept_button.y and y < self.accept_button.y + self.accept_button.height then
        if x > self.cancel_button.x then
            gamestate.pop()
        elseif x < self.accept_button.x + self.accept_button.width then
            self.callback("accept", self.entered_text.text, self.score)
        end
    end
end 

function this:textinput(text)
    if self.entered_text.text:len() < 10 then
        self.entered_text.text = self.entered_text.text..text
    end
end

-- see https://love2d.org/wiki/love.textinput, necessary for deleting in the entered text
function this:keypressed(key)
    if key == "backspace" then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(self.entered_text.text, -1)
 
        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            self.entered_text.text = string.sub(self.entered_text.text, 1, byteoffset - 1)
        end
    end
end

function this:enter()
    love.keyboard.setTextInput(true)
end

function this:leave()
    --- disable keyboard if on touch
    love.keyboard.setTextInput(not self.is_touch)
    self.timer.cancel(self.cursor.timer)
end 

return this