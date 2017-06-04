local this = {}

local is_touch = require("is_touch")()
require("persistent_storage")

local avl_settings = {
    fullscreen = {"yes", "borderless", "no"},
    resolution = {"640x480", "1366x768", "1920x1080", "2560x1440", "3840x2160"},
    vsync = {"yes", "no"},
    sound = {"on", "off"}
}

local default_state = {
    fullscreen = 3,
    resolution = 1,
    vsync = 1,
    sound = 1
}

local avl_settings_touch = {
    fullscreen = {"yes", "no"},
    sound = {"on", "off"},
    control = {"accelerometer", "touchpad"}
}

local default_state_touch = {
    fullscreen = 2,
    sound = 1,
    control = 2
}

function this:get_current_value(key)
    return self.available_settings[key][self.state[key]]
end

function this:audio_mode_changed()
    local sound_enabled = self:get_current_value("sound")
    if sound_enabled == "on" then
        love.audio.setVolume(1)
    else
        love.audio.setVolume(0)
    end
end

function this:graphics_mode_changed()
    --- touch has more limited options
    if is_touch then
        love.window.setMode(0, 0, {fullscreen = self:get_current_value("fullscreen") == "yes"})
        return
    end

    -- get resolution as settings display
    local width, height = unpack(string.split(self:get_current_value("resolution"), "x"))
    local flags = {}

    local fullscreen_mode = self:get_current_value("fullscreen")
    local vsync_mode = self:get_current_value("fullscreen") == "yes"

    if fullscreen_mode == "borderless" then
        flags.borderless = true
        flags.fullscreen = false
    else
        flags.fullscreen = fullscreen_mode == "yes"
    end

    love.window.setMode(width, height, flags)
    
    -- refresh buttons so they are visible
    self.menu:invalidate_buttons()
    self:generate_buttons()
end

-- create all buttons currently needed, representing the current state
function this:generate_buttons()
    self.menu:clear_buttons()

    for setting in pairs(self.available_settings) do
        self.menu:add_button(setting..": "..self:get_current_value(setting))
    end 

    self.menu:add_button("back")
end

function this:on_button_clicked(text)
    for setting, avl in pairs(self.available_settings) do
        -- only react if setting is found in the button text
        if string.match(text, setting) then
            
            --- choose the next setting, weird wraparound thanks to 1-indexing
            self.state[setting] = (self.state[setting] % #avl) + 1

            if setting == "vsync" or setting == "fullscreen" or setting == "resolution" then
                self:graphics_mode_changed()
            elseif setting == "sound" then
                self:audio_mode_changed()
            end
        end 
    end

    if text == "back" then
        gamestate.pop()
    end 

    self:generate_buttons()
end

-- redirection
local function on_button_clicked(text)
    this:on_button_clicked(text)
end

function this:init() 
    self.menu = dofile("menu.lua")
    self.menu:set_title("settings")
    self.menu.on_button_clicked = on_button_clicked

    if is_touch then
        self.available_settings = avl_settings_touch
        self.state = persistent_storage.get("settings", default_state_touch)
    else
        self.available_settings = avl_settings
        self.state = persistent_storage.get("settings", default_state)
    end

    self:generate_buttons()
end

function this:leave()
    persistent_storage.set("settings", self.state)
end

-- forward these events to the menu
function this:draw()
    self.menu:draw()
end 

function this:mousepressed(x, y)
    self.menu:mousepressed(x, y)
end 

function this:enter()
    self.menu:enter()
end

return this