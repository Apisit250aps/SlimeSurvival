local Map = require "src.generators.map"

-- Initialization function
function love.load()

    -- Initialize the map
    map = Map:new(64, 64, 32)
end

-- Update function
function love.update(dt)
    map:update(dt)
end

-- Draw function
function love.draw()
    -- Draw the map
    map:draw()
end

function love.keypressed(key)
    if map and map.keypressed then
        map:keypressed(key)
    end
end
