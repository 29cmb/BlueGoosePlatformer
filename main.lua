local main = {}
local world = love.physics.newWorld(0, 1000, true)
local player = require("modules.player")
local level = require("modules.level")
local sprite = require("modules.sprite")
local editor = require("editor")
local utils = require("modules.utils")
local fonts = require("modules.font")
local pause = require('modules.pause')
local audio = require("modules.audio")
local win = require('modules.win')

local inMenu = true
local levelPage = 1
local pages = {}

local function getFileCount(directory)
    local count = 0
    local items = love.filesystem.getDirectoryItems(directory)
    for _, item in ipairs(items) do
        if love.filesystem.getInfo(directory .. "/" .. item, "file") and item:match("%.bgoose$") then
            count = count + 1
        end
    end
    return count
end

local function tableToString(tbl, indent)
    local result = "{\n"
    local nextIndent = indent .. "    "
    for k, v in pairs(tbl) do
        if type(k) == "string" then
            k = string.format("%q", k)
        end
        if type(v) == "string" then
            v = string.format("%q", v)
        elseif type(v) == "table" then
            v = tableToString(v, nextIndent)
        end
        result = result .. string.format("%s[%s] = %s,\n", nextIndent, k, v)
    end
    result = result .. indent .. "}"
    return result
end

local defaultLevel = {
    ["Start"] = {["X"] = 0, ["Y"] = 0},
    ["Platforms"] = {},
    ["Hazards"] = {},
    ["Gates"] = {}
}

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
                audio.Menu:stop()
                audio.Ingame:play()
            end
        end
    },
    ["Edit"] = {
        ["Transform"] = {406, 385, 267, 201},
        ["Callback"] = function()
            local lvl = pages[levelPage]
            if lvl then
                local data = love.filesystem.load(lvl)()
                if editor.IsLoaded == false then editor:Load() end
                editor:LoadLevel(lvl, data)
                audio.Menu:stop()
                audio.Editor:play()
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
    },
    ["NewLevel"] = {
        ["Transform"] = {265, 188, 275, 82},
        ["Callback"] = function()
            if #pages ~= 0 then levelPage = levelPage + 1 end
            love.filesystem.setIdentity("blue-goose-platformer")
            local name = "Level" .. getFileCount("/") + 1 .. ".bgoose"
            love.filesystem.write(name, "return " .. tableToString(defaultLevel, ""))
        end
    }
}

function love.load()
    if sprite.IsLoaded == false then sprite:Init() end
    if audio.IsLoaded == false then audio:Init() end
    if fonts.IsLoaded == false then fonts:Load() end
    if pause.IsLoaded == false then pause:Load() end
    if win.IsLoaded == false then win:Load() end
    if editor.InEditor == true then editor:Load() return end
    
    world:setCallbacks(beginContact, endContact)
    level:init(world)
    
    audio.Ingame:setVolume(0.5)
    audio.Ingame:setLooping(true)
    
    audio.Menu:setVolume(0.5)
    audio.Menu:setLooping(true)

    audio.Editor:setVolume(0.5)
    audio.Editor:setLooping(true)

    audio.Menu:play()
    
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
        pause:Draw()
        win:Draw()
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
    if key == "j" and editor.InEditor == false then 
        player:WaterToggle()
    elseif key == "escape" and (inMenu == false or editor.InEditor == true) and win.WinVisible == false then
        pause.Paused = not pause.Paused
    end
end

function love.mousepressed(x, y, button)
    if win.WinVisible == true then win:MouseClick(x, y) return end
    if pause.Paused == true then pause:MouseClick(x, y) return end
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

function love.mousemoved(x, y, dx, dy)
    if editor.InEditor == true then editor:MouseMoved(x,y, dx, dy) return end
end

function beginContact(a, b)
    if a:getUserData() == "Player" then
        if b:getUserData() == "Spike" and player.IsWater == false then 
            player:YieldRespawn()
        elseif b:getUserData() == "Sponge" and player.IsWater == true then
            player:YieldRespawn()
        elseif b:getUserData() == "Flag" then
            win.WinVisible = true
        end 
    end
end

function endContact() end

function main:Exit()
    audio.Ingame:stop()
    audio.Menu:play()
    
    inMenu = true
end

return main