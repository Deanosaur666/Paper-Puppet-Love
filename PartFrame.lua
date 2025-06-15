-- paper part frame has:
-- current sprite index,
-- rotation, position
-- stretch (for arms and legs, defined by ik)

require "Math"

-- TODO: add hit ball type for current part for current frame (hittable, unhittable, active+hitabble, active+unhittable (disjoint))

function PartFrame(blueprintIndex, spriteIndex, rotation, x, y, layer)
    return {
        BlueprintIndex = blueprintIndex,
        SpriteIndex = spriteIndex,
        Rotation = rotation,
        -- current rotation after rotation by parent
        CRotation = rotation,
        X = x,
        Y = y,
        -- current x and y values after offset by parent
        CX = x,
        CY = y,
        XScale = 1,
        YScale = 1,
        Layer = layer,

        HitballFlags = {}, -- changing hit balls from inactive to active, for example
        HitballScale = {} -- changing the size of a hit ball for an attack
    }
end

function GetPartSprite(part, blueprint, spriteSet)
    return spriteSet[part.SpriteIndex or blueprint.DefSpriteIndex]
end

function GetPartBluePrint(part, skeleton)
    -- use part.BlueprintIndex
    return skeleton.PartBlueprints[part.BlueprintIndex]
end

function GetParent(part, blueprint, frame)
    -- return this part's parent
    -- use part.ParentIndex
    return frame.PartFrames[blueprint.ParentIndex]
end

function UpdatePartFrame(part, frame, skeleton)
    local blueprint = GetPartBluePrint(part, skeleton)
    local parent = GetParent(part, blueprint, frame)

    if(parent == nil) then
        part.CX = part.X + blueprint.X
        part.CY = part.Y + blueprint.Y
        part.CRotation = part.Rotation;
        return
    end

    -- look at parent rotation and position
    local px = parent.CX
    local py = parent.CY
    local prot = parent.CRotation

    local pxscale = parent.XScale
    local pyscale = parent.YScale

    -- add parent rotation and modulo to keep within 0 and 2pi
    part.CRotation = prot + part.Rotation

    local dx, dy = RotatePoint((blueprint.X + part.X)*pxscale, (blueprint.Y + part.Y)*pyscale, prot)

    part.CX = px + dx
    part.CY = py + dy

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