local anim8 = require 'libs.anim8'

local Enemy = {}
Enemy.__index = Enemy

-- Constructor for the Enemy class
function Enemy:new(x, y, target)
    love.graphics.setDefaultFilter("nearest", "nearest")

    local self = setmetatable({}, Enemy)

    self.position = {
        x = x,
        y = y
    }
    self.speed = {
        min = 50,
        base = 60,
        max = 75
    }
    self.target = target
    self.health = {
        min = 0,
        base = 100,
        max = 100
    }
    self.sprite = {
        sheet = love.graphics.newImage("assets/sprites/entities/ghost-Sheet.png"),
        currentAnimation = nil,
        currentFrame = 1,
        frameTimer = 0,
        frameDuration = 0.2,
        scale = 1,
        size = 32
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
    self.speed.base = love.math.random(self.speed.min, self.speed.max)
    -- Move in the X direction
    if self.target.position.x > self.position.x then
        self.position.x = self.position.x + self.speed.base * dt
    else
        self.position.x = self.position.x - self.speed.base * dt
    end
    -- Move in the Y direction
    if self.target.position.y > self.position.y then
        self.position.y = self.position.y + self.speed.base * dt
    else
        self.position.y = self.position.y - self.speed.base * dt
    end

    self.sprite.currentAnimation:update(dt)
end

-- Draw function to render the enemy sprite
function Enemy:draw()
    -- Draw sprite
    self.sprite.currentAnimation:draw(self.sprite.sheet, self.position.x, self.position.y, 0, self.sprite.scale,
        self.sprite.scale)
end

return Enemy
