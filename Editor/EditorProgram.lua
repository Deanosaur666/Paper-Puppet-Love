
CurrentScreen = nil
-- contains all sprite sets
-- each set is a collection of PaperSprites
-- contains all skeletons

-- name of current spriteset or skeleton
SpriteSetName = nil
SkeletonName = nil

-- what sheet we're using for drawing
SheetIndex = 1
SpriteSetIndex = nil

-- skeletons
-- SCARY!
SkeletonIndex = 1

-- text entry
TextEntryOn = false
TextEntryPrompt = nil
TextEntryPattern = "[%w%.%s_]+" -- just alphanumeric characters, space, dot, and underscore
TextEntered = ""
TextEntryFinished = nil -- a function for when entry is finished


-- Core data for multiple editors

MouseDragX = nil
MouseDragY = nil

ScreenDragX = nil
ScreenDragY = nil

SkeletonFrame = nil
SkeletonX = 0
SkeletonY = 0
CurrentPart = nil
CurrentHitball = nil

CurrentPartStartCRotation = 0
CurrentPartStartCX = 0
CurrentPartStartCY = 0
CurrentPartStartXScale = 0
CurrentPartStartYScale = 0
PartDragMX = 0
PartDragMY = 0

function CurrentTexture()
    return SpriteSheets[SpriteSheetFiles[SheetIndex]]
end

function CurrentSpriteSet()
    return SpriteSets[SpriteSetIndex]
end

function CurrentSkeleton()
   return Skeletons[SkeletonIndex]
end

EditorProgram = BlankProgram()

function EditorProgram:Load()
    CurrentScreen = SelectionMenu()
end

function EditorProgram:Draw()
    local lg = love.graphics
    if(CurrentScreen ~= nil) then
        CurrentScreen:Draw()
    end

    if(TextEntryOn) then
        lg.push("all")
        lg.setFont(Font_Consolas32)
        local text = TextEntered .. " "
        local w = math.max(Font_Consolas32:getWidth(text), 100)
        local h = Font_Consolas32:getHeight()
        local x = ScreenWidth/2 - w/2
        local y = ScreenHeight/2 - h/2

        lg.setColor(0, 0, 0)
        lg.rectangle("fill", x, y, w, h)
        lg.setColor(1, 1, 1)
        lg.print(text, x, y)

        if(TextEntryPrompt ~= nil) then
            text = TextEntryPrompt
            w = Font_Consolas32:getWidth(text)
            y = y - h - 10
            x = ScreenWidth/2 - w/2
            lg.rectangle("fill", x, y, w, h)
            lg.setColor(0, 0, 0)
            lg.print(text, x, y)
        end

        lg.pop()
    end
end

function EditorProgram:Update()
    if(CurrentScreen ~= nil) then
        CurrentScreen:Update()
    end
end

function EditorProgram:KeyPressed(key, scancode, isrepeat)
    
    if(TextEntryOn) then
        if key == "backspace" then
            -- get the byte offset to the last UTF-8 character in the string.
            local byteoffset = utf8.offset(TextEntered, -1)

            if byteoffset then
                -- remove the last UTF-8 character.
                -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
                TextEntered = string.sub(TextEntered, 1, byteoffset - 1)
            end
        elseif key == "return" then
            TextEntryOn = false
            if(TextEntryFinished) then
                TextEntryFinished(CurrentScreen, TextEntered)
            end
        end
            
        return
    end

    if(key == "escape") then
        CurrentScreen = SelectionMenu()
        return
    end
    
    local filesSelected = FilesSelected()
    -- screen change
    -- we return so the screen won't receive this input
    if(key == "1" and filesSelected) then
        CurrentScreen = PaperSpriteEditor()
        return
    elseif(key == "2" and filesSelected) then
        CurrentScreen = PartBlueprintEditor()
        return
    elseif(key == "3" and filesSelected) then
        CurrentScreen = AnimationEditor()
        return
    end

    if(CurrentScreen ~= nil) then
        CurrentScreen:KeyPressed(key, scancode, isrepeat)
    end
end

function EditorProgram:TextInput(t)
    if(TextEntryOn) then
        TextEntered = TextEntered .. (t:match(TextEntryPattern) or "")
        return
    end

    if(CurrentScreen ~= nil) then
        CurrentScreen:TextInput(t)
    end
end


function EditorProgram:MousePressed(mb)
    if(CurrentScreen ~= nil) then
        CurrentScreen:MousePressed(mb)
    end
