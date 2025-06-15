require "tables"

-- paper sprite has:
-- texture, quad, anchor

-- a sprite set is a collection of sprites with keys, mapped to a skeleton

function SaveSpriteSet(spriteSet, name)
    local file = io.open("spritesets/"..name, "w")

    for _, sprite in ipairs(spriteSet) do
        local line = PaperSpriteToString(sprite)
        file:write(line .. "\n")
    end
    
    io.close(file)
end

function LoadSpriteSet(filename)
    filename = "spritesets/" .. filename
    local spriteSet = {}
    for line in love.filesystem.lines(filename) do
		table.insert(spriteSet, PaperSpriteFromString(line))
	end
    return spriteSet
end

function PaperSprite(quad, anchorX, anchorY)
    return {Quad = quad, AnchorX = anchorX, AnchorY = anchorY}
end

-- texture override exists so we can swap out sprites easily enough
-- needs rotation and scale
function DrawPaperSprite(sprite, texture, x, y, rot, xscale, yscale)

    xscale = xscale or 1
    yscale = yscale or 1
    rot = rot or 0

    -- we need to use the anchors for rotation and scale
    local lg = love.graphics
    lg.push("all")
    
    lg.translate(x, y)
    
    lg.rotate(rot)

    lg.scale(xscale, yscale)

    lg.translate(-sprite.AnchorX, -sprite.AnchorY)

    --lg.translate(sprite.AnchorX, sprite.AnchorY)
    

    -- needs to use rotation and scale
    -- love.graphics.draw(texture, sprite.Quad, x - (sprite.AnchorX*xscale), y - (sprite.AnchorY*yscale))
    love.graphics.draw(texture, sprite.Quad, 0, 0)

    lg.pop()
end


function PaperSpriteToString(sprite)
    local qx, qy, qw, qh = sprite.Quad:getViewport()
    local sw, sh = sprite.Quad:getTextureDimensions( )

    return stringjoin({qx, qy, qw, qh, sw, sh, sprite.AnchorX, sprite.AnchorY}, ":")
end

function PaperSpriteFromString(str)
    local split = stringsplit(str, ":")
    local qx, qy, qw, qh, sw, sh, ax, ay =
        split[1], split[2], split[3], split[4], split[5], split[6], split[7], split[8]
    
    return PaperSprite(love.graphics.newQuad(qx, qy, qw, qh, sw, sh), ax, ay)
end


