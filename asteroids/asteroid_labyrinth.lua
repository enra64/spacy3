local _, get_asteroid_fragments, new_random_asteroid, is_in_viewport = unpack(require("asteroids.asteroid_asset_helper"))
local hc = require("hc")
local timer = require("hump.timer")
require("difficulty_handler")
require("drops")
require("flyapartomatic")

local asteroid_storage
local asteroid_base_scale
local asteroid_column_storage = {}

local function update(asteroid, dx)
    asteroid.x = asteroid.x + dx

    asteroid.rotation = asteroid.rotation + asteroid.rotation_speed
    asteroid.shape:rotate(asteroid.rotation_speed)
end

local function get_asteroid()
    -- get some random asteroid
    local new = new_random_asteroid()

    -- set update routine
    new.update = update

    -- function to check for viewport
    new.is_in_viewport = is_in_viewport

    -- positioning, movement
    new.x = love.graphics.getWidth() + 100
    new.y =

    new.x = math.random(love.graphics.getWidth() * 0.75, love.graphics.getWidth() + 100)
    new.gradient = math.random() + 0.3

    new.fragments = get_asteroid_fragments(new.asteroid_type)

    --- set random speed -- "speed" should be horizontal speed
    new.speed = scaling.get("asteroid_speed")[current_level()]
    new.speed = -(new.speed + math.random(0, new.speed / 10))


    new.rotation_speed = math.random(7, 7 + new.speed / 80) / 100
    new.rotation = math.random(2 * math.pi)

    --- collision shape
    new.shape = hc.polygon(unpack(new.asteroid_collision_coordinates))


    new.scale = asteroid_base_scale + math.random(-asteroid_base_scale * 25, asteroid_base_scale * 25) / 100

    -- move to "position of asteroid" - "center of asteroid"
    new.shape:move(new.x - new.width / 2, new.y - new.height / 2)
    new.shape:scale(new.scale)
    new.shape.object_type = "asteroid"

    return new
end

local function check_column_fill()

end

-- init function
return function(asteroid_storage_reference, asteroid_scale)
    asteroid_base_scale = asteroid_scale
    asteroid_storage = asteroid_storage_reference
    timer.every(0.1, check_column_fill)
end