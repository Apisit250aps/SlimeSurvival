local Camera = require "libs.hump.camera"
local Player = require "src.entities.player"

function love.load()
    player = Player:new()
    cam = Camera(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
end

function love.update(dt)
    player:update(dt)
    cam:lookAt(player.position.x, player.position.y)
end

function love.draw()
    cam:attach()

    player:draw()

    cam:detach()
    love.graphics.print("position : x = " .. player.position.x .. " y = " .. player.position.y .. " ", 0, 0)
end
