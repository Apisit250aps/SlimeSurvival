local Camera = require "libs.hump.camera"
local Player = require "src.entities.player"
local Enemy = require "src.entities.enemy"
local Map = require "src.generators.map"


-- Initialization function
function love.load()
    cam = Camera(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    map = Map:new(96, 96, 32)
    player = Player:new(map.world, 0, 0)
    enemy = Enemy:new(map.world, 100, 100)
end

-- Update function
function love.update(dt)
    player:update(dt)
    enemy:update(dt)
    -- Update camera position to follow player
    cam:lookAt(player.collider:getX(), player.collider:getY())
    map:update(dt)
end

-- Draw function
function love.draw()
    cam:attach()

    map:draw()
    player:draw()
    enemy:draw()

    cam:detach()
    -- Display player and enemy positions and health
    love.graphics.print(
        "Player position: x = " .. math.floor(player.position.x) .. " y = " .. math.floor(player.position.y), 10, 10)
    love.graphics.print("Player HP: " .. math.floor(player.health.base), 10, 50)
    love.graphics.print("Esan blood: " .. math.floor(enemy.health.base) .. "", 10, 70)
    love.graphics.print("E x: " .. enemy.velocity.x .. "", 10, 90)
    love.graphics.print("E y: " .. enemy.velocity.y .. "", 10, 110)
    love.graphics.print("E speed: " .. enemy.speed.base .. "", 10, 130)
    love.graphics.print("Esan Distant: " .. math.floor(enemy.distantSquared) .. "", 10, 150)
end
