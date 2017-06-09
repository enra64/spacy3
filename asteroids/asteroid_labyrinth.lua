local _, get_asteroid_fragments, new_random_asteroid, is_in_viewport = unpack(require("asteroids.asteroid_asset_helper"))
local hc = require("hc")
local timer = require("hump.timer")
require("difficulty_handler")
require("drops")
require("flyapartomatic")
local new_ellers_algorithm = require("asteroids.ellers_algorithm")

local asteroid_storage
local asteroid_base_scale

local function update(asteroid, dx)
    asteroid.x = asteroid.x + dx

    --asteroid.rotation = asteroid.rotation + asteroid.rotation_speed
    --asteroid.shape:rotate(asteroid.rotation_speed)
end

local function get_asteroid()
    -- get some random asteroid
    local new = new_random_asteroid()

    -- set update routine
    new.update = update

    -- function to check for viewport
    new.is_in_viewport = is_in_viewport

    -- positioning, movement


    return new
end

local function check_column_fill()

end

-- init function
return function(asteroid_storage_reference, asteroid_scale)
    asteroid_base_scale = asteroid_scale
    asteroid_storage = asteroid_storage_reference
--    timer.every(0.1, check_column_fill)
    local ellers = new_ellers_algorithm(5)
    ellers:print_debug_column()

    for i=1,10 do
        ellers:step()
        print("step "..i)
        ellers:print_debug_column()
    end
end