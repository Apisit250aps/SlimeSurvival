local Camera = require "libs.hump.camera"
local Player = require "src.entities.player"
local Enemy = require "src.entities.enemy"

function love.load()
    player = Player:new()
    cam = Camera(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)

    enemy = Enemy:new()
end

function love.update(dt)

    player:update(dt)
    cam:lookAt(player.position.x, player.position.y)

    enemy:update(player.position.x,player.position.y,dt)
end

function love.draw()
    cam:attach()

    enemy:draw()
    player:draw()


    cam:detach()
    --everthing must in cam function

    love.graphics.print("position : x = " .. player.position.x .. " y = " .. player.position.y .. " ", 0, 0)
end
