require "PaperSprite"
require "PaperSkeleton"
require "PartBlueprint"
require "PartFrame"
require "PaperAnimation"

local utf8 = require("utf8")

CurrentScreen = nil
-- contains all sprite sets
-- each set is a collection of PaperSprites
SpriteSets = {}
-- contains all skeletons
Skeletons = {}

-- what sheet we're using for drawing
SheetIndex = 1
SpriteSetIndex = nil

-- skeletons
-- SCARY!
Skeletons = { PaperSkeleton() }
SkeletonIndex = 1

-- text entry
TextEntryOn = false
TextEntryPattern = "[%w%._]+" -- just alphanumeric characters, dot, and underscore
TextEntered = ""
TextEntryFinished = nil -- a function for when entry is finished

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
CurrentScreen = PaperSpriteEditor()

TextEntryOn = true

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
    
    -- screen change
    -- we return so the screen won't receive this input
    if(key == "1") then
        CurrentScreen = PaperSpriteEditor()
        return
    elseif(key == "2") then
        CurrentScreen = PartBlueprintEditor()
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