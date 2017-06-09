require("common")

local function new_cell(position, set)
    local cell = {}
    cell.position = position
    cell.set = set
    cell.north = false
    cell.south = false
    cell.east = false
    cell.west = false
    return cell
end

local function merge_set(sets, sink_set, source_set)
    for cell_index, cell in pairs(source_set) do
        cell.set = sink_set
        sink_set[cell_index] = cell
    end

    source_set = {}
end

local function populate(column_cells, sets, set_index, height)
    -- fills unpopulated column positions with new cells in new sets
    for cell_index=1,height do
        if not column_cells[cell_index] then
            -- create new set for the empty position
            set_index = set_index + 1
            sets[set_index] = {}

            -- create a new cell in that set
            local cell = new_cell(cell_index, sets[set_index])

            -- store that new cell in the new set
            table.insert(sets[set_index], cell)

            -- store the cell in the column
            column_cells[cell_index] = cell
        end
    end
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
            local next_level_cell = table.twolevel_clone(cell)
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

    local current_column_cells = table.twolevel_clone(self.column_cells)
    self.column_cells = next_column_cells

    populate(self.column_cells, self.sets, self.set_index, self.height)

    return current_column_cells
end

local function print_debug_column(self)
    for _, c in pairs(self.column_cells) do
        if c.north then
            print(" ")
        else
            print(" _")
        end

        if c.west then
            io.write(" ")
        else
            io.write("|")
        end

        if c.south then
            io.write(" ")
        else
            io.write("_")
        end

        if c.east then
            print(" ")
        else
            print("|")
        end


    end
end

return function(height)
    assert(height, "height needed for ellers algorithm")

    local new = {}
    new.height = height
    new.column_cells = {}
    new.sets = {}
    new.set_index = 0
    new.step = step
    new.print_debug_column = print_debug_column
    populate(new.column_cells, new.sets, new.set_index, new.height)
    return new
end