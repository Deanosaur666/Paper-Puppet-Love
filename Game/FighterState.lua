-- an instance of a fighter on screen
-- needs: a reference to a Fighter sheet
-- x, y, facing, current animation, current frame

function FighterState(props)
    local state = {
        -- basically their current animation
        CurrentAction = "Idle",
        -- I cut the "time left" value, because it's unnecessary, and you can find this by just looking at the animation
        -- so rather than frame index, this is just a timer
        CurrentFrame = 1,

        X = 0,
        Y = 0,

        -- facing right
        Facing = true,
    }
    state = tableMerge(state, props)

    return state
end

function BeginAction(fstate, action)
    fstate.CurrentAction = action
    fstate.CurrentFrame = 1
end

function FighterFrame(fstate, fsheet)
    local skeletonName = fsheet.SkeletonIndex
    local skeleton = Skeletons[skeletonName]
    local action = fsheet.Actions[fstate.CurrentAction]
    local anim = SkeletonAnimNameMap[skeletonName][action.AnimName]
    --local pose = anim.Frames[fstate.CurrentFrame]
    local pose = GetAnimationFrame(anim, fstate.CurrentFrame, fstate.CurrentAction == "Idle")
    
    if(pose == nil) then
        BeginAction(fstate, "Idle")
        pose = GetAnimationFrame(anim, fstate.CurrentFrame, false)
    end
    

    -- TWEEN test
    --pose = TweenedPose(skeleton, pose, anim.Frames[fstate.CurrentFrame+3], (CurrentFrame % 30)/30)
    --UpdatePose(pose, skeleton)
    
    --if(math.random(0, 10) > 5) then
    --    pose = anim.Frames[fstate.CurrentFrame+1]
    --end
    
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

    return fframe
end

function UpdateFighter(fstate, fframe)
    fstate.CurrentFrame = fstate.CurrentFrame + 1

    fframe = FighterFrame(fstate, fframe.Sheet)
    return fstate, fframe
end

function DrawFighter(fframe)
    local fstate = fframe.State
    local spriteSet = SpriteSets[fframe.Sheet.SpriteSetIndex]
    local tex = SpriteSheets[fframe.Sheet.TextureIndex]

    DrawPose(fframe.Pose, fframe.Skeleton, spriteSet, tex, fstate.X, fstate.Y, 0, fframe.XScale, 1)
end