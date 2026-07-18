local Entity = require('src.classes.entity')
-- configs
local lizard = 'src.config.entities.lizard_config'

-- declaration
local mousePos = {0, 0}
local testLizard = nil

-- input handling
function love.mousemoved(x, y)
    mousePos = {x, y}
end

-- init
function love.load()
    testLizard = Entity.new(lizard, {960, 340}, 1, math.pi, mousePos, 1)
end

---------------
-- Game loop --
---------------

-- render
function love.draw()
    testLizard:draw()
end

-- update
function love.update(dt)
    testLizard:setTarget(mousePos)
    testLizard:update(dt)
end