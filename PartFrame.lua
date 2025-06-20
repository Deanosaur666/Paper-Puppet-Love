-- paper part frame has:
-- current sprite index,
-- rotation, position
-- stretch (for arms and legs, defined by ik)

require "Math"

-- TODO: add hit ball type for current part for current frame (hittable, unhittable, active+hitabble, active+unhittable (disjoint))

function PartPose(skeleton, blueprintIndex)
    local part = {
        BlueprintIndex = blueprintIndex,
        SpriteIndex = nil,
        Rotation = 0,
        -- current rotation after rotation by parent
        CRotation = 0,
        X = 0,
        Y = 0,
        -- current x and y values after offset by parent
        CX = 0,
        CY = 0,
        XScale = 1,
        YScale = 1,
        Layer = nil,

        Hidden = false,

        HitballFlags = {},
        HitballScale = {}
    }

    local blueprint = GetPartBluePrint(part, skeleton)
    local hitballs = #blueprint.Hitballs
    fillArray(part.HitballFlags, HITBALL_HITTABLE, hitballs)
    fillArray(part.HitballScale, 1, hitballs)

    return part
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

function UpdatePartPose(part, frame, skeleton)
    local blueprint = GetPartBluePrint(part, skeleton)
    local parent = GetParent(part, blueprint, frame)
    part.Rotation = part.Rotation % (math.pi * 2)

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