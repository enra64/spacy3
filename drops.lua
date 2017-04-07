local timer = require("hump.timer")
local hc = require("hc")
require("scaling")

drops = {}

drops.make_drop = function(type, x, y)
  local drop = {}
  
  if type == "asteroid_drop" then
      drop.texture = love.graphics.newImage("img/drop_box.png")
      drop.illuminated_texture = love.graphics.newImage("img/drop_box_illuminated.png")
  else
      print("unknown drop type requested: "..type)
  end
  
  drop.x = x
  drop.y = y
  drop.rotation = math.rad(math.random(360))
  drop.x_scale = scaling.get("drop_scale")
  drop.y_scale = drop.x_scale--keep square
  drop.width = drop.texture:getWidth() * drop.x_scale
  drop.height = drop.texture:getHeight() * drop.y_scale
  -- async move after tweening must be able to check if the hc shape has been removed
  drop.is_removed = false
  
  -- create hc shape, align to texture
  drop.shape = hc.rectangle(0, 0, drop.width, drop.height)
  -- since we draw centered, we can easily use these functions, which work with regard to the shape center
  drop.shape:rotate(drop.rotation)
  drop.shape:moveTo(drop.x, drop.y)
  
  print("new drop at "..drop.x..","..drop.y..", w/h: "..drop.width..","..drop.height)
  
  timer.tween(.5, drop, {x = drop.x - math.random(50, 70)}, 'out-quad', 
      -- adjust the drop shape position after tweening
      function() 
          if not drop.is_removed then 
            drop.shape:moveTo(drop.x, drop.y) 
          end 
      end
  )
  
  -- tween every "tween_duration", begin tweening manually
  drop.illuminated = false
  timer.every(1, function() drop.illuminated = not drop.illuminated end)
  
  drop.remove_flag = false
  timer.after(5, function() drop.remove_flag = true end)
  
  table.insert(drops.drop_list, drop)
end

drops.update = function()
    for i, drop in ipairs(drops.drop_list) do
        if drop.remove_flag then
            drop.is_removed = true
            table.remove(drops.drop_list, i)
            hc.remove(drop.shape)
        end
    end
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
          drop.is_removed = true
          table.remove(drops.drop_list, i)
          hc.remove(drop.shape)
          return "asteroid_drop"
      end
  end
  
  return false
end

drops.draw = function() 
  for _, drop in ipairs(drops.drop_list) do
    local texture
    if drop.illuminated then
      texture = drop.texture
    else
      texture = drop.illuminated_texture
    end
    love.graphics.draw(
        texture, 
        drop.x, 
        drop.y, 
        drop.rotation, 
        drop.x_scale,
        drop.y_scale,
        texture:getWidth() / 2, 
        texture:getHeight() / 2
    )
    --drop.shape:draw()
  end
end

drops.init = function()
    drops.drop_list = {}
end