local sprite = {
    ["Player"] = "images/player.png",
    ["Spike"] = "images/spike.png",
    ["Water"] = "images/water.jpg",
    ["WaterPlayer"] = "images/water_player.png",
    ["PlayerButton"] = "images/PlayerButton.png",
    ["SpikeButton"] = "images/SpikeButton.png",
    ["PlatformButton"] = "images/PlatformButton.png",
    ["WaterButton"] = "images/WaterButton.png",
    ["Sponge"] = "images/Sponge.jpg",
    ["SpongeButton"] = "images/SpongeButton.png",
    ["WinButton"] = "images/WinButton.png",
    ["EndFlag"] = "images/EndFlag.png",
    ["SaveButton"] = "images/SaveButton.png",
    ["MainMenu"] = "images/MainMenu.png",
    ["PauseMenu"] = "images/PauseMenu.png"
}
sprite.IsLoaded = false

function sprite:Init()
    for index,spr in pairs(self) do
        if type(spr) == "string" then 
            self[index] = love.graphics.newImage(spr)
        end 
    end
    self.IsLoaded = true
end

return sprite