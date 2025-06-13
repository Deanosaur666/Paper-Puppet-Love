require "PaperSprite"

CurrentScreen = nil
-- contains all sprite sets
-- each set is a collection of PaperSprites
SpriteSets = {}
-- contains all skeletons
Skeletons = {}

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