local level = {}

level.map = {}

function level:init(w)
    world = w
end

function level:loadLevel(path)
    local data = require(path)
    for _,platform in pairs(data.Platforms) do 
        local body = love.physics.newBody(world, platform.X, platform.Y)
        local shape = love.physics.newRectangleShape(platform.W, platform.H)
        local fixture = love.physics.newFixture(body, shape)

        table.insert(self.map, {
            ["body"] = body,
            ["shape"] = shape,
            ["fixture"] = fixture,
            ["type"] = "Platform"
        })
    end
end

function level:draw()
    if self.map ~= {} then 
        for _,platform in pairs(self.map) do 
            if platform.type == "Platform" then
                love.graphics.polygon("fill", platform.body:getWorldPoints(platform.shape:getPoints()))
            end
        end
    end
end

return level