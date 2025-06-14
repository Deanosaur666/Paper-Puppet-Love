require "PaperSprite"
require "PaperSkeleton"
require "PartBlueprint"
require "PartFrame"
require "PaperAnimation"

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

function EditorProgram:Draw()
    if(CurrentScreen ~= nil) then
        CurrentScreen:Draw()
    end
end

function EditorProgram:Update()
    if(CurrentScreen ~= nil) then
        CurrentScreen:Update()
    end
end

function EditorProgram:KeyPressed(key, scancode, isrepeat)
    if(CurrentScreen ~= nil) then
        CurrentScreen:KeyPressed(key, scancode, isrepeat)
    end

    if(key == "1") then
        CurrentScreen = PaperSpriteEditor()
    elseif(key == "2") then
        CurrentScreen = PartBlueprintEditor()
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