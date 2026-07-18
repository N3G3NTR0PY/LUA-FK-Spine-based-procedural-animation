local parser = require('src.utils.config_utils')
local renderer = require('src.utils.render_utils')
local physics = require('src.utils.physics_utils')
local colors = require('src.config.color_table')

local Entity = {}

function Entity.new(entityConfig, headPos, size, direction, targetPos, speed)
    -- holds data unique to the instance
    local self = {}
    self.config = require(entityConfig)
    self.segmentRadii, self.relativeAngleLimits= parser.parseBody(self.config.body, self.config.unitScale, size)
    self.segmentSpacing = self.config.segmentSpacing * size
    self.segmentPos, self.relativeAngles, self.absoluteAngles, self.sightDir = physics.createBody(
        headPos,
        self.segmentRadii,
        direction,
        self.segmentSpacing
    )
    self.outlineWidth = self.config.outlineWidth * size
    self.targetPos = targetPos
    self.speed = self.config.speed * speed
    self.turnSpeed = self.config.turnSpeed * speed
    self.damping = self.config.damping
    self.snapDistance =  self.config.snapDistance
    self.size = size

    -- color assignment
    self.bodyColor = self.config.bodyColor
    self.outlineColor = self.config.outlineColor

    -- links funcs that are not instance specific
    setmetatable(self, { __index = Entity})

    return self
end

-- runtime funcs
function Entity:setTarget(pos)
    self.targetPos = pos
end

function Entity:setSpeed(newSpeed)
    self.speed = newSpeed
end

-- render
function Entity:draw()
    renderer.drawBody(
        self.segmentPos,
        self.segmentRadii,
        self.outlineWidth,
        {self.bodyColor, self.outlineColor}
    )
    if self.config.debug then
        renderer.debugOverlay(
            self.segmentPos,
            self.relativeAngles,
            self.segmentRadii,
            self.relativeAngleLimits,
            {colors.white, colors.black, colors.black, colors.red},
            self.size,
            self.targetPos,
            self.sightDir
        )
    end
end

-- update
function Entity:update(deltaTime)
    physics.moveBody(
        self.segmentRadii,
        self.relativeAngles,
        self.absoluteAngles,
        self.segmentPos,
        self.targetPos,
        self.sightDir,
        self.segmentSpacing,
        self.speed * deltaTime,
        self.turnSpeed * deltaTime,
        self.relativeAngleLimits,
        self.snapDistance,
        self.damping
    )
end

return Entity