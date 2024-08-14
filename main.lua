local Map = require "src.generators.map"

-- Initialization function
function love.load()

    map = Map:new(48, 48, 32)

end

-- Update function
function love.update(dt)

    map:update(dt)
end

-- Draw function
function love.draw()

    map:draw()

end
