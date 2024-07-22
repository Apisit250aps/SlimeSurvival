-- Map class
Map = {}
Map.__index = Map

-- Constructor
function Map:new(width, height, tileSize)
    local self = setmetatable({}, Map)
    self.width = width
    self.height = height
    self.tileSize = tileSize
    self.tiles = {
        grass1 = love.graphics.newImage("assets/sprites/tiles/grass.png"),
        grass2 = love.graphics.newImage("assets/sprites/tiles/grass2.png"),
        grass3 = love.graphics.newImage("assets/sprites/tiles/grass3.png"),
        flower = love.graphics.newImage("assets/sprites/tiles/flower.png")
    }
    self.map = {}
    self:generateMap()
    return self
end

-- Map generation
function Map:generateMap()
    for x = 1, self.width do
        self.map[x] = {}
        for y = 1, self.height do
            local rand = math.random()
            if rand < 0.01 then
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

-- Draw the map
function Map:draw()
    for x = 1, self.width do
        for y = 1, self.height do
            local tileType = self.map[x][y]
            if tileType then
                love.graphics.setDefaultFilter("nearest", "nearest")
                love.graphics.draw(self.tiles[tileType], (x - (self.width / 2)) * self.tileSize, (y - (self.height / 2)) * self.tileSize)
            end
        end
    end
end


return Map