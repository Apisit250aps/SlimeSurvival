local anim8 = require 'libs.anim8'

local Player = {}
Player.__index = Player

function Player:new(world, x, y)
    love.graphics.setDefaultFilter("nearest", "nearest")

    local self = setmetatable({}, Player)
    self.world = world

    -- Initialize sprite and animations
    self.sprite = {
        sheet = love.graphics.newImage("assets/sprites/entities/player.png"),
        scale = 1,
        size = 32,
        frameDuration = 0.125,
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

    -- Initialize collider
    self.collider = self.world:newBSGRectangleCollider(x, y, self.sprite.size, self.sprite.size, 10)
    self.collider:setFixedRotation(true)
    self.world:addCollisionClass("Player")
    self.collider:setCollisionClass('Player')

    -- Initialize properties
    self.position = { x = self.collider:getX(), y = self.collider:getY() }
    self.velocity = { x = 0, y = 0 }
    self.speed = { base = 200 }
    self.health = { min = 0, base = 100, max = 100 }
    self.stamina = { min = 0, base = 100, max = 100 }
    self.state = { onMove = false }
    self.score = 0

    return self
end

function Player:update(dt)
    self.world:update(dt)
    self.sprite.currentAnimation:update(dt)

    -- Reset velocity
    self.velocity.x, self.velocity.y = 0, 0

    -- Movement controls
    local speed = self.speed.base
    if love.keyboard.isDown("d", "right") then self.velocity.x = speed end
    if love.keyboard.isDown("a", "left") then self.velocity.x = -speed end
    if love.keyboard.isDown("s", "down") then self.velocity.y = speed end
    if love.keyboard.isDown("w", "up") then self.velocity.y = -speed end

    -- Determine animation based on direction
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

    -- Update movement state
    self.state.onMove = self.velocity.x ~= 0 or self.velocity.y ~= 0
    self.collider:setLinearVelocity(self.velocity.x, self.velocity.y)

    -- Sync player position with collider
    self.position.x, self.position.y = self.collider:getPosition()
end

function Player:draw()
    self.sprite.currentAnimation:draw(
        self.sprite.sheet,
        self.position.x - self.sprite.size / 2,
        self.position.y - self.sprite.size / 2,
        0,
        self.sprite.scale,
        self.sprite.scale
    )
end

function Player:addScore(amount)
    self.score = self.score + amount
end

return Player