end

function EditorProgram:MouseHeld(mb)
    if(CurrentScreen ~= nil) then
        CurrentScreen:MouseHeld(mb)
    end
end

function EditorProgram:MouseReleased(mb)
    if(CurrentScreen ~= nil) then
        CurrentScreen:MouseReleased(mb)
    end
end

function EditorProgram:SaveAll()

end

function PrintCentered(text, x, y)
    local lg = love.graphics
    local font = lg.getFont()
    local w = font:getWidth(text)
    local h = font:getHeight()
    x = x - w/2
    y = y - h/2

    lg.print(text, x, y)
end

function DrawEditorBackground()
    local lg = love.graphics
    lg.push("all")

    lg.clear(0.3, 0.3, 0.3)
    
    lg.setLineWidth(2)
    
    DarkGray()

    local w = ScreenWidth/15
    for x=w/2,ScreenWidth,w do
        lg.line(x, 0, x, ScreenHeight)
    end

    for y=w/2,ScreenHeight,w do
        lg.line(0, y, ScreenWidth, y)
    end

    lg.setColor(0.6, 0.6, 0.6)

    for x=0,ScreenWidth,w do
        lg.line(x, 0, x, ScreenHeight)
    end

    for y=0,ScreenHeight,w do
        lg.line(0, y, ScreenWidth, y)
    end

    lg.pop()
end

function UpdateZoomAndOffset(self)
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

function DarkGray()
    love.graphics.setColor(0.4, 0.4, 0.4)
end

function White()
    love.graphics.setColor(1, 1, 1)
end

function ClickableButton(x, y, w, h, props)
    local button = {
        X = x,
        Y = y,
        W = w,
        H = h
    }

    function button.LPressed(prog, button, mx, my)
        -- nothing
    end
    function button.RPressed(prog, button, mx, my)
        -- nothing
    end
    function button.MPressed(prog, button, mx, my)
        -- nothing
    end
    function button.LHeld(prog, button, mx, my)
        -- nothing
    end
    function button.RHeld(prog, button, mx, my)
        -- nothing
    end
    function button.MHeld(prog, button, mx, my)
        -- nothing
    end
    function button.LReleased(prog, button, mx, my)
        -- nothing
    end
    function button.RReleased(prog, button, mx, my)
        -- nothing
    end
    function button.MReleased(prog, button, mx, my)
        -- nothing
    end

    for k, v in pairs(props) do
        button[k] = v
    end

    return button
end

function CheckClickableButton(prog, button, mx, my)
    if(not PointInRectangle(mx, my, button.X, button.Y, button.W, button.H)) then
        return
    end
    if(MousePressed[1]) then
        button.LPressed(prog, button, mx, my)
    end
    if(MousePressed[2]) then
        button.RPressed(prog, button, mx, my)
    end
    if(MousePressed[3]) then
        button.MPressed(prog, button, mx, my)
    end
    if(MouseDown[1]) then
        button.LHeld(prog, button, mx, my)
    end
    if(MouseDown[2]) then
        button.RHeld(prog, button, mx, my)
    end
    if(MouseDown[3]) then
        button.MHeld(prog, button, mx, my)
    end
    if(MouseDownPrev[1] and not MouseDown[1]) then
        button.LReleased(prog, button, mx, my)
    end
    if(MouseDownPrev[2] and not MouseDown[2]) then
        button.RReleased(prog, button, mx, my)
    end
    if(MouseDownPrev[3] and not MouseDown[3]) then
        button.MReleased(prog, button, mx, my)
    end
end

function GetRelativeMouse(scale, offsetX, offsetY)
    local mx, my = love.mouse.getPosition()

    mx = (mx - offsetX) / scale
    my = (my - offsetY) / scale
    
    return mx, my
end


function DrawCheckButton(prog, button, text, mx, my, r, g, b)
    local lg = love.graphics
    lg.push("all")
    CheckClickableButton(prog, button, mx, my)

    r = r or 1
    g = g or 1
    b = b or 0
    lg.setLineWidth(3)
    lg.setColor(r, g, b)
    
    lg.rectangle("fill", button.X, button.Y, button.W, button.H)
    lg.setColor(0, 0, 0)
    lg.rectangle("line",  button.X, button.Y, button.W, button.H)

    PrintCentered(text, button.X + button.W/2, button.Y + button.H/2)
    lg.pop()
    
end