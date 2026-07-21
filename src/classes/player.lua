local renderer = require('src.utils.render_utils')
local physics = require('src.utils.physics_utils')
local input = require('src.utils.input_utils')
local colors = require('src.config.color_table')

local Player = {}

function Player.new(playerConfig, pos, size, speed)
    -- holds data unique to the instance
    local self = {}
    self.config = require(playerConfig)
    self.pos = pos
    self.speed = self.config.speed * speed
    self.size = self.config.size * size
    self.movementDir = {0, 0}

    -- color assignment
    self.color = colors.white

    -- links funcs that are not instance specific
    setmetatable(self, { __index = Player})

    return self
end

-- runtime funcs
function Player:setTarget(pos)
    self.targetPos = pos
end

function Player:setSpeed(newSpeed)
    self.speed = newSpeed
end

function Player:setPos(newPos)
    self.pos = newPos
end

-- render
function Player:draw()
    renderer.drawDot(self.pos, self.color, self.size)
end

-- update
function Player:update(deltaTime)
    input.updateMovementDir(self.movementDir)
    physics.moveObject(self.pos, self.speed * deltaTime, self.movementDir)
end

return Player