
-- paper part blueprint has:
-- parent (a hand is parented to an arm, which is parented to upper arm, which is parented to body)
-- parent offset ()
-- ik flag (for hands and feet that can drag limbs)
-- position lock flag (for elbows and stuff that can't be moved from anchor)

function PartBlueprint(parentIndex, x, y, defSpriteIndex)
    return {
        ParentIndex = parentIndex,
        X = x,
        Y = y,
        DefSpriteIndex = defSpriteIndex,
        DefLayer = 0,
        IK = false,
        PositionLock = false,
        Hitballs = {},
        FlippedX = false,
        FlippedY = false,
    }
end

-- this is just used for flipping
function GetBlueprintScale(bp)
    local xsc = 1
    local ysc = 1
    if(bp.FlippedX) then
        xsc = -1
    end
    if(bp.FlippedY) then
        ysc = -1
    end

    return xsc, ysc
end