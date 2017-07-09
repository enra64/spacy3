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
            polygon =  unpack(read_csv("collisionmaps/singlebrown.csv"))
        },
        {
            texture = "img/asteroids/1/asteroid_grey.png",
            polygon =  unpack(read_csv("collisionmaps/singlegrey.csv"))
        }
    },
    _2 = {
        {
            texture = "img/asteroids/2/double1.png",
            polygon =  unpack(read_csv("collisionmaps/double1.csv"))
        }, {
            texture = "img/asteroids/2/double2.png",
            polygon =  unpack(read_csv("collisionmaps/double2.csv"))
        }, {
            texture = "img/asteroids/2/double3.png",
            polygon =  unpack(read_csv("collisionmaps/double3.csv"))
        }, {
            texture = "img/asteroids/2/double4.png",
            polygon =  unpack(read_csv("collisionmaps/double4.csv"))
        }
    },
    _3 = {
        {
            texture = "img/asteroids/3/triple1.png",
            polygon =  unpack(read_csv("collisionmaps/triple1.csv"))
        }, {
            texture = "img/asteroids/3/triple2.png",
            polygon =  unpack(read_csv("collisionmaps/triple2.csv"))
        }, {
            texture = "img/asteroids/3/triple3.png",
            polygon =  unpack(read_csv("collisionmaps/triple3.csv"))
        }
    },
    _4 = {
        {
            texture = "img/asteroids/4/quadruple1.png",
            polygon =  unpack(read_csv("collisionmaps/quadruple1.csv"))
        }, {
            texture = "img/asteroids/4/quadruple2.png",
            polygon =  unpack(read_csv("collisionmaps/quadruple2.csv"))
        }, {
            texture = "img/asteroids/4/quadruple3.png",
            polygon =  unpack(read_csv("collisionmaps/quadruple3.csv"))
        }
    },
    _8 = {
        {
            texture = "img/asteroids/8/eighter1.png",
            polygon =  unpack(read_csv("collisionmaps/eighter1.csv"))
        }, {
            texture = "img/asteroids/8/eighter2.png",
            polygon =  unpack(read_csv("collisionmaps/eighter2.csv"))
        }, {
            texture = "img/asteroids/8/eighter3.png",
            polygon =  unpack(read_csv("collisionmaps/eighter3.csv"))
        }
    }
}

-- load_random_asteroid
local function load_random_asteroid()
    local textures = { "img/asteroids/1/asteroid_brown.png", "img/asteroids/1/asteroid_grey.png" }
    local polygons = {
        {
            59, 163, 29, 143, 29, 137, 3, 105, 1, 83, 6, 36, 17, 22, 36, 9, 56, 1, 86, 5, 93, 10, 108, 9, 119, 16,
            134, 25, 144, 34, 148, 51, 162, 68, 163, 90, 166, 113, 161, 127, 152, 129, 151, 134, 142, 135, 134, 152, 96, 168, 67, 165
        },
        {
            31, 149, 31, 142, 18, 123, 7, 114, 7, 107, 4, 96, 5, 83, 2, 74, 20, 45, 21, 36, 29, 25, 43, 20, 47, 15, 61, 5, 81, 2, 88, 5, 107, 2, 114, 4, 115,
            12, 145, 21, 143, 27, 170, 41, 162, 59, 171, 79, 175, 102, 172, 122, 165, 143, 141, 158, 118, 169, 92, 172, 66, 171, 52, 168, 31, 150, 31, 149
        }
    }

    assert(#textures == #polygons, "bad texture/shape mapping count")

    local choice = math.random(#textures)

    -- return the texture, the polygon, and the choice
    return love.graphics.newImage(textures[choice]), polygons[choice], string.sub(textures[choice], 5, -5)
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

local function new_random_asteroid()
    local new_asteroid = {}
    new_asteroid.texture, new_asteroid.asteroid_collision_coordinates, new_asteroid.asteroid_type = load_random_asteroid()
    new_asteroid.fragments = get_asteroid_fragments(new_asteroid.asteroid_type)
    new_asteroid.width, new_asteroid.height = new_asteroid.texture:getDimensions()
    new_asteroid.is_in_viewport = is_in_viewport
    new_asteroid.on_destroyed = function() end
    return new_asteroid
end

functions[3] = new_random_asteroid



return functions