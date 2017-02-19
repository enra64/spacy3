--
-- Created by IntelliJ IDEA.
-- User: arne
-- Date: 19.02.17
-- Time: 13:08
-- To change this template use File | Settings | File Templates.
--

local functions = {}

local function check_collides(a, b)
    return a.x < b.x + b.width and
            a.x + a.width > b.x and
            a.y < b.y + b.height and
            a.height + a.y > b.y
end
functions.check_collides = check_collides

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
functions.remove_all_colliding = remove_all_colliding

local function check_collides_with_table(a, table)
    for _, o in ipairs(table) do
        if check_collides(o, a) then
            return true
        end
    end
    return false
end
functions.check_collides_with_table = check_collides_with_table

return functions