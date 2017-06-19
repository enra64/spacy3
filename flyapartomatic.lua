flyapartomatic = {}

local parts
local part_textures
local timer = require("hump.timer")
local random = dofile("random.lua")

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

flyapartomatic.spawn = function(list_of_texture_paths, x, y, speed, scale)
    -- secure optional parameters
    speed = speed or 1
    scale = scale or 1
        
    local list_of_texture_paths = random.shuffle(list_of_texture_paths)
    
    local number_of_textures_to_be_spawned = math.random(#list_of_texture_paths / 3, #list_of_texture_paths)
    table.truncate(list_of_texture_paths, number_of_textures_to_be_spawned)
    
    local directions = get_flying_directions(#list_of_texture_paths)
    local screen_size = math.max(love.graphics.getHeight(), love.graphics.getWidth())
    
    for i, texture_path in ipairs(list_of_texture_paths) do
        local part = {}
        part.texture = get_texture(texture_path)
        part.x = x
        part.y = y
        part.opacity = 255
        part.rotation = math.rad(math.random(360))
        part.rotation_speed = math.rad(math.random(3, 7))
        part.x_scale = .25 * scale
        part.y_scale = .25 * scale
        part.width = part.texture:getWidth() * part.x_scale
        part.height = part.texture:getHeight() * part.y_scale
        
        local flying_distance = math.random(screen_size / 10, screen_size / 4)
        
        local movement_duration = speed * (math.random(30, 50) / 100)
        local percentage_to_fadeout = 0.25
        
        timer.tween(
            movement_duration, 
            part, 
            {x = part.x + directions[i].x * flying_distance, y = part.y + directions[i].y * flying_distance}, 
            'out-quad', 
            function() 
                remove_part(part)
            end
        )
        
        timer.after(
            movement_duration * percentage_to_fadeout,
            function()
                timer.tween(
                    movement_duration * (1 - percentage_to_fadeout),
                    part,
                    {opacity = 0},
                    'out-linear'
                )
            end
        )
        
        table.insert(parts, part)
    end
end

flyapartomatic.update = function(dt)
    for _, part in ipairs(parts) do
        part.rotation = part.rotation + part.rotation_speed
    end
end

flyapartomatic.draw = function()
    for _, part in ipairs(parts) do
        love.graphics.setColor(255, 255, 255, part.opacity)
        love.graphics.draw(part.texture, part.x, part.y, part.rotation, part.x_scale, part.y_scale, part.width / 2, part.height / 2)
    end
    love.graphics.setColor(255, 255, 255, 255)
end

flyapartomatic.init = function() 
  parts = {}
  part_textures = {}
end