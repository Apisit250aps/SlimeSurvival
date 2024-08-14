local anim8 = require 'libs.anim8'

local Player = {}
Player.__index = Player

function Player:new(world, x, y)
    love.graphics.setDefaultFilter("nearest", "nearest")

    local self = setmetatable({}, Player)
    self.world = world

    -- Sprite และการตั้งค่าแอนิเมชั่น
    self.sprite = {
        sheet = love.graphics.newImage("assets/sprites/entities/player.png"),
        currentAnimation = nil,
        currentFrame = 1,
        frameTimer = 0,
        frameDuration = 0.125,
        scale = 1,
        size = 32
    }

    self.score = 0

    -- สร้างคอลลิเดอร์
    self.collider = self.world:newBSGRectangleCollider(x, y, self.sprite.size, self.sprite.size, 10)
    self.collider:setFixedRotation(true) -- ป้องกันไม่ให้ผู้เล่นหมุน
    self.world:addCollisionClass("Player")
    self.collider:setCollisionClass('Player')
    -- คุณสมบัติทั่วไป
    self.position = {
        x = self.collider:getX(),
        y = self.collider:getY()
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

    -- รีเซ็ตความเร็ว
    self.velocity.x = 0
    self.velocity.y = 0

    if love.keyboard.isDown("d") then
        self.velocity.x = self.speed.base
    end
    if love.keyboard.isDown("a") then
        self.velocity.x = self.speed.base * -1
    end
    if love.keyboard.isDown("s") then
        self.velocity.y = self.speed.base
    end
    if love.keyboard.isDown("w") then
        self.velocity.y = self.speed.base * -1
    end

    if self.velocity.x > 0 then
        self.sprite.currentAnimation = self.animations.right
    end
    if self.velocity.x < 0 then
        self.sprite.currentAnimation = self.animations.left
    end
    if self.velocity.y > 0 then
        self.sprite.currentAnimation = self.animations.down
    end
    if self.velocity.y < 0 then
        self.sprite.currentAnimation = self.animations.up
    end
    if self.velocity.x == 0 and self.velocity.y == 0 then
        self.sprite.currentAnimation = self.animations.down
    end

    self.collider:setLinearVelocity(self.velocity.x, self.velocity.y)

    -- ซิงค์ตำแหน่งผู้เล่นกับตำแหน่งของคอลลิเดอร์
    self.position.x, self.position.y = self.collider:getPosition()

end

function Player:draw()
    -- self.world:draw()
    self.sprite.currentAnimation:draw(self.sprite.sheet, self.position.x - (self.sprite.size / 2),
        self.position.y - (self.sprite.size / 2), 0, self.sprite.scale, self.sprite.scale)

end

function Player:addScore(amount)
    self.score = self.score + amount
end

return Player
