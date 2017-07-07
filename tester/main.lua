-- https://coronalabs.com/blog/2014/09/02/tutorial-printing-table-contents/
function print_table( t )
    local print_r_cache={}
    local function sub_print_r(t,indent)
        if (print_r_cache[tostring(t)]) then
            print(indent.."*"..tostring(t))
        else
            print_r_cache[tostring(t)]=true
            if (type(t)=="table") then
                for pos,val in pairs(t) do
                    if (type(val)=="table") then
                        print(indent.."["..pos.."] => "..tostring(val).." {")
                        sub_print_r(val,indent..string.rep(" ",string.len(pos)+8))
                        print(indent..string.rep(" ",string.len(pos)+6).."}")
                    elseif (type(val)=="string") then
                        print(indent.."["..pos..'] => "'..val..'"')
                    else
                        print(indent.."["..pos.."] => "..tostring(val))
                    end
                end
            else
                print(indent..tostring(t))
            end
        end
    end
    if (type(t)=="table") then
        print(tostring(t).." {")
        sub_print_r(t,"  ")
        print("}")
    else
        sub_print_r(t,"  ")
    end
    print()
end

function love.load()
    local joysticks = love.joystick.getJoysticks()
    joystick = joysticks[1]

    position = {x = 400, y = 300}
    speed = 300

    print("axes")
    print_table(joystick:getAxisCount())
    print("vibration: "..tostring(joystick:isVibrationSupported()))
    joystick:setVibration(.5, .5)
end

function love.update(dt)
    if not joystick then return end

    if joystick:isGamepadDown("dpleft") then
        position.x = position.x - speed * dt
    elseif joystick:isGamepadDown("dpright") then
        position.x = position.x + speed * dt
    end

    if joystick:isGamepadDown("dpup") then
        position.y = position.y - speed * dt
    elseif joystick:isGamepadDown("dpdown") then
        position.y = position.y + speed * dt
    end
end

function love.draw()
    love.graphics.circle("fill", position.x, position.y, 50)
end