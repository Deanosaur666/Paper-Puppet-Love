require "PaperSprite"

CurrentScreen = nil
-- contains all sprite sets
-- each set is a collection of PaperSprites
SpriteSets = {}
-- contains all skeletons
Skeletons = {}

EditorProgram = BlankProgram()
CurrentScreen = PaperSpriteEditor()

function EditorProgram.Draw()
    if(CurrentScreen ~= nil) then
        CurrentScreen.Draw()
    end
end

function EditorProgram.SaveAll()

end