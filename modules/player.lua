local player = {}
local debug = true
local movementDirections = {a = {-1,0}, d = {1,0}, space = {0,-1}}
player.MovementData = {
    ["Speed"] = 5000,
    ["MaxSpeed"] = 400,
    ["Direction"] = 1,
    ["JumpHeight"] = 1500,
    ["OnGround"] = false,
}

player.CameraData = {
    ["CameraX"] = 0,
    ["CameraY"] = 0,
    ["CameraOffsetX"] = 400,
    ["CameraOffsetY"] = 200,
    ["CamSpeed"] = 500
}

local jumped = false

function player:load(world)
    self.body = love.physics.newBody(world, 200, 0, "dynamic")
    self.body:setLinearDamping(1)
    self.shape = love.physics.newRectangleShape(50, 50)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData("player")
    self.fixture:setRestitution(0)
end

function player:update(dt)
    self.MovementData.OnGround = false

    if not love.keyboard.isDown("space") then
        jumped = false
    end
    
    if #self.body:getContacts() >= 1 then -- should add wall jumping
        self.MovementData.OnGround = true
    end

    -- if love.keyboard.isDown("d") then 
    --     self.body:applyForce(400, 0)
    -- elseif love.keyboard.isDown("a") then 
    --     self.body:applyForce(-400, 0)
    -- elseif love.keyboard.isDown("space") and self.grounded == true then 
    --     self.body:applyForce(0, 400)
    -- end

    for key, data in pairs(movementDirections) do 
        if love.keyboard.isDown(key) then 
            local impulseX = 0
            local impulseY = 0
            
            if key == "space" and self.MovementData.OnGround and not jumped then        
                impulseY = self.MovementData.JumpHeight * data[2]

                jumped = true
            else
                impulseX = self.MovementData.Speed * data[1] * dt
                
                if key == "a" then
                    self.MovementData.Direction = 1
                elseif key == "d" then
                    self.MovementData.Direction = -1
                end
            end
            
            self.body:applyLinearImpulse(impulseX, impulseY)
        end
    end

    local velX, velY = self.body:getLinearVelocity()
    
    if velX > self.MovementData.MaxSpeed then velX = self.MovementData.MaxSpeed 
    elseif velX < -self.MovementData.MaxSpeed then velX = -self.MovementData.MaxSpeed end

    self.body:setLinearVelocity(velX, velY)
end

function player:draw()
    love.graphics.draw(love.graphics.newImage("images/player.png"), self.body:getX() - 25, self.body:getY() - 25)
    if debug then 
        love.graphics.rectangle("line", self.body:getX() - 25, self.body:getY() - 25, 50, 50)
    end
end

return player