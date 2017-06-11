require("common")

local function is_fully_blocked(cell) return not (cell.north or cell.south or cell.east or cell.west) end

local function north_west(cell) return not (cell.north or cell.west) end

local function north_east(cell) return not (cell.north or cell.east) end

local function south_west(cell) return not (cell.south or cell.west) end

local function south_east(cell) return not (cell.south or cell.east) end

local function new_cell(position, set, set_index)
    local cell = {}
    cell.position = position
    cell.set = set
    cell.north = false
    cell.south = false
    cell.east = false
    cell.west = false
    cell.set_index = set_index

    -- helper functions for getting cell information
    cell.is_fully_blocked = is_fully_blocked
    cell.north_west_blocked = north_west
    cell.north_east_blocked = north_east
    cell.south_west_blocked = south_west
    cell.south_east_blocked = south_east
    cell.north_blocked = function(cell) return not cell.north end
    cell.south_blocked = function(cell) return not cell.south end
    cell.east_blocked = function(cell) return not cell.east end
    cell.west_blocked = function(cell) return not cell.west end
    cell.blocked_tests = {
        cell.is_fully_blocked,
        cell.north_west_blocked,
        cell.north_east_blocked,
        cell.south_west_blocked,
        cell.south_east_blocked,
        cell.north_blocked,
        cell.south_blocked,
        cell.east_blocked,
        cell.west_blocked
    }
    return cell
end

local function merge_set(sets, sink_set_index, source_set_index)
    if sink_set_index == source_set_index then return end
    for _, cell in pairs(sets[source_set_index]) do
        cell.set = sets[sink_set_index]
        cell.set_index = sink_set_index
        table.insert(sets[sink_set_index], cell)
    end

    sets[source_set_index] = nil
end

local function populate(column_cells, sets, set_index, height)
    --print("sets before populating")print_table(sets)
    -- fills unpopulated column positions with new cells in new sets
    for cell_index = 1, height do
        if not column_cells[cell_index] then
            -- create new set for the empty position
            set_index = set_index + 1
            sets[set_index] = {}

            -- create a new cell in that set
            local cell = new_cell(cell_index, sets[set_index], set_index)

            -- set connections
            if cell_index == 1 or cell_index == 1 then
                if cell_index == 1 then
                    cell.north = false
                elseif cell_index == height then
                    cell.south = false
                end
            else
                if column_cells[cell_index - 1].south then
                    cell.north = true
                end

                if column_cells[cell_index + 1] and column_cells[cell_index + 1].north then
                    cell.south = true
                end
            end

            -- store that new cell in the new set
            table.insert(sets[set_index], cell)

            -- store the cell in the column
            column_cells[cell_index] = cell
        end
    end

    --print("sets after populating")print_table(sets)

    return set_index
end

local function create_vertical_corridors(column_cells, sets, height)
    --print("sets before vertical corridors")print_table(sets)

    for c = 1, height - 1 do
        local c0, c1 = column_cells[c], column_cells[c + 1]
        if love.math.random() > .6 then
            c0.south, c1.north = true, true
            merge_set(sets, c0.set_index, c1.set_index)
        end
    end

    --print("sets after vertical corridors")print_table(sets)
end

local function create_horizontal_corridors(sets)
    local next_column_cells = {}
    local next_column_sets = {}
    --print("sets before horizontal corridors")print_table(sets)
    for set_index, set in pairs(sets) do
        local connection_count = math.random(#set - 1)
        local shuffled = random.shuffle(set)
        local horizontal_connections = table.subrange(shuffled, 1, connection_count)

        for _, cell in pairs(horizontal_connections) do
            -- copy the cell to the next state
            local next_level_cell = table.twolevel_clone(cell)
            next_level_cell.west = true -- the new cell has a west connection
            cell.east = true -- the cell we just copied now has a east connection
            next_column_cells[cell.position] = next_level_cell

            --print("hor con at "..cell.position)
            --print("clc")print_table(cell)print("nlc")print_table(next_level_cell)

            -- add the set to the set of sets in the next column
            if next_column_sets[cell.set_index] then
                table.insert(next_column_sets[cell.set_index], next_level_cell)
            else
                next_column_sets[cell.set_index] = { next_level_cell }
            end
        end
    end

    --print("sets after horizontal corridors (current column set)")print_table(sets)
    --print("sets after horizontal corridors (next column set)")print_table(next_column_sets)

    return next_column_cells, next_column_sets
end

local function step(self)
    -- work the current column
    create_vertical_corridors(self.column_cells, self.sets, self.height)
    local next_column_cells, next_column_sets = create_horizontal_corridors(self.sets)

    -- copy state info
    self.sets = next_column_sets
    local current_column_cells = table.twolevel_clone(self.column_cells)
    self.column_cells = next_column_cells

    -- fill in missing positions in next column
    self.set_index = populate(self.column_cells, self.sets, self.set_index, self.height)

    -- return current column cells
    return current_column_cells
end

local function debug_print_cell(self, cell)
    if cell.north then
        print(" ")
    else
        print(" _")
    end

    if cell.west then
        io.write(" ")
    else
        io.write("|")
    end

    if cell.south then
        io.write(" ")
    else
        io.write("_")
    end

    if cell.east then
        print(" ")
    else
        print("|")
    end
end

local function print_debug_column(self)
    for _, c in pairs(self.column_cells) do
        self:debug_print_cell(c)
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

    new.debug_print_cell = debug_print_cell
    new.print_debug_column = print_debug_column

    new.set_index = populate(new.column_cells, new.sets, new.set_index, new.height)

    return new
end