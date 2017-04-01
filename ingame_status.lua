--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 10.03.17
-- Time: 17:08
-- To change this template use File | Settings | File Templates.
--

local functions = {}

--- ui elements
local missile_count_widget = {}
local score_widget = {}
local overheat_bar = {}
local missile_icon = {}
local laser_icon = {}
local credit_widget = {}

--- variables
local missile_count = 0
local laser_heat = 0
local score = 0

--- constants
local ui_margin = 10
local ui_height
local ui_width
local ui_rhs
local font

--- required stuff
local weaponry = require("weapons")
require("player_ship_upgrade_state")

functions.init = function()
    font = require("font_config").get_font("ingame")

    --- general
    ui_width = love.graphics.getWidth() - ui_margin * 2
    ui_height = font:getHeight()
    ui_rhs = ui_width + ui_margin

    --- score display
    score_widget.x = 0
    score_widget.y = 0
    score_widget.width = font:getWidth("1234 points")
    score_widget.height = font:getHeight()

    --- laser heat icon
    laser_icon.texture = love.graphics.newImage("img/ui/heat_icon.png")
    local width, height = laser_icon.texture:getDimensions()
    laser_icon.x_scale = math.scale_from_to(height, ui_height)
    laser_icon.y_scale = math.scale_from_to(height, ui_height)
    laser_icon.width, laser_icon.height = width * laser_icon.x_scale, height * laser_icon.y_scale

    laser_icon.x = ui_margin + score_widget.width
    laser_icon.y = 0

    --- laser overheat bar
    overheat_bar.background_texture =love.graphics.newImage("img/ui/laser_overheating_bar_background.png")
    overheat_bar.texture = love.graphics.newImage("img/ui/laser_overheating_bar.png")

    width, height = overheat_bar.texture:getDimensions()

    overheat_bar.x_scale = math.scale_from_to(width,  ui_width / 2)
    overheat_bar.y_scale = math.scale_from_to(height, ui_height)

    -- both bar textures should have the same width and height
    overheat_bar.width = width * overheat_bar.x_scale
    overheat_bar.height = height * overheat_bar.y_scale

    -- no scaling applied here
    overheat_bar.quad = love.graphics.newQuad(0, 0, width, height, width, height)

    -- drawn relative to ui
    overheat_bar.x = ui_margin + laser_icon.x + laser_icon.width
    overheat_bar.y = 0

    --- missile count display
    missile_count_widget.x = ui_rhs - font:getWidth("200")
    missile_count_widget.y = 0

    --- missile count icon
    missile_icon.texture = love.graphics.newImage("img/ui/missile_icon.png")
    width, height = missile_icon.texture:getDimensions()
    missile_icon.x_scale = math.scale_from_to(height, ui_height)
    missile_icon.y_scale = math.scale_from_to(height, ui_height)
    missile_icon.width, missile_icon.height = width * missile_icon.x_scale, height * missile_icon.y_scale
    
    -- credit count display
    credit_widget.x = missile_count_widget.x - font:getWidth("$200000")
    credit_widget.y = missile_count_widget.y
    

    missile_icon.x = missile_count_widget.x - missile_icon.width - ui_margin
    missile_icon.y = 0
end

functions.draw = function()
    --- laser heat icon
    love.graphics.draw(laser_icon.texture, laser_icon.x + ui_margin, laser_icon.y + ui_margin, NO_ROTATION, laser_icon.x_scale, laser_icon.y_scale)

    --- laser overheat bar
    love.graphics.draw(
        overheat_bar.texture,
        overheat_bar.quad,
        overheat_bar.x + ui_margin,
        overheat_bar.y + ui_margin,
        NO_ROTATION,
        overheat_bar.x_scale,
        overheat_bar.y_scale)
    love.graphics.draw(
        overheat_bar.background_texture,
        overheat_bar.x + ui_margin,
        overheat_bar.y + ui_margin,
        NO_ROTATION,
        overheat_bar.x_scale,
        overheat_bar.y_scale)

    -- credits
    love.graphics.print(
        "$"..player_ship_upgrade_state.get_credits(),
        credit_widget.x,
        credit_widget.y + ui_margin
    )

    --- missile count
    love.graphics.print(
        missile_count,
        missile_count_widget.x + ui_margin,
        missile_count_widget.y + ui_margin)

    --- missile count icon
    love.graphics.draw(
        missile_icon.texture,
        missile_icon.x + ui_margin,
        missile_icon.y + ui_margin,
        NO_ROTATION,
        missile_icon.x_scale,
        missile_icon.y_scale)

    --- score
    love.graphics.print(score .. " points", ui_margin, ui_margin)
end

functions.enter = function()
    love.graphics.setFont(font)
end

functions.update = function(score_)
    missile_count = weaponry.get_missile_count()

    score = score_

    laser_heat = weaponry.get_laser_heat()
    overheat_bar.quad:setViewport(0, 0, (overheat_bar.width / overheat_bar.x_scale) * laser_heat, overheat_bar.height / overheat_bar.y_scale)
end

return functions