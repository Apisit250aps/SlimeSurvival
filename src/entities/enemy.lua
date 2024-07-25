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
        min = 1,
        base = 20,
        max = 20
    }
    self.health = {
        min = 0,
        base = 10,
        max = 10
    }
    self.distant = 0

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

    self.velocity.x = 0
    self.velocity.y = 0

    self.distant = math.floor(math.sqrt((player.position.x - self.position.x) ^ 2 +
        (player.position.y - self.position.y) ^ 2))

    if math.floor(player.position.x) > math.floor(self.position.x) then
        self.velocity.x = self.speed.base
    end
    if math.floor(player.position.x) < math.floor(self.position.x) then
        self.velocity.x = self.speed.base * -1
    end

    if math.floor(player.position.y) > math.floor(self.position.y) then
        self.velocity.y = self.speed.base
    end
    if math.floor(player.position.y) < math.floor(self.position.y) then
        self.velocity.y = self.speed.base * -1
    end

    if self.velocity.x > 0 then
        self.sprite.currentAnimation = self.animations.right
    elseif self.velocity.x < 0 then
        self.sprite.currentAnimation = self.animations.left
    end
    if self.velocity.y > 0 then
        self.sprite.currentAnimation = self.animations.down
    elseif self.velocity.y < 0 then
        self.sprite.currentAnimation = self.animations.up
    end

    self.collider:setLinearVelocity(self.velocity.x, self.velocity.y)
    self.position.x, self.position.y = self.collider:getPosition()

    self:collision(dt)
end

function Enemy:draw()
    self.sprite.currentAnimation:draw(self.sprite.sheet, self.position.x - (self.sprite.size / 2),
        self.position.y - (self.sprite.size / 2), 0, self.sprite.scale, self.sprite.scale)
end

function Enemy:collision(dt)
    -- Collision callback
    self.collider:setPreSolve(function(collider_1, collider_2, contact)
        if collider_1 == self.collider and collider_2 == player.collider then
            player.health.base = player.health.base - 1 * dt
            self.speed.base = self.speed.min
            self.health.base = self.health.base - 1 * dt
        end
    end
    )
    if self.distant > 32 then
        self.speed.base = self.speed.max
    end

    if self.health.base <= 0 then
        self.world:remove(self.collider)
    end
end

return Enemy
