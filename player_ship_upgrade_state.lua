require("difficulty_handler")

player_ship_upgrade_state = {}

local default_state = {
    heat_diffuser = 1,
    ship_hull = 1
}

local state_maximum = {
    heat_diffuser = 1,
    ship_hull = 1
}

player_ship_upgrade_state.init = function()
    player_ship_upgrade_state.state = default_state
    player_ship_upgrade_state.credits = 0
end

player_ship_upgrade_state.increase_credits = function(amount)
    player_ship_upgrade_state.credits = player_ship_upgrade_state.credits + amount
end

player_ship_upgrade_state.upgrade = function(part_to_upgrade)
    local price = player_ship_upgrade_state.get_price(part_to_upgrade)
    if player_ship_upgrade_state.credits >= price then
        player_ship_upgrade_state.state[part_to_upgrade] = math.clamp(
            player_ship_upgrade_state.state[part_to_upgrade],
            1,
            state_maximum[part_to_upgrade])
        player_ship_upgrade_state.credits = player_ship_upgrade_state.credits - price
        return true
    end
    return false
end

player_ship_upgrade_state.get_state = function(part)
    return player_ship_upgrade_state.state[part_to_upgrade]
end

player_ship_upgrade_state.get_price = function(part)
    local price_table, current_state
    if part == "heat_diffuser" then
        price_table = difficulty.get("heat_diffuser_upgrade_costs")
        current_state = player_ship_upgrade_state.get_state("heat_diffuser")
    elseif part == "ship_hull" then
        price_table = difficulty.get("hull_upgrade_costs")
        current_state = player_ship_upgrade_state.get_state("ship_hull")
    end
    return price_table[current_state]
end