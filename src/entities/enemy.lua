local anim8 = require 'libs.anim8'

local Enemy = {}
Enemy.__index = Enemy

-- Constructor for the Enemy class
function Enemy:new(x, y, target)
    love.graphics.setDefaultFilter("nearest", "nearest")

    local self = setmetatable({}, Enemy)

    -- Initialize position, speed, and health
    self.position = { x = x, y = y }
    self.target = target
    self.speed = { min = 50, max = 75 }
    self.health = { min = 0, max = 100, base = 100 }

    -- Load sprite and animations
    self.sprite = {
        sheet = love.graphics.newImage("assets/sprites/entities/ghost-Sheet.png"),
        scale = 1,
        size = 32,
        frameDuration = 0.2,
        currentAnimation = nil
    }
    local g = anim8.newGrid(self.sprite.size, self.sprite.size, self.sprite.sheet:getWidth(),
        self.sprite.sheet:getHeight())
    self.animations = {
        right = anim8.newAnimation(g('1-4', 1), 0.125),
        left = anim8.newAnimation(g('1-4', 1), 0.125),
        down = anim8.newAnimation(g('1-4', 1), 0.125),
        up = anim8.newAnimation(g('1-4', 1), 0.125)
    }
    self.sprite.currentAnimation = self.animations.down

    return self
end

-- Update function to move the enemy towards the target position
function Enemy:update(dt)
    local directionX = self.target.position.x > self.position.x and 1 or -1
    local directionY = self.target.position.y > self.position.y and 1 or -1
    local speed = love.math.random(self.speed.min, self.speed.max)

    -- Move towards the target
    self.position.x = self.position.x + directionX * speed * dt
    self.position.y = self.position.y + directionY * speed * dt

    -- Update animation
    self.sprite.currentAnimation:update(dt)
end

-- Draw function to render the enemy sprite
function Enemy:draw()
    self.sprite.currentAnimation:draw(self.sprite.sheet, self.position.x, self.position.y, 0, self.sprite.scale,
        self.sprite.scale)
end

return Enemy
