local is_touch = require("is_touch")()

difficulty = {}

local touch_value_dictionary = {
    ship_scale = 1.8,
    enemy_simple_scale = 1.8
}

local desktop_value_dictionary = {
    ship_scale = 1,
    enemy_simple_scale = 1
}

local common_value_dictionary = {
    player_speed = 400,
    enemy_simple_speed = {200, 250, 300, 325, 350},
    enemy_simple_score = {2, 4, 8, 16, 32},
    level_threshold = {10, 45, 150, 300, 700},
    enemy_simple_count = {3, 4, 5, 5, 6},
    asteroid_period = {4, 3, 2.8, 2.6, 2.2},
    asteroid_speed = {100, 120, 150, 180, 220},
    heat_diffuser_upgrade_costs = {100, 200, 300},
    hull_upgrade_costs = {150, 250}
}

function difficulty.get(value, level)
    assert(not level or (level > 0 and level <= 5), "invalid level value ")
    
    --- use appropriate value table
    local dict
    if not (touch_value_dictionary[value] and desktop_value_dictionary[value]) then
        dict = common_value_dictionary
    elseif is_touch then
        dict = touch_value_dictionary
    else
        dict = desktop_value_dictionary
    end
    
    --- return level value for dict if level was given
    if level and type(dict[value]) == "table" then
        return dict[value][level]
    end
    
    --- return either single (non-level-dependent) value, or table of level values
    return dict[value]
end