function PaperSpriteEditor()
    local prog = BlankProgram()
    prog.Scale = 0.5
    prog.OffsetX = 100
    prog.OffsetY = 100

    -- mapping sprites to names/indexes
    
    prog.SpriteIndex = 0

    prog.MouseDragX = 0
    prog.MouseDragY = 0

    function prog:Draw()
        local lg = love.graphics
        lg.push("all")

        lg.clear(0.4, 0.4, 0.4)

        lg.setFont(Font_K)

        local str = "Current Sheet: " .. SheetIndex
        lg.print(str, 10, 0)

        local spriteSet = CurrentSpriteSet() or {}

        str = "Current Sprite: " .. tostring(self.SpriteIndex) .. "/" .. tostring(#spriteSet)
        lg.print(str, 10, 20)

        str = "Current SpriteSet: " .. tostring(SpriteSetIndex or 0) .. "/" .. tostring(#SpriteSets)
        lg.print(str, 700, 20)

        lg.scale(self.Scale, self.Scale)
        lg.translate(self.OffsetX, self.OffsetY)

        local screenHeight = ScreenHeight/self.Scale - self.OffsetY*2

        local sheet = CurrentTexture()
        love.graphics.draw(sheet, 0, 0)

        lg.rectangle("line", 0, 0, sheet:getWidth(), sheet:getHeight())

        local mx, my = GetRelativeMouse(self.Scale, self.OffsetX, self.OffsetY)

        if(MouseDown[1]) then
            lg.setColor(1, 0, 0)
            lg.rectangle("line", MouseDragX, MouseDragY, mx - MouseDragX, my - MouseDragY)
            lg.setColor(1, 1, 1)
        end

        lg.circle("line", mx, my, 5)

        local spriteSet = SpriteSets[SpriteSetIndex] or {}
        local dx = sheet:getWidth() + 10
        local dy = 10
        local maxX = 0
        for i, sprite in ipairs(spriteSet) do
            local w, h = 200, 100
            if(dy + h > screenHeight) then
                dy = 10
                dx = maxX + 10
            end

            if(sprite.Quad ~= nil) then
                _, _, w, h = sprite.Quad:getViewport()
                if(dy + h > screenHeight) then
                    dy = 10
                    dx = maxX + 10
                end
                DrawPaperSprite(sprite, CurrentTexture(), dx + sprite.AnchorX, dy + sprite.AnchorY)
            end

            if(i == self.SpriteIndex) then
                if(sprite.Quad ~= nil) then
                    lg.setColor(1, 1, 1)
                    local x, y, w, h = sprite.Quad:getViewport()
                    lg.rectangle("line", x, y, w, h)
                    lg.setColor(0, 1, 0)
                    lg.circle("line", x + sprite.AnchorX, y + sprite.AnchorY, 5)
                end
                lg.setColor(1, 0, 0)
            end

            lg.setFont(Font_KBig)
            lg.print(tostring(i), dx + 10, dy + 10)
            lg.rectangle("line", dx, dy, w, h)
            lg.circle("line", dx + sprite.AnchorX, dy + sprite.AnchorY, 5)
            maxX = math.max(maxX, dx + w)

            lg.setColor(1, 1, 1)

            dy = dy + h + 2
        end

        lg.pop()
        
        
    end

    function prog:Update()
    
    end

    function prog:KeyPressed(key, scancode, isrepeat)
        local spriteSet = CurrentSpriteSet() or {}
        if(key == "n") then
            if(SpriteSetIndex == nil) then
                self:CreateSpriteSet()
                spriteSet = CurrentSpriteSet()
            end
            self:CreateSprite()
        elseif(key == "left") then
            SheetIndex = ((SheetIndex - 2) % #SpriteSheetFiles) + 1
        elseif(key == "right") then
            SheetIndex = (SheetIndex % #SpriteSheetFiles) + 1
        elseif(key == "up") then
            self.SpriteIndex = ((self.SpriteIndex - 2) % #spriteSet) + 1
        elseif(key == "down") then
            self.SpriteIndex = (self.SpriteIndex % #spriteSet) + 1
        elseif(key == "s") then
            SpriteSetIndex = SpriteSetIndex or 0
            if(love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
                self:CreateSpriteSet()
            elseif((love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) and #spriteSet > 0) then
                SaveSpriteSet(spriteSet, tostring(SpriteSetIndex))
            else
                SpriteSetIndex = (SpriteSetIndex % #SpriteSets) + 1
            end
        elseif(key == "delete") then
            table.remove(spriteSet, self.SpriteIndex)
        end
            
    end

    function prog:MousePressed(mb)
        local mx, my = GetRelativeMouse(self.Scale, self.OffsetX, self.OffsetY)
        if(mb == 1) then
            MouseDragX, MouseDragY = GetRelativeMouse(self.Scale, self.OffsetX, self.OffsetY)
        end

        local sprite = self:CurrentSprite()
        if(sprite == nil) then
            return
        end
        
        if(mb == 2)then
            local x, y, w, h = sprite.Quad:getViewport()
            self:DefineAnchor(mx - x, my - y)
        end
            
    end

    function prog:MouseReleased(mb)
        local sprite = self:CurrentSprite()
        if(sprite == nil) then
            return
        end
        if(mb == 1) then
            local mx, my = GetRelativeMouse(prog.Scale, prog.OffsetX, prog.OffsetY)
            local x1 = math.min(MouseDragX, mx)
            local x2 = math.max(MouseDragX, mx)
            local y1 = math.min(MouseDragY, my)
            local y2 = math.max(MouseDragY, my)
            self:DefineQuad(x1, y1, x2 - x1, y2 - y1)
        end
    end

    function prog:CurrentSprite()
        local spriteSet = CurrentSpriteSet()
        if(spriteSet == nil) then
            return nil
        end
        return spriteSet[self.SpriteIndex]
    end

    function prog:CreateSpriteSet()
        -- new sprite set
        SpriteSetIndex = #SpriteSets + 1
        local spriteSet = {}
        SpriteSets[SpriteSetIndex] = spriteSet
    end

    function prog:CreateSprite()
        local spriteSet = CurrentSpriteSet()
        if(spriteSet == nil) then
            return false
        end
        -- create an empty sprite
        self.SpriteIndex = #spriteSet + 1
        spriteSet[self.SpriteIndex] = PaperSprite(nil, 0, 0)
    end

    function prog:DefineQuad(x, y, w, h)
        local texture = CurrentTexture()
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

