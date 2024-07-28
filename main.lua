local world = love.physics.newWorld(0, 1000, true)
local player = require("modules.player")
local level = require("modules.level")
local sprite = require("modules.sprite")
local editor = require("editor")
local utils = require("modules.utils")
local fonts = require("modules.font")

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
    },
    ["Previous"] = {
        ["Transform"] = {28, 266, 61, 96},
        ["Callback"] = function()
            if levelPage == 1 then 
                levelPage = #pages
            else
                levelPage = levelPage - 1
            end
        end
    },
    ["Next"] = {
        ["Transform"] = {713, 266, 61, 96},
        ["Callback"] = function()
            if levelPage == #pages then 
                levelPage = 1
            else
                levelPage = levelPage + 1
            end
        end
    },
    ["Delete"] = {
        ["Transform"] = {355, 273, 94, 85},
        ["Callback"] = function()
            local buttonClicked = love.window.showMessageBox("Delete", "Are you sure you would like to delete this level?", {"No", "Yes"})
            if buttonClicked == 2 then 
                love.filesystem.remove(pages[levelPage])
                if levelPage == 1 then 
                    levelPage = #pages - 1
                else 
                    levelPage = levelPage - 1 
                end
            end
        end
    }
}

function love.load()
    if sprite.IsLoaded == false then sprite:Init() end
    if fonts.IsLoaded == false then fonts:Load() end
    if editor.InEditor == true then editor:Load() return end
    world:setCallbacks(beginContact, endContact)
    level:init(world)

    love.filesystem.setIdentity("blue-goose-platformer")
end

function love.draw()
    love.graphics.setBackgroundColor(1, 1, 1)
    if editor.InEditor == true then editor:Draw() return end
    
    if inMenu == true then
        love.graphics.draw(sprite.MainMenu)
        love.graphics.setColor(0,0,0)
        love.graphics.setFont(fonts.Valentiny)
        love.graphics.printf(pages[levelPage] or "You have no levels!", 60, 80, 400)
        love.graphics.setColor(1,1,1)
    else
        level:draw()
        player:draw() 
    end
    
end

function love.update(dt)
    pages = {}
    for _, file in pairs(love.filesystem.getDirectoryItems("/")) do 
        if love.filesystem.getInfo("/" .. file) and file:match("%.bgoose$") then
            table.insert(pages, file)
        end
    end

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