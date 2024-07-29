local editor = {}
local Sprites = require("modules.sprite")
local utils = require("modules.utils")
local fonts = require("modules.font")
local pause = require("modules.pause")

editor.InEditor = false
editor.IsLoaded = false

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

local sliding = false
local hue = 0.0
local saturation = 1.0
local brightness = 1.0

function HSVtoRGB(h, s, v)
    if s <= 0 then return v,v,v end
    h = h*6
    local c = v*s
    local x = (1-math.abs((h%2)-1))*c
    local m,r,g,b = (v-c), 0, 0, 0
    if h < 1 then
        r, g, b = c, x, 0
    elseif h < 2 then
        r, g, b = x, c, 0
    elseif h < 3 then
        r, g, b = 0, c, x
    elseif h < 4 then
        r, g, b = 0, x, c
    elseif h < 5 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end
    return r+m, g+m, b+m
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
    self.buttons = {
        ["Player"] = {
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
        ["Spike"] = {
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
        ["Platform"] = {
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
        ["Water"] = {
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
        ["Sponge"] = {
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
        ["Win"] ={
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
        ["Delete"] = {
            ["Sprite"] = Sprites.DeleteButton,
            ["Transform"] = {490, 10, 75, 75},
            ["IsVisible"] = function()
                return true
            end,
            ["Selected"] = function()
                return placeMode == "delete"
            end,
            ["Callback"] = function()
                placeMode = "delete"
            end
        },
        ["Save"] = {
            ["Sprite"] = Sprites.SaveButton,
            ["Transform"] = {570, 10, 75, 75},
            ["IsVisible"] = function()
                return true
            end,
            ["Selected"] = function()
                return false
            end,
            ["Callback"] = function()
                if level.End then
                    love.filesystem.setIdentity("blue-goose-platformer")
                    love.filesystem.write(fileName, "return " .. tableToString(level, ""))
                    love.window.showMessageBox("Saved", "Save was successful!")
                else
                    love.window.showMessageBox("Error", "You cannot save a level without an end flag!", "error")
                end
            end
        },
        
    }
    
    self.HSVSliders = {
        {
            Sprite = "Hue",
            Transform = {10, 90, 200, 25},
            SliderPos = function ()
                return (10 + (hue * 200))
            end,
            Callback = function (percentage)
                hue = percentage
                if hue > 1.0 then
                    hue = 1.0
                end
                if hue < 0.0 then
                    hue = 0.0
                end
            end
        },
        
        {
            Sprite = "Saturation",
            Transform = {10, 120, 200, 25},
            SliderPos = function ()
                return (10 + (saturation * 200))
            end,
            Callback = function (percentage)
                saturation = percentage
                if saturation > 1.0 then
                    saturation = 1.0
                end
                if saturation < 0.0 then
                    saturation = 0.0
                end
            end
        },
    
        {
            Sprite = "Brightness",
            Transform = {10, 150, 200, 25},
            SliderPos = function ()
                return (10 + (brightness * 200))
            end,
            Callback = function (percentage)
                brightness = percentage
                if brightness > 1.0 then
                    brightness = 1.0
                end
                if brightness < 0.0 then
                    brightness = 0.0
                end
            end
        }
    }

    self.IsLoaded = true
end

local mX, mY = 0, 0
local placingPlatform = false

function editor:Draw()
    for _,platform in pairs(level.Platforms) do
        love.graphics.setColor(platform.Color.R, platform.Color.G, platform.Color.B)
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
    
    if placeMode == "platform" then
        for _, s in ipairs(self.HSVSliders) do
            if s.Sprite == "Saturation" then
                love.graphics.setColor(1,1,1,1)
                love.graphics.rectangle("fill", s.Transform[1], s.Transform[2], s.Transform[3], s.Transform[4])
    
                local r,g,b = HSVtoRGB(hue, 1, brightness)
                love.graphics.setColor(r,g,b,1)
            elseif s.Sprite == "Brightness" then
                local r,g,b = HSVtoRGB(hue, saturation, 1)
                love.graphics.setColor(r,g,b,1)
            end     
    
            love.graphics.draw(Sprites[s.Sprite], s.Transform[1], s.Transform[2], 0)
            
            love.graphics.setColor(1,1,1,1)
            love.graphics.draw(Sprites.Slider, s.SliderPos(), s.Transform[2], 0, 1, 1, 5)
        end

        local r,g,b = HSVtoRGB(hue, saturation, brightness)
        love.graphics.setColor(r,g,b,1)
        love.graphics.rectangle("fill", 10, 180, 25, 25)
    end

    love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.draw(Sprites.Player, level.Start.X + self.CameraData.CameraX, level.Start.Y + self.CameraData.CameraY)
        love.graphics.setColor(1,1,1,1)

    if level.End then 
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.draw(Sprites.EndFlag, level.End.X + self.CameraData.CameraX, level.End.Y + self.CameraData.CameraY)
        love.graphics.setColor(1,1,1,1)
    end
    
    for _,button in pairs(self.buttons) do
        if button.IsVisible() then
            if button.Selected() then
                love.graphics.setColor(0.8,0.8,0.8)
                love.graphics.draw(button.Sprite, button.Transform[1], button.Transform[2])
                love.graphics.setColor(1,1,1,1)
            else
                love.graphics.draw(button.Sprite, button.Transform[1], button.Transform[2])
            end
        end
       
    end

    if fileName ~= nil then
        love.graphics.push()
        love.graphics.setFont(fonts.ValentinySubtext)
        love.graphics.setColor(0,0,0)
        love.graphics.printf(fileName, 190, 560, 600, "right")
        love.graphics.setColor(1,1,1)
        love.graphics.setFont(fonts.Valentiny)
        love.graphics.pop()
    end

    pause:Draw()
end

local cX, cY = 0, 0

function editor:Update(dt)
    if pause.Paused == true then return end
    for key, data in pairs(directions) do 
        if love.keyboard.isDown(key) then 
            cX = cX + self.CameraData.CamSpeed * data[1] * dt
            cY = cY + self.CameraData.CamSpeed * data[2] * dt
        end
    end

    self.CameraData.CameraX = self.CameraData.CameraX + cX
    self.CameraData.CameraY = self.CameraData.CameraY + cY
    cX, cY = 0, 0
end

function editor:MousePressed(x, y, button)
    if pause.Paused then 
        pause:MouseClick(x, y)
        return
    end

    if button == 1 then 
        local buttonPressed = false
        for _,btn in pairs(self.buttons) do 
            if btn.IsVisible() and utils:CheckCollision(x, y, 1, 1, btn.Transform[1], btn.Transform[2], btn.Transform[3], btn.Transform[4]) then 
                btn.Callback(editor)
                buttonPressed = true
            end
        end

        for _, s in ipairs(self.HSVSliders) do
            if utils:CheckCollision(x, y, 1, 1, s.Transform[1], s.Transform[2], s.Transform[3], s.Transform[4]) and placeMode == "platform" then
                local sliderPercent = (x - s.Transform[1]) / s.Transform[3]
                s.Callback(sliderPercent)
                sliding = true
                
                return
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
        elseif placeMode == "delete" then
            for index, value in pairs(level.Platforms) do 
                if utils:CheckCollision(x - self.CameraData.CameraX, y - self.CameraData.CameraY, 1, 1, value.X, value.Y, value.W, value.H) then 
                    table.remove(level.Platforms, index)
                end
            end

            for index, value in pairs(level.Gates) do 
                if utils:CheckCollision(x - self.CameraData.CameraX, y - self.CameraData.CameraY, 1, 1, value.X, value.Y, value.W, value.H) then 
                    table.remove(level.Gates, index)
                end
            end

            for index, value in pairs(level.Hazards) do
                if utils:CheckCollision(x - self.CameraData.CameraX, y - self.CameraData.CameraY, 1, 1, value.X, value.Y, value.W or 65, value.H or 65) then 
                    table.remove(level.Hazards, index)
                end
            end
        end
    end
end

function editor:MouseReleased(x, y)
    sliding = false

    if placingPlatform == true then
        local sX = math.abs(x - mX)
        local sY = math.abs(y - mY)

        if placeMode == "platform" then 
            print("platform")
            
            local r, g, b = HSVtoRGB(hue, saturation, brightness)

            table.insert(level.Platforms, {
                ["X"] = math.min(mX, x) - self.CameraData.CameraX,
                ["Y"] = math.min(mY, y) - self.CameraData.CameraY,
                ["W"] = sX,
                ["H"] = sY,
                ["Color"] = {
                    ["R"] = r,
                    ["G"] = g,
                    ["B"] = b
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

function editor:MouseMoved(x, y)
    for _, s in ipairs(self.HSVSliders) do
        if utils:CheckCollision(x, y, 1, 1, s.Transform[1], s.Transform[2], s.Transform[3], s.Transform[4]) and sliding and placeMode == "platform" then
            local sliderPercent = (x - s.Transform[1]) / s.Transform[3]
            s.Callback(sliderPercent)
            
            return
        end
    end
end

function editor:LoadLevel(name, data)
    level = data
    fileName = name
    self.InEditor = true
end

return editor