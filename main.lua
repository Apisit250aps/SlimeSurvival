local Camera = require "libs.hump.camera"
local Player = require "src.entities.player"
local Enemy = require "src.entities.enemy"
local Map = require "src.generators.map"


-- Initialization function
function love.load()
    cam = Camera(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    map = Map:new(96, 96, 32)
    player = Player:new(map.world, 0, 0)
   
end

-- Update function
function love.update(dt)
    player:update(dt)
    cam:lookAt(player.position.x, player.position.y)
    map:update(dt)
end

-- Draw function
function love.draw()
    cam:attach()
    map:draw()
    player:draw()

    cam:detach()
    -- Display player and enemy positions and health
    love.graphics.print("Player position: x = " .. player.position.x .. " y = " .. player.position.y, 10, 10)
    love.graphics.print("Player HP: " .. math.floor(player.health.base), 10, 50)
    love.graphics.print(""..player.velocity.x.."",10,70)
end
