local fonts = {
    ["Valentiny"] = {"Fonts/Valentiny.ttf", 80},
    ["ValentinySubtext"] = {"Fonts/Valentiny.ttf", 40}
}
fonts.IsLoaded = false

function fonts:Load()
    for name,fnt in pairs(self) do 
        if type(fnt) == "table" then 
            self[name] = love.graphics.newFont(fnt[1], fnt[2])
        end
    end
    self.IsLoaded = true
end

return fonts