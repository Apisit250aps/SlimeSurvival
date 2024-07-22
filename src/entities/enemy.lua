Enemy = {}
Enemy.__index = Enemy

-- Constructor for the Enemy class
function Enemy:new()
    love.graphics.setDefaultFilter("nearest", "nearest")

    local spriteSheet = love.graphics.newImage("assets/sprites/entities/enemy.jpg")
    if not spriteSheet then
        error("Failed to load enemy sprite")
    end

    local this = {
        position = {
            x = 120, -- Initial position X
            y = 120  -- Initial position Y
        },
        speed = {
            min = 90,
            base = 50,
            max = 90
        },
        health = {
            min = 0,
            base = 100,
            max = 100
        },
        sprite = {
            sheet = spriteSheet
        },
        scale = {
            x = 0.3,
            y = 0.3
        }
    }

    setmetatable(this, self)
    return this
end

-- Update function to move the enemy towards the target position
function Enemy:update(moveX, moveY, dt)
    -- Move in the X direction
    if moveX > self.position.x then
        self.position.x = self.position.x + self.speed.base * dt
    else
        self.position.x = self.position.x - self.speed.base * dt
    end

    -- Move in the Y direction
    if moveY > self.position.y then
        self.position.y = self.position.y + self.speed.base * dt
    else
        self.position.y = self.position.y - self.speed.base * dt
    end
end

-- Draw function to render the enemy sprite
function Enemy:draw()
    love.graphics.draw(self.sprite.sheet, self.position.x, self.position.y, 0, self.scale.x, self.scale.y)
end

return Enemy
