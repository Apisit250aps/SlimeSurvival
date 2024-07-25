local anim8 = require 'libs.anim8'


local Enemy = {}
Enemy.__index = Enemy

function Enemy:new(world, x, y)
    love.graphics.setDefaultFilter("nearest", "nearest")

    local self = setmetatable({}, Enemy)
    self.world = world

    -- Sprite and animation settings
    self.sprite = {
        sheet = love.graphics.newImage("assets/sprites/entities/player.png"),
        currentAnimation = nil,
        currentFrame = 1,
        frameTimer = 0,
        frameDuration = 0.125,
        scale = 1,
        size = 32
    }

    -- Create collider
    self.world:addCollisionClass("Enemy")
    self.collider = self.world:newBSGRectangleCollider(x, y, self.sprite.size, self.sprite.size, 10)
    self.collider:setFixedRotation(true)
    self.collider:setCollisionClass("Enemy")


    -- General properties
    self.position = {
        x = self.collider:getX(),
        y = self.collider:getY(),
    }
    self.velocity = {
        x = 0,
        y = 0
    }
    self.speed = {
        min = 50,
        base = 100,
        max = 150
    }
    self.health = {
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

function Enemy:update(dt)
    self.world:update(dt)

    player.health.base = player.health.base - 1
    self.sprite.currentAnimation:update(dt)

    self.velocity.x = 0
    self.velocity.y = 0

    if player.position.x > self.position.x then
        self.velocity.x = self.speed.base
    end
    if player.position.x < self.position.x then
        self.velocity.x = -self.speed.base
    end

    if player.position.y > self.position.y then
        self.velocity.y = self.speed.base
    end
    if player.position.y < self.position.y then
        self.velocity.y = -self.speed.base
    end

    if self.velocity.x > 0 then
        self.sprite.currentAnimation = self.animations.right
    elseif self.velocity.x < 0 then
        self.sprite.currentAnimation = self.animations.left
    elseif self.velocity.y > 0 then
        self.sprite.currentAnimation = self.animations.down
    elseif self.velocity.y < 0 then
        self.sprite.currentAnimation = self.animations.up
    else
        self.sprite.currentAnimation = self.animations.down
    end

    self.collider:setLinearVelocity(self.velocity.x, self.velocity.y)
    self.position.x, self.position.y = self.collider:getPosition()

    self:onCollision()
end

function Enemy:draw()
    self.sprite.currentAnimation:draw(self.sprite.sheet, self.position.x - (self.sprite.size / 2),
        self.position.y - (self.sprite.size / 2), 0, self.sprite.scale, self.sprite.scale)
    self.world:draw()
end

function Enemy:onCollision()
    if self.collider:enter('Player') then
        player.health.base = player.health.base - 1
    end
end

return Enemy
