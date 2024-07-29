local sprite = require("modules.sprite")
local utils = require("modules.utils")
local win = {}
win.WinVisible = false
win.IsLoaded = false

function win:Load()
    main = require("main")
    level = require("modules.level")
    player = require("modules.player")
    self.IsLoaded = true
end

local buttons = {
    ["Exit"] = {
        ["Transform"] = {200, 217, 397, 125},
        ["Callback"] = function()
            main:Exit()
            level:Unload()
            win.WinVisible = false
        end
    },
    ["Restart"] = {
        ["Transform"] = {200, 355, 397, 125},
        ["Callback"] = function()
            player.body:setX(level.map.Start.X or 0)
            player.body:setY(level.map.Start.Y or 0)
            win.WinVisible = false
        end
    }
}

function win:Draw()
    if self.WinVisible == true then
        love.graphics.draw(sprite.WinScreen)
    end
end

function win:MouseClick(x, y)
    for _,btn in pairs(buttons) do 
        if utils:CheckCollision(x, y, 1, 1, btn["Transform"][1], btn["Transform"][2], btn["Transform"][3], btn["Transform"][4]) then 
            btn.Callback()
        end
    end
end


return win