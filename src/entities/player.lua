local anim8 = require 'libs.anim8'

local Player = {}
Player.__index = Player

function Player:new(world, x, y)
    love.graphics.setDefaultFilter("nearest", "nearest")

    local self = setmetatable({}, Player)
    self.world = world

    -- Sprite and animation setup
    self.sprite = {
        sheet = love.graphics.newImage("assets/sprites/entities/player.png"),
        currentAnimation = nil,
        currentFrame = 1,
        frameTimer = 0,
        frameDuration = 0.125,
        scale = 1,
        size = 32
    }

    -- Initialize collider
    self.collider = self.world:newRectangleCollider(x, y, self.sprite.size, self.sprite.size)
    self.collider:setFixedRotation(true) -- Prevent the player from rotating

    -- General properties
    self.position = {
        x = x,
        y = y
    }
    self.velocity = {
        x = 0,
        y = 0
    }
    self.speed = {
        min = 250,
        base = 200,
        max = 250
    }
    self.health = {
        min = 0,
        base = 100,
        max = 100
    }
    self.stamina = {
        min = 0,
        base = 100,
        max = 100
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

function Player:update(dt)
    self.world:update(dt)
    self.sprite.currentAnimation:update(dt)

    -- Reset velocity
    self.velocity.x = 0
    self.velocity.y = 0

    if love.keyboard.isDown("d") then
        self.velocity.x = self.velocity.x + self.speed.base * dt
        self.sprite.currentAnimation = self.animations.right
    elseif love.keyboard.isDown("a") then
        self.velocity.x = self.velocity.x - self.speed.base * dt
        self.sprite.currentAnimation = self.animations.left
    elseif love.keyboard.isDown("s") then
        self.velocity.y = self.velocity.y + self.speed.base * dt
        self.sprite.currentAnimation = self.animations.down
    elseif love.keyboard.isDown("w") then
        self.velocity.y = self.velocity.y - self.speed.base * dt
        self.sprite.currentAnimation = self.animations.up
    else
        self.sprite.currentAnimation = self.animations.down
    end

    -- Update collider velocity
    -- self.collider:setLinearVelocity(self.velocity.x, self.velocity.y)

    -- Sync player position with collider position
    self.position.x = self.position.x + self.velocity.x
    self.position.y = self.position.y + self.velocity.y
    self.collider:setLinearVelocity(self.velocity.x, self.velocity.y)
    self.collider:setPosition(self.position.x + self.sprite.size / 2, self.position.y + self.sprite.size / 2)
end

function Player:draw()
    self.world:draw()
    self.sprite.currentAnimation:draw(self.sprite.sheet, self.position.x, self.position.y, 0, self.sprite.scale,
        self.sprite.scale)

end

return Player
