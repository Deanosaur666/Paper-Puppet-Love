
-- paper skeleton has:
-- sprite slots (should match sprite set)
-- paper parts
-- animations, which have:
--      frames, which are collections of parts

function PaperSkeleton()
    return {
        SpriteSlots = {}, -- full of PaperSprites
        PartBluePrints = {}, -- full of PartBluePrints
    }
end