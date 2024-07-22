local sprite = {
    Sprites = {
        ["Player"] = "images/player.png",
        ["Spike"] = "images/spike.png"
    }
}

function sprite:Init()
    for index,spr in pairs(self.Sprites) do 
        self.Sprites[index] = love.graphics.newImage(spr)
    end
end

return sprite