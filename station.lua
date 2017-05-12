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
end

function station:init()
    -- define area where store is triggered
    self.texture = love.graphics.newImage("img/station.png")
    self.scale = math.scale_from_to(station.texture:getHeight(), love.graphics.getHeight())
    self.store_trigger_shape = hc.polygon(57,476,119,490,176,279,108,265)
    
    local inverse_scale = 1 - station.scale
    local x_off, y_off = inverse_scale * self.texture:getWidth(), inverse_scale * self.texture:getHeight()
    self.store_trigger_shape:move(-x_off / 4, -y_off / 4)
    self.store_trigger_shape:scale(self.scale)
    
    self.store_trigger_shape.object_type = "store_trigger"
    self.store_lock = false
end

return station