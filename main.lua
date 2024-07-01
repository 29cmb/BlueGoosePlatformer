local world = love.physics.newWorld(0, 1000, true)
local player = require("modules.player")
local level = require("modules.level")
local Sprites = {}

function love.load()
    for name,spr in pairs(Sprites) do 
        Sprites[name] = love.graphics.newImage(spr)
    end

    world:setCallbacks(beginContact, endContact)

    player:load(world)
    level:init(world)
    level:loadLevel("levels.test")
end

function love.draw()
    player:draw()
    level:draw()
end

function love.update(dt)
   player:update(dt)
end

function beginContact()
    -- handle death and stuff like that
end

function endContact() end