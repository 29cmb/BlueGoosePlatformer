local pause = {}
pause.Paused = false

local Sprites = require("modules.sprite")
local utils = require("modules.utils")

function pause:Load()
    main = require('main')
    editor = require("editor")
end

function pause:Draw() 
    if self.Paused == true then 
        love.graphics.draw(Sprites.PauseMenu)
    end
end

local buttons = {
    ["Resume"] = {
        ["Transform"] = {200, 217, 397, 125},
        ["Callback"] = function()
            pause.Paused = false
        end
    },
    ["Exit"] = {
        ["Transform"] = {200, 355, 397, 125},
        ["Callback"] = function()
            -- next
        end
    }
}

function pause:MouseClick(x, y)
    if pause.Paused == true then 
        for _,btn in pairs(buttons) do 
            if utils:CheckCollision(x, y, 1, 1, btn.Transform[1], btn.Transform[2], btn.Transform[3], btn.Transform[4]) then 
                btn.Callback()
            end
        end
    end
end

return pause