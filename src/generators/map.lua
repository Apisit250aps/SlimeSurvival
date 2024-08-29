local wf = require "libs.windfield"
local Camera = require "libs.hump.camera"
local Player = require "src.entities.player"
local Enemy = require "src.entities.enemy"
local SoundsPlay = require "src.utils.sound"

Map = {}
Map.__index = Map

local fonts = {
    min = love.graphics.newFont("assets/alagard.ttf", 24),
    mid = love.graphics.newFont("assets/alagard.ttf", 36),
    max = love.graphics.newFont("assets/alagard.ttf", 48)
}

local tileImages = {
    grass1 = love.graphics.newImage("assets/sprites/tiles/grass.png"),
    grass2 = love.graphics.newImage("assets/sprites/tiles/grass2.png"),
    grass3 = love.graphics.newImage("assets/sprites/tiles/grass3.png"),
    flower = love.graphics.newImage("assets/sprites/tiles/flower.png"),
    rock = love.graphics.newImage("assets/sprites/tiles/stone.png"),
    coin = love.graphics.newImage("assets/sprites/tiles/pudding.png")
}

function Map:new(width, height, tileSize)
    local self = setmetatable({}, Map)
    self.width, self.height, self.tileSize = width, height, tileSize
    self.tiles = tileImages
    self.map, self.coins = {}, {}
    self.world = wf.newWorld(0, 0, true)
    self.world:addCollisionClass("Wall")
    self.world:addCollisionClass("Coin")
    self:generateMaze()

    cam = Camera(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    player = Player:new(self.world, self:randomPlayerSpawn())

    self:createMapBoundaries()
    self:createObjects()

    self.score, self.timer, self.gameOver = 0, 0, false
    self.sound = SoundsPlay:new()
    self.sound.src.gameStart:play()
    self:loadHighScore()

    self.enemySpawnTimer, self.enemies, self.enemiesQuantity = 0, {}, 0
    self.coin = 0

    return self
end

function Map:randomPlayerSpawn()
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
    if self.gameOver then return end

    self.world:update(dt)
    player:update(dt)
    if player.state.onMove then self.sound.src.slimeWalk:play() end
    cam:lookAt(player.collider:getX(), player.collider:getY())

    self.enemySpawnTimer = self.enemySpawnTimer + dt
    if self.enemySpawnTimer >= 5 or self.enemiesQuantity == 0 then
        self:spawnEnemy()
    end

    self:updateEnemies(dt)
    self:checkCoinCollisions()
    self.timer = self.timer + dt

    if self.gameOver then
        self.score = self.coin * self.timer / 10
        if self.score > self.highScore then
            self.highScore = math.ceil(self.score)
            self:saveHighScore()
            self.sound.src.gameOver:play()
        end
    end
end

function Map:spawnEnemy()
    self.enemySpawnTimer = 0
    local spawnX, spawnY
    repeat
        spawnX = (math.random(1, self.width) - self.width / 2) * self.tileSize
        spawnY = (math.random(1, self.height) - self.height / 2) * self.tileSize
    until math.sqrt((player.collider:getX() - spawnX) ^ 2 + (player.collider:getY() - spawnY) ^ 2) > math.random(800, 3200)

    table.insert(self.enemies, Enemy:new(spawnX, spawnY, player))
    self.enemiesQuantity = self.enemiesQuantity + 1
end

function Map:updateEnemies(dt)
    for i, enemy in ipairs(self.enemies) do
        enemy:update(dt)
        if self:checkCollision(player.position, enemy.position) then
            self.gameOver = true
        end

        for j, otherEnemy in ipairs(self.enemies) do
            if i ~= j then
                local distance = math.sqrt((enemy.position.x - otherEnemy.position.x) ^ 2 +
                    (enemy.position.y - otherEnemy.position.y) ^ 2)
                if distance < 32 then
                    local pushX, pushY = (enemy.position.x - otherEnemy.position.x) * 0.1,
                        (enemy.position.y - otherEnemy.position.y) * 0.1
                    enemy.position.x, enemy.position.y = enemy.position.x + pushX, enemy.position.y + pushY
                    otherEnemy.position.x, otherEnemy.position.y = otherEnemy.position.x - pushX,
                        otherEnemy.position.y - pushY
                end
            end
        end
    end
end

function Map:checkCoinCollisions()
    local px, py = player.collider:getPosition()
    local px1, py1 = px - 16, py - 16

    for i, coin in ipairs(self.coins) do
        local cx, cy = (coin.x - (self.width / 2)) * self.tileSize, (coin.y - (self.height / 2)) * self.tileSize
        if px1 < cx + self.tileSize and px1 + 32 > cx and py1 < cy + self.tileSize and py1 + 32 > cy then
            if self:collectCoin(coin.x, coin.y) then
                local coinValue = math.random(5, 15)
                player:addScore(coinValue)
                self.coin = self.coin + coinValue
            end
        end
    end
end

function Map:draw()
    cam:attach()
    self:drawMap()
    self:drawCoins()
    player:draw()
    for _, enemy in ipairs(self.enemies) do enemy:draw() end
    cam:detach()

    self:drawUI()
    if self.gameOver then self:drawGameOver() end
end

function Map:drawMap()
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

function Map:drawCoins()
    for _, coin in ipairs(self.coins) do
        love.graphics.draw(self.tiles.coin, (coin.x - (self.width / 2)) * self.tileSize,
            (coin.y - (self.height / 2)) * self.tileSize)
    end
end

function Map:drawUI()
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.min)

    local uiX, uiY, uiWidth, uiHeight = 5, 5, 200, 100
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", uiX, uiY, uiWidth, uiHeight)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("line", uiX, uiY, uiWidth, uiHeight)

    love.graphics.print("High Score: " .. math.ceil(self.highScore), uiX + 10, uiY + 10)
    love.graphics.print("Pudding: " .. self.coin, uiX + 10, uiY + 30)
    love.graphics.print("Time: " .. math.ceil(self.timer), uiX + 10, uiY + 50)
    love.graphics.print("Enemy: " .. self.enemiesQuantity, uiX + 10, uiY + 70)
