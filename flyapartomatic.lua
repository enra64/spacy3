flyapartomatic = {}

local parts
local part_textures
local timer = require("hump.timer")

local function get_texture(texture_path)
    if part_textures[texture_path] == nil then
        part_textures[texture_path] = love.graphics.newImage(texture_path)
    end
    return part_textures[texture_path]
end

local function get_flying_directions(count)
    local dirs = {}
    local direction_modifier = math.random(360)
    local direction_distance = 360 / count
    for i = 1, count do
        local dir =  
            direction_modifier
            + direction_distance * i
            + math.random(-direction_distance / 4,direction_distance / 4)
        
        table.insert(dirs, {x = math.cos(math.rad(dir)), y = math.sin(math.rad(dir))})
    end
    
    return dirs
end

local function remove_part(part)
    for i, iterated_part in ipairs(parts) do
        if iterated_part == part then
            table.remove(parts, i)
        end
    end
end

flyapartomatic.spawn = function(list_of_texture_paths, x, y)
    local directions = get_flying_directions(#list_of_texture_paths)
    for i, texture_path in ipairs(list_of_texture_paths) do
        local part = {}
        part.texture = get_texture(texture_path)
        part.x = x
        part.y = y
        part.rotation = math.rad(math.random(360))
        part.x_scale = 1
        part.y_scale = 1
        timer.tween(
            1.5, 
            part, 
            {x = directions[i].x * 1920, y = directions[i].y * 1920}, 
            'out-linear', 
            function() 
                remove_part(part)
            end
        )
        table.insert(parts, part)
    end
end

flyapartomatic.draw = function()
  for _, part in ipairs(parts) do
    love.graphics.draw(part.texture, part.x, part.y, part.rotation, part.x_scale, part.y_scale)
  end
end

flyapartomatic.init = function() 
  parts = {}
  part_textures = {}
end