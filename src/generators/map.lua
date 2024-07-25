local wf = require "libs.windfield"
local Camera = require "libs.hump.camera"
local Player = require "src.entities.player"

Map = {}
Map.__index = Map

function Map:new(width, height, tileSize)
    local self = setmetatable({}, Map)
    self.width = width
    self.height = height
    self.tileSize = tileSize
    self.tiles = {
        grass1 = love.graphics.newImage("assets/sprites/tiles/grass.png"),
        grass2 = love.graphics.newImage("assets/sprites/tiles/grass2.png"),
        grass3 = love.graphics.newImage("assets/sprites/tiles/grass3.png"),
        flower = love.graphics.newImage("assets/sprites/tiles/flower.png"),
        rock = love.graphics.newImage("assets/sprites/tiles/rock.png")
    }
    self.map = {}
    self.world = wf.newWorld(0, 0, true)

    self.world:addCollisionClass("Wall")
    self:generateMap()

    cam = Camera(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    self:createMapBoundaries()
    self:createObjects()
    return self
end

function Map:generateMap()
    for x = 1, self.width do
        self.map[x] = {}
        for y = 1, self.height do
            local rand = math.random()
            if rand < 0.005 then
                self.map[x][y] = "rock"
            elseif rand < 0.01 then
                self.map[x][y] = "flower"
            elseif rand < 0.1 then
                self.map[x][y] = "grass1"
            elseif rand < 0.15 then
                self.map[x][y] = "grass2"
            else
                self.map[x][y] = "grass3"
            end
        end
    end
end

function Map:createObjects()
    for x = 1, self.width do
        for y = 1, self.height do
            local tileType = self.map[x][y]
            if tileType then
                if tileType == "rock" then
                    self.world:newRectangleCollider((x - (self.width / 2)) * self.tileSize,
                        ((y - (self.width / 2)) * self.tileSize) + self.tileSize - 8, self.tileSize, 8)
                        :setType('static')
                end
            end
        end
    end
end

function Map:drawRock()
    for x = 1, self.width do
        for y = 1, self.height do
            local tileType = self.map[x][y]
            if tileType == "rock" then
                -- love.graphics.setDefaultFilter("nearest", "nearest")
                love.graphics.draw(self.tiles[tileType], (x - (self.width / 2)) * self.tileSize,
                    (y - (self.height / 2)) * self.tileSize)
            end
        end
    end

end

function Map:createMapBoundaries()

    local halfWidth = (self.width / 2) * self.tileSize
    local halfHeight = (self.height / 2) * self.tileSize

    local left = self.world:newRectangleCollider(-halfWidth, -halfHeight, self.tileSize,
        self.height * self.tileSize + (self.tileSize * 2))
    local right = self.world:newRectangleCollider(halfWidth + self.tileSize, -halfHeight, self.tileSize,
        self.height * self.tileSize + (self.tileSize * 2))
    -- 
    local top = self.world:newRectangleCollider(-halfWidth + self.tileSize, -halfHeight, self.width * self.tileSize,
        self.tileSize)
    local bottom = self.world:newRectangleCollider(-halfWidth + self.tileSize, halfHeight + self.tileSize,
        self.width * self.tileSize, self.tileSize)
    -- -- 
    left:setType('static')
    left:setCollisionClass('Wall')
    -- -- 
    top:setType('static')
    top:setCollisionClass('Wall')
    -- -- 
    right:setType('static')
    right:setCollisionClass('Wall')
    -- -- 
    bottom:setType('static')
    bottom:setCollisionClass('Wall')
end

function Map:update(dt)
    self.world:update(dt)
end

function Map:draw()
    -- self.world:setQueryDebugDrawing(true)
    for x = 1, self.width do
        for y = 1, self.height do
            local tileType = self.map[x][y]
            if tileType then
                love.graphics.setDefaultFilter("nearest", "nearest")
                love.graphics.draw(self.tiles[tileType], (x - (self.width / 2)) * self.tileSize,
                    (y - (self.height / 2)) * self.tileSize)
            end
        end
    end

end

return Map
