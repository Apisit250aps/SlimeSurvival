local Camera = require "libs.hump.camera"
local Player = require "src.entities.player"

local tiles = {
    grass1 = love.graphics.newImage("assets/sprites/tiles/grass.png"),
    grass2 = love.graphics.newImage("assets/sprites/tiles/grass2.png"),
    grass3 = love.graphics.newImage("assets/sprites/tiles/grass3.png"),
    flower = love.graphics.newImage("assets/sprites/tiles/flower.png")
}

local mapSize = 96
local mapWidth = mapSize
local mapHeight = mapSize
local tileSize = 32

local map = {}

local function generateMap()
    for x = 1, mapWidth do
        map[x] = {}
        for y = 1, mapHeight do
            local rand = math.random()
            if rand < 0.01 then
                map[x][y] = "flower"
            elseif rand < 0.1 then
                map[x][y] = "grass1"
            elseif rand < 0.15 then
                map[x][y] = "grass2"
            else
                map[x][y] = "grass3"
            end
        end
    end
end

local function drawMap()
    for x = 1, mapWidth do
        for y = 1, mapHeight do
            local tileType = map[x][y]
            if tileType then
                love.graphics.draw(tiles[tileType], (x - (mapWidth / 2)) * tileSize, (y - (mapHeight / 2)) * tileSize)
            end
        end
    end
end

function love.load()
    player = Player:new()
    cam = Camera(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    generateMap()
end

function love.update(dt)
    player:update(dt)
    cam:lockPosition(player.position.x, player.position.y, Camera.smooth.damped(5))

end

function love.draw()
    cam:attach()
    drawMap()
    player:draw()
    cam:detach()
    love.graphics.print(
        "position : x = " .. math.floor(player.position.x) .. " y = " .. math.floor(player.position.y) .. " ", 0, 0)
end
