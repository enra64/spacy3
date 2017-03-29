local timer = require("hump.timer")
local hc = require("hc")

drops = {}

drops.make_drop = function(type, x, y)
  drop = {}
  
  if type == "asteroid_drop" then
      drop.texture = love.graphics.newImage("img/asteroid_drop.png")
      drop.illuminated_texture = love.graphics.newImage("img/blue_laser.png")
  else
      print("unknown drop type requested: "..type)
  end
  
  drop.x = x
  drop.y = y
  drop.rotation = math.rad(math.random(360))
  drop.x_scale = math.random(80, 120) / 100
  drop.y_scale = math.random(80, 120) / 100
  drop.width = drop.texture:getWidth() * drop.x_scale
  drop.height = drop.texture:getHeight() * drop.y_scale
  
  -- create hc shape, align to texture (rect is temp, thus the weird init)
  drop.shape = hc.rectangle(0, 0, drop.texture:getWidth(), drop.texture:getHeight())
  drop.shape:scale(drop.x_scale, drop.y_scale)
  drop.shape:rotate(drop.rotation)
  drop.shape:move(
    drop.x - drop.width / 2, 
    drop.y - drop.height / 2)      
  
  timer.tween(.5, drop, {x = drop.x - math.random(50, 70)}, 'out-quad')
  
  -- tween every "tween_duration", begin tweening manually
  timer.every(1, function() drop.illuminated = not drop.illuminated end)
  
  timer.every(.5, function() print("test") end)
  
  table.insert(drops.drop_list, drop)
end



drops.update = function()
end

local function get_index_of_shape(shape)
  for i, drop in ipairs(drops.drop_list) do
      if drop.shape == shape then
          return i
      end
  end
  return 0
end

drops.remove_colliding_drops = function(shape)
  for i, drop in ipairs(drops.drop_list) do
      if shape:collidesWith(drop.shape) then
          table.remove(drops.drop_list, i)
          hc.remove(drop.shape)
          return "asteroid_drop"
      end
  end
  
  return false
end

drops.draw = function() 
  for _, drop in ipairs(drops.drop_list) do
    love.graphics.draw(drop.texture, drop.x, drop.y, drop.rotation, drop.x_scale, drop.y_scale, drop.width / 2, drop.height / 2)
  end
end

drops.init = function()
    drops.drop_list = {}
end