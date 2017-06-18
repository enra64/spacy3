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
local ASTEROID_HEIGHT, ASTEROID_WIDTH
local COLUMN_SPAWN_MARGIN
local ASTEROIDS_PER_BORDER = 6
local LABYRINTH_CELLS_PER_COLUMN = 5
local CELL_HEIGHT
local DEBUG_SPAWN_ALL = false

local function update(asteroid, dx)
    -- move left on update
    local speed = 100
    asteroid.x = asteroid.x - dx * speed
    asteroid.shape:move(-dx * speed, 0)

    -- rotate on update
    asteroid.rotation = asteroid.rotation + asteroid.rotation_speed
    asteroid.shape:rotate(asteroid.rotation_speed)
end

local function get_asteroid(x, y)
    -- get some random asteroid
    local new = new_random_asteroid()

    -- set some methods
    new.update = update
    new.scale_x = math.scale_from_to(new.width, ASTEROID_WIDTH)
    new.scale_y = math.scale_from_to(new.height, ASTEROID_HEIGHT)

    -- set position
    new.x, new.y = x, y
    new.rotation, new.rotation_speed = 0, 0

    -- initialise the collision shape
    new.shape = hc.polygon(unpack(new.asteroid_collision_coordinates))
    new.shape:move(new.x - new.width / 2, new.y - new.height / 2)
    new.shape:scale(new.scale_x, new.scale_y)
    new.shape:rotate(0)
    new.shape.object_type = "asteroid"
    return new
end

local function add_asteroids(x, col, row, cell)
    local new_asteroids = {}

    -- because we don't need overlapping borders, the south wall is actually never drawn, making cells smaller
    local drawn_cell_height = CELL_HEIGHT - ASTEROID_HEIGHT

    if DEBUG_SPAWN_ALL or cell:north_blocked() then
        local x_off, y_off = x, row * drawn_cell_height + ASTEROID_HEIGHT / 2
        for i = 1, ASTEROIDS_PER_BORDER - 1 do
            table.insert(new_asteroids, get_asteroid(x_off + i * ASTEROID_WIDTH, y_off))
        end
    end
    if DEBUG_SPAWN_ALL or cell:east_blocked() then
        local x_off, y_off = x + CELL_HEIGHT - ASTEROID_WIDTH, row * drawn_cell_height + ASTEROID_HEIGHT / 2
        for i = 1, ASTEROIDS_PER_BORDER - 1 do
            table.insert(new_asteroids, get_asteroid(x_off, y_off + i * ASTEROID_HEIGHT))
        end
    end

    -- get asteroid at the specified position
    table.foreach(new_asteroids, function(asteroid, _)
        asteroid.shape.identity = "col" .. col .. "row" .. row
        asteroid.on_destroyed = function() table.remove_object(asteroid_columns[col][row], asteroid) end
        return asteroid
    end)

    -- set up the table structure this asteroid belongs to if it does not yet exists
    if not asteroid_columns[col] then asteroid_columns[col] = {} end
    if not asteroid_columns[col][row] then asteroid_columns[col][row] = {} end

    -- insert new into storage
    table.insert_multiple(asteroid_columns[col][row], new_asteroids)
    table.insert_multiple(asteroid_storage, new_asteroids)
end

local function spawn_asteroid_column(x)
    local ellers_labyrinth_column = ellers:step()

    local col = #asteroid_columns + 1
    for _, cell in ipairs(ellers_labyrinth_column) do
        -- add asteroids for this cell. position - 1 to make indices start at 1
        add_asteroids(x, col, cell.position - 1, cell)
    end
end

local function find_asteroid()
    -- go through the last column
    for i = #asteroid_columns, 1, -1 do
        -- find any row that is filled
        for _, row in pairs(asteroid_columns[i]) do
            if row and #row > 0 then
                -- find the right-most element
                local right_most = 0
                local right_most_ast
                for _, ast in ipairs(row) do
                    local _, _, right, _ = ast.shape:bbox()
                    if right_most < right then
                        right_most = right
                        right_most_ast = ast
                    end
                end

                --return 0, 0, 4000, 0
                return right_most_ast.shape:bbox()
            end
        end
    end

    return 0, 0, love.graphics.getWidth(), 0
end

local function check_column_fill()
    -- find asteroid field right

    local _, _, field_right, _ = find_asteroid()
    if field_right - ASTEROID_WIDTH / 2 < love.graphics.getWidth() then
        spawn_asteroid_column(field_right - ASTEROID_WIDTH / 2)
    end
end

local function test_ellers()
    local ellers = new_ellers_algorithm(8)

    local cols = {}

    for i = 1, 20 do
        table.insert(cols, ellers:step())
    end

    for row = 1, ellers.height do
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

    ellers = new_ellers_algorithm(LABYRINTH_CELLS_PER_COLUMN)

    CELL_HEIGHT = love.graphics.getHeight() / (LABYRINTH_CELLS_PER_COLUMN - 1)

    -- asteroids are slightly larger than cell_height/asteroids_per_border because the north_south walls are collapsed
    ASTEROID_HEIGHT = CELL_HEIGHT / (ASTEROIDS_PER_BORDER - 0)
    ASTEROID_WIDTH = ASTEROID_HEIGHT

    -- start the field
    spawn_asteroid_column(love.graphics.getWidth() + 10)
end