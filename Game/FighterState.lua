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

function FighterFrame(fstate, fsheet)
    local skeletonName = fsheet.SkeletonIndex
    local skeleton = Skeletons[skeletonName]
    local action = fsheet.Actions[fstate.CurrentAction]
    local anim = SkeletonAnimNameMap[skeletonName][action.AnimName]
    local pose = anim.Frames[fstate.CurrentFrame]
    
    local xsc = 1
    if(not fstate.Facing) then
        xsc = -1
    end

    local fframe = {

        State = fstate,
        Sheet = fsheet,

        Skeleton = skeleton,
        Action = action,
        Animation = anim,
        Pose = pose,
        Hitballs = GetPoseHitballs(pose, skeleton, fstate.X, fstate.Y, xsc, 1),
        XScale = xsc,
    }
end

function UpdateFighter(fstate, fframe)

    return fstate
end

function DrawFighter(fframe)
    local fstate = fframe.State
    local spriteSet = SpriteSets[fframe.Sheet.SpriteSetIndex]
    local tex = SpriteSheets[fframe.Sheet.TextureIndex]

    DrawPose(fframe.Pose, fframe.Skeleton, spriteSet, tex, fstate.X, fstate.Y, 0, fframe.XScale, 1)
end