--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 19.02.17
-- Time: 13:43
-- To change this template use File | Settings | File Templates.
--

local functions = {}


local function draw_explosions()
    for _, explosion in ipairs(explosions) do
        local main_offset_x = explosion.main_texture:getWidth() / 2
        local main_offset_y = explosion.main_texture:getHeight() / 2
        love.graphics.draw(explosion.main_texture, explosion.x, explosion.y, explosion.main_rotation, explosion.x_scale, explosion.y_scale, main_offset_x, main_offset_y)
    end
end
functions.draw = draw_explosions

local function update_explosions(dt)
    for index, explosion in ipairs(explosions) do
        explosion.age = explosion.age + dt

        --- remove old explosions
        if explosion.age > maximum_explosion_age then
            table.remove(explosions, index)
        end
    end
end
functions.update = update_explosions

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

    --- make explosion sound
    --local explosion_sound = love.audio.newSource("explosion.ogg", "static")
    --explosion_sound:setVolume(.5)
    --explosion_sound:play()

    local fire_sound = love.audio.newSource("explosion.ogg", "static")
    fire_sound:play()
end
functions.create_explosion = create_explosion

return functions