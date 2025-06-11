
-- paper part blueprint has:
-- parent (a hand is parented to an arm, which is parented to upper arm, which is parented to body)
-- parent offset ()
-- ik flag (for hands and feet that can drag limbs)
-- position lock flag (for elbows and stuff that can't be moved from anchor)

function PartBlueprint(parentIndex, parentOffsetX, parentOffsetY, defSpriteIndex, ik, positionLock)
    return {
        ParentIndex = parentIndex,
        ParentOffsetX = parentOffsetX,
        ParentOffsetY = parentOffsetY,
        DefSpriteIndex = defSpriteIndex,
        IK = ik,
        PositionLock = positionLock
    }
end

-- paper part frame has:
-- current sprite index,
-- rotation, position
-- stretch (for arms and legs, defined by ik)

function PartFrame(blueprintIndex, spriteIndex, rotation, x, y, layer)
    return {
        BlueprintIndex = blueprintIndex,
        SpriteIndex = spriteIndex,
        Rotation = rotation,
        -- current rotation after rotation by parent
        CRotation = rotation,
        X = x,
        y = y,
        -- current x and y values after offset by parent
        CX = x,
        CY = y,
        ScaleX = 1,
        ScaleY = 1,
        Layer = layer
    }
end

function GetPartBluePrint(part, skeleton)

end

function GetParent(part, skeleton)
    -- return this part's parent 
end

function UpdatePartFrame(part, skeleton)
    local parent = GetParent(part, skeleton)
    local blueprint = GetPartBluePrint(part, skeleton)

    if(parent == nil) then
        part.CX = part.X
        part.CY = part.Y
        part.CRotation = part.Rotation;
        return
    end

    -- look at parent rotation and position

end