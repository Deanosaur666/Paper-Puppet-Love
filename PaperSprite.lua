
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
    prog.SheetIndex = 2

    -- mapping sprites to names/indexes
    prog.SpriteSetIndex = nil
    prog.SpriteIndex = 0

    prog.MouseDragX = 0
    prog.MouseDragY = 0

    function prog:Draw()
        local lg = love.graphics
        lg.push("all")

        local str = "Current Sheet: " .. prog.SheetIndex
        lg.print(str, 10, 0)

        local spriteSet = self:CurrentSpriteSet() or {}

        str = "Current Sprite: " .. tostring(prog.SpriteIndex) .. "/" .. tostring(#spriteSet)
        lg.print(str, 10, 20)

        lg.scale(prog.Scale, prog.Scale)
        lg.translate(prog.OffsetX, prog.OffsetY)
        local sheet = SpriteSheets[SpriteSheetFiles[prog.SheetIndex]]
        love.graphics.draw(sheet, 10, 10)

        lg.rectangle("line", 0, 0, sheet:getWidth(), sheet:getHeight())

        local mx, my = GetRelativeMouse(prog.Scale, prog.OffsetX, prog.OffsetY)

        if(MouseDown[1]) then
            lg.setColor(1, 0, 0)
            lg.rectangle("line", MouseDragX, MouseDragY, mx - MouseDragX, my - MouseDragY)
            lg.setColor(1, 1, 1)
        end

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

            if(i == self.SpriteIndex) then
                lg.setColor(1, 0, 0)
            end
            lg.print(tostring(i), dx + 10, dy + 10)
            lg.rectangle("line", dx, dy, w, h)

            lg.setColor(1, 1, 1)

            dy = dy + h + 2
        end

        lg.pop()
        
        
    end

    function prog:Update()
    
    end

    function prog:KeyPressed(key, scancode, isrepeat)
        local spriteSet = SpriteSets[self.SpriteSetIndex] or {}
        if(key == "n") then
            if(self.SpriteSetIndex == nil) then
                self:CreateSpriteSet()
                spriteSet = SpriteSets[self.SpriteSetIndex]
            end
            self:CreateSprite()
        elseif(key == "left") then
            self.SheetIndex = ((self.SheetIndex - 2) % #SpriteSheetFiles) + 1
        elseif(key == "right") then
            self.SheetIndex = (self.SheetIndex % #SpriteSheetFiles) + 1
        elseif(key == "up") then
            self.SpriteIndex = ((self.SpriteIndex - 2) % #spriteSet) + 1
        elseif(key == "down") then
            self.SpriteIndex = (self.SpriteIndex % #spriteSet) + 1
        end
    end

    function prog:MousePressed(mb)
        if(mb == 1) then
            MouseDragX, MouseDragY = GetRelativeMouse(self.Scale, self.OffsetX, self.OffsetY)
        end
    end

    function prog:MouseReleased(mb)
        if(mb == 1) then
            local mx, my = GetRelativeMouse(prog.Scale, prog.OffsetX, prog.OffsetY)
            self:DefineQuad(MouseDragX, MouseDragY, mx - MouseDragX, my - MouseDragY)
        end
    end

    function prog:CurrentSpriteSet()
        return SpriteSets[self.SpriteSetIndex]
    end

    function prog:CurrentSprite()
        local spriteSet = SpriteSets[self.SpriteSetIndex]
        return spriteSet[self.SpriteIndex]
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
        self.SpriteIndex = #spriteSet + 1
        spriteSet[self.SpriteIndex] = PaperSprite(SpriteSheetFiles[self.SheetIndex], nil, 0, 0)
    end

    function prog:DefineQuad(x, y, w, h)
        local texture = SpriteSheets[SpriteSheetFiles[prog.SheetIndex]]
        local quad = love.graphics.newQuad(x, y, w, h, texture)
        local sprite = self:CurrentSprite()
        sprite.Quad = quad
    end

    function prog:DefineAnchor(x, y)
        local sprite = self:CurrentSprite()
        sprite.AnchorX = x
        sprite.AnchorY = y
    end

    return prog
end

