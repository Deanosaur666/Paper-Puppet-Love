
-- paper part blueprint has:
-- parent (a hand is parented to an arm, which is parented to upper arm, which is parented to body)
-- parent offset ()
-- ik flag (for hands and feet that can drag limbs)
-- position lock flag (for elbows and stuff that can't be moved from anchor)

-- TODO: add hit balls to part blueprints

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

-- TODO: add hit ball type for current part for current frame (hittable, unhittable, active+hitabble, active+unhittable (disjoint))

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
    -- use part.BlueprintIndex
    return skeleton.PartBluePrints[part.BluePrintIndex]
end

function GetParent(part, frame)
    -- return this part's parent
    -- use part.ParentIndex
    return frame.Parts[part.ParentIndex]
end

function UpdatePartFrame(part, frame, skeleton)
    local parent = GetParent(part, frame)
    local blueprint = GetPartBluePrint(part, skeleton)

    if(parent == nil) then
        part.CX = part.X
        part.CY = part.Y
        part.CRotation = part.Rotation;
        return
    end

    -- look at parent rotation and position
    local px = parent.CX
    local py = parent.CY
    local prot = parent.CRotation

    local pxscale = parent.ScaleX
    local pyscale = parent.ScaleY

    -- add parent rotation and modulo to keep within 0 and 2pi
    part.CRotation = (prot + part.Rotation + 2*math.pi) % math.pi

    part.CX = px + (blueprint.ParentOffsetX + part.X)*math.cos(prot)*pxscale
    part.CX = px + (blueprint.ParentOffsetY + part.Y)*math.sin(prot)*pyscale

end

function GetPartSprite(part, spriteSet)
    return spriteSet[part.SpriteIndex]
end

function MovePart(dx, dy)
    -- move a part's on-screen position, taking inherited rotation into account
    -- effectively, we want CX and CY to change by these values next update
end

function ApplyIK(part, frame)
    -- for now, we can assume IK always goes two bones back
    -- we also assume IK controllers (hands and feet) completely hijack the scale of their two previous bones
    -- we want p1xoffset*cos(p1angle) + p2xoffset*cos(p2angle) = IK target X
    local parent1 = GetParent(part, frame) -- the nearer parent
    local parent2 = GetParent(parent1, frame) -- the farther parent
    -- at first, we assume we can only change their rotations
end

function FlipIK(part, skeleton)
    -- there are two valid rotations for any IK that's not fully extended
    -- so we want to be able to swap between them
end