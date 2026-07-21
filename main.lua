local Player = require('src.classes.player')
local Entity = require('src.classes.entity')
-- helpers
local physics = require('src.utils.physics_utils')
local input = require('src.utils.input_utils')
-- configs
local player = 'src.config.player_config'
local lizard = 'src.config.entities.lizard_config'

-- declaration
local mousePos = {0, 0}
local newPlayer, newEntity = nil, nil

-- init
function love.load()
    newPlayer = Player.new(player, {1200, 540}, 1, 1)
    newEntity = Entity.new(lizard, {500, 540}, 1, 0, mousePos, 1)
end

-- input handling
function love.mousemoved(x, y)
    mousePos = {x, y}
end

---------------
-- Game loop --
---------------

-- render
function love.draw()
    newPlayer:draw()
    newEntity:draw()
end

-- update
function love.update(dt)
    newPlayer:update(dt, input.getMovementDir())
    newEntity:setTarget(newPlayer.pos)
    newEntity:update(dt)
end