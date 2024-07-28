local editor = {}
local Sprites = require("modules.sprite")
local utils = require("modules.utils")
editor.InEditor = false

editor.CameraData = {
    ["CameraX"] = 400,
    ["CameraY"] = 200,
    ["CamSpeed"] = 500
}

local directions = {a = {1,0}, d = {-1,0}, w = {0,1}, s = {0,-1}}

local level = {
    ["Start"] = {["X"] = 0, ["Y"] = 0},
    ["Platforms"] = {},
    ["Hazards"] = {},
    ["Gates"] = {}
}

local fileName = nil

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

local placeMode = "none"

function editor:Load()
    level = {
        ["Start"] = {["X"] = 0, ["Y"] = 0},
        ["Platforms"] = {},
        ["Hazards"] = {},
        ["Gates"] = {}
    } -- return level to defaults when the editor loads

    buttons = {
        {
            ["Sprite"] = Sprites.PlayerButton,
            ["Transform"] = {10, 10, 75, 75},
            ["IsVisible"] = function()
                return true
            end,
            ["Selected"] = function()
                return placeMode == "startPos"
            end,
            ["Callback"] = function(self)
                placeMode = "startPos"
            end
        },
        {
            ["Sprite"] = Sprites.SpikeButton,
            ["Transform"] = {90, 10, 75, 75},
            ["IsVisible"] = function()
                return true
            end,
            ["Selected"] = function()
                return placeMode == "spike"
            end,
            ["Callback"] = function(self)
                placeMode = "spike"
            end
        },
        {
            ["Sprite"] = Sprites.PlatformButton,
            ["Transform"] = {170, 10, 75, 75},
            ["IsVisible"] = function() 
                return true
            end,
            ["Selected"] = function()
                return placeMode == "platform"
            end,
            ["Callback"] = function(self)
                placeMode = "platform"
            end
        },
        {
            ["Sprite"] = Sprites.WaterButton,
            ["Transform"] = {250, 10, 75, 75},
            ["IsVisible"] = function()
                return true
            end,
            ["Selected"] = function() 
                return placeMode == "waterPlatform"
            end,
            ["Callback"] = function()
                placeMode = "waterPlatform"
            end
        },
        {
            ["Sprite"] = Sprites.SpongeButton,
            ["Transform"] = {330, 10, 75, 75},
            ["IsVisible"] = function()
                return true
            end,
            ["Selected"] = function()
                return placeMode == "sponge"
            end,
            ["Callback"] = function()
                placeMode = "sponge"
            end
        },
        {
            ["Sprite"] = Sprites.WinButton,
            ["Transform"] = {410, 10, 75, 75},
            ["IsVisible"] = function() 
                return true
            end,
            ["Selected"] = function()
                return placeMode == "win"
            end,
            ["Callback"] = function()
                placeMode = "win"
            end
        },
        {
            ["Sprite"] = Sprites.SaveButton,
            ["Transform"] = {490, 10, 75, 75},
            ["IsVisible"] = function()
                return true
            end,
            ["Selected"] = function()
                return false
            end,
            ["Callback"] = function()
                if level.End then
                    if fileName == nil then fileName = "Level" .. getFileCount("/") + 1 .. ".bgoose" end
                    love.filesystem.setIdentity("blue-goose-platformer")
                    love.filesystem.write(fileName, "return " .. tableToString(level, ""))
                    love.window.showMessageBox("Saved", "Save was successful!")
                else
                    love.window.showMessageBox("Error", "You cannot save a level without an end flag!")
                end
            end
        }
    }
end

local mX, mY = 0, 0
local placingPlatform = false

