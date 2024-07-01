local player = {}
local debug = true

function player:load(world)
    self.body = love.physics.newBody(world, 200, 0, "dynamic")
    self.body:setLinearDamping(1)
    self.shape = love.physics.newRectangleShape(50, 50)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData("player")
    self.fixture:setRestitution(0)
end

function player:update(dt)
    self.grounded = false
    
    if #self.body:getContacts() >= 1 then -- should add wall jumping
        self.grounded = true
    end

    if love.keyboard.isDown("d") then 
        self.body:applyForce(400, 0)
    elseif love.keyboard.isDown("a") then 
        self.body:applyForce(-400, 0)
    elseif love.keyboard.isDown("space") and self.grounded == true then 
        self.body:applyForce(0, 400)
    end
end

function player:draw()
    love.graphics.draw(love.graphics.newImage("images/player.png"), self.body:getX() - 25, self.body:getY() - 25)
    if debug then 
        love.graphics.rectangle("line", self.body:getX() - 25, self.body:getY() - 25, 50, 50)
    end
end

return player