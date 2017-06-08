-- created by arne using intellij.
-- props to http://weblog.jamisbuck.org/2010/12/29/maze-generation-eller-s-algorithm for ellers algorithm
local HEIGHT

local function connected(self, cell_a, cell_b)
    return self.cells[cell_a] == self.cells[cell_b]
end

local function add_cell(self, cell, set)
    self.cells[cell] = set
    table.insert(self.sets[set], cell)
end

local function merge(self, sink, target)
    local sink_set, target_set = self.sets[sink], self.sets[target]

    -- concat target to sink
    for k, v in pairs(target) do sink[k] = v end
    for _, cell in pairs(self.sets[target_set]) do self.cells[cell] = sink_set end
    self.sets[target_set] = nil
end

local function randomly_connect_adjacent_cells(self)
    local connected_sets = {}
    local connected_set = {0}

    for c=1,height do
        if self:connected(c, c+1) or math.random(2) > 0 then
            table.insert(connected_sets, connected_set)
            connected_set = {c + 1}
        else
            self:merge(c, c+1)
            table.insert(connected_sets, c + 1)
        end
    end
end

local function overwrite_with(source, target)
    target.sets = source.sets
    target.cells = source.cells
end

local function step(self)
    self:randomly_connect_adjacent_cells()
    self:overwrite_with(self:random_horizontal_connections())
end

local function new(height)
    HEIGHT = HEIGHT or height

    local new = {}
    new.sets = {}
    new.cells = {}
    new.height = HEIGHT

    new.step = step
    new.merge = merge
    new.add_cell = add_cell
    new.connected = connected
    new.overwrite_with = overwrite_with
    new.randomly_connect_adjacent_cells = randomly_connect_adjacent_cells

    new.random_horizontal_connections = function(self)
        local horizontals = {}
        local next_state = new()

        for set in self.sets do
            local cells_to_connect = random.shuffle(set)
            self:merge(horizontals, cells_to_connect)
            for cell in cells_to_connect do
                next_state:add_cell(cell, set)
            end
        end

        return next_state
    end

    return new
end