function editor:Draw()
    for _,platform in pairs(level.Platforms) do
        love.graphics.setColor(platform.Color.R, platform.Color.B, platform.Color.G)
        love.graphics.rectangle("fill", platform.X + self.CameraData.CameraX, platform.Y + self.CameraData.CameraY, platform.W, platform.H)
        love.graphics.setColor(1, 1, 1)
    end

    for _,hazard in pairs(level.Hazards) do
        if hazard.Type == "Spike" then 
            love.graphics.draw(Sprites.Spike, hazard.X + self.CameraData.CameraX, hazard.Y + self.CameraData.CameraY)
        elseif hazard.Type == "Sponge" then
            love.graphics.draw(Sprites.Sponge, hazard.X + self.CameraData.CameraX, hazard.Y + self.CameraData.CameraY, 0, hazard.W / 536, hazard.H / 350)
        end
    end

    for _,gate in pairs(level.Gates) do 
        love.graphics.draw(Sprites.Water, gate.X + self.CameraData.CameraX, gate.Y + self.CameraData.CameraY, 0, gate.W / 643, gate.H / 360)
    end

    if placingPlatform == true then 
        local sX = math.abs(love.mouse.getX() - mX)
        local sY = math.abs(love.mouse.getY() - mY)

        love.graphics.setColor(0,1,0,0.5)
        love.graphics.rectangle("fill", math.min(mX, love.mouse.getX()), math.min(mY, love.mouse.getY()), sX, sY)
        love.graphics.setColor(1,1,1,1)
    end

    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.draw(Sprites.Player, level.Start.X + self.CameraData.CameraX, level.Start.Y + self.CameraData.CameraY)
    love.graphics.setColor(1,1,1,1)

    if level.End then 
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.draw(Sprites.EndFlag, level.End.X + self.CameraData.CameraX, level.End.Y + self.CameraData.CameraY)
        love.graphics.setColor(1,1,1,1)
    end
    
    for _,button in pairs(buttons) do
        if button.Selected() then
            love.graphics.setColor(0.8,0.8,0.8)
            love.graphics.draw(button.Sprite, button.Transform[1], button.Transform[2])
            love.graphics.setColor(1,1,1,1)
        else
            love.graphics.draw(button.Sprite, button.Transform[1], button.Transform[2])
        end
    end

    if fileName ~= nil then
        love.graphics.push()
        love.graphics.scale(2,2)
        love.graphics.setColor(0,0,0)
        love.graphics.print(fileName, 300, 20)
        love.graphics.setColor(1,1,1)
        love.graphics.scale(1,1)
        love.graphics.pop()
    end
end

local cX, cY = 0, 0

function editor:Update(dt)
    for key, data in pairs(directions) do 
        if love.keyboard.isDown(key) then 
            cX = self.CameraData.CamSpeed * data[1] * dt
            cY = self.CameraData.CamSpeed * data[2] * dt
        end
    end

    self.CameraData.CameraX = self.CameraData.CameraX + cX
    self.CameraData.CameraY = self.CameraData.CameraY + cY
    cX, cY = 0, 0
end

function editor:MousePressed(x, y, button)
    if button == 1 then 
        local buttonPressed = false
        for _,btn in pairs(buttons) do 
            if btn.IsVisible() and utils:CheckCollision(x, y, 1, 1, btn.Transform[1], btn.Transform[2], btn.Transform[3], btn.Transform[4]) then 
                btn.Callback(editor)
                buttonPressed = true
            end
        end

        if buttonPressed == true then return end
        if placeMode == "startPos" then 
            level.Start.X = x - self.CameraData.CameraX - 10
            level.Start.Y = y - self.CameraData.CameraY - 10
        elseif placeMode == "spike" then
            local CanPlace = true

            for _, hazard in ipairs(level.Hazards) do
                local distance = math.sqrt((hazard.X - (x - self.CameraData.CameraX - 40))^2 + (hazard.Y - (y - self.CameraData.CameraY - 40))^2)
                if distance <= 25 then
                    CanPlace = false
                    break
                end
            end

            if CanPlace == true then 
                table.insert(level.Hazards, {
                    ["X"] = x - self.CameraData.CameraX - 40,
                    ["Y"] = y - self.CameraData.CameraY - 40,
                    ["Type"] = "Spike" 
                })
            end
        elseif placeMode == "platform" or placeMode == "waterPlatform" or placeMode == "sponge" then
            placingPlatform = true
            mX, mY = x, y
        elseif placeMode == "win" then
            level.End = {
                ["X"] = x - self.CameraData.CameraX - 40,
                ["Y"] = y - self.CameraData.CameraY - 40,
            }
        end
    end
end

function editor:MouseReleased(x, y)
    if placingPlatform == true then
        local sX = math.abs(x - mX)
        local sY = math.abs(y - mY)

        if placeMode == "platform" then 
            print("platform")
            table.insert(level.Platforms, {
                ["X"] = math.min(mX, x) - self.CameraData.CameraX,
                ["Y"] = math.min(mY, y) - self.CameraData.CameraY,
                ["W"] = sX,
                ["H"] = sY,
                ["Color"] = {
                    ["R"] = 1,
                    ["G"] = 0,
                    ["B"] = 0
                }
            })
        elseif placeMode == "waterPlatform" then
            table.insert(level.Gates, {
                ["X"] = math.min(mX, x) - self.CameraData.CameraX,
                ["Y"] = math.min(mY, y) - self.CameraData.CameraY,
                ["W"] = sX,
                ["H"] = sY,
            })
        elseif placeMode == "sponge" then 
            table.insert(level.Hazards, {
                ["X"] = math.min(mX, x) - self.CameraData.CameraX,
                ["Y"] = math.min(mY, y) - self.CameraData.CameraY,
                ["W"] = sX,
                ["H"] = sY,
                ["Type"] = "Sponge"
            })
        end
        

        placingPlatform = false
        mX, mY = 0, 0
    end
end

return editor