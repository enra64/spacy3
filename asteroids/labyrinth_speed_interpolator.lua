--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 17.07.17
-- Time: 17:56
-- To change this template use File | Settings | File Templates.
--

require("splines.bspline")
require("difficulty_handler")


local points = difficulty.get("labyrinth_bspline")
local BASE_SPEED = difficulty.get("labyrinth_base_speed")

local pl = #points
local last_bspline_sector_linear_formula = { m = ((points[pl - 0] - points[pl - 2]) / (points[pl - 1] - points[pl - 3])) }
last_bspline_sector_linear_formula.b = points[pl - 0] - last_bspline_sector_linear_formula.m * points[pl - 1]
local bspline_length = points[pl - 1]
local speed_bspline = BSpline.new(points)
local bspline_max_t = (pl / 2) - 3


-- get_speed
return function(game_duration)
    if game_duration <= bspline_length then
        local game_duration_as_t = (game_duration / bspline_length) * bspline_max_t
        return speed_bspline:eval(game_duration_as_t).y + BASE_SPEED
    else
        return last_bspline_sector_linear_formula.m * game_duration + last_bspline_sector_linear_formula.b + BASE_SPEED
    end
end

