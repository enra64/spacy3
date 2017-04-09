require("common")

scaling = {}

local vga = {
    ship_scale = 0.15,
    enemy_simple_scale = .7,
    asteroid_base_scale = .4,
    planet_scale = .3,
    drop_scale = .15,
    fonts_ingame = love.graphics.newFont("spacy3font.otf", 35),
    fonts_menu_title = love.graphics.newFont("spacy3font.otf", 45),
    fonts_menu = love.graphics.newFont("spacy3font.otf", 30),
    fonts_store_description = love.graphics.newFont("spacy3font.otf", 17),
    fonts_store_title = love.graphics.newFont("spacy3font.otf", 22),
    speed_player_ship_upgrade_0 = 300,
    speed_player_ship_upgrade_1 = 350,
    speed_player_ship_upgrade_2 = 400,
    enemy_simple_speed = table.multeach({200, 250, 300, 325, 350, 375, 500}, 0.7),
    asteroid_speed = table.multeach({100, 120, 150, 180, 220, 250, 300}, 0.7)
}

local thirteen_sixtysix = {
    ship_scale = 0.28,
    enemy_simple_scale = 1,
    asteroid_base_scale = 0.7,
    planet_scale = .45,
    drop_scale = .3,
    fonts_ingame = love.graphics.newFont("spacy3font.otf", 40),
    fonts_menu_title = love.graphics.newFont("spacy3font.otf", 60),
    fonts_menu = love.graphics.newFont("spacy3font.otf", 40),
    fonts_store_description = love.graphics.newFont("spacy3font.otf", 40),
    fonts_store_title = love.graphics.newFont("spacy3font.otf", 50),
    speed_player_ship_upgrade_0 = 400,
    speed_player_ship_upgrade_1 = 450,
    speed_player_ship_upgrade_2 = 500,
    enemy_simple_speed = table.multeach({200, 250, 300, 325, 350, 375, 500}, 1),
    asteroid_speed = table.multeach({100, 120, 150, 180, 220, 250, 300}, 1)
}

local fhd = {
    ship_scale = 0.4,
    enemy_simple_scale = 1.7,
    asteroid_base_scale = 0.8,
    planet_scale = .65,
    drop_scale = .3,
    fonts_ingame = love.graphics.newFont("spacy3font.otf", 60),
    fonts_menu_title = love.graphics.newFont("spacy3font.otf", 90),
    fonts_menu = love.graphics.newFont("spacy3font.otf", 60),
    fonts_store_description = love.graphics.newFont("spacy3font.otf", 50),
    fonts_store_title = love.graphics.newFont("spacy3font.otf", 70),
    speed_player_ship_upgrade_0 = 600,
    speed_player_ship_upgrade_1 = 650,
    speed_player_ship_upgrade_2 = 700,
    enemy_simple_speed = table.multeach({200, 250, 300, 325, 350, 375, 500}, 1.2),
    asteroid_speed = table.multeach({100, 120, 150, 180, 220, 250, 300}, 1.2)
}

local wqhd = {
    ship_scale = 0.3,
    enemy_simple_scale = 1,
    asteroid_base_scale = 1.2,
    planet_scale = .8,
    drop_scale = .3,
    fonts_ingame = love.graphics.newFont("spacy3font.otf", 40),
    fonts_menu_title = love.graphics.newFont("spacy3font.otf", 120),
    fonts_menu = love.graphics.newFont("spacy3font.otf", 80),
    fonts_store_description = love.graphics.newFont("spacy3font.otf", 40),
    fonts_store_title = love.graphics.newFont("spacy3font.otf", 50),
    speed_player_ship_upgrade_0 = 500,
    speed_player_ship_upgrade_1 = 550,
    speed_player_ship_upgrade_2 = 600,
    enemy_simple_speed = table.multeach({200, 250, 300, 325, 350, 375, 500}, 1.5),
    asteroid_speed = table.multeach({100, 120, 150, 180, 220, 250, 300}, 1.5)
}

local uhd = {
    ship_scale = 0.3,
    enemy_simple_scale = 1,
    asteroid_base_scale = 1.5,
    planet_scale = 1,
    drop_scale = .3,
    fonts_ingame = love.graphics.newFont("spacy3font.otf", 40),
    fonts_menu_title = love.graphics.newFont("spacy3font.otf", 200),
    fonts_menu = love.graphics.newFont("spacy3font.otf", 120),
    fonts_store_description = love.graphics.newFont("spacy3font.otf", 40),
    fonts_store_title = love.graphics.newFont("spacy3font.otf", 60),
    speed_player_ship_upgrade_0 = 600,
    speed_player_ship_upgrade_1 = 650,
    speed_player_ship_upgrade_2 = 700,
    enemy_simple_speed = table.multeach({200, 250, 300, 325, 350, 375, 500}, 1.7),
    asteroid_speed = table.multeach({100, 120, 150, 180, 220, 250, 300}, 1.7)
}

scaling.get = function(value)
    local table
    
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
        return table[value]
    else
        print("unknown scaling value requested!: "..value)
    end
end