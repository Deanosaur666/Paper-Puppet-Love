-- an instance of a fighter on screen
-- needs: a reference to a Fighter sheet
-- x, y, facing, current animation, current frame

function FighterState()
    return {
        -- basically their current animation
        CurrentAction = "Idle",
        CurrentFrame = 1,
        FrameTimeLeft = 0,

        X = 0,
        Y = 0,

        -- facing right
        Facing = true,
    }
end

function GetFighterPose(fstate, fsheet)
    local skeletonName = fsheet.SkeletonIndex
    local action = fsheet.Actions[fstate.CurrentAction]
    local anim = SkeletonAnimNameMap[skeletonName][action.AnimName]

    return anim.Frames[fstate.CurrentFrame]
end

function DrawFighter(fstate, fsheet)
    local pose = GetFighterPose(fstate, fsheet)
    local skeleton = Skeletons[fsheet.SkeletonIndex]
    local spriteSet = SpriteSets[fsheet.SpriteSetIndex]
    local tex = SpriteSheets[fsheet.TextureIndex]

    local xsc = 1
    if(not fstate.Facing) then
        xsc = -1
    end

    DrawPose(pose, skeleton, spriteSet, tex, fstate.X, fstate.Y, 0, xsc, 1)
end