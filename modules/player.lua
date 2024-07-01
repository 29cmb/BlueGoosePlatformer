local player = {}

function player:load(world)
    self.world = world
    self.body = love.physics.newBody(world, 200, 0, "dynamic")
    self.shape = love.physics.newRectangleShape(50, 50)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData("player")
end

function player:update(dt)
    self.world:update(dt)
    self.grounded = false
    
    if #self.body:getContacts() >= 1 then 
        self.grounded = true
    end

    if love.keyboard.isDown("d") then 
        self.body:applyForce(400, 0)
    elseif love.keyboard.isDown("a") then 
        self.body:applyForce(-400, 0)
    end
end

function player:draw()
    love.graphics.draw(love.graphics.newImage("images/player.png"), self.body:getX(), self.body:getY())
end

return player