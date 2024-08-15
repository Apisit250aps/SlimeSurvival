local Map = require "src.generators.map"

-- Initialization function
function love.load()

    map = Map:new(72, 72, 32)

end

-- Update function
function love.update(dt)

    map:update(dt)
end

-- Draw function
function love.draw()

    map:draw()

end

function love.keypressed(key)
    if map and map.keypressed then
        map:keypressed(key)
    end
end
