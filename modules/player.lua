---@diagnostic disable: missing-parameter
local player = {}
local sprite = require("modules.sprite")
local pause = require("modules.pause")
local level = require("modules.level")
local win   = require("modules.win")
local movementDirections = {a = {-1,0}, d = {1,0}, space = {0,-1}}
local respawning = false
player.MovementData = {
    ["Speed"] = 9000,
    ["MaxSpeed"] = 400,
    ["Direction"] = -1,
    ["JumpHeight"] = 1800,
    ["OnGround"] = false,
}

player.CameraData = {
    ["CameraX"] = 0,
    ["CameraY"] = 0,
    ["CameraOffsetX"] = 400,
    ["CameraOffsetY"] = 200,
    ["CamSpeed"] = 300
}

player.IsWater = false

local cX, cY = 0, 0

local function lerp(a, b, t)
    return t < 0.5 and a + (b - a) * t or b + (a - b) * (1 - t)
end

local jumped = false

function player:load(world)
    self.body = love.physics.newBody(world, 0, 0, "dynamic")
    self.body:setLinearDamping(1)
    self.shape = love.physics.newRectangleShape(50, 50)
    self.fixture = love.physics.newFixture(self.body, self.shape)
    self.fixture:setUserData("Player")
    self.fixture:setRestitution(0)
    self.fixture:setCategory(1)
    self.fixture:setMask(2)
end

function player:update(dt)
    if respawning == true then 
        self:Respawn()
        respawning = false
        return
    end

    self.MovementData.OnGround = false

    if not love.keyboard.isDown("space") then
        jumped = false
    end
    
    if #self.body:getContacts() >= 1 then -- should add wall jumping
        self.MovementData.OnGround = true
    end

    for key, data in pairs(movementDirections) do 
        if love.keyboard.isDown(key) and (pause.Paused == false and win.WinVisible == false) then
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

    cX = lerp(cX, self.body:getX(), 0.1)
    cY = lerp(cY, self.body:getY(), 0.1)
    
    self.CameraData.CameraX = cX - self.CameraData.CameraOffsetX
    self.CameraData.CameraY = cY - self.CameraData.CameraOffsetY

    if self.body:getY() > 600 then self:Respawn() end
end

function player:draw()
    love.graphics.draw((self.IsWater == true) and sprite.WaterPlayer or sprite.Player, self.body:getX() - self.CameraData.CameraX, self.body:getY() - self.CameraData.CameraY, 0, self.MovementData.Direction, 1, 25, 25)
end

function player:Respawn()
    if level.map.Start then 
        self.body:setX(level.map.Start.X or 0)
        self.body:setY(level.map.Start.Y or 0)
    else
        self.body:setX(0)
        self.body:setY(0)
    end 
end

function player:YieldRespawn()
    respawning = true
    level:Water(false)
    self.IsWater = false
end

function player:WaterToggle()
    level:Water(not self.IsWater)
    self.IsWater = not self.IsWater
end

function player:Unload()
    self.body:destroy()
    self.body = nil
    self.fixture = nil
    self.shape = nil
end

return player