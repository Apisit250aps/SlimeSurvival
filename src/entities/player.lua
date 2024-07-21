local anim8 = require 'libs.anim8'

Player = {}
Player.__index = Player

local animations

function Player:new()
    love.graphics.setDefaultFilter("nearest", "nearest")
    local this = {
        -- genaral
        position = {
            x = 0,
            y = 0
        },
        speed = {
            min = 250,
            base = 250,
            max = 250
        },
        health = {
            min = 0,
            base = 100,
            max = 100
        },
        stamina = {
            min = 0,
            base = 100,
            max = 100
        },
        sprite = {
            sheet = love.graphics.newImage("assets/sprites/entities/player.png"),
            currentAnimation = nil,
            currentFrame = 1,
            frameTimer = 0,
            frameDuration = 0.125,
            scale = 1.5
        }
    }
    -- anim
    local g = anim8.newGrid(32, 32, this.sprite.sheet:getWidth(), this.sprite.sheet:getHeight())
    animations = {
        right = anim8.newAnimation(g('1-4', 2), 0.125),
        left = anim8.newAnimation(g('1-4', 3), 0.125),
        down = anim8.newAnimation(g('1-4', 1), 0.125),
        up = anim8.newAnimation(g('1-4', 4), 0.125)
    }

    this.sprite.currentAnimation = animations.down
    -- finally
    setmetatable(this, self)

    return this
end

function Player:update(dt)
    self.sprite.currentAnimation:update(dt)
    
    if love.keyboard.isDown("d") then
        self.position.x = self.position.x + self.speed.base * dt
        self.position.y = self.position.y + 1
        self.sprite.currentAnimation = animations.right
        self.position.y = self.position.y -1
    elseif love.keyboard.isDown("a") then
        self.position.x = self.position.x - self.speed.base * dt
        self.sprite.currentAnimation = animations.left
    elseif love.keyboard.isDown("s") then
        self.position.y = self.position.y + self.speed.base * dt
        self.sprite.currentAnimation = animations.down
    elseif love.keyboard.isDown("w") then
        self.position.y = self.position.y - self.speed.base * dt
        self.sprite.currentAnimation = animations.up
    else
        self.sprite.currentAnimation = animations.down
    end
end

function Player:draw()
    -- Draw sprite
    self.sprite.currentAnimation:draw(self.sprite.sheet, self.position.x, self.position.y, 0, self.sprite.scale,
        self.sprite.scale)
end

return Player
