local anim8 = require 'libs.anim8'

local Enemy = {}
Enemy.__index = Enemy

-- Constructor for the Enemy class
function Enemy:new( x, y)
    love.graphics.setDefaultFilter("nearest", "nearest")


    local self = setmetatable({}, Enemy)



    self.position = { x = x, y = y }


    self.speed = {
        min = 90,
        base = 90,
        max = 160
    }

    self.health = {
        min = 0,
        base = 100,
        max = 100
    }

    self.sprite = {
        sheet = love.graphics.newImage("assets/sprites/entities/player.png"),
        currentAnimation = nil,
        currentFrame = 1,
        frameTimer = 0,
        frameDuration = 0.125,
        scale = 1,
        size = 32
    }



    local g = anim8.newGrid(self.sprite.size, self.sprite.size, self.sprite.sheet:getWidth(),
        self.sprite.sheet:getHeight())
    self.animations = {
        right = anim8.newAnimation(g('1-4', 2), 0.125),
        left = anim8.newAnimation(g('1-4', 3), 0.125),
        down = anim8.newAnimation(g('1-4', 1), 0.125),
        up = anim8.newAnimation(g('1-4', 4), 0.125)
    }

    self.sprite.currentAnimation = self.animations.down

    return self
end

-- Update function to move the enemy towards the target position
function Enemy:update(moveX, moveY, dt)
    self.speed.base = love.math.random(self.speed.min, self.speed.max,10)
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

    self.sprite.currentAnimation:update(dt)
end

-- Draw function to render the enemy sprite
function Enemy:draw()
    -- Draw sprite

    self.sprite.currentAnimation:draw(self.sprite.sheet, self.position.x, self.position.y, 0, self.sprite.scale,
        self.sprite.scale)
end

return Enemy
