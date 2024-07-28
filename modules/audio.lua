local audio = {
    ["Ingame"] = {"audio/main.mp3", "stream"},
    ["Menu"] = {"audio/menu.mp3", "stream"}
}
audio.IsLoaded = false

function audio:Init()
    for index, sound in pairs(self) do
        if type(sound) == "table" then 
            self[index] = love.audio.newSource(sound[1], sound[2])
        end 
    end
    self.IsLoaded = true
end

return audio