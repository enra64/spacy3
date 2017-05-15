local station = {}

local timer = require("hump.timer")
local hc = require("hc")

function station:update(player_shape, dt)
    if player_shape:collidesWith(self.store_trigger_shape) then
        if not self.store_lock then
            -- load store
            gamestate.push(dofile("store.lua"))
            
            -- notify that the game is no longer primary gamestate
            signal.emit('backgrounded')
            self.store_lock = true
        end
    else
        self.store_lock = false
    end    
end

function station:draw()
    -- draw station
    love.graphics.draw(self.texture, 0, 0, NO_ROTATION, self.scale)
    
    -- draw lights
    for _, light in pairs(self.lights) do
        love.graphics.setColor(255, 255, 255, light.opacity)
        love.graphics.draw(light.texture, 0, 0, NO_ROTATION, self.scale)
    end
    love.graphics.setColor(255, 255, 255)
end

function station:init()
    -- load textures
    self.texture = love.graphics.newImage("img/station.png")
    
    self.upper_red_light = {
        texture = love.graphics.newImage("img/station_upper_red_light.png"),
        opacity = 0
    }
    
    self.lower_red_light = {
        texture = love.graphics.newImage("img/station_lower_red_light.png"),
        opacity = 0
    }
    
    self.green_light = {
        texture = love.graphics.newImage("img/station_green_light.png"),
        opacity = 0
    }
    
    self.lights = {self.upper_red_light, self.lower_red_light, self.green_light}
    
    self.scale = math.scale_from_to(station.texture:getHeight(), love.graphics.getHeight())
    
    -- define area where store is triggered
    self.store_trigger_shape = hc.polygon(57,476,119,490,176,279,108,265)
    
    -- align collision shape and station image
    local inv_scale = 1 - station.scale
    local x_off,y_off = inv_scale * self.texture:getWidth(), inv_scale * self.texture:getHeight()
    self.store_trigger_shape:move(-x_off / 4, -y_off / 4)
    self.store_trigger_shape:scale(self.scale)
    
    self.store_trigger_shape.object_type = "store_trigger"
    self.store_lock = false
    
    timer.yoyo_tween(
        1.5,
        self.green_light,
        {opacity = 255},
        {opacity = 0},
        'in-linear'
    )
    
    timer.yoyo_tween(
        4,
        self.upper_red_light,
        {opacity = 255},
        {opacity = 0},
        'in-linear'
    )
    
    timer.yoyo_tween(
        4,
        self.lower_red_light,
        {opacity = 255},
        {opacity = 0},
        'in-linear'
    )
end

return station