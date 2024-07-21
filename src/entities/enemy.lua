Enemy = {}
Enemy.__index = Enemy

function Enemy:new()
    love.graphics.setDefaultFilter("nearest", "nearest")
    local this = {
        position = {
            x = 120, -- Adjust position for visibility
            y = 120
        },
        speed = {
            min = 90,
            base = 90,
            max = 90,
        },
        health = {
            min = 0,
            base = 100,
            max = 100
        },
        sprite = {
            sheet = love.graphics.newImage("assets/sprites/entities/enemy.jpg"),
        },
        scale = {
            x = 0.3,
            y = 0.3
        }
    }

    if not this.sprite.sheet then
        error("Failed to load enemy sprite")
    end

    setmetatable(this, self)

    return this
end

function Enemy:update(dt)
    -- Add any update logic for the enemy here
end

function Enemy:draw()
    love.graphics.draw(self.sprite.sheet, self.position.x, self.position.y, 0, self.scale.x, self.scale.y)
end

return Enemy