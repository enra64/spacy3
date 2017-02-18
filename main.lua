world = {}

enemies = {}
bullets = {}
player = {}
background = nil

bullet_speed = 1000
enemy_speed = 200
speed = 400

explosions = {}

score = 0

maximum_explosion_age = .2

shot_pressed = false

local function check_collides(a, b)
    return a.x < b.x + b.width and
            a.x + a.width > b.x and
            a.y < b.y + b.height and
            a.height + a.y > b.y
end

local function remove_all_colliding(collection, colliding_object, collision_handler)
    local had_collision = false
    for index, object in ipairs(collection) do
        if check_collides(object, colliding_object) then
            collision_handler(colliding_object, object)
            table.remove(collection, index)
            had_collision = true
        end
    end

    return had_collision
end

local function check_collides_with_enemy(a)
    for _, o in ipairs(enemies) do
        if check_collides(o, a) then
            return true
        end
    end
    return false
end

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
        new_enemy.x = math.random(love.graphics.getWidth(), love.graphics.getWidth()+ 100)
        new_enemy.y = math.random(love.graphics.getHeight() - height)
    until (not check_collides_with_enemy(new_enemy))

    table.insert(enemies, new_enemy)
end

local function shoot(x, y)
    local new_bullet = {}

    new_bullet.texture = love.graphics.newImage("missile_with_propulsion.png")

    --- store scaling factor
    new_bullet.scale = .6

    --- store width and height
    local width = new_bullet.texture:getWidth()
    local height = new_bullet.texture:getHeight()
    new_bullet.width = width * new_bullet.scale
    new_bullet.height = height * new_bullet.scale


    --- init pos
    new_bullet.x = x
    new_bullet.y = y

    --- add new bullet to list
    table.insert(bullets, new_bullet)
end

local function create_explosion(x, y)
    explosion = {}
    explosion.corona_texture = love.graphics.newImage("explosion_blue_ring.png")
    explosion.main_texture = love.graphics.newImage("explosion.png")

    --- age determines the scaling of explosions
    explosion.age = 0
    explosion.x = x
    explosion.y = y

    --- add some variation using random rotation
    explosion.corona_rotation = math.rad(math.random(360))
    explosion.main_rotation = math.rad(math.random(360))

    --- store explosion
    table.insert(explosions, explosion)
end

local function handle_kill(_, killed_enemy)
    create_enemy()
    score = score + 10

    --- make explody thing over enemy. explosions are drawn at their center point,
    create_explosion(killed_enemy.x, killed_enemy.y)
end

local function update_bullets(dt)
    for i, bullet in ipairs(bullets) do
        bullet.x = bullet.x + (bullet_speed * dt)

        if bullet.x > love.graphics.getWidth() then
            table.remove(bullets, i)
        end

        if remove_all_colliding(enemies, bullet, handle_kill) then
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

local function update_player(dt)
    if love.keyboard.isDown("d") then
        player.x = player.x + (speed * dt)
    end
    if love.keyboard.isDown("a") then
        player.x = player.x - (speed * dt)
    end
    if love.keyboard.isDown("w") then
        player.y = player.y - (speed * dt)
    end
    if love.keyboard.isDown("s") then
        player.y = player.y + (speed * dt)
    end
    if love.keyboard.isDown("space") and not shot_pressed then
        shoot(player.x + player.width, player.y + player.height / 2)
        shot_pressed = true
    elseif not love.keyboard.isDown("space") then
        shot_pressed = false
    end

    if(check_collides_with_enemy(player)) then
        print("\nYou failed your colony. Also, you made " .. score .. " points.")
        love.event.push('quit')
    end
end

local function update_explosions(dt)
    for index, explosion in ipairs(explosions) do
        explosion.age = explosion.age + dt

        -- remove old explosions
        if explosion.age > maximum_explosion_age then
            table.remove(explosions, index)
        end
    end
end

function love.update(dt)
    update_bullets(dt)
    update_player(dt)
    update_enemies(dt)
    update_explosions(dt)
end

local function draw_all_in(collection)
    for _, item in ipairs(collection) do
        love.graphics.draw(item.texture, item.x, item.y, 0, item.scale)
    end
end

local function draw_explosions()
    for _, explosion in ipairs(explosions) do
        love.graphics.setColor(255, 255, 255, 255 - (255 * explosion.age / maximum_explosion_age))
        local corona_scaling_factor = explosion.age * 2 / maximum_explosion_age
        local corona_offset_x = explosion.corona_texture:getWidth() / 2
        local corona_offset_y = explosion.corona_texture:getHeight() / 2
        love.graphics.draw(explosion.corona_texture, explosion.x, explosion.y, explosion.corona_rotation, corona_scaling_factor, corona_scaling_factor, corona_offset_x, corona_offset_y)

        love.graphics.setColor(255, 255, 255)
        local main_scaling_factor = explosion.age / maximum_explosion_age
        local main_offset_x = explosion.main_texture:getWidth() / 2
        local main_offset_y = explosion.main_texture:getHeight() / 2
        love.graphics.draw(explosion.main_texture, explosion.x, explosion.y, explosion.main_rotation, main_scaling_factor, main_scaling_factor, main_offset_x, main_offset_y)
    end
end

function love.draw()
    --- background
    love.graphics.draw(background, 0, 0, 0, love.graphics.getWidth() / background:getWidth(), love.graphics.getHeight() / background:getHeight())

    draw_all_in(enemies)
    draw_all_in(bullets)
    draw_explosions()
    love.graphics.draw(player.texture, player.x, player.y, 0, 1, 1)
end

local function create_player()
    player.x = 50
    player.y = love.graphics.getHeight() / 2
    player.texture = love.graphics.newImage("my_spaceship_with_propulsion.png")
    player.width = player.texture:getWidth()
    player.height = player.texture:getHeight()
end

function love.load()
    --- load background texture
    background = love.graphics.newImage("background.png")

    --- set window size to background size
    love.window.setMode(background:getWidth() * 2, background:getHeight() * 2)

    --- initialise the player
    create_player()

    --- create some enemies to get started
    for i = 1, 3 do create_enemy() end
end
