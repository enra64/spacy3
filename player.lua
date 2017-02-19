--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 19.02.17
-- Time: 13:04
-- To change this template use File | Settings | File Templates.
--

local functions = {}

local is_shot_pressed = false

local collisions = require("collisions")
local weaponry = require("weapons")


local function update_player(dt)
    --- reset all movements to false
    for i, _ in pairs(player.movement) do
        player.movement[i] = false
    end

    --- check direction keys
    if love.keyboard.isDown("d") and player.x + player.width < love.graphics.getWidth() then
        player.x = player.x + (speed * dt)
        player.movement.right = true
    end
    if love.keyboard.isDown("a") and player.x > 0 then
        player.x = player.x - (speed * dt)
        player.movement.left = true
    end
    if love.keyboard.isDown("w") and player.y > 0 then
        player.y = player.y - (speed * dt)
        player.movement.up = true
    end
    if love.keyboard.isDown("s") and player.y + player.height < love.graphics.getHeight() then
        player.y = player.y + (speed * dt)
        player.movement.down = true
    end

    --- adjust thruster volume
    local thruster_count = 0
    for _, thruster_activated in pairs(player.movement) do
        if thruster_activated then
            thruster_count = thruster_count + 1
        end
    end

    player.thruster_sound:setVolume(.25 * thruster_count)

    if thruster_count > 0 then
        player.thruster_sound:play()
    else
        player.thruster_sound:pause()
    end

    --- shooting
    if love.keyboard.isDown("space") and not is_shot_pressed then
        weaponry.shoot_missile(player.x + player.width, player.y + player.height / 2)
        is_shot_pressed = true
    elseif not love.keyboard.isDown("space") then
        is_shot_pressed = false
    end

    --- die on collision
    if (collisions.has_rect_collision(player, enemies)) then
        print("\nYou failed your colony. Also, you made " .. score .. " points.")
        love.event.push('quit')
    end
end
functions.update = update_player

local function draw_player()
    --- the propulsion images are larger than the main ship body, so the must be drawn slightly up left from it
    local x_prop_offset = (player.propulsion_texture.right:getWidth() - player.texture:getWidth()) / 1
    local y_prop_offset = (player.propulsion_texture.right:getHeight() - player.texture:getHeight()) / 2

    --- draw the available bodies
    for direction, direction_enabled in pairs(player.movement) do
        if direction_enabled then
            love.graphics.draw(player.propulsion_texture[direction], player.x - x_prop_offset, player.y - y_prop_offset, 0, 1, 1)
        end
    end

    love.graphics.draw(player.texture, player.x, player.y, 0, 1, 1)
end
functions.draw = draw_player

local function create_player()
    player.x = 50
    player.y = love.graphics.getHeight() / 2
    player.texture = love.graphics.newImage("ship_main.png")

    player.width = player.texture:getWidth()
    player.height = player.texture:getHeight()

    --- storage for direction
    player.movement = {right = false, left = false, up = false, down = false }

    --- store all four propulsion textures
    player.propulsion_texture = {}
    player.propulsion_texture.right = love.graphics.newImage("ship_flame_back.png")
    player.propulsion_texture.left = love.graphics.newImage("ship_flame_front.png")
    player.propulsion_texture.up = love.graphics.newImage("ship_flame_down.png")
    player.propulsion_texture.down = love.graphics.newImage("ship_flame_up.png")

    --- player audio
    player.thruster_sound = love.audio.newSource("thrusters2.ogg")
    player.thruster_sound:setLooping(true)
end
functions.load = create_player



return functions

