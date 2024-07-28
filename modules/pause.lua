local pause = {}
pause.Paused = false
pause.IsLoaded = false

local Sprites = require("modules.sprite")
local utils = require("modules.utils")
local level = require("modules.level")

function pause:Load()
    main = require('main')
    editor = require("editor")

    self.IsLoaded = true
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
            if editor.InEditor == true then
                local choice = love.window.showMessageBox("Save", "Would you like to save this level?", {"No", "Yes"})
                if choice == 2 then editor.buttons.Save.Callback() end

                editor.InEditor = false
            else
                main:Exit()
                level:Unload()
            end
            pause.Paused = false
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