end

function Map:drawGameOver()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(fonts.max)
    love.graphics.printf("Game Over", 0, love.graphics.getHeight() / 2 - 50, love.graphics.getWidth(), "center")
    love.graphics.setFont(fonts.mid)
    love.graphics.printf("Final Score: " .. math.ceil(self.score), 0, love.graphics.getHeight() / 2 + 10,
        love.graphics.getWidth(), "center")
    love.graphics.printf("Press R to Restart", 0, love.graphics.getHeight() / 2 + 120, love.graphics.getWidth(), "center")
end

function Map:checkCollision(pos1, pos2)
    local distance = math.sqrt((pos1.x - pos2.x) ^ 2 + (pos1.y - pos2.y) ^ 2)
    return distance < 16
end

function Map:keypressed(key)
    if key == "r" and self.gameOver then
        self:reset()
    elseif key == "q" and self.gameOver then
        love.window.close()
    end
end

function Map:reset()
    self.coins, self.map = {}, {}
    self.world:destroy()
    self.world = wf.newWorld(0, 0, true)
    self.world:addCollisionClass("Wall")
    self.world:addCollisionClass("Coin")
    self:generateMaze()
    player = Player:new(self.world, self:randomPlayerSpawn())
    self:createMapBoundaries()
    self:createObjects()

    self.score, self.timer, self.gameOver, self.coin = 0, 0, false, 0
    self.enemies, self.enemySpawnTimer, self.enemiesQuantity = {}, 0, 0
end

function Map:generateMaze()
    for x = 1, self.width do
        self.map[x] = {}
        for y = 1, self.height do
            self.map[x][y] = "rock"
        end
    end

    local stack, visited = {}, {}
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
        local neighbors, directions = {}, { { x = 4, y = 0 }, { x = -4, y = 0 }, { x = 0, y = 4 }, { x = 0, y = -4 } }
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

    local startX, startY = 2 * math.random(1, math.floor(self.width / 4)) * 2 - 1,
        2 * math.random(1, math.floor(self.height / 4)) * 2 - 1
    table.insert(stack, { x = startX, y = startY })
    visited[startX][startY] = true
    for i = -1, 0 do
        for j = -1, 0 do
            self.map[startX + i][startY + j] = "grass1"
        end
    end

    local exitX, exitY
    local exitSide = math.random(1, 4)
    if exitSide == 1 then
        exitX, exitY = 1, 2 * math.random(1, math.floor(self.height / 4)) * 2 - 1
    elseif exitSide == 2 then
        exitX, exitY = self.width, 2 * math.random(1, math.floor(self.height / 4)) * 2 - 1
    elseif exitSide == 3 then
        exitX, exitY = 2 * math.random(1, math.floor(self.width / 4)) * 2 - 1, 1
    elseif exitSide == 4 then
        exitX, exitY = 2 * math.random(1, math.floor(self.width / 4)) * 2 - 1, self.height
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

    self.map[exitX][exitY] = "grass1"
end

function Map:createMapBoundaries()
    local wallThickness = 1
    local boundaries = {
        { -(self.width / 2) * self.tileSize - wallThickness, -(self.height / 2) * self.tileSize,                 wallThickness,              self.height * self.tileSize },
        { (self.width / 2) * self.tileSize,                  -(self.height / 2) * self.tileSize,                 wallThickness,              self.height * self.tileSize },
        { -(self.width / 2) * self.tileSize,                 -(self.height / 2) * self.tileSize - wallThickness, self.width * self.tileSize, wallThickness },
        { -(self.width / 2) * self.tileSize,                 (self.height / 2) * self.tileSize,                  self.width * self.tileSize, wallThickness }
    }

    for _, boundary in ipairs(boundaries) do
        local wall = self.world:newRectangleCollider(unpack(boundary))
        wall:setType("static")
        wall:setCollisionClass("Wall")
    end
end

function Map:createObjects()
    for x = 1, self.width do
        for y = 1, self.height do
            if self.map[x][y] == "rock" then
                self:createWall(x, y)
            elseif self.map[x][y]:find("grass") and math.random() < 0.1 then
                self:createCoin(x, y)
            end
        end
    end
end

function Map:createWall(x, y)
    local wall = self.world:newRectangleCollider(
        (x - (self.width / 2)) * self.tileSize,
        (y - (self.height / 2)) * self.tileSize,
        self.tileSize,
        self.tileSize
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
            local coinSound = self.sound.src.coinSound:clone()
            coinSound:play()
            table.remove(self.coins, i)
            return true
        end
    end
    return false
end

function Map:loadHighScore()
    local file = love.filesystem.read("highscore.txt")
    self.highScore = file and tonumber(file) or 0
end

function Map:saveHighScore()
    love.filesystem.write("highscore.txt", tostring(self.highScore))
end

return Map
