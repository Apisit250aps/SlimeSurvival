local Camera = require "libs.hump.camera"
local Player = require "src.entities.player"
local Map = require "src.generators.map"

function love.load()
    player = Player:new()
    cam = Camera(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    map = Map:new(96, 96, 32)
end

function love.update(dt)

    player:update(dt)
    cam:lockPosition(player.position.x, player.position.y, Camera.smooth.damped(20))

end

function love.draw()
    cam:attach()
    -- 
    map:draw()
    player:draw()
    -- 
    cam:detach()
    love.graphics.print("FPS: "..tostring(love.timer.getFPS()), 0, 15)
    love.graphics.print(
        "position : x = " .. math.floor(player.position.x) .. " y = " .. math.floor(player.position.y) .. " ", 0, 0)
end
