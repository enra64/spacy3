scaling = {}

function table.multeach(tbl, factor)
    return lume.map(tbl, function(val) return val * factor end)
end

scaling.gamemode = "endless game" -- one of "endless game" or "asteroid rush"

local labyrinth_override_factors = {
    ship_scale = 0.6,
    drop_scale = 0.6,
    asteroid_fragment_scale = 0.25,
    explosion_base_scale = 0.7
}

local vga = {
    ship_scale = 0.20,
    enemy_simple_scale = .8,
    explosion_base_scale = 80,
    asteroid_base_scale = .4,
    missile_scale = .4,
    laser_scale = .4,
    asteroid_fragment_scale = 1,
    ship_fragment_scale = 0.5,
    planet_scale = .3,
    drop_scale = .15,
    fonts_ingame = 35,
    fonts_menu_title = 45,
    fonts_menu = 30,
    labyrinth_cells_per_column = 4,
    fonts_store_description = 17,
    fonts_store_title = 22,
    fonts_splash_main_text = 70,
    fonts_splash_sub_text = 40,
    speed_player_ship_upgrade_0 = 300,
    speed_player_ship_upgrade_1 = 350,
    speed_player_ship_upgrade_2 = 400,
    enemy_simple_speed = table.multeach({ 200, 250, 300, 325, 350, 375, 500 }, 0.7),
    asteroid_speed = table.multeach({ 100, 120, 150, 180, 220, 250, 300 }, 0.7)
}

local thirteen_sixtysix = {
    ship_scale = 0.28,
    enemy_simple_scale = 1,
    explosion_base_scale = 80,
    asteroid_base_scale = 0.7,
    missile_scale = .6,
    laser_scale = .6,
    asteroid_fragment_scale = 4,
    ship_fragment_scale = 1,
    planet_scale = .45,
    drop_scale = .3,
    fonts_ingame = 40,
    fonts_menu_title = 60,
    fonts_menu = 40,
    labyrinth_cells_per_column = 5,
    fonts_store_description = 25,
    fonts_store_title = 50,
    fonts_splash_main_text = 120,
    fonts_splash_sub_text = 60,
    speed_player_ship_upgrade_0 = 400,
    speed_player_ship_upgrade_1 = 450,
    speed_player_ship_upgrade_2 = 500,
    enemy_simple_speed = table.multeach({ 200, 250, 300, 325, 350, 375, 500 }, 1),
    asteroid_speed = table.multeach({ 100, 120, 150, 180, 220, 250, 300 }, 1)
}

local fhd = {
    ship_scale = 0.4,
    enemy_simple_scale = 1.7,
    explosion_base_scale = 80,
    asteroid_base_scale = 0.8,
    missile_scale = .6,
    laser_scale = .6,
    asteroid_fragment_scale = 4,
    ship_fragment_scale = 1.3,
    planet_scale = .65,
    drop_scale = .3,
    fonts_ingame = 60,
    fonts_menu_title = 90,
    fonts_menu = 60,
    labyrinth_cells_per_column = 5,
    fonts_store_description = 50,
    fonts_store_title = 70,
    fonts_splash_main_text = 200,
    fonts_splash_sub_text = 60,
    speed_player_ship_upgrade_0 = 600,
    speed_player_ship_upgrade_1 = 650,
    speed_player_ship_upgrade_2 = 700,
    enemy_simple_speed = table.multeach({ 200, 250, 300, 325, 350, 375, 500 }, 1.2),
    asteroid_speed = table.multeach({ 100, 120, 150, 180, 220, 250, 300 }, 1.2)
}

local wqhd = {
    ship_scale = 0.4,
    enemy_simple_scale = 1.4,
    explosion_base_scale = 80,
    asteroid_base_scale = 0.7,
    missile_scale = .7,
    laser_scale = 1,
    asteroid_fragment_scale = 4,
    ship_fragment_scale = 1,
    planet_scale = .8,
    drop_scale = .3,
    fonts_ingame = 60,
    labyrinth_cells_per_column = 7,
    fonts_menu_title = 120,
    fonts_menu = 80,
    fonts_store_description = 40,
    fonts_store_title = 50,
    fonts_splash_main_text = 160,
    fonts_splash_sub_text = 120,
    speed_player_ship_upgrade_0 = 550,
    speed_player_ship_upgrade_1 = 600,
    speed_player_ship_upgrade_2 = 650,
    enemy_simple_speed = table.multeach({ 200, 250, 300, 325, 350, 375, 500 }, 1.5),
    asteroid_speed = table.multeach({ 100, 120, 150, 180, 220, 250, 300 }, 1.5)
}

local uhd = {
    ship_scale = 0.45,
    enemy_simple_scale = 1.9,
    explosion_base_scale = 90,
    asteroid_base_scale = 1.1,
    missile_scale = 1,
    laser_scale = 1.1,
    asteroid_fragment_scale = 4,
    ship_fragment_scale = 1,
    planet_scale = 1,
    drop_scale = .45,
    fonts_ingame = 70,
    labyrinth_cells_per_column = 7,
    fonts_menu_title = 150,
    fonts_menu = 120,
    fonts_store_description = 60,
    fonts_store_title = 80,
    fonts_splash_main_text = 200,
    fonts_splash_sub_text = 160,
    speed_player_ship_upgrade_0 = 600,
    speed_player_ship_upgrade_1 = 650,
    speed_player_ship_upgrade_2 = 700,
    enemy_simple_speed = table.multeach({ 225, 275, 300, 325, 350, 375, 500 }, 1.5),
    asteroid_speed = table.multeach({ 100, 120, 150, 180, 220, 250, 300 }, 1.5)
}

scaling.get = function(value)
    local table

    -- get gamemode override factor
    local gamemode_override_factor
    if scaling.gamemode == "asteroid rush" then
        for key, override_factor in pairs(labyrinth_override_factors) do
            if key == value then
                gamemode_override_factor = override_factor
            end
        end
    end

    local res = love.graphics.getWidth()
    if res >= 3840 then
        table = uhd
    elseif res >= 2560 then
        table = wqhd
    elseif res >= 1920 then
        table = fhd
    elseif res >= 1366 then
        table = thirteen_sixtysix
    else
        table = vga
    end

    if table[value] ~= nil then
        if gamemode_override_factor then
            return table[value] * gamemode_override_factor
        end
        return table[value]
    else
        print("unknown scaling value requested!: " .. value)
    end
end

function scaling.get_enemy_speed(enemy_type, current_level)
    return scaling.get("enemy_" .. enemy_type .. "_speed")[current_level]
end
