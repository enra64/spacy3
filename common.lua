require("lume.lume")
require("random")

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

function table.truncate(tbl, count)
    --- reduce number of items in tbl to count
    for i=1,#tbl - count do
        table.remove(tbl, #tbl)
    end
    return tbl
end

function table.multeach(tbl, factor)
    return table.foreach(tbl, function(key) return key * factor end)
end

function table.subrange(t, first, last)
    local sub = {}
    for i=first,last do
        sub[#sub + 1] = t[i]
    end
    return sub
end

function table.foreach(tbl, func)
    --- replace each value in tbl with the return value of func(value, key)
    for k, v in pairs(tbl) do
        tbl[k] = func(v, k)
    end
    return tbl
end

function ipairs_if(tbl, if_fn)
    local i = 0
    return function()
        i = i + 1
        if i < #tbl and if_fn(tbl[i]) then return tbl[i] end
    end
end

--http://stackoverflow.com/a/15706820
function spairs(t, order)
    --- ordered iteration through a table
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
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
function print_table( t )  
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(t).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

--http://stackoverflow.com/a/7615129
function string.split(inputstr, sep)
        assert(sep)
        local t={} ; i=1
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                t[i] = str
                i = i + 1
        end
        return t
end

function math.clamp(val, lower, upper)
    assert(val and lower and upper, "missing argument for math.clamp")
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

function math.scale_from_to(from, to)
    return to / from
end