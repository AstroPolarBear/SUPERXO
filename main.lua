function love.load()
    anim8 = require 'libraries/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")

    player = {}
    player.x = 400
    player.y = 200
    player.speed = 1
    player.spriteSheet = love.graphics.newImage('sprites/bat.png')
    player.grid = anim8.newGrid( 32, 32, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

    player.animations = {}
    player.animations.down = anim8.newAnimation( player.grid('2-4',1), 0.2)
    player.animations.right = anim8.newAnimation( player.grid('2-4',2), 0.2)
    player.animations.up = anim8.newAnimation( player.grid('2-4',3), 0.2)
    player.animations.left = anim8.newAnimation( player.grid('2-4',4), 0.2)

    player.anim = player.animations.left

end


function love.update(dt)
    local isMoving = false

    if love.keyboard.isDown("right") then
        player.x = player.x + player.speed
        player.anim = player.animations.right
        isMoving = true
    end
    if love.keyboard.isDown("up") then
        player.y = player.y - player.speed
        player.anim = player.animations.up
        isMoving = true
    end
    if love.keyboard.isDown("left") then
        player.x = player.x - player.speed
        player.anim = player.animations.left
        isMoving = true
    end
    if love.keyboard.isDown("down") then
        player.y = player.y + player.speed
        player.anim = player.animations.down
        isMoving = true
    end

    player.anim:update(dt)
end


function love.draw()
    love.graphics.setBackgroundColor(0.5,0,1)
    player.anim:draw(player.spriteSheet, player.x, player.y, nil, 3, 3)
end