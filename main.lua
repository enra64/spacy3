enemies = {}
bullets = {}

bullet_speed = 1000
enemy_speed = 200
speed = 400

explosions = {}

score = 0

maximum_explosion_age = .2

local bg = require("background")
local player = require("player")
local collisions = require("collisions")

local function create_enemy()
    local new_enemy = {}

    --- load texture
    new_enemy.texture = love.graphics.newImage("enemy_with_propulsion.png")

    --- store width and height
    local width = new_enemy.texture:getWidth()
    local height = new_enemy.texture:getHeight()
    new_enemy.width = width
    new_enemy.height = height

    --- no scaling
    new_enemy.scale = 1

    --- find free position
    repeat
        new_enemy.x = math.random(love.graphics.getWidth(), love.graphics.getWidth() + 100)
        new_enemy.y = math.random(love.graphics.getHeight() - height)
    until (not collisions.check_collides_with_table(new_enemy, enemies))

    table.insert(enemies, new_enemy)
end



local function create_explosion(x, y)
    local explosion = {}
    explosion.main_texture = love.graphics.newImage("explosion.png")

    --- age determines the scaling of explosions
    explosion.age = 0
    explosion.x = x
    explosion.y = y

    --- add some variation using random rotation
    explosion.main_rotation = math.rad(math.random(360))

    --- add more variation using random scale
    local x_scale = math.random(60, 100)
    explosion.x_scale = x_scale / 100
    explosion.y_scale = math.random(x_scale - 20, x_scale + 20) / 100

    --- store explosion
    table.insert(explosions, explosion)
end

local function handle_kill(_, killed_enemy)
    create_enemy()
    score = score + 10

    --- make explody thing over enemy
    create_explosion(killed_enemy.x, killed_enemy.y)
end

local function update_bullets(dt)
    for i, bullet in ipairs(bullets) do
        bullet.x = bullet.x + (bullet_speed * dt)

        if bullet.x > love.graphics.getWidth() then
            table.remove(bullets, i)
        end

        if collisions.remove_all_colliding(enemies, bullet, handle_kill) then
            table.remove(bullets, i)
        end
    end
end

local function update_enemies(dt)
    for index, enemy in ipairs(enemies) do
        enemy.x = enemy.x - (dt * enemy_speed)

        if enemy.x + enemy.width < 0 then
            table.remove(enemies, index)
            create_enemy()
        end
    end
end

local function update_explosions(dt)
    for index, explosion in ipairs(explosions) do
        explosion.age = explosion.age + dt

        --- remove old explosions
        if explosion.age > maximum_explosion_age then
            table.remove(explosions, index)
        end
    end
end

function love.update(dt)
    update_bullets(dt)
    player.update(dt, enemies)
    update_enemies(dt)
    update_explosions(dt)
    bg.update(dt)
end

local function draw_all_in(collection)
    for _, item in ipairs(collection) do
        love.graphics.draw(item.texture, item.x, item.y, 0, item.scale)
    end
end

local function draw_explosions()
    for _, explosion in ipairs(explosions) do
        local main_offset_x = explosion.main_texture:getWidth() / 2
        local main_offset_y = explosion.main_texture:getHeight() / 2
        love.graphics.draw(explosion.main_texture, explosion.x, explosion.y, explosion.main_rotation, explosion.x_scale, explosion.y_scale, main_offset_x, main_offset_y)
    end
end


function love.draw()
    bg.draw()
    draw_all_in(enemies)
    draw_all_in(bullets)
    player.draw()
    draw_explosions()

    --- score
    love.graphics.print(score .. " points", 0, 0, 0, 2)
end

function love.load()
    --- unshittify random numbers
    math.randomseed(os.time())

    --- set some window size
    love.window.setMode(1024, 768)

    --- load background textures
    bg.load()

    --- initialise the player
    player.load()

    --- create some enemies to get started
    for i = 1, 3 do create_enemy() end
end
