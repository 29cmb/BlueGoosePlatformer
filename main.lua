local world = love.physics.newWorld(0, 1000, true)
local player = require("modules.player")
local level = require("modules.level")
local sprite = require("modules.sprite")
local editor = require("editor")

function love.load()
    if sprite.IsLoaded == false then sprite:Init() end
    if editor.InEditor == true then editor:Load() return end
    world:setCallbacks(beginContact, endContact)
    level:init(world)

    -- Load a test level
    player:load(world)
    level:loadLevel("levels.test")
end

function love.draw()
    love.graphics.setBackgroundColor(1, 1, 1)
    if editor.InEditor == true then editor:Draw() return end
    
    player:draw()
    level:draw()
end

function love.update(dt)
    if editor.InEditor == true then editor:Update(dt) return end
    player:update(dt)
    world:update(dt)
end

function love.keypressed(key)
    if editor.InEditor == true then return end
    if key == "j" then 
        player:WaterToggle()
    end
end

function love.mousepressed(x, y, button) 
    if editor.InEditor == true then editor:MousePressed(x, y, button) end    
end

function love.mousereleased(x, y)
    if editor.InEditor == true then editor:MouseReleased(x, y) end
end

function beginContact(a, b)
    if a:getUserData() == "Player" and b:getUserData() == "Hazard" then 
        player:YieldRespawn()
    end
end

function endContact() end