lume = require("lume.lume")
require("random")
local font_config = require("font_config")

--- remove annoying 0 parameter in draw calls
NO_ROTATION = 0


function function_location()
    --- return name and location of the calling function
    local w = debug.getinfo(2, "S")
    return w.short_src .. ":" .. w.linedefined
end

function dofile(file)
    --- overwrite luas "dofile" to work on android
    return love.filesystem.load(file)()
end

function bbox_width(shape)
    local x1, _, x2, _ = shape:bbox()
    return x2 - x1
end

function bbox_height(shape)
    local _, y1, _, y2 = shape:bbox()
    return y2 - y1
end

function polygon_contains(self, other)
    -- for convex polygons we can just check if all points are contained
    --if self._polygon:isConvex() and other._polygon:isConvex() then
    for _, foreign_vertex in ipairs(other._polygon.vertices) do
        if not self:contains(foreign_vertex.x, foreign_vertex.y) then
            return false
        end
    end
    return true
    --end
end

function table.truncate(tbl, count)
    --- reduce number of items in tbl to count
    for i = 1, #tbl - count do
        table.remove(tbl, #tbl)
    end
    return tbl
end

function table.set_default_function(tbl, def_function)
    local mt = { __index = def_function }
    setmetatable(tbl, mt)
end


--- return 0 if the absolute value of val is below epsilon, and val otherwise
function math.apply_epsilon(val, epsilon)
    if math.abs(val) < epsilon then
        return 0
    end
    return val
end

function table.insert_multiple(tbl_sink, tbl_source)
    lume.push(tbl_sink, unpack(tbl_source))
end

function table.twolevel_clone(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- like lume.each, but in reverse order to allow deletion
function table.reach(t, fn, ...)
    for _, v in lume.ripairs(t) do
        if type(fn) == "string" then
            v[fn](v, ...)
        else
            fn(v, ...)
        end
    end
end

function table.multeach(tbl, factor)
    return lume.map(tbl, function(val) return val * factor end)
end

function table.subrange(t, first, last)
    local sub = {}
    for i = first, last do
        sub[#sub + 1] = t[i]
    end
    return sub
end

function table.each_if(t, fn, condition, ...)
    local iter = ipairs
    if type(fn) == "string" then
        for _, v in iter(t) do if condition(v) then v[fn](v, ...) end end
    else
        for _, v in iter(t) do if condition(v) then fn(v, ...) end end
    end
    return t
end


--- for the given text, max width and maximum height, return a reducing scale if necessary
function string.get_wrapping_scale(text, wraplimit, max_height)
    local _, wrapped_lines = love.graphics.getFont():getWrap(text, wraplimit)
    local resulting_length = #wrapped_lines * love.graphics.getFont():getHeight()
    if resulting_length > max_height then
        return math.scale_from_to(resulting_length, max_height)
    end
    return 1
end

--- this function estimates a fitting print size for fonts
function love.graphics.printf_fitting(text, xpos, ypos, max_width, max_height, alignment)
    local required_factor = string.get_wrapping_scale(text, max_width, max_height)

    if required_factor < 1 then
        required_factor = required_factor * 1.5
    end

    local old_font, old_font_size = font_config.get_current_font()
    local modified_font = font_config.get_font_by_size(math.floor(old_font_size * required_factor))

    love.graphics.setFont(modified_font)
    love.graphics.printf(text, xpos, ypos, max_width, alignment)
    love.graphics.setFont(old_font)
end

--- return a biased random value
--- min: minimum returned value, defaults to 1
--- max: maximum returned value, required
--- bias_toward_low_values: (in range (0, inf)) the higher this value is, the more probable it is that a low value will
--- be returned
function math.random_biased(min, max, bias_toward_low_values)
    -- imitate an overload for elapsing "min"
    if not bias_toward_low_values then
        bias_toward_low_values = max
        max = min
        min = 1
    end

    return math.floor(min + (max - min) * math.random() ^ bias_toward_low_values)
end

-- Convert from CSV string to table (converts a single line of a CSV file)
-- from http://lua-users.org/wiki/CsvUtils
function read_csv(path)
    local s, _ = love.filesystem.read(path)
    s = s .. ',' -- ending comma
    local t = {} -- table to collect fields
    local fieldstart = 1
    repeat
        local nexti = string.find(s, ',', fieldstart)
        table.insert(t, tonumber(string.sub(s, fieldstart, nexti - 1)))
        fieldstart = nexti + 1
    until fieldstart > string.len(s)
    return t
end

--http://stackoverflow.com/a/15706820
function spairs(t, order)
    --- ordered iteration through a table
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a, b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

-- https://coronalabs.com/blog/2014/09/02/tutorial-printing-table-contents/
function print_table(t)
    local print_r_cache = {}
    local function sub_print_r(t, indent)
        if (print_r_cache[tostring(t)]) then
            print(indent .. "*" .. tostring(t))
        else
            print_r_cache[tostring(t)] = true
            if (type(t) == "table") then
                for pos, val in pairs(t) do
                    if (type(val) == "table") then
                        print(indent .. "[" .. pos .. "] => " .. tostring(val) .. " {")
                        sub_print_r(val, indent .. string.rep(" ", string.len(pos) + 8))
                        print(indent .. string.rep(" ", string.len(pos) + 6) .. "}")
                    elseif (type(val) == "string") then
                        print(indent .. "[" .. pos .. '] => "' .. val .. '"')
                    else
                        print(indent .. "[" .. pos .. "] => " .. tostring(val))
                    end
                end
            else
                print(indent .. tostring(t))
            end
        end
    end

    if (type(t) == "table") then
        print(tostring(t) .. " {")
        sub_print_r(t, "  ")
        print("}")
    else
        sub_print_r(t, "  ")
    end
    print()
end

-- see https://github.com/rxi/lume#lumelerpa-b-amount
--- takes in a, its min and max, and returns the scaled and normalized a.
function math.normalize(a, min, max)
    return (a - min) / (max - min)
end

--http://stackoverflow.com/a/7615129
function string.split(inputstr, sep)
    assert(sep)
    local t = {}; i = 1
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

function math.clamp(val, lower, upper)
    return lume.clamp(val, lower, upper)
end

function math.scale_from_to(from, to)
    return to / from
end