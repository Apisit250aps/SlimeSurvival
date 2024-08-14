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
        rock = love.graphics.newImage("assets/sprites/tiles/rock.png"),
        coin = love.graphics.newImage("assets/sprites/tiles/coin.png")
    }
    self.map = {}
    self.coins = {}
    self.world = wf.newWorld(0, 0, true)

    self.world:addCollisionClass("Wall")
    self.world:addCollisionClass("Coin")
    self:generateMaze()

    cam = Camera(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    player = Player:new(self.world, 735, 720)
    self:createMapBoundaries()
    self:createObjects()
    return self
end


function Map:update(dt)
    self.world:update(dt)
    player:update(dt)
    cam:lookAt(player.collider:getX(), player.collider:getY())

    -- Check for coin collisions
    local px, py = player.collider:getPosition()
    local px1, py1 = px - 16, py - 16 -- Adjust according to player collider size

    for i, coin in ipairs(self.coins) do
        local cx, cy = (coin.x - (self.width / 2)) * self.tileSize, (coin.y - (self.height / 2)) * self.tileSize
        if px1 < cx + self.tileSize and px1 + 32 > cx and py1 < cy + self.tileSize and py1 + 32 > cy then
            if self:collectCoin(coin.x, coin.y) then
                player:addScore(10) -- Add points for each collected coin
            end
        end
    end
end

function Map:draw()
    cam:attach()
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

    for _, coin in ipairs(self.coins) do
        love.graphics.draw(self.tiles.coin, (coin.x - (self.width / 2)) * self.tileSize,
            (coin.y - (self.height / 2)) * self.tileSize)
    end
    player:draw()
    cam:detach()

end


function Map:generateMaze()
    -- Initialize the map with walls (rocks)
    for x = 1, self.width do
        self.map[x] = {}
        for y = 1, self.height do
            self.map[x][y] = "rock"
        end
    end

    -- Maze generation using Recursive Backtracker algorithm with 2-tile wide paths
    local stack = {}
    local visited = {}
    for x = 1, self.width, 2 do
        visited[x] = {}
        for y = 1, self.height, 2 do
            visited[x][y] = false
        end
    end

    local function isValid(x, y)
        return x > 0 and x <= self.width and y > 0 and y <= self.height
    end

    local function getNeighbors(x, y)
        local neighbors = {}
        local directions = {{
            x = 4,
            y = 0
        }, -- right
        {
            x = -4,
            y = 0
        }, -- left
        {
            x = 0,
            y = 4
        }, -- down
        {
            x = 0,
            y = -4
        } -- up
        }

        -- Shuffle the directions to increase randomness
        for i = #directions, 2, -1 do
            local j = math.random(i)
            directions[i], directions[j] = directions[j], directions[i]
        end

        for _, dir in ipairs(directions) do
            local nx, ny = x + dir.x, y + dir.y
            if isValid(nx, ny) and not visited[nx][ny] then
                table.insert(neighbors, {
                    x = nx,
                    y = ny
                })
            end
        end
        return neighbors
    end

    local function removeWall(x1, y1, x2, y2)
        local wx, wy = (x1 + x2) / 2, (y1 + y2) / 2
        for i = -1, 0 do
            for j = -1, 0 do
                self.map[wx + i][wy + j] = "grass1"
            end
        end
    end

    -- Start from a random position
    local startX, startY = 2 * math.random(1, math.floor(self.width / 4)) * 2 - 1,
        2 * math.random(1, math.floor(self.height / 4)) * 2 - 1
    table.insert(stack, {
        x = startX,
        y = startY
    })
    visited[startX][startY] = true
    for i = -1, 0 do
        for j = -1, 0 do
            self.map[startX + i][startY + j] = "grass1"
        end
    end

    -- Define exit position on one of the edges
    local exitX, exitY
    local exitSide = math.random(1, 4)
    if exitSide == 1 then
        exitX = 1
        exitY = 2 * math.random(1, math.floor(self.height / 4)) * 2 - 1
    elseif exitSide == 2 then
        exitX = self.width
        exitY = 2 * math.random(1, math.floor(self.height / 4)) * 2 - 1
    elseif exitSide == 3 then
        exitX = 2 * math.random(1, math.floor(self.width / 4)) * 2 - 1
        exitY = 1
    else
        exitX = 2 * math.random(1, math.floor(self.width / 4)) * 2 - 1
        exitY = self.height
    end

    -- Ensure exit is on grass
    for i = -1, 0 do
        for j = -1, 0 do
            self.map[exitX + i][exitY + j] = "grass1"
        end
    end

    while #stack > 0 do
        local current = stack[#stack]
        local neighbors = getNeighbors(current.x, current.y)

        if #neighbors > 0 then
            local next = neighbors[math.random(#neighbors)]
            removeWall(current.x, current.y, next.x, next.y)
            visited[next.x][next.y] = true
            for i = -1, 0 do
                for j = -1, 0 do
                    self.map[next.x + i][next.y + j] = "grass1"
                end
            end
            table.insert(stack, next)
        else
            table.remove(stack)
        end
    end

    -- Generate coins on grass tiles
    for x = 1, self.width do
        for y = 1, self.height do
            if self.map[x][y]:find("grass") and math.random() < 0.05 then
                table.insert(self.coins, {
                    x = x,
                    y = y
                })
            end
        end
    end

    -- Mark the exit for visual purposes (optional)
    self.map[exitX][exitY] = "flower"
end

function Map:createObjects()
    for x = 1, self.width do
        for y = 1, self.height do
            local tileType = self.map[x][y]
            if tileType == "rock" then
                wall = self.world:newRectangleCollider((x - (self.width / 2)) * self.tileSize,
                    (y - (self.width / 2)) * self.tileSize, self.tileSize, self.tileSize)
                wall:setType('static')
                wall:setCollisionClass('Wall')
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
    local top = self.world:newRectangleCollider(-halfWidth + self.tileSize, -halfHeight, self.width * self.tileSize,
        self.tileSize)
    local bottom = self.world:newRectangleCollider(-halfWidth + self.tileSize, halfHeight + self.tileSize,
        self.width * self.tileSize, self.tileSize)

    left:setType('static')
    left:setCollisionClass('Wall')
    top:setType('static')
    top:setCollisionClass('Wall')
    right:setType('static')
    right:setCollisionClass('Wall')
    bottom:setType('static')
    bottom:setCollisionClass('Wall')
end

function Map:collectCoin(x, y)
    for i, coin in ipairs(self.coins) do
        if coin.x == x and coin.y == y then
            table.remove(self.coins, i)
            return true
        end
    end
    return false
end

return Map
