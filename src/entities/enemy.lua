local anim8 = require 'libs.anim8'
local winf = require "libs.windfield"

local Enemy = {}
Enemy.__index = Enemy

local animations
local world -- Global world variable within this module

-- Constructor for the Enemy class
function Enemy:new()
    love.graphics.setDefaultFilter("nearest", "nearest")
    world = winf.newWorld(0, 0)

    local self = setmetatable({}, Enemy)


    self.collider = world:newBSGRectangleCollider(200, 200, 32, 32, 10)
    self.position = { x = self.collider:getX(), y = self.collider:getY() }


    self.speed = {
        min = 90,
        base = 50,
        max = 90
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

    self.collider:setFixedRotation(true)

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

    -- Update collider position to match the enemy position
    self.collider:setPosition(self.position.x + self.sprite.size / 2, self.position.y + self.sprite.size / 2)
    self.sprite.currentAnimation:update(dt)
end

-- Draw function to render the enemy sprite
function Enemy:draw()
    -- Draw sprite
    world:draw()
    self.sprite.currentAnimation:draw(self.sprite.sheet, self.position.x, self.position.y, 0, self.sprite.scale,
        self.sprite.scale)
    world:draw()
end

return Enemy
