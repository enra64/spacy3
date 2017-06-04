-- store the actual newImage function
local newImage = love.graphics.newImage

-- table for the loaded images
local image_table = {}

-- overwrite the newImage call
love.graphics.newImage = function(path, ...)
    -- if texture was never loaded, create from path
    if not image_table[path] then 
        image_table[path] = newImage(path, ...)
    end
    
    -- return the texture
    return image_table[path]
end