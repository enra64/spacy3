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
local asteroid_height, asteroid_width

local function update(asteroid, dx)
    asteroid.x = asteroid.x + dx

    --asteroid.rotation = asteroid.rotation + asteroid.rotation_speed
    --asteroid.shape:rotate(asteroid.rotation_speed)
end

local function add_asteroid(col, row, x, y_off)
    -- get some random asteroid
    local new = new_random_asteroid()

    -- set some methods
    new.update = update
    new.scale_x = math.scale_from_to(new.width, asteroid_width)
    new.scale_y = math.scale_from_to(new.height, asteroid_height)

    -- set position
    new.x, new.y = x, (row - 1) * asteroid_height + y_off

    -- initialise the collision shape
    new.shape = hc.polygon(unpack(new.asteroid_collision_coordinates))
    new.shape:move(new.x - new.width / 2, new.y - new.height / 2)
    new.shape:scale(new.scale_x, new.scale_y)
    new.shape.object_type = "asteroid"

    new.on_destroyed = function() table.remove_object(asteroid_columns[col][row], new) end

    if not asteroid_columns[col] then asteroid_columns[col] = {} end
    if not asteroid_columns[col][row] then asteroid_columns[col][row] = {} end

    table.insert(asteroid_columns[col][row], new)
    table.insert(asteroid_storage, new)
end

local function spawn_asteroid_column(x)
    local col = ellers:step()

    for _, cell in ipairs(col) do
        if cell:north_west_blocked() then add_asteroid(#asteroid_columns, cell.position, x, 0) end
        if cell:west_blocked() then add_asteroid(#asteroid_columns, cell.position, x, asteroid_height) end
        if cell:south_west_blocked() then add_asteroid(#asteroid_columns, cell.position, x, asteroid_height * 2) end

        if cell:north_blocked() then add_asteroid(#asteroid_columns, cell.position, x + asteroid_width, 0) end
        if cell:is_fully_blocked() then add_asteroid(#asteroid_columns, cell.position, x + asteroid_width, asteroid_height) end
        if cell:south_blocked() then add_asteroid(#asteroid_columns, cell.position, x + asteroid_width, asteroid_height * 2) end

        if cell:north_east_blocked() then add_asteroid(#asteroid_columns, cell.position, x + asteroid_width, 0) end
        if cell:east_blocked() then add_asteroid(#asteroid_columns, cell.position, x + asteroid_width, asteroid_height) end
        if cell:south_east_blocked() then add_asteroid(#asteroid_columns, cell.position, x + asteroid_width, asteroid_height * 2) end
    end
end

local function find_asteroid()
    local col = asteroid_columns[#asteroid_columns]
    for _, row in ipairs(col) do
        if row and #row > 0 then
            return row[1].shape:bbox()
        end
    end

    return 0, 0, love.graphics.getWidth(), 0
end

local function check_column_fill()
    -- find asteroid field right

    local _, _, field_right, _ = find_asteroid()

    if field_right < love.graphics.getWidth() + asteroid_width then
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
    asteroid_columns = {}
    timer.every(0.1, check_column_fill)

    local HEIGHT = 5
    ellers = new_ellers_algorithm(HEIGHT)
    asteroid_height = love.graphics.getHeight() / (HEIGHT * 3)
    asteroid_width = asteroid_height

    -- start the field
    spawn_asteroid_column(love.graphics.getWidth())
end