function love.load()
    hamster = love.graphics.newImage("my_spaceship_with_propulsion.png")
    x = 50
    y = 50
    speed = 300
end

function love.update(dt)
    if love.keyboard.isDown("right") then
        x = x + (speed * dt)
    end
    if love.keyboard.isDown("left") then
        x = x - (speed * dt)
    end
    if love.keyboard.isDown("up") then
        y = y - (speed * dt)
    end
    if love.keyboard.isDown("down") then
        y = y + (speed * dt)
    end
end

function love.draw()
    love.graphics.draw(hamster, x, y)
end
