
-- paper sprite has:
-- texture, quad, anchor

-- a sprite set is a collection of sprites with keys, mapped to a skeleton

function PaperSprite(textureIndex, quad, anchorX, anchorY)
    return {TextureIndex = textureIndex, Quad = quad, AnchorX = anchorX, AnchorY = anchorY}
end

-- texture override exists so we can swap out sprites easily enough
-- needs rotation and scale
function DrawPaperSprite(sprite, x, y, rot, xscale, yscale, texture_override)
    local tex = texture_override or SpriteSheets[sprite.TextureIndex]

    xscale = xscale or 1
    yscale = yscale or 1
    rot = rot or 0
    -- needs to use rotation and scale
    love.graphics.draw(tex, sprite.Quad, x + sprite.AnchorX, y + sprite.AnchorY)
end


function PaperSpriteToString(paperSprite)

end

function PaperSpriteFromString(str)

end


function PaperSpriteEditor()
    local prog = BlankProgram()
    prog.Scale = 0.5
    prog.OffsetX = 100
    prog.OffsetY = 100
    prog.SheetIndex = "Paper Puppet 2.png"

    -- mapping sprites to names/indexes
    prog.SpriteSetIndex = 0
    prog.TotalSprites = 0
    prog.CurrentSpriteIndex = 0

    prog.Draw = function ()
        local lg = love.graphics
        lg.push("all")

        local str = "Current Sheet: " .. prog.SheetIndex
        lg.print(str, 10, 0)

        str = "Current Sprite: " .. tostring(prog.CurrentSpriteIndex) .. "/" .. tostring(prog.TotalSprites)
        lg.print(str, 10, 20)

        lg.scale(prog.Scale, prog.Scale)
        lg.translate(prog.OffsetX, prog.OffsetY)
        local sheet = SpriteSheets[prog.SheetIndex]
        love.graphics.draw(sheet, 10, 10)

        lg.rectangle("line", 0, 0, sheet:getWidth(), sheet:getHeight())

        local mx, my = GetRelativeMouse(prog.Scale, prog.OffsetX, prog.OffsetY)

        lg.circle("line", mx, my, 5)

        local spriteSet = SpriteSets[prog.SpriteSetIndex] or {}
        local dx = sheet:getWidth() + 10
        local dy = 10
        for i, sprite in ipairs(spriteSet) do
            local w, h = 0, 0

            if(sprite.Quad ~= nil) then
                DrawPaperSprite(sprite, dx, dy)
                _, _, w, h = sprite.Quad:getViewport()
            end

            w = math.max(w, 200)
            h = math.max(h, 100)

            lg.print(tostring(i), dx + 10, dy + 10)
            lg.rectangle("line", dx, dy, w, h)

            dy = dy + h + 2
        end

        lg.pop()
        
        
    end

    function prog:CurrentSprite()
        local spriteSet = SpriteSets[self.SpriteSetIndex]
        return spriteSet[self.CurrentSpriteIndex]
    end

    function prog:CreateSpriteSet()
        -- new sprite set
        self.SpriteSetIndex = #SpriteSets + 1
        local spriteSet = {}
        SpriteSets[self.SpriteSetIndex] = spriteSet
    end

    function prog:CreateSprite()
        local spriteSet = SpriteSets[self.SpriteSetIndex]
        if(spriteSet == nil) then
            return false
        end
        -- create an empty sprite
        self.CurrentSpriteIndex = #spriteSet + 1
        spriteSet[self.CurrentSpriteIndex] = PaperSprite(self.SheetIndex, nil, 0, 0)
    end

    function prog:DefineQuad(x, y, w, h)
        local texture = SpriteSheets[self.SheetIndex]
        local quad = love.graphics.newQuad(x, y, w, h, texture)
        local sprite = self:CurrentSprite()
        sprite.Quad = quad
    end

    function prog:DefineAnchor(x, y)
        local sprite = self:CurrentSprite()
        sprite.AnchorX = x
        sprite.AnchorY = y
    end

    prog:CreateSpriteSet()
    prog:CreateSprite()

    return prog
end

