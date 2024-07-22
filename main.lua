local Camera = require "libs.hump.camera"
local Player = require "src.entities.player"
local Enemy = require "src.entities.enemy"
local Map = require "src.generators.map"


-- Initialization function
function love.load()
    player = Player:new()
    cam = Camera(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    map = Map:new(96, 96, 32)
    enemy = Enemy:new()
end

-- Update function
function love.update(dt)

    player:update(dt)
    cam:lookAt(player.position.x, player.position.y)
    enemy:update(player.position.x, player.position.y, dt)
    enemy:update(player.position.x, player.position.y, dt)

    -- Check for collision and reduce player health
    if math.abs(player.position.x - enemy.position.x) < 5 and math.abs(player.position.y - enemy.position.y) < 5 then
        player.health.base = player.health.base - 1 * dt
    end
    -- Check for collision and reduce player health
    if math.abs(player.position.x - enemy.position.x) < 5 and math.abs(player.position.y - enemy.position.y) < 5 then
        player.health.base = player.health.base - 1 * dt
    end
end

-- Draw function
function love.draw()
    cam:attach()
    map:draw()
    enemy:draw()
    player:draw()

    cam:detach()



    -- Display player and enemy positions and health
    love.graphics.print("Player position: x = " .. player.position.x .. " y = " .. player.position.y, 10, 10)
    love.graphics.print("Enemy position: x = " .. enemy.position.x .. " y = " .. enemy.position.y, 10, 30)
    love.graphics.print("Player HP: " .. math.floor(player.health.base), 10, 50)
end
