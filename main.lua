local Sprites = {}

function love.load()
    for name,spr in pairs(Sprites) do 
        Sprites[name] = love.graphics.newImage(spr)
    end
end

function love.draw()

end

function love.update(dt)
    
end