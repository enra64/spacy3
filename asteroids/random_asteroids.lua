local _, get_asteroid_fragments, new_random_asteroid, is_in_viewport = unpack(require("asteroids.asteroid_asset_helper"))
local hc = require("hc")
local timer = require("hump.timer")
require("difficulty_handler")
require("drops")
require("flyapartomatic")

local asteroid_storage
local asteroid_base_scale

local function update(asteroid, dx)
    local dx_abs = dx * asteroid.speed
    asteroid.x = asteroid.x + dx_abs


    local new_y = asteroid.y_intersection + asteroid.x * asteroid.gradient

    local dy = new_y - asteroid.y
    asteroid.y = new_y
    asteroid.shape:move(dx_abs, dy)

    asteroid.rotation = asteroid.rotation + asteroid.rotation_speed
    asteroid.shape:rotate(asteroid.rotation_speed)
end

local function get_asteroid()
    -- get some random asteroid
    local new = new_random_asteroid()

    -- set update routine
    new.update = update

    -- positioning, movement
    new.x = math.random(love.graphics.getWidth() * 0.75, love.graphics.getWidth() + 100)
    new.gradient = math.random() + 0.3

    -- position asteroid above or below game field, store information
    if math.random() > 0.5 then
        new.y = -new.height - 10
    else
        new.y = love.graphics.getHeight() + 10 + new.height
        -- a smaller y value means going up
        new.gradient = -new.gradient
    end

    --- set random speed -- "speed" should be horizontal speed
    new.speed = scaling.get("asteroid_speed")[current_level()]
    new.speed = -(new.speed + math.random(0, new.speed / 10))

    -- if the asteroid is going left, the gradient value need to be inverted to avoid sending it into nirvana
    local going_left = new.speed < 0
    if going_left then
        new.gradient = -new.gradient
    end

    --- calculate y axis intersection given our position and the random gradient
    new.y_intersection = new.y - new.gradient * new.x

    new.rotation_speed = math.random(7, 7 + new.speed / 80) / 100
    new.rotation = 0--math.random(2 * math.pi)

    --- collision shape
    new.scale = asteroid_base_scale + math.random(-asteroid_base_scale * 25, asteroid_base_scale * 25) / 100

    -- move to "position of asteroid" - "center of asteroid"
    new.shape:moveTo(new.x, new.y)
    new.shape:scale(new.scale)
    new.shape.object_type = "asteroid"

    -- clean up when the asteroid is destroyed
    new.on_destroyed = function(asteroid)
        lume.remove(asteroid_storage, asteroid)
        asteroid.shape.asteroid_reference = nil
        hc.remove(asteroid.shape)
    end

    return new
end

local function get_next_asteroid_delay()
    return math.random() * .8 + difficulty.get("asteroid_period", current_level())
end

local function on_asteroid_timer()
    table.insert(asteroid_storage, get_asteroid())
    timer.after(get_next_asteroid_delay(), on_asteroid_timer)
end

local function start(asteroid_storage_reference, asteroid_scale)
    asteroid_base_scale = asteroid_scale
    asteroid_storage = asteroid_storage_reference
    timer.after(get_next_asteroid_delay(), on_asteroid_timer)
end

return {start = start, stop = function() end}