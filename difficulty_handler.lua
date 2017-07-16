local is_touch = require("is_touch")()

difficulty = {}

local touch_value_dictionary = {
}

local desktop_value_dictionary = {
}

local common_value_dictionary = {
    enemy_simple_score = {2, 4, 8, 16, 32, 48, 64},
    level_threshold = {10, 45, 150, 300, 700, 1200, 1500},
    enemy_simple_count = {3, 4, 5, 5, 6, 7, 8},
    asteroid_period = {4, 3, 2.8, 2.6, 2.2, 2, 1.8},
    heat_diffuser_upgrade_costs = {100, 400, 800},
    hull_upgrade_costs = {350, 500, 1000},
    heat_diffuser_resulting_speeds = {0.3, 0.4, 0.5},
    player_start_money = 0,
    asteroid_drop_credits = 40,
    health_player_ship_upgrade_0 = 1,
    health_player_ship_upgrade_1 = 2,
    health_player_ship_upgrade_2 = 3,
    labyrinth_scroll_speed = {30, 40, 50, 60, 80, 100, 130, 160, 200, 240, 300, 350, 400, 470, 550, 600} -- gl hf
}

function difficulty.get_enemy_speed(enemy_type, current_level)
    return difficulty.get("enemy_"..enemy_type.."_speed")[current_level]
end

function difficulty.level_count()
    return #common_value_dictionary.level_threshold
end

function difficulty.get(value, level)
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
    
    if dict[value] == nil then
        print(value.." not found in difficulty_handler.lua!")
    end
    
    --- return either single (non-level-dependent) value, or table of level values
    return dict[value]
end
