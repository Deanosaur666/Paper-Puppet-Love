
-- paper skeleton has:
-- sprite slots (should match sprite set)
-- paper parts
-- animations, which have:
--      frames, which are collections of parts

function PaperSkeleton()
    return {
        Name = "",
        PartBlueprints = {}, -- full of PartBluePrints
        Animations = {}
    }
end

function Animation(name)
    return {
        Name = name,
        Frames = {},
    }
end

function Frame()
    return {
        Duration = 0,
        Parts = {} -- a collection of PartFrames
        -- more like FartPrames
    }
end