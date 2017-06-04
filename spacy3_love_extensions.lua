require("common")

-- store the actual newImage function
local loveNewImage = love.graphics.newImage
local loveDraw = love.graphics.draw

-- table for the loaded images
local image_table = {}

-- overwrite the newImage call
love.graphics.newImage = function(path, ...)
    -- if texture was never loaded, create from path
    if not image_table[path] then 
        image_table[path] = loveNewImage(path, ...)
    end
    
    -- return the texture
    return image_table[path]
end

love.graphics.drawObjectCentered = function(drawable, ...)
    drawable.scale_x = drawable.scale_x or drawable.scale or 1
    drawable.scale_y = drawable.scale_y or drawable.scale or 1
    drawable.rotation = drawable.rotation or NO_ROTATION
    
    loveDraw(
        drawable.texture,
        drawable.x,
        drawable.y,
        drawable.rotation,
        drawable.scale_x,
        drawable.scale_y,
        drawable.width / 2, 
        drawable.height / 2
    )   
end

love.graphics.drawObject = function(drawable, ...)
    drawable.scale_x = drawable.scale_x or drawable.scale or 1
    drawable.scale_y = drawable.scale_y or drawable.scale or 1
    drawable.rotation = drawable.rotation or NO_ROTATION
    
    loveDraw(
        drawable.texture,
        drawable.x,
        drawable.y,
        drawable.rotation,
        drawable.scale_x,
        drawable.scale_y
    )
end