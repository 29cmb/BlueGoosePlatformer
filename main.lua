local world = love.physics.newWorld(0, 1000, true)
local player = require("modules.player")
local Sprites = {}

function love.load()
    for name,spr in pairs(Sprites) do 
        Sprites[name] = love.graphics.newImage(spr)
    end

    world:setCallbacks(beginContact, endContact)

    player:load(world)
end

function love.draw()
    player:draw()
end

function love.update(dt)
   player:update(dt) 
end

function beginContact()
    -- handle death and stuff like that
end

function endContact() end