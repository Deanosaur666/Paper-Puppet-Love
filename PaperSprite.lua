require "tables"

-- paper sprite has:
-- texture, quad, anchor

-- a sprite set is a collection of sprites with keys, mapped to a skeleton

function SaveSpriteSet()
    local spriteSet = CurrentSpriteSet()
    local name = SpriteSetName
    if(name == nil or name == "[NEW]") then
        EnterSpriteSetName()
        return
    end
    local file = io.open("spritesets/"..name, "w")

    for _, sprite in ipairs(spriteSet) do
        local line = PaperSpriteToString(sprite)
        file:write(line .. "\n")
    end
    
    io.close(file)
end

function EnterSpriteSetName()
    TextEntryOn = true
    TextEntered = SpriteSetName or ""
    TextEntryFinished = SpriteSetNameEntered
end

function SpriteSetNameEntered()
    if(TextEntered == "") then
        EnterSpriteSetName()
        return
    end
    local spriteSet = CurrentSpriteSet()
    SpriteSetIndex = TextEntered
    SpriteSetName = SpriteSetIndex
    SpriteSets[SpriteSetIndex] = spriteSet

    SaveSpriteSet()
end

function LoadSpriteSet(filename)
    filename = "spritesets/" .. filename
    local spriteSet = {}
    for line in love.filesystem.lines(filename) do
		table.insert(spriteSet, PaperSpriteFromString(line))
	end
    return spriteSet
end

