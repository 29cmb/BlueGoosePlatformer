local level = {}

level.map = {}

function level:init(w)
    world = w
end

function level:loadLevel(path)
    local data = require(path)
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
            ["type"] = "Platform"
        })
    end
end

function level:draw()
    if self.map ~= {} then 
        for _,platform in pairs(self.map) do 
            if platform.type == "Platform" then
                love.graphics.rectangle("fill", platform.transform[1], platform.transform[2], platform.transform[3], platform.transform[4])
            end
        end
    end
end

return level