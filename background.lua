--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 19.02.17
-- Time: 12:17
-- To change this template use File | Settings | File Templates.
--

local functions = {}

local planets = {}
local stars = {}

local function shuffle(array)
    -- fisher-yates
    local output = {}
    local random = math.random

    for index = 1, #array do
        local offset = index - 1
        local value = array[index]
        local randomIndex = offset * random()
        local flooredIndex = randomIndex - randomIndex % 1

        if flooredIndex == offset then
            output[#output + 1] = value
        else
            output[#output + 1] = output[flooredIndex + 1]
            output[flooredIndex + 1] = value
        end
    end

    return output
end

local function load_planets()
    local planet_image_paths = {"blue_planet_1.png", "blue_planet_2.png", "yellow_planet.png" }

    --- make the planets appear in a random order
    planet_image_paths = shuffle(planet_image_paths)

    local planet_count = #planet_image_paths
    local g_width = love.graphics.getWidth()
    local g_height = love.graphics.getHeight()
    local sector_width = g_width / planet_count
    local row_count = 2
    local sector_height = g_height / row_count

    --- randomize the row in which we begin placing planets
    local planet_row = math.random(row_count)

    for index, planet_name in ipairs(planet_image_paths) do
        local planet = {}
        planet.texture = love.graphics.newImage(planet_name)

        --- begin with random rotation, scale
        planet.rotation = math.rad(math.random(360))
        planet.rotation_speed = math.random(-4, 4)

        planet.scale = (math.random(30, 40) / 100 )

        --- store size
        planet.width = planet.texture:getWidth()
        planet.height = planet.texture:getHeight()

        --- decide where to put the planet
        planet.x = math.random(planet.width / 2 + (index - 1) * sector_width, (index + 0) * sector_width - planet.width / 2)
        planet.y = math.random(planet.height / 2 + (planet_row - 1) * sector_height, (planet_row + 0) * sector_height - planet.height / 2)

        --- put the next planet in another row
        local old_planet_row = planet_row
        repeat
            planet_row = math.random(row_count)
        until not (planet_row == old_planet_row)

        --- put planet into list
        table.insert(planets, planet)
    end
end

local function load_stars()
    local star_image_paths = {"star_1.png", "star_2.png", "star_3.png", "star_4.png", "star_5.png"}
    for i = 1, math.random(50, 150), 1 do
        local star = {}

        star.texture = love.graphics.newImage(star_image_paths[math.random(#star_image_paths)])
        star.rotation = math.rad(math.random(360))
        star.scale = math.random(30) / 100
        star.width = star.texture:getWidth()
        star.height = star.texture:getHeight()
        star.color = {math.random(255), math.random(255), math.random(255), math.random(255) }
        star.x = math.random(love.graphics.getWidth())
        star.y = math.random(love.graphics.getHeight())

        table.insert(stars, star)
    end
end

local function load()
    math.randomseed(os.time())
    load_planets()
    load_stars()
end

functions.load = load

local function draw_background()
    --- clear to black background
    love.graphics.clear(0, 0, 0)

    --- draw all stars
    for _, star in ipairs(stars) do
        love.graphics.setColor(star.color)
        love.graphics.draw(star.texture, star.x, star.y, math.rad(star.rotation), star.scale, star.scale, star.width / 2, star.height / 2)
    end
    love.graphics.setColor(255,255,255)

    --- draw all planets
    for _, planet in ipairs(planets) do
        love.graphics.draw(planet.texture, planet.x, planet.y, math.rad(planet.rotation), planet.scale, planet.scale, planet.width / 2, planet.height / 2)
    end
end

functions.draw = draw_background

local function update_background(dt)
    for _, planet in ipairs(planets) do
        planet.rotation = planet.rotation + planet.rotation_speed * dt
    end
end

functions.update = update_background

return functions

