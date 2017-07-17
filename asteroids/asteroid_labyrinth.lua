local _, _, new_random_asteroid, _ = unpack(require("asteroids.asteroid_asset_helper"))
local hc = require("hc")
local timer = require("hump.timer")
local get_speed = require("asteroids.labyrinth_speed_interpolator")
require("difficulty_handler")
require("drops")
require("flyapartomatic")
local lume = require("lume.lume")
local new_ellers_algorithm = require("asteroids.ellers_algorithm")

local asteroid_storage
local asteroid_columns
local asteroid_base_scale
local ellers
local ASTEROID_HEIGHT, ASTEROID_WIDTH
local COLUMN_SPAWN_MARGIN
local ASTEROIDS_PER_VERTICAL_BORDER, ASTEROIDS_PER_HORIZONTAL_BORDER = 8, 14
local LABYRINTH_CELLS_PER_COLUMN = 5 -- ellers height
local CELL_HEIGHT, CELL_WIDTH
local DEBUG_SPAWN_ALL = false
local column_fill_check_timer, start_time, time_score_divisor

local function update(asteroid, dx)
    -- move left on update
    local speed = get_speed(os.time() - start_time)
    asteroid.x = asteroid.x - dx * speed
    asteroid.shape:move(-dx * speed, 0)

    -- rotate on update
    asteroid.rotation = asteroid.rotation + asteroid.rotation_speed
    asteroid.shape:rotate(asteroid.rotation_speed)
end

local function get_asteroid_width(asteroid)
    local x1, _, x2, _ = asteroid.shape:bbox()
    return x2 - x1
end

local function get_asteroid_height(asteroid)
    local _, y1, _, y2 = asteroid.shape:bbox()
    return y2 - y1
end

local function get_asteroid(x, y, length, orientation)
    -- get some random asteroid
    local new = new_random_asteroid(length)

    -- set some methods
    new.update = update
    new.scale_x = math.scale_from_to(new.width, ASTEROID_WIDTH)
    new.scale_y = new.scale_x

    -- set position
    new.x, new.y = x, y

    -- rotate the asteroid a little
    new.rotation, new.rotation_speed = math.rad(math.random(-8, 8)), 0

    -- if horizontal rotate by 90 degrees
    if orientation == "horizontal" then
        new.rotation = new.rotation + math.rad(lume.randomchoice({ 90, -90 }))
    end

    -- initialise the collision shape
    new.shape:scale(new.scale_x, new.scale_y)
    new.shape:rotate(new.rotation)
    new.shape.object_type = "asteroid"

    if orientation == "horizontal" then
        new.x = new.x + get_asteroid_width(new) / 2
    else
        new.y = new.y + get_asteroid_height(new) / 2
    end

    new.shape:moveTo(new.x, new.y)

    return new
end

--- this table stores the possible combinations of available asteroids to reach a given length
local packing_solutions = {
    _8 = { { 1, 1, 2, 2, 2 }, { 1, 1, 2, 4 }, { 1, 1, 2, 2, 2 }, { 1, 1, 2, 4 }, { 1, 1, 3, 3 }, { 1, 2, 2, 3 }, { 1, 3, 4 }, { 1, 2, 2, 3 }, { 1, 3, 4 }, { 2, 2, 2, 2 }, { 2, 2, 4 }, { 2, 3, 3 }, { 2, 2, 4 }, { 2, 3, 3 }, { 2, 2, 4 }, { 2, 3, 3 }, { 4, 4 }, { 8 } },
    _14 = { { 1, 1, 2, 2, 2, 2, 4 }, { 1, 1, 2, 2, 2, 3, 3 }, { 1, 1, 2, 2, 4, 4 }, { 1, 1, 2, 2, 8 }, { 1, 1, 2, 2, 2, 3, 3 }, { 1, 1, 2, 2, 4, 4 }, { 1, 1, 2, 2, 8 }, { 1, 1, 2, 2, 4, 4 }, { 1, 1, 2, 2, 8 }, { 1, 1, 2, 3, 3, 4 }, { 1, 1, 2, 2, 2, 3, 3 }, { 1, 1, 2, 2, 4, 4 }, { 1, 1, 2, 2, 8 }, { 1, 1, 2, 2, 4, 4 }, { 1, 1, 2, 2, 8 }, { 1, 1, 2, 3, 3, 4 }, { 1, 1, 2, 2, 4, 4 }, { 1, 1, 2, 2, 8 }, { 1, 1, 2, 3, 3, 4 }, { 1, 1, 4, 4, 4 }, { 1, 1, 4, 8 }, { 1, 2, 2, 2, 3, 4 }, { 1, 2, 2, 3, 3, 3 }, { 1, 2, 2, 2, 3, 4 }, { 1, 2, 2, 3, 3, 3 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 2, 2, 2, 3, 4 }, { 1, 2, 2, 3, 3, 3 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 2, 2, 3, 3, 3 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 3, 3, 3, 4 }, { 1, 2, 2, 2, 3, 4 }, { 1, 2, 2, 3, 3, 3 }, { 1, 2, 2, 2, 3, 4 }, { 1, 2, 2, 3, 3, 3 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 2, 2, 2, 3, 4 }, { 1, 2, 2, 3, 3, 3 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 2, 2, 3, 3, 3 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 2, 3, 4, 4 }, { 1, 2, 3, 8 }, { 1, 3, 3, 3, 4 }, { 2, 2, 2, 2, 3, 3 }, { 2, 2, 2, 4, 4 }, { 2, 2, 2, 8 }, { 2, 2, 2, 4, 4 }, { 2, 2, 2, 8 }, { 2, 2, 3, 3, 4 }, { 2, 2, 2, 4, 4 }, { 2, 2, 2, 8 }, { 2, 2, 3, 3, 4 }, { 2, 4, 4, 4 }, { 2, 4, 8 }, { 2, 2, 2, 4, 4 }, { 2, 2, 2, 8 }, { 2, 2, 3, 3, 4 }, { 2, 4, 4, 4 }, { 2, 4, 8 }, { 2, 2, 3, 3, 4 }, { 2, 4, 4, 4 }, { 2, 4, 8 }, { 2, 4, 4, 4 }, { 2, 4, 8 }, { 3, 3, 4, 4 }, { 3, 3, 8 }, { 3, 3, 4, 4 }, { 3, 3, 8 }, { 3, 3, 4, 4 }, { 3, 3, 8 } }
}

local function get_vertical_line(x_off, y_off)
    local new_asteroids = {}
    local packing_choice = lume.shuffle(lume.randomchoice(packing_solutions["_" .. ASTEROIDS_PER_VERTICAL_BORDER]))
    for _, ast_len in ipairs(packing_choice) do
        local new_asteroid = get_asteroid(x_off, y_off, ast_len, "vertical")
        table.insert(new_asteroids, new_asteroid)
        y_off = y_off + get_asteroid_height(new_asteroid) + 2
    end
    return new_asteroids
end

local function get_horizontal_line(x_off, y_off)
    local new_asteroids = {}
    local packing_choice = lume.randomchoice(packing_solutions["_" .. ASTEROIDS_PER_HORIZONTAL_BORDER])

    for _, ast_len in ipairs(packing_choice) do
        local new_asteroid = get_asteroid(x_off, y_off, ast_len, "horizontal")
        table.insert(new_asteroids, new_asteroid)
        x_off = x_off + get_asteroid_width(new_asteroid) + 2
    end
    return new_asteroids
end

local function add_asteroids(x, col, row, cell)
    local new_asteroids = {}

    -- because we don't need overlapping borders, the south wall is actually never drawn, making cells smaller
    local drawn_cell_height = CELL_HEIGHT - ASTEROID_HEIGHT

    if DEBUG_SPAWN_ALL or cell:north_blocked() then
        table.insert_multiple(new_asteroids,
            get_horizontal_line(x + ASTEROID_WIDTH / 2, row * drawn_cell_height + ASTEROID_HEIGHT / 2))
    end
    if DEBUG_SPAWN_ALL or cell:east_blocked() then
        table.insert_multiple(new_asteroids,
            get_vertical_line(x + CELL_WIDTH - ASTEROID_WIDTH, row * drawn_cell_height + ASTEROID_HEIGHT / 2))
    end

    local cell_at_bottom = cell.position == LABYRINTH_CELLS_PER_COLUMN
    if (DEBUG_SPAWN_ALL and cell_at_bottom) or (cell:south_blocked() and cell_at_bottom) then
        table.insert_multiple(new_asteroids,
            get_horizontal_line(x + ASTEROID_WIDTH / 2, (1 + row) * drawn_cell_height + ASTEROID_HEIGHT / 2))
    end

    -- get asteroid at the specified position
    lume.map(new_asteroids, function(asteroid, _)
        asteroid.shape.identity = "spalte " .. col .. ", zeile" .. row
        asteroid.on_destroyed = function(ast)
            hc.remove(ast.shape)
            lume.remove(asteroid_storage, ast)
            lume.remove(asteroid_columns[col][row], ast)
            ast.shape.asteroid_reference = nil
        end
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

local function start(asteroid_storage_reference, asteroid_scale)
    asteroid_base_scale = asteroid_scale
    asteroid_storage = asteroid_storage_reference
    asteroid_columns = {}
    column_fill_check_timer = timer.every(0.1, check_column_fill)

    ellers = new_ellers_algorithm(LABYRINTH_CELLS_PER_COLUMN)

    -- asteroids are square (roughly...)
    local number_of_drawn_asteroids = ASTEROIDS_PER_VERTICAL_BORDER - 1
    ASTEROID_HEIGHT = love.graphics.getHeight() / (LABYRINTH_CELLS_PER_COLUMN * number_of_drawn_asteroids + 1)
    ASTEROID_WIDTH = ASTEROID_HEIGHT

    CELL_HEIGHT = ASTEROID_HEIGHT * ASTEROIDS_PER_VERTICAL_BORDER
    CELL_WIDTH = (ASTEROID_WIDTH + 2) * ASTEROIDS_PER_HORIZONTAL_BORDER

    -- start the field
    spawn_asteroid_column(love.graphics.getWidth() + 10)

    -- get score speed
    time_score_divisor = difficulty.get("labyrinth_time_score_divisor")

    -- store duration
    start_time = os.time()
end

local function stop()
    if column_fill_check_timer then
        timer.cancel(column_fill_check_timer)
    end
end

local function get_score()
    return math.floor((os.time() - start_time) / time_score_divisor)
end

-- init function
return { start = start, stop = stop, get_score = get_score }