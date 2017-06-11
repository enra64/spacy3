local _, get_asteroid_fragments, new_random_asteroid, is_in_viewport = unpack(require("asteroids.asteroid_asset_helper"))
local hc = require("hc")
local timer = require("hump.timer")
require("difficulty_handler")
require("drops")
require("flyapartomatic")
local new_ellers_algorithm = require("asteroids.ellers_algorithm")

local asteroid_storage
local asteroid_columns
local asteroid_base_scale
local ellers

local function update(asteroid, dx)
    asteroid.x = asteroid.x + dx

    --asteroid.rotation = asteroid.rotation + asteroid.rotation_speed
    --asteroid.shape:rotate(asteroid.rotation_speed)
end

local function get_asteroid(col, row, x, y)
    -- get some random asteroid
    local new = new_random_asteroid()

    -- set some methods
    new.update = update
    new.scale = asteroid_base_scale

    -- set position
    new.x, new.y = x, y

    -- initialise the collision shape
    new.shape = hc.polygon(unpack(new.asteroid_collision_coordinates))
    new.shape:move(new.x - new.width / 2, new.y - new.height / 2)
    new.shape:scale(new.scale)
    new.shape.object_type = "asteroid"

    new.on_destroyed = function() asteroid_columns[col][row] = nil end

    asteroid_columns[col][row] = new
    table.insert(asteroid_storage, new)

    return new.shape:bbox()
end

local function spawn_asteroid_column(x_start)
    local col = ellers:step()

    for _, cell in ipairs(col) do
        if cell.north_west_blocked() then
            add_asteroid(#asteroid_columns, cell.position, x_start)
    end
end

local function check_column_fill()
    -- find asteroid field right
    local _, _, field_right, _ = asteroid_columns[#asteroid_columns].shape:bbox()

    if field_right < love.graphics.getWidth() + 100 then
        spawn_asteroid_column(field_right)
    end
end

local function test_ellers()
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

-- init function
return function(asteroid_storage_reference, asteroid_scale)
    asteroid_base_scale = asteroid_scale
    asteroid_storage = asteroid_storage_reference
    timer.every(0.1, check_column_fill)
    ellers = new_ellers_algorithm(5)
end