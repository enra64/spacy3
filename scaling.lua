scaling = {}

local vga = {
    ship_scale = 0.1,
    enemy_simple_scale = .3,
    asteroid_base_scale = 1,
    planet_scale = .2
}

local thirteen_sixtysix = {
    ship_scale = 0.3,
    enemy_simple_scale = 1,
    asteroid_base_scale = 1,
    planet_scale = .35
}

local fhd = {
    ship_scale = 0.4,
    enemy_simple_scale = 1.7,
    asteroid_base_scale = 1.2,
    planet_scale = .5
}

local wqhd = {
    ship_scale = 0.3,
    enemy_simple_scale = 1,
    asteroid_base_scale = 1,
    planet_scale = .7
}

local uhd = {
    ship_scale = 0.3,
    enemy_simple_scale = 1,
    asteroid_base_scale = 1,
    planet_scale = 1
}

scaling.get = function(value)
    local table
    
    local res = love.graphics.getWidth()
    if res >= 3840 then
        table = uhd
    elseif res >= 2560 then
        table = wqhd
    elseif res >= 1920 then
        table = fhd
    elseif res >= 1366 then
        table = thirteen_sixtysix
    else
        table = vga
    end
    
    return table[value]
end