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
    player = Player:new(self.world, self:randomPlayerSpawn())
    self:createMapBoundaries()
    self:createObjects()

    -- Initialize score and timer
    self.score = 0
    self.timer = 30
    self.gameOver = false

    self:loadHighScore() -- Load the high score

    return self
end

function Map:randomPlayerSpawn()
    -- Find a random grass tile for player spawn
    local validTiles = {}
    for x = 1, self.width do
        for y = 1, self.height do
            if self.map[x][y]:find("grass") then
                table.insert(validTiles, { x = x, y = y })
            end
        end
    end
    local spawnTile = validTiles[math.random(#validTiles)]
    return (spawnTile.x - (self.width / 2)) * self.tileSize, (spawnTile.y - (self.height / 2)) * self.tileSize
end

function Map:update(dt)
    if self.gameOver then
        return
    end

    self.world:update(dt)
    player:update(dt)
    cam:lookAt(player.collider:getX(), player.collider:getY())

    -- Decrease timer
    if self.timer > 0 then
        self.timer = self.timer - dt
    else
        self.timer = 0
        self.gameOver = true
    end

    -- Check for coin collisions
    local px, py = player.collider:getPosition()
    local px1, py1 = px - 16, py - 16 -- Adjust according to player collider size

    for i, coin in ipairs(self.coins) do
        local cx, cy = (coin.x - (self.width / 2)) * self.tileSize, (coin.y - (self.height / 2)) * self.tileSize
        if px1 < cx + self.tileSize and px1 + 32 > cx and py1 < cy + self.tileSize and py1 + 32 > cy then
            if self:collectCoin(coin.x, coin.y) then
                ranScore = math.random(50, 70)
                player:addScore(ranScore)          -- Add points for each collected coin
                self.score = self.score + ranScore -- Update score
            end
        end
    end
    if self.gameOver and self.score > self.highScore then
        self.highScore = self.score
        self:saveHighScore() -- Save the new high score
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

    -- Draw score and timer
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(16))
    love.graphics.print("High Score: " .. self.highScore, 10, 10)
    love.graphics.print("Score: " .. self.score, 10, 30)
    love.graphics.print("Time: " .. math.ceil(self.timer), 10, 50)

    -- Draw game over screen if the game is over
    if self.gameOver then
        love.graphics.setColor(0, 0, 0, 0.7)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(love.graphics.newFont(48)) -- ขนาดตัวอักษรใหญ่ขึ้น
        love.graphics.printf("Game Over", 0, love.graphics.getHeight() / 2 - 50, love.graphics.getWidth(), "center")
        love.graphics.setFont(love.graphics.newFont(36)) -- ขนาดตัวอักษรใหญ่ขึ้นสำหรับคะแนน
        love.graphics.printf("Final Score: " .. self.score, 0, love.graphics.getHeight() / 2 + 10,
            love.graphics.getWidth(), "center")
        love.graphics.printf("Press R to Restart", 0, love.graphics.getHeight() / 2 + 60, love.graphics.getWidth(),
            "center")
    end
end

function Map:keypressed(key)
    if key == "r" and self.gameOver then
        self:reset()
    end
end

function Map:reset()
    self.coins = {}
    self.map = {}
    self.world:destroy()
    self.world = wf.newWorld(0, 0, true)
    self.world:addCollisionClass("Wall")
    self.world:addCollisionClass("Coin")
    self:generateMaze()
    player = Player:new(self.world, self:randomPlayerSpawn())
    self:createMapBoundaries()
    self:createObjects()

    -- Reset score, timer and game state
    self.score = 0
    self.timer = 30
    self.gameOver = false
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
        local directions = { { x = 4, y = 0 }, -- right
            { x = -4, y = 0 },                 -- left
            { x = 0,  y = 4 },                 -- down
            { x = 0,  y = -4 }                 -- up
        }

        -- Shuffle the directions to increase randomness
        for i = #directions, 2, -1 do
            local j = math.random(i)
            directions[i], directions[j] = directions[j], directions[i]
        end

        for _, dir in ipairs(directions) do
            local nx, ny = x + dir.x, y + dir.y
            if isValid(nx, ny) and not visited[nx][ny] then
                table.insert(neighbors, { x = nx, y = ny })
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
    table.insert(stack, { x = startX, y = startY })
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
    elseif exitSide == 4 then
        exitX = 2 * math.random(1, math.floor(self.width / 4)) * 2 - 1
        exitY = self.height
    end

    while #stack > 0 do
        local current = stack[#stack]
        local neighbors = getNeighbors(current.x, current.y)
        if #neighbors > 0 then
            local nextCell = neighbors[math.random(#neighbors)]
            removeWall(current.x, current.y, nextCell.x, nextCell.y)
            table.insert(stack, nextCell)
            visited[nextCell.x][nextCell.y] = true
            for i = -1, 0 do
                for j = -1, 0 do
                    self.map[nextCell.x + i][nextCell.y + j] = "grass1"
                end
            end
        else
            table.remove(stack)
        end
    end

    -- Create exit path
    self.map[exitX][exitY] = "grass1"
end

function Map:createMapBoundaries()
    -- Add invisible walls to the edges of the map
    local wallThickness = 1
    -- Left boundary
    local leftWall = self.world:newRectangleCollider(-(self.width / 2) * self.tileSize - wallThickness,
        -(self.height / 2) * self.tileSize, wallThickness, self.height * self.tileSize)
    leftWall:setType("static")
    leftWall:setCollisionClass("Wall")

    -- Right boundary
    local rightWall = self.world:newRectangleCollider((self.width / 2) * self.tileSize,
        -(self.height / 2) * self.tileSize, wallThickness, self.height * self.tileSize)
    rightWall:setType("static")
    rightWall:setCollisionClass("Wall")

    -- Top boundary
    local topWall = self.world:newRectangleCollider(-(self.width / 2) * self.tileSize,
        -(self.height / 2) * self.tileSize - wallThickness, self.width * self.tileSize, wallThickness)
    topWall:setType("static")
    topWall:setCollisionClass("Wall")

    -- Bottom boundary
    local bottomWall = self.world:newRectangleCollider(-(self.width / 2) * self.tileSize,
        (self.height / 2) * self.tileSize, self.width * self.tileSize, wallThickness)
    bottomWall:setType("static")
    bottomWall:setCollisionClass("Wall")
end

function Map:createObjects()
    -- Create walls and coins based on the map
    for x = 1, self.width do
        for y = 1, self.height do
            if self.map[x][y] == "rock" then
                self:createWall(x, y)
            elseif self.map[x][y]:find("grass") then
                -- Randomly place coins on grass tiles
                if math.random() < 0.1 then
                    self:createCoin(x, y)
                end
            end
        end
    end
end

function Map:createWall(x, y)
    local wall = self.world:newRectangleCollider(
        (x - (self.width / 2)) * self.tileSize,
        (y - (self.height / 2)) * self.tileSize,
        self.tileSize, self.tileSize
    )
    wall:setType("static")
    wall:setCollisionClass("Wall")
end

function Map:createCoin(x, y)
    table.insert(self.coins, { x = x, y = y })
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

function Map:loadHighScore()
    local file = love.filesystem.read("highscore.txt")
    if file then
        self.highScore = tonumber(file)
    else
        self.highScore = 0
    end
end

function Map:saveHighScore()
    love.filesystem.write("highscore.txt", tostring(self.highScore))
end

return Map
