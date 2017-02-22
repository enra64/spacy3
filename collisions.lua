--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 19.02.17
-- Time: 13:08
-- To change this template use File | Settings | File Templates.
--

local functions = {}

local function has_collision_point_rectangle(point, rectangle)
    return point.x > rectangle.x and point.x < rectangle.x + rectangle.width and point.y > rectangle.y and point.y < rectangle.y + rectangle.height
end
functions.has_collision_point_rectangle = has_collision_point_rectangle

local function has_rectangular_collision(a, b)
    return a.x < b.x + b.width and
            a.x + a.width > b.x and
            a.y < b.y + b.height and
            a.height + a.y > b.y
end
functions.has_rectangular_collision = has_rectangular_collision

local function remove_all_colliding(collection, colliding_object, collision_handler)
    local had_collision = false
    for index, object in ipairs(collection) do
        if has_rectangular_collision(object, colliding_object) then
            collision_handler(colliding_object, object)
            table.remove(collection, index)
            had_collision = true
        end
    end

    return had_collision
end
functions.remove_all_colliding = remove_all_colliding

local function has_collision(object, table, collision_func)
    for _, o in ipairs(table) do
        if collision_func(o, object) then
            return true
        end
    end
    return false
end
functions.has_collision = has_collision

local function has_rect_collision(collision_check_object, table)
    return has_collision(collision_check_object, table, has_rectangular_collision)
end
functions.has_rect_collision = has_rect_collision

return functions