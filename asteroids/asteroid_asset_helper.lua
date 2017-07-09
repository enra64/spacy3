--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 05.06.17
-- Time: 20:59
-- To change this template use File | Settings | File Templates.
--

-- return an array load_random_asteroid, get_asteroid_fragments

local functions = {}



local asteroids = {
    _1 = {
        {
            texture = "img/asteroids/1/asteroid_brown.png",
            polygon =  (read_csv("collisionmaps/singlebrown.csv"))
        },
        {
            texture = "img/asteroids/1/asteroid_grey.png",
            polygon =  (read_csv("collisionmaps/singlegrey.csv"))
        }
    },
    _2 = {
        {
            texture = "img/asteroids/2/double1.png",
            polygon =  (read_csv("collisionmaps/double1.csv"))
        }, {
            texture = "img/asteroids/2/double2.png",
            polygon =  (read_csv("collisionmaps/double2.csv"))
        }, {
            texture = "img/asteroids/2/double3.png",
            polygon =  (read_csv("collisionmaps/double3.csv"))
        }, {
            texture = "img/asteroids/2/double4.png",
            polygon =  (read_csv("collisionmaps/double4.csv"))
        }
    },
    _3 = {
        {
            texture = "img/asteroids/3/triple1.png",
            polygon =  (read_csv("collisionmaps/triple1.csv"))
        }, {
            texture = "img/asteroids/3/triple2.png",
            polygon =  (read_csv("collisionmaps/triple2.csv"))
        }, {
            texture = "img/asteroids/3/triple3.png",
            polygon =  (read_csv("collisionmaps/triple3.csv"))
        }
    },
    _4 = {
        {
            texture = "img/asteroids/4/quadruple1.png",
            polygon =  (read_csv("collisionmaps/quadruple1.csv"))
        }, {
            texture = "img/asteroids/4/quadruple2.png",
            polygon =  (read_csv("collisionmaps/quadruple2.csv"))
        }, {
            texture = "img/asteroids/4/quadruple3.png",
            polygon =  (read_csv("collisionmaps/quadruple3.csv"))
        }
    },
    _8 = {
        {
            texture = "img/asteroids/8/eighter1.png",
            polygon =  (read_csv("collisionmaps/eighter1.csv"))
        }, {
            texture = "img/asteroids/8/eighter2.png",
            polygon =  (read_csv("collisionmaps/eighter2.csv"))
        }, {
            texture = "img/asteroids/8/eighter3.png",
            polygon =  (read_csv("collisionmaps/eighter3.csv"))
        }
    }
}

-- load_random_asteroid
local function load_random_asteroid(length)
    length = length or 1

    local asteroids_with_matching_length = asteroids["_"..length]
    local choice = math.random(#asteroids_with_matching_length)
    local polygon = asteroids_with_matching_length[choice].polygon
    local texture_path = asteroids_with_matching_length[choice].texture
    local id = texture_path:match("^.+/(.+)%..*$")

    -- return the texture, the polygon, and the name of the chosen asteroid
    return love.graphics.newImage(texture_path), polygon, id
end

functions[1] = load_random_asteroid

-- get_asteroid_fragments
local function get_asteroid_fragments(asteroid_type)
    if asteroid_type == "asteroid_brown" then
        return {
            "img/asteroids/1/brown_asteroid_fragment_1.png",
            "img/asteroids/1/brown_asteroid_fragment_2.png",
            "img/asteroids/1/brown_asteroid_fragment_3.png",
            "img/asteroids/1/brown_asteroid_fragment_4.png",
            "img/asteroids/1/brown_asteroid_fragment_5.png",
            "img/asteroids/1/brown_asteroid_fragment_6.png"
        }
    elseif asteroid_type == "asteroid_grey" then
        return {
            "img/asteroids/1/grey_asteroid_fragment_1.png",
            "img/asteroids/1/grey_asteroid_fragment_2.png",
            "img/asteroids/1/grey_asteroid_fragment_3.png",
            "img/asteroids/1/grey_asteroid_fragment_4.png",
            "img/asteroids/1/grey_asteroid_fragment_5.png",
            "img/asteroids/1/grey_asteroid_fragment_6.png"
        }
    else
        return {}
    end
end

functions[2] = get_asteroid_fragments

local function is_in_viewport(asteroid)
    return not (asteroid.x + 2 * asteroid.width < 0 or
            asteroid.x - asteroid.width > love.graphics.getWidth() or
            asteroid.y + 2 * asteroid.height < 0 or
            asteroid.y - 2 * asteroid.height > love.graphics.getHeight())
end

functions[4] = is_in_viewport

local function new_random_asteroid(length)
    local new_asteroid = {}
    new_asteroid.texture, new_asteroid.asteroid_collision_coordinates, new_asteroid.asteroid_type = load_random_asteroid(length)
    new_asteroid.fragments = get_asteroid_fragments(new_asteroid.asteroid_type)
    new_asteroid.width, new_asteroid.height = new_asteroid.texture:getDimensions()
    new_asteroid.is_in_viewport = is_in_viewport
    new_asteroid.on_destroyed = function() end
    return new_asteroid
end

functions[3] = new_random_asteroid



return functions