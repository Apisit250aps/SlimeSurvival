local anim8 = require 'libs.anim8'
local winf = require "libs.windfield"

local Player = {}
Player.__index = Player

local animations
local world -- Moved this to be a global variable within this module

function Player:new()
    love.graphics.setDefaultFilter("nearest", "nearest")
    world = winf.newWorld(0, 0)

    local self = setmetatable({}, Player)

    -- Collider setup
    self.collider = world:newBSGRectangleCollider(100, 100, 32, 32, 10)
    
    -- General properties
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
        base = 500,
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

function Player:update(dt)
    world:update(dt)
    self.sprite.currentAnimation:update(dt)

    -- Reset velocity
    self.velocity.x = 0
    self.velocity.y = 0

    if love.keyboard.isDown("d") then
        self.velocity.x = self.speed.base
        self.sprite.currentAnimation = self.animations.right
    elseif love.keyboard.isDown("a") then
        self.velocity.x = -self.speed.base
        self.sprite.currentAnimation = self.animations.left
    elseif love.keyboard.isDown("s") then
        self.velocity.y = self.speed.base
        self.sprite.currentAnimation = self.animations.down
    elseif love.keyboard.isDown("w") then
        self.velocity.y = -self.speed.base
        self.sprite.currentAnimation = self.animations.up
    else
        self.sprite.currentAnimation = self.animations.down
    end

    -- Update position with velocity
    self.position.x = self.position.x + self.velocity.x * dt
    self.position.y = self.position.y + self.velocity.y * dt

    -- Update collider position
    self.collider:setPosition(self.position.x + self.sprite.size / 2, self.position.y + self.sprite.size / 2)
end

function Player:draw()
    world:draw()
    -- Draw sprite
    self.sprite.currentAnimation:draw(self.sprite.sheet, self.position.x, self.position.y, 0, self.sprite.scale,
        self.sprite.scale)
end

return Player
