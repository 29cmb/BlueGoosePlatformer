local editor = {}
local Sprites = require("modules.sprite")
local utils = require("modules.utils")
editor.InEditor = true

editor.CameraData = {
    ["CameraX"] = 400,
    ["CameraY"] = 200,
    ["CamSpeed"] = 300
}

local directions = {a = {1,0}, d = {-1,0}, w = {0,1}, s = {0,-1}}

local level = {
    ["Start"] = {["X"] = 0, ["Y"] = 0},
    ["Platforms"] = {},
    ["Hazards"] = {},
    ["Gates"] = {}
}

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
            ["Callback"] = function(self)
                placeMode = "spike"
            end
        }
    }
end

function editor:Draw()
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.draw(Sprites.Player, level.Start.X + self.CameraData.CameraX, level.Start.Y + self.CameraData.CameraY)
    love.graphics.setColor(1,1,1,1)

    for _,button in pairs(buttons) do 
        love.graphics.draw(button.Sprite, button.Transform[1], button.Transform[2])
    end

    for _,platform in pairs(level.Platforms) do
        love.graphics.setColor(platform.Color.R, platform.Color.B, platform.Color.G)
        love.graphics.rectangle("fill", platform.Transform[1] - self.CameraData.CameraX, platform.Transform[2] - self.CameraData.CameraY, platform.Transform[3], platform.Transform[4])
        love.graphics.setColor(1, 1, 1)
    end

    for _,hazard in pairs(level.Hazards) do
        love.graphics.draw(Sprites.Spike, hazard.X + self.CameraData.CameraX, hazard.Y + self.CameraData.CameraY)
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
            if btn.IsVisible() == true and utils:CheckCollision(x, y, 1, 1, btn.Transform[1], btn.Transform[2], btn.Transform[3], btn.Transform[4]) then 
                btn.Callback(editor)
                buttonPressed = true
            end
        end

        if buttonPressed == true then return end
        if placeMode == "startPos" then 
            level.Start.X = x - self.CameraData.CameraX - 10
            level.Start.Y = y - self.CameraData.CameraY - 10
        elseif placeMode == "spike" then 
            table.insert(level.Hazards, {
                ["X"] = x - self.CameraData.CameraX - 40,
                ["Y"] = y - self.CameraData.CameraY - 40,
                ["Type"] = "Spike" 
            })
        end
    end
end

return editor