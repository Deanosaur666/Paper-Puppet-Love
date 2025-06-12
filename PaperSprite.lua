
-- paper sprite has:
-- texture, quad, anchor

-- a sprite set is a collection of sprites with keys, mapped to a skeleton

function PaperSprite(texture, quad, anchorX, anchorY)
    return {Texture = texture, Quad = quad, AnchorX = anchorX, AnchorY = anchorY}
end

-- texture override exists so we can swap out sprites easily enough
function DrawPaperSprite(sprite, x, y, texture_override)
    local tex = texture_override or sprite.Texture

    love.graphics.draw(tex, sprite.Quad, x + sprite.AnchorX, y + sprite.AnchorY)
end



function PaperSpriteEditor()
    local prog = BlankProgram()
    prog.Scale = 0.5
    prog.OffsetX = 100
    prog.OffsetY = 100
    prog.SheetIndex = 2

    -- mapping sprites to names/indexes
    prog.SpriteSet = {}
    prog.TotalSprites = 0
    prog.CurrentSprite = 0

    prog.Draw = function ()
        local lg = love.graphics
        lg.push("all")

        local str = "Current Sheet: " .. SpriteSheetFiles[prog.SheetIndex]
        lg.print(str, 10, 0)

        str = "Current Sprite: " .. tostring(prog.CurrentSprite) .. "/" .. tostring(prog.TotalSprites)
        lg.print(str, 10, 20)

        lg.scale(prog.Scale, prog.Scale)
        lg.translate(prog.OffsetX, prog.OffsetY)
        local sheet = SpriteSheets[prog.SheetIndex]
        love.graphics.draw(sheet, 10, 10)

        lg.rectangle("line", 0, 0, sheet:getWidth(), sheet:getHeight())

        local mx, my = GetRelativeMouse(prog.Scale, prog.OffsetX, prog.OffsetY)

        lg.circle("line", mx, my, 5)

        lg.pop()
        
        
    end

    return prog
end

