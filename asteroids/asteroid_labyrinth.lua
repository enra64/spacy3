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
    local ellers = new_ellers_algorithm(8)

    local cols = {}

    for i=1,20 do
        table.insert(cols, ellers:step())
    end

    for row=1,ellers.height do
        for column, _ in ipairs(cols) do
            local cell = cols[column][row]
            if cell.north then
                io.write("   ")
            else
                io.write("___")
            end
        end

        print()

        for column, _ in ipairs(cols) do
            local cell = cols[column][row]
            if cell.west == true then
                io.write(" ")
            else
                io.write("W")
            end

            if cell.south then
                io.write(" ")
            else
                io.write("_")
            end

            if cell.east then
                io.write(" ")
            else
                io.write("E")
            end
        end
        print()
    end
end