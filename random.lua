local functions = {}

-- boxmuller.c           Implements the Polar form of the Box-Muller
--Transformation

--(c) Copyright 1994, Everett F. Carter Jr.
--Permission is granted by the author to use
--this software for any application provided this
--copyright notice is preserved.

local bm_use_last = {}
local bm_y2 = {}

local function box_muller(mean, standard_derivation, bm_use_index)
    local x1, x2, w, y1

    --- use value from previous call
    if (bm_use_last[bm_use_index]) then
        y1 = bm_y2[bm_use_index]
        bm_use_last[bm_use_index] = false
    else
        repeat
            x1 = 2.0 * math.random() - 1.0
            x2 = 2.0 * math.random() - 1.0
            w = x1 * x1 + x2 * x2
        until (w < 1)

        w = math.sqrt((-2.0 * math.log(w)) / w)
        y1 = x1 * w
        bm_y2[bm_use_index] = x2 * w
        bm_use_last[bm_use_index] = true
    end
    return mean + y1 * standard_derivation
end
functions.box_muller = box_muller

local function shuffle(array)
    -- fisher-yates
    local output = {}
    local random = math.random

    for index = 1, #array do
        local offset = index - 1
        local value = array[index]
        local randomIndex = offset * random()
        local flooredIndex = randomIndex - randomIndex % 1

        if flooredIndex == offset then
            output[#output + 1] = value
        else
            output[#output + 1] = output[flooredIndex + 1]
            output[flooredIndex + 1] = value
        end
    end

    return output
end
functions.shuffle = shuffle

random = {}
function random.choose(tbl)
    return tbl[math.random(#tbl)]
end

return functions