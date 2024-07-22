local world = love.physics.newWorld(0, 1000, true)
local player = require("modules.player")
local level = require("modules.level")
local sprite = require("modules.sprite")

function love.load()
    world:setCallbacks(beginContact, endContact)
    sprite:Init()
    player:load(world)
    level:init(world)
    level:loadLevel("levels.test")
end

function love.draw()
    love.graphics.setBackgroundColor(1, 1, 1)
    player:draw()
    level:draw()
end

function love.update(dt)
   player:update(dt)
   world:update(dt)
end

function beginContact(a, b)
    if a:getUserData() == "Player" and b:getUserData() == "Hazard" then 
        player:YieldRespawn()
    end
end

function endContact() end