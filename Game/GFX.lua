function GFX_Popup(spriteName, x, y, time, lifetime)
    return {
        SpriteName = spriteName,
        X = x,
        Y = y,
        Time = time,
        Lifetime = lifetime
    }
end

function AddGFX(spriteName, x, y, time, lifetime)
    local gfx = GFX_Popup(spriteName, x, y, time, lifetime)
    table.insert(GameState.GFX, gfx)
end

function DrawGFX(gfx, x, y)
    local spriteList = GFX[gfx.SpriteName]
    local spriteCount = #spriteList
    local index = math.floor(Clamp((gfx.Time/gfx.Lifetime)*spriteCount + 1, 1, spriteCount))

    local sprite = spriteList[index]
    local w, h = sprite:getDimensions( )

    love.graphics.draw(sprite, gfx.X - w/2, gfx.Y - h/2)

    gfx.Time = gfx.Time + 1
end