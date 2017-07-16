--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 19.02.17
-- Time: 13:43
-- To change this template use File | Settings | File Templates.
--

local functions = {}

local simple_enemies = {}
local enemy_types = { "simple" }
local enemy_tweening_values = { simple = 0 }
local hc = require("hc")
local timer = require("hump.timer")
require("difficulty_handler")
require("scaling")

functions.enable_enemy_spawning = true



local function create_enemy()
    local new_enemy = {}

    --- load texture
    new_enemy.texture = love.graphics.newImage("img/enemy_ship_2_body.png")

    --- store width and height
    new_enemy.width, new_enemy.height = new_enemy.texture:getDimensions()

    --- no scaling
    new_enemy.scale = scaling.get("enemy_simple_scale")
    new_enemy.score = difficulty.get("enemy_simple_score", current_level())
    new_enemy.type = "simple"

    --- find free position
    local position_found = false

    while not position_found do
        new_enemy.x = math.random(love.graphics.getWidth(), love.graphics.getWidth() + 100)
        new_enemy.y = math.random(new_enemy.height, love.graphics.getHeight() - 2 * new_enemy.height)
        new_enemy.shape = hc.rectangle(new_enemy.x, new_enemy.y, new_enemy.width * new_enemy.scale, new_enemy.height * new_enemy.scale)
        new_enemy.shape.object_type = "enemy"

        position_found = true

        for _, _ in pairs(hc.collisions(new_enemy.shape)) do
            -- if we found a collision, that enemy will not be added; its shape must be deleted from the collision system
            position_found = false
            hc.remove(new_enemy.shape)
        end
    end


    table.insert(simple_enemies, new_enemy)
end

local function create_simple_enemies()
    while #simple_enemies < difficulty.get("enemy_simple_count", current_level()) do
        create_enemy()
    end
end

functions.update = function(dt)
    if functions.enable_enemy_spawning then
        create_simple_enemies()
    end

    for index, enemy in ipairs(simple_enemies) do
        local enemy_speed = scaling.get_enemy_speed(enemy.type, current_level()) + enemy_tweening_values[enemy.type]

        enemy.x = enemy.x - (dt * enemy_speed)
        enemy.shape:move(-dt * enemy_speed, 0)

        if enemy.x + enemy.width < 0 then
            hc.remove(enemy.shape)
            table.remove(simple_enemies, index)
        end
    end
end

functions.set_enemies_spawning = function(spawn)
    functions.enable_enemy_spawning = spawn
end

functions.leave = function()
    simple_enemies = {}
end

local function trigger_speed_tween_up(level)
    local TWEEN_DURATION = 0.5
    for _, enemy_type in ipairs(enemy_types) do
        local old_speed = scaling.get_enemy_speed(enemy.type, level - 1)
        local new_speed = scaling.get_enemy_speed(enemy.type, level)

        enemy_tweening_values[enemy_type] = old_speed - new_speed

        timer.tween(TWEEN_DURATION, enemy_tweening_values, { x = 0 }, 'out-quad')
    end
end

functions.enter = function()
    signal.register("levelup", trigger_speed_tween_up)
end

functions.draw = function()
    for _, item in ipairs(simple_enemies) do
        love.graphics.drawObject(item)
    end
end

functions.remove_colliding_enemies = function(shape, on_kill)
    local had_collision = false
    for i, enemy in ipairs(simple_enemies) do
        if enemy.shape:collidesWith(shape) then
            table.remove(simple_enemies, i)
            hc.remove(enemy.shape)
            had_collision = true

            flyapartomatic.spawn({
                "img/simple_enemy_ship_fragment_1.png",
                "img/simple_enemy_ship_fragment_2.png",
                "img/simple_enemy_ship_fragment_3.png",
                "img/simple_enemy_ship_fragment_4.png",
                "img/simple_enemy_ship_fragment_5.png",
            },
                enemy.x,
                enemy.y,
                1,
                1.3)

            on_kill(enemy)
        end
    end

    return had_collision
end

return functions
