local anim8 = require 'libs.anim8'

Player = {}
Player.__index = Player

local animations

function Player:new()
    love.graphics.setDefaultFilter("nearest", "nearest")
    local self = setmetatable({}, Player)

    -- General properties
    self.position = { x = 0, y = 0 }
    self.speed = { min = 250, base = 500, max = 250 }
    self.health = { min = 0, base = 100, max = 100 }
    self.stamina = { min = 0, base = 100, max = 100 }

    -- Sprite and animation setup
    self.sprite = {
        sheet = love.graphics.newImage("assets/sprites/entities/player.png"),
        currentAnimation = nil,
        currentFrame = 1,
        frameTimer = 0,
        frameDuration = 0.125,
        scale = 1.5
    }

    local g = anim8.newGrid(32, 32, self.sprite.sheet:getWidth(), self.sprite.sheet:getHeight())
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
    self.sprite.currentAnimation:update(dt)

    if love.keyboard.isDown("d") then
        self.position.x = self.position.x + self.speed.base * dt
        self.position.y = self.position.y + 1
        self.sprite.currentAnimation = self.animations.right
        self.position.y = self.position.y - 1
    elseif love.keyboard.isDown("a") then
        self.position.x = self.position.x - self.speed.base * dt
        self.sprite.currentAnimation = self.animations.left
    elseif love.keyboard.isDown("s") then
        self.position.y = self.position.y + self.speed.base * dt
        self.sprite.currentAnimation = self.animations.down
    elseif love.keyboard.isDown("w") then
        self.position.y = self.position.y - self.speed.base * dt
        self.sprite.currentAnimation = self.animations.up
    else
        self.sprite.currentAnimation = self.animations.down
    end
end

function Player:draw()
    -- Draw sprite
    self.sprite.currentAnimation:draw(self.sprite.sheet, self.position.x, self.position.y, 0, self.sprite.scale,
        self.sprite.scale)
end



return Player