function LoadSpriteSets()
    local dir  = "spritesets"

    local files = love.filesystem.getDirectoryItems(dir)
    for _, value in ipairs(files) do
        SpriteSets[value] = LoadSpriteSet(value)
    end

    if(#SpriteSets > 0) then
        SpriteSetIndex = 1
    end
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
   
    local qx, qy, qw, qh = 0, 0, 0, 0
    local sw, sh = 0, 0
    if(sprite.Quad ~= nil) then
        qx, qy, qw, qh = sprite.Quad:getViewport()
        sw, sh = sprite.Quad:getTextureDimensions( )
    end
    

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

    prog.BannerHeight = 60

    prog.OffsetX = 20
    prog.OffsetY = prog.BannerHeight + 20

    -- mapping sprites to names/indexes
    
    prog.SpriteIndex = 0

    MouseDragX = 0
    MouseDragY = 0

    function prog:Draw()
        local lg = love.graphics
        lg.push("all")

        --lg.clear(0.4, 0.4, 0.4)
        DrawEditorBackground()
        lg.setLineWidth(4)

        lg.setFont(Font_K)

        local str = "Current Sheet: " .. SheetIndex
        lg.print(str, 10, 0)

        local spriteSet = CurrentSpriteSet() or {}

        str = "Current Sprite: " .. tostring(self.SpriteIndex) .. "/" .. tostring(#spriteSet)
        lg.print(str, 10, 20)

        str = "Current SpriteSet: " .. tostring(SpriteSetIndex or "none")
        lg.print(str, 700, 20)

        lg.translate(self.OffsetX, self.OffsetY)
        lg.scale(self.Scale, self.Scale)

        local screenTop = (self.BannerHeight + 10)/self.Scale - self.OffsetY/self.Scale
        local screenBottom = ScreenHeight/self.Scale - self.OffsetY/self.Scale

        ScrollLock = false

        local sheet = CurrentTexture()

        local viewW = sheet:getWidth()
        local viewH = sheet:getHeight()


        lg.setColor(0.4, 0.4, 0.4)
        lg.rectangle("fill", 0, 0, viewW, viewH)
        lg.setColor(1, 1, 1)
        love.graphics.draw(sheet, 0, 0)
        lg.rectangle("line", 0, 0, viewW, viewH)

        local mx, my = GetRelativeMouse(self.Scale, self.OffsetX, self.OffsetY)

        local button = ClickableButton(0, 0, viewW, viewH, {
            --LHeld = self.SetSkeletonXY,
            LHeld = self.SpriteBounds,
            LReleased = self.SetSpriteBounds,
            RPressed = self.SetSpriteAnchor,
        })
        CheckClickableButton(self, button, mx, my)

        lg.circle("line", mx, my, 5)

        local spriteSet = SpriteSets[SpriteSetIndex] or {}
        local dx = sheet:getWidth() + 20
        local startDY = screenTop
        local dy = startDY
        local maxX = 0
        for i, sprite in ipairs(spriteSet) do
            local w, h = 200, 100
            if(dy + h > screenBottom) then
                dy = startDY
                dx = maxX + 20
            end

            if(sprite.Quad ~= nil) then
                _, _, w, h = sprite.Quad:getViewport()
                -- necessary so accidentally tiny quads are still barely clickable
                if(w < 100) then
                    w = 100
                end
                if(h < 100) then
                    h = 100
                end

                if(dy + h > screenBottom) then
                    dy = startDY
                    dx = maxX + 10
                end

                lg.setColor(0.4, 0.4, 0.4)
                lg.rectangle("fill", dx, dy, w, h)
                lg.setColor(1, 1, 1)

                DrawPaperSprite(sprite, CurrentTexture(), dx + sprite.AnchorX, dy + sprite.AnchorY)
            else
                lg.setColor(0.4, 0.4, 0.4)
                lg.rectangle("fill", dx, dy, w, h)
                lg.setColor(1, 1, 1)
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

            local button = ClickableButton(dx, dy, w, h, {
                SpriteIndex = i,
                LPressed = self.SetSpriteIndex,
                RPressed = self.SetSpriteAnchor,
            })
            CheckClickableButton(self, button, mx, my)

            maxX = math.max(maxX, dx + w)

            lg.setColor(1, 1, 1)

            dy = dy + h + 20


        end

        lg.pop()

        lg.push("all")

        local mx, my = GetRelativeMouse(1, 0, 0)

        lg.setColor(0.2, 0.2, 0.2)
        lg.rectangle("fill", 0, 0, ScreenWidth, self.BannerHeight)
        lg.setFont(Font_Consolas16)

        local newSpriteButton = ClickableButton(30, 5, 150, 50, {
            LPressed = self.CreateSprite,
        })
        DrawCheckButton(self, newSpriteButton, "New Sprite", mx, my)

        local deleteSpriteButton = ClickableButton(190, 5, 150, 50, {
            LPressed = self.DeleteSprite,
        })
        DrawCheckButton(self, deleteSpriteButton, "Delete Sprite", mx, my)

        local saveSpriteButton = ClickableButton(350, 5, 200, 50, {
            LPressed = self.SaveSpriteButton,
        })
        DrawCheckButton(self, saveSpriteButton, "Save Sprite Set", mx, my)

        lg.pop()
        
        
    end

    function prog:SetSpriteIndex(button, mx, my)
        self.SpriteIndex = button.SpriteIndex
    end

    function prog:SpriteBounds(button, mx, my)
        local lg = love.graphics
        lg.setColor(1, 0, 0)
        lg.rectangle("line", MouseDragX, MouseDragY, mx - MouseDragX, my - MouseDragY)
        lg.setColor(1, 1, 1)
    end

    function prog:SetSpriteBounds(button, mx, my)
        local sprite = self:CurrentSprite()
        if(sprite == nil) then
            return
        end
        --if(mb == 1) then
            --local mx, my = GetRelativeMouse(prog.Scale, prog.OffsetX, prog.OffsetY)
            local x1 = math.min(MouseDragX, mx)
            local x2 = math.max(MouseDragX, mx)
            local y1 = math.min(MouseDragY, my)
            local y2 = math.max(MouseDragY, my)
            self:DefineQuad(x1, y1, x2 - x1, y2 - y1)
        --end
    end

    function prog:SetSpriteAnchor(button, mx, my)
        local sprite = self:CurrentSprite()
        if(sprite == nil) then
            return
        end
        
        local x, y, w, h = sprite.Quad:getViewport()

        if(button.SpriteIndex ~= nil) then
            x = 0
            y = 0
        end

        self:DefineAnchor(mx - x - button.X, my - y - button.Y)
    end

    function prog:Update()
        local mx, my = GetRelativeMouse(self.Scale, self.OffsetX, self.OffsetY)
        if(not ScrollLock) then
            if(love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
                self.Scale = Clamp(self.Scale + MouseWheel*0.05, 0.1, 10)
            end
        end

        if(MousePressed[3]) then
            ScreenDragX = mx
            ScreenDragY = my
        end
        if(MouseDown[3] and not CtrlDown and not ShiftDown and not AltDown) then
            self.OffsetX = self.OffsetX + (mx - ScreenDragX) * self.Scale
            self.OffsetY = self.OffsetY + (my - ScreenDragY) * self.Scale
            mx, my = GetRelativeMouse(self.Scale, self.OffsetX, self.OffsetY)
            ScreenDragX = mx
            ScreenDragY = my
        end
    end

    function prog:DeleteSprite()
        local spriteSet = CurrentSpriteSet() or {}
        table.remove(spriteSet, self.SpriteIndex)

    end

    function prog:SaveSpriteButton()
        local spriteSet = CurrentSpriteSet() or {}
        if(#spriteSet > 0) then
            SaveSpriteSet(spriteSet, tostring(SpriteSetIndex))
        else
            print("Can't save sprite set...")
        end
    end

    function prog:KeyPressed(key, scancode, isrepeat)
        local spriteSet = CurrentSpriteSet() or {}
        if(key == "n") then
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
            if((love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) and #spriteSet > 0) then
                SaveSpriteSet(spriteSet, tostring(SpriteSetIndex))
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
        

            
    end

    function prog:MouseReleased(mb)

    end

    function prog:CurrentSprite()
        local spriteSet = CurrentSpriteSet()
        if(spriteSet == nil) then
            return nil
        end
        return spriteSet[self.SpriteIndex]
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

