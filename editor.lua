local editor = {}
local Sprites = require("modules.sprite")
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

function editor:Load()
    level = {
        ["Start"] = {["X"] = 0, ["Y"] = 0},
        ["Platforms"] = {},
        ["Hazards"] = {},
        ["Gates"] = {}
    } -- return level to defaults when the editor loads
end

function editor:Draw()
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.draw(Sprites.Player, level.Start.X + self.CameraData.CameraX, level.Start.Y + self.CameraData.CameraY)
    love.graphics.setColor(1,1,1,1)
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

function editor:Keypressed(key)

end

return editor