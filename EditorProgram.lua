require "PaperSprite"
require "PaperSkeleton"
require "PartBlueprint"
require "PartFrame"
require "PaperAnimation"
require "EditorStartScreen"

local utf8 = require("utf8")

CurrentScreen = nil
-- contains all sprite sets
-- each set is a collection of PaperSprites
SpriteSets = {}
-- contains all skeletons
Skeletons = {}

-- name of current spriteset or skeleton
SpriteSetName = nil
SkeletonName = nil

-- what sheet we're using for drawing
SheetIndex = 1
SpriteSetIndex = nil

-- skeletons
-- SCARY!
Skeletons = { }
SkeletonIndex = 1

-- text entry
TextEntryOn = false
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

function DarkGray()
    love.graphics.setColor(0.4, 0.4, 0.4)
end

function White()
    love.graphics.setColor(1, 1, 1)
end