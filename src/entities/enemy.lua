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
        size = 32,
        halfSize = 16
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
    self.velocity = { x = 0, y = 0 }
    self.speed = { min = 1, base = 20, max = 20 }
    self.health = { min = 0, base = 10, max = 10 }
    self.distantSquared = 0

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
    self.sprite.currentAnimation:update(dt)

    local playerPos = player.position
    local selfPos = self.position
    local dx = playerPos.x - selfPos.x                              
    local dy = playerPos.y - selfPos.y

    self.distantSquared = math.sqrt(dx * dx + dy * dy)

    if math.abs(dx) > 1 then
        self.velocity.x = self.speed.base * (dx > 0 and 1 or -1)
        self.sprite.currentAnimation = dx > 0 and self.animations.right or self.animations.left
    else
        self.velocity.x = 0
    end

    if math.abs(dy) > 1 then
        self.velocity.y = self.speed.base * (dy > 0 and 1 or -1)
        self.sprite.currentAnimation = dy > 0 and self.animations.down or self.animations.up
    else
        self.velocity.y = 0
    end

    self.collider:setLinearVelocity(self.velocity.x, self.velocity.y)
    self.position.x, self.position.y = self.collider:getPosition()

    self:collision(dt)
end

function Enemy:draw()
    self.sprite.currentAnimation:draw(self.sprite.sheet, self.position.x - self.sprite.halfSize,
        self.position.y - self.sprite.halfSize, 0, self.sprite.scale, self.sprite.scale)

end

function Enemy:collision(dt)
    self.collider:setPreSolve(function(collider_1, collider_2, contact)
        if collider_1 == self.collider and collider_2 == player.collider then
            player.health.base = player.health.base - dt
            self.speed.base = self.speed.min
            self.health.base = self.health.base - dt
        end
    end)
    if self.distantSquared > 32 then
        self.speed.base = self.speed.max
    end

    if self.health.base <= 0 then
        self.world:remove(self.collider)
        self.toRemove = true
    end
end


return Enemy
