local world = love.physics.newWorld(0, 1000, true)
local player = require("modules.player")
local level = require("modules.level")
local sprite = require("modules.sprite")
local editor = require("editor")
local utils = require("modules.utils")

local inMenu = true
local levelPage = 1
local pages = {}

local menuButtons = {
    ["Play"] = {
        ["Transform"] = {26, 385, 267, 201},
        ["Callback"] = function()
            print("Play")
            local lvl = pages[levelPage]
            if lvl then
                love.filesystem.setIdentity("blue-goose-platformer")
                inMenu = false
                local data = love.filesystem.load(lvl)()
                player:load(world)
                level:loadLevel(data)
            end
        end
    }
}

function love.load()
    if sprite.IsLoaded == false then sprite:Init() end
    if editor.InEditor == true then editor:Load() return end
    world:setCallbacks(beginContact, endContact)
    level:init(world)

    love.filesystem.setIdentity("blue-goose-platformer")
    for _, file in pairs(love.filesystem.getDirectoryItems("/")) do 
        if love.filesystem.getInfo("/" .. file) and file:match("%.bgoose$") then
            table.insert(pages, file)
        end
    end
end

function love.draw()
    love.graphics.setBackgroundColor(1, 1, 1)
    if editor.InEditor == true then editor:Draw() return end
    
    if inMenu == true then
        love.graphics.draw(sprite.MainMenu)
    else
       level:draw()
        player:draw() 
    end
    
end

function love.update(dt)
    if editor.InEditor == true then editor:Update(dt) return end
    if inMenu == false then player:update(dt) end
    world:update(dt)
end

function love.keypressed(key)
    if editor.InEditor == true then return end
    if key == "j" then 
        player:WaterToggle()
    end
end

function love.mousepressed(x, y, button) 
    if editor.InEditor == true then editor:MousePressed(x, y, button) return end
    if inMenu == true then 
        for _,btn in pairs(menuButtons) do 
            if utils:CheckCollision(x, y, 1, 1, btn.Transform[1], btn.Transform[2], btn.Transform[3], btn.Transform[4]) then 
                btn.Callback()
            end
        end
    end
end

function love.mousereleased(x, y)
    if editor.InEditor == true then editor:MouseReleased(x, y) return end
end

function beginContact(a, b)
    if a:getUserData() == "Player" then
        if b:getUserData() == "Spike" and player.IsWater == false then 
            player:YieldRespawn()
        elseif b:getUserData() == "Sponge" and player.IsWater == true then
            player:YieldRespawn()
        end 
    end
end

function endContact() end