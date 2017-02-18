world = {}

enemies = {}
bullets = {}
player = {}
background_planets = {}

bullet_speed = 1000
enemy_speed = 200
speed = 400

explosions = {}

score = 0

maximum_explosion_age = .2

shot_pressed = false

local function shuffle(array)
    -- fisher-yates
    local output = { }
    local random = math.random

    for index = 1, #array do
        local offset = index - 1
        local value = array[index]
        local randomIndex = offset*random()
        local flooredIndex = randomIndex - randomIndex%1

        if flooredIndex == offset then
            output[#output + 1] = value
        else
            output[#output + 1] = output[flooredIndex + 1]
            output[flooredIndex + 1] = value
        end
    end

    return output
end


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
        new_enemy.x = math.random(love.graphics.getWidth(), love.graphics.getWidth() + 100)
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
    explosion.main_texture = love.graphics.newImage("explosion.png")

    --- age determines the scaling of explosions
    explosion.age = 0
    explosion.x = x
    explosion.y = y

    --- add some variation using random rotation
    explosion.main_rotation = math.rad(math.random(360))

    --- add more variation using random scale
    explosion.x_scale = math.random() + 0.5
    explosion.y_scale = math.random() + 0.5

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

    --- shooting
    if love.keyboard.isDown("space") and not shot_pressed then
        shoot(player.x + player.width, player.y + player.height / 2)
        shot_pressed = true
    elseif not love.keyboard.isDown("space") then
        shot_pressed = false
    end

    --- die on collision
    if (check_collides_with_enemy(player)) then
        print("\nYou failed your colony. Also, you made " .. score .. " points.")
        love.event.push('quit')
    end
end

local function update_background(dt)
    for i, planet in ipairs(background_planets) do
        planet.rotation = planet.rotation + planet.rotation_speed * dt
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
    update_player(dt)
    update_enemies(dt)
    update_explosions(dt)
    update_background(dt)
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

local function draw_background()
    --- clear to black background
    love.graphics.clear(0, 0, 0)

    --- draw all planets
    for _, planet in ipairs(background_planets) do
        love.graphics.draw(planet.texture, planet.x, planet.y, math.rad(planet.rotation), planet.scale, planet.scale, planet.width / 2, planet.height / 2)
    end
end

function love.draw()
    draw_background()
    draw_all_in(enemies)
    draw_all_in(bullets)
    draw_explosions()
    draw_player()

    --- score
    love.graphics.print(score .. " points", 0, 0, 3)
end

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
end

local function load_background_planets()
    local planets = {"blue_planet_1.png", "blue_planet_2.png", "yellow_planet.png" }

    planets = shuffle(planets)

    local planet_count = #planets
    local g_width = love.graphics.getWidth()
    local g_height = love.graphics.getHeight()
    local sector_width = g_width / planet_count
    local row_count = 2
    local sector_height = g_height / row_count

    --- randomize the row in which we begin placing planets
    local planet_row = math.random(row_count)

    for index, planet_name in ipairs(planets) do
        local planet = {}
        planet.texture = love.graphics.newImage(planet_name)

        --- begin with random rotation, scale
        planet.rotation = math.rad(math.random(360))
        planet.rotation_speed = (math.random() * 6) - 3

        planet.scale = (math.random() * .1) + .3

        --- store size
        planet.width = planet.texture:getWidth()
        planet.height = planet.texture:getHeight()

        --- decide where to put the planet
        planet.x = math.random(planet.width / 2 + (index - 1) * sector_width, (index + 0) * sector_width)
        planet.y = math.random(planet.height / 2 + (planet_row - 1) * sector_height, (planet_row + 0) * sector_height)

        --- put the next planet in another row
        local old_planet_row = planet_row
        repeat
            planet_row = math.random(row_count)
        until not (planet_row == old_planet_row)

        --- put planet into list
        table.insert(background_planets, planet)
    end
end

function love.load()
    --- load background textures
    math.randomseed(os.time())
    load_background_planets()

    --- set some window size
    love.window.setMode(1024, 768)

    --- initialise the player
    create_player()



    --- create some enemies to get started
    for i = 1, 3 do create_enemy() end
end
