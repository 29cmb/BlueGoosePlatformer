local level = {}
local sprite = require("modules.sprite")
level.map = {}

function level:init(w)
    world = w
    player = require("modules.player")
end

function level:loadLevel(path)
    local data = require(path)
    if data.Start then self.map.Start = data.Start end
    for _,platform in pairs(data.Platforms) do 
        local body = love.physics.newBody(world, platform.X + (platform.W / 2), platform.Y + (platform.H / 2), "static")
        local shape = love.physics.newRectangleShape(platform.W, platform.H)
        local fixture = love.physics.newFixture(body, shape)
        fixture:setUserData("Platform")

        table.insert(self.map, {
            ["body"] = body,
            ["shape"] = shape,
            ["fixture"] = fixture,
            ["transform"] = {platform.X, platform.Y, platform.W, platform.H},
            ["color"] = {R = platform.Color.R, G = platform.Color.G, B = platform.Color.B},
            ["type"] = "Platform"
        })
    end

    for _,hazard in pairs(data.Hazards) do 
        local body = love.physics.newBody(world, hazard.X + (65 / 2), hazard.Y + (65 / 2), "static")
        local shape = love.physics.newRectangleShape(65, 65)
        local fixture = love.physics.newFixture(body, shape)
        fixture:setUserData("Hazard")

        table.insert(self.map, {
            ["body"] = body,
            ["shape"] = shape,
            ["fixture"] = fixture,
            ["transform"] = {hazard.X, hazard.Y},
            ["type"] = "Spike"
        })
    end

    for _,gate in pairs(data.Gates) do 
        local body = love.physics.newBody(world, gate.X + (gate.W / 2), gate.Y + (gate.H / 2), "static")
        local shape = love.physics.newRectangleShape(gate.W, gate.H)
        local fixture = love.physics.newFixture(body, shape)
        fixture:setUserData("Gate")

        table.insert(self.map, {
            ["body"] = body,
            ["shape"] = shape,
            ["fixture"] = fixture,
            ["transform"] = {gate.X, gate.Y, gate.W, gate.H},
            ["type"] = "Gate"
        })
    end

    if self.map.Start then 
        player.body:setX(self.map.Start.X)
        player.body:setY(self.map.Start.Y)
    end
end

function level:draw()
    if self.map ~= {} then 
        for _,platform in pairs(self.map) do 
            if platform.type == "Platform" then
                love.graphics.setColor(platform.color.R, platform.color.B, platform.color.G)
                love.graphics.rectangle("fill", platform.transform[1] - player.CameraData.CameraX, platform.transform[2] - player.CameraData.CameraY, platform.transform[3], platform.transform[4])
                love.graphics.setColor(1, 1, 1)
            elseif platform.type == "Spike" then
                love.graphics.draw(sprite.Spike, platform.transform[1] - player.CameraData.CameraX, platform.transform[2] - player.CameraData.CameraY)
            elseif platform.type == "Gate" then 
                love.graphics.draw(sprite.Water, platform.transform[1] - player.CameraData.CameraX, platform.transform[2] - player.CameraData.CameraY, 0, platform.transform[3] / 643, platform.transform[4] / 360)
            end
        end
    end
end

return level