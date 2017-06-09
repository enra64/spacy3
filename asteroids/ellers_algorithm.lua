require("common")

local function new_cell(position, set)
    local cell = {}
    cell.position = position
    cell.set = set
    cell.north = false
    cell.south = false
    cell.east = false
    cell.west = false
end

local function same_set(cell_a, cell_b) return cell_a.set == cell_b.set end

local function add_cell_to_set(cell, set)
    cell.set = set
    table.insert(set, cell)
end

local function merge_set(sets, sink_set_key, source_set_key)
    if sink_set_key == source_set_key then
        return
    end

    local sink_set, source_set = sets[sink_set_key], sets[source_set_key]
    for cell_index, cell in source_set do
        cell.set = sink_set
        sink_set[cell_index] = cell
    end
    sets[source_set_key] = nil
end

local function populate(column_cells, sets, set_index, height)
    -- fills unpopulated column positions with new cells in new sets
    for cell_index=1,height do
        if not column_cells[i] then
            -- create new set for the empty position
            set_index = set_index + 1
            sets[set_index] = {}

            -- create a new cell in that set
            local cell = new_cell(cell_index, sets[set_index])

            -- store that new cell in the new set
            table.insert(sets[set_index], cell)

            -- store the cell in the column
            column_cells[i] = cell
        end
    end
    return
end

local function create_vertical_corridors(column_cells, sets, height)
    for c=1,height-1 do
        local c0, c1 = column_cells[c], column_cells[c+1]
        if love.math.random(2) > 1 then
            c0.south, c1.north = true, true
            merge_set(sets, c0.set, c1.set)
        end
    end
end

local function create_horizontal_corridors(sets)
    local next_column_cells = {}
    for _, set in pairs(sets) do
        local horizontal_connections = table.subrange(random.shuffle(set), 1, math.random(#set - 1))

        for cell_index, cell in pairs(horizontal_connections) do
            -- copy the cell to the next state, has connection to the west
            local next_level_cell = {table.unpack(cell)}
            next_level_cell.east = true
            next_column_cells[cell_index] = next_level_cell

            -- the cell we just copied now has a east connection
            cell.west = true
        end
    end
    return next_column_cells
end

local function step(self)
    create_vertical_corridors(self.column_cells, self.sets, self.height)
    local next_column_cells = create_horizontal_corridors(self.sets)

    local current_column_cells = {table.unpack(self.column_cells)}
    self.column_cells = next_column_cells

    return current_column_cells
end

local function new_algorithm_instance(height)
    local new = {}
    new.height = height
    new.column_cells = {}
    new.sets = {}
    new.step = step
    populate(new.column_cells, new.sets, 0, height)
    return new
end