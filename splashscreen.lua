local timer = require("hump.timer").new()
local font_config = require("font_config")

local splashscreen = {}

local click_sound = love.audio.newSource("sounds/button_click.ogg")

local tween_in_duration = 1
local display_duration = 2
local splashscreen_duration = tween_in_duration + display_duration

function splashscreen:update(dt)
    timer:update(dt)
end

function splashscreen:draw()
    -- clear to black background
    love.graphics.clear()
    
    -- configure font
    local current_font = font_config.get_font("splash_sub_text")
    local sub_font_height = current_font:getHeight()
    love.graphics.setFont(current_font)
    love.graphics.setColor(255, 255, 255, self.opacity)
         
    -- draw pretext
    love.graphics.printf(
        "dedicated to",
        self.text_box.left,
        self.text_box.top,
        self.text_box.width,
        "center")

    -- draw post text
    love.graphics.printf(
        "for always supporting us",
        self.text_box.left,
        self.text_box.bottom - sub_font_height,
        self.text_box.width,
        "center")


    -- load large font
    current_font = font_config.get_font("splash_main_text")
    local main_font_height = current_font:getHeight()
    love.graphics.setFont(current_font)
    
    -- draw main text, large
    love.graphics.printf(
        "SUSANNE",
        self.text_box.left,
        self.text_box.top + (self.text_box.height - main_font_height) / 2,
        self.text_box.width,
        "center")
end

function splashscreen:init()
    self.opacity = 0
    self.opaque = false
    
    self.opacity_tweener = timer:tween(
            tween_in_duration, 
            self, 
            {opacity = 255}, 
            'out-linear', 
            function() 
                self.opaque = true
            end
        )
        
    -- at splashscreen end, pop the gamestate
    self.splashscreen_timer = timer:after(splashscreen_duration, gamestate.pop)
    
    self.text_box = {}
    self.text_box.left = love.graphics.getWidth() * 0.15
    self.text_box.right = love.graphics.getWidth() * 0.85
    self.text_box.top = love.graphics.getHeight() * 0.25
    self.text_box.bottom = love.graphics.getHeight() * 0.75
    self.text_box.width = self.text_box.right - self.text_box.left
    self.text_box.height = self.text_box.bottom - self.text_box.top
end

function splashscreen:skip()
    click_sound:play()
    
    -- skip to full opacity
    if not self.opaque then
        self.opaque = true
        timer:cancel(self.opacity_tweener)
    -- skip to main menu
    else 
        timer:cancel(self.splashscreen_timer)
        gamestate.pop()
    end
end

-- interacting with the splashscreen will move it forward
splashscreen.mousepressed = splashscreen.skip
splashscreen.keypressed = splashscreen.skip

return splashscreen