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
local collider = require("hc").new()
local star_image_paths = { "img/star_1.png", "img/star_2.png", "img/star_3.png", "img/star_4.png", "img/star_5.png" }
local random = require("random")
require("common")
local planet_base_scale

local function load_planets()
    local planet_image_paths = { "img/blue_planet_1.png", "img/blue_planet_2.png", "img/yellow_planet.png", "img/grey_planet.png", "img/brown_planet.png"}

    --- make the planets appear in a random order
    planet_image_paths = random.shuffle(planet_image_paths)
    
    planet_image_paths = table.truncate(planet_image_paths, 3)

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

        
        planet.scale = planet_base_scale + math.random(-planet_base_scale * 100 / 7, planet_base_scale * 100 / 7) / 100

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

local function get_single_star(x, y)
    local star = {}

    star.texture = love.graphics.newImage(star_image_paths[math.random(#star_image_paths)])
    star.rotation = math.rad(math.random(360))
    star.scale = math.random(5, 12) / 100
    star.width = star.texture:getWidth() * star.scale
    star.height = star.texture:getHeight() * star.scale
    --star.color = { math.random(255), math.random(255), math.random(255), math.random(255) }
    star.color = {255, 255, 255}
    star.x = x
    star.y = y
    
    star.shape = collider:rectangle(x, y, star.width, star.height)

    return star
end

local function create_gaussian_star_cluster()
    --- temp storage for screen size
    local height = love.graphics.getHeight()
    local width = love.graphics.getWidth()

    --- parameters both for the line making up the center line of the stars and the normal of that line
    local y_aa = height / 2 + math.random(-height / 4, height / 4)

    --- change slope so the cluster will be on screen
    local slope
    if y_aa > height / 2 then
        slope = math.random(-50, -10) / 100
    else
        slope = math.random(10, 50) / 100
    end

    local normal_slope = -(1 / slope)

    --- generate me some stars
    local star_count = math.random(100, 300)
    for i = 1, star_count do
        --- random position somewhere on the x axis with a normal distribution
        local x_position = ((16 + random.box_muller(0, 5, 1)) / 30) * width

        --- calculate the y position of that x position given our x
        local y_position = y_aa + slope * x_position

        --- choose an x position slightly offset, so we calculate some point of the tangent that is likely on the screen
        local x = x_position + (random.box_muller(0, 2, 2) * 5)

        --- calculate normal position
        local y = normal_slope * x + (y_position - (normal_slope * x_position))

        --- only add the created star if it is set within the screen
        if x < 0 or y < 0 or x > width or y > height then
            i = i - 1
        else
            local new_star = get_single_star(x, y)

            has_no_collision = true
            
            for _, _ in pairs(collider:collisions(new_star.shape)) do
                has_no_collision = false
            end

            if has_no_collision then
                table.insert(stars, new_star)
            else
                i = i - 1
                collider:remove(new_star.shape)
            end
        end
    end
end

local function load_stars()
    for i = 1, math.random(50, 100), 1 do
        table.insert(stars, get_single_star(math.random(love.graphics.getWidth()), math.random(love.graphics.getHeight())))
    end
end

local function load()
    math.randomseed(os.time())
    
    planet_base_scale = scaling.get("planet_scale")
    
    load_planets()
    load_stars()
    create_gaussian_star_cluster()
    
    -- draw the stars to a separate canvas
    functions.star_canvas = love.graphics.newCanvas(
        love.graphics.getWidth(), 
        love.graphics.getHeight())
    love.graphics.setCanvas(functions.star_canvas)
    
    -- draw all stars
    for _, star in ipairs(stars) do
        love.graphics.setColor(star.color)
        love.graphics.draw(star.texture, star.x, star.y, star.rotation, star.scale, star.scale, star.width / 2, star.height / 2)
    end
    love.graphics.setColor(255, 255, 255)
    
    -- reset canvas to screen
    love.graphics.setCanvas()
end

functions.load = load



local function draw_background()
    --- clear to black background
    love.graphics.clear(0, 0, 0)

    -- draw star canvas
    love.graphics.setBlendMode("alpha", "premultiplied")
    love.graphics.draw(functions.star_canvas)
    love.graphics.setBlendMode("alpha")

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

functions.leave = function()
    stars = {}
    planets = {}
    
end

functions.enter = function()
    planet_base_scale = scaling.get("planet_scale")
end

return functions

