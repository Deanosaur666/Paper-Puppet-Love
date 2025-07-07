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

        StateFlags = 0,

        -- facing right
        Facing = true,
    }
    state = tableMerge(state, props)

    return state
end

function BeginAction(fstate, fframe, actionName)
    local action = fframe.Sheet.Actions[actionName]
    fstate.CurrentAction = actionName
    fstate.CurrentFrame = 1
    fstate.StateFlags = action.StateFlags
end

function FighterFrame(fstate, fsheet)
    local skeletonName = fsheet.SkeletonIndex
    local skeleton = Skeletons[skeletonName]
    local action = fsheet.Actions[fstate.CurrentAction]
    local anim = action.Animation
    --local pose = anim.Frames[fstate.CurrentFrame]
    local pose = GetAnimationFrame(anim, fstate.CurrentFrame, fstate.CurrentAction == "Idle")
    

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

-- fsheet is only needed if fframe is nil
-- might be useful for rollback. IDK
function UpdateFighter(fstate, fframe, controller, fsheet)
    
    if(fframe == nil) then
        fframe = FighterFrame(fstate, fsheet)
    end
    
    fstate.CurrentFrame = fstate.CurrentFrame + 1
    local action = fframe.Action
    if(action.Startup and action.Active and action.Recovery) then
        if(fstate.CurrentFrame <= action.Startup) then
            fstate.StateFlags = SetStateAttackPhase(fstate.StateFlags, PHASE_STARTUP)
        elseif(fstate.CurrentFrame <= action.Startup + action.Active) then
            fstate.StateFlags = SetStateAttackPhase(fstate.StateFlags, PHASE_ACTIVE)
        elseif(fstate.CurrentFrame <= action.Startup + action.Active + action.Recovery) then
            fstate.StateFlags = SetStateAttackPhase(fstate.StateFlags, PHASE_RECOVERY)
        else
            -- TODO: fake idle
        end
    end

    local pose = GetAnimationFrame(fframe.Animation, fstate.CurrentFrame)
    if(pose == nil) then
        BeginAction(fstate, fframe, "Idle")
    end

    CheckActions(fstate, fframe, controller)

    local xsc = 1
    if(not fstate.Facing) then
        xsc = -1
    end

    local dx = 0

    if(ControllerInputDown(controller, FlipInput(fstate.Facing, BUTTON_LEFT)) and bit.band(fstate.StateFlags, STATE_CANMOVE) ~= 0) then
        dx = - fframe.Sheet.WalkBackSpeed*xsc
    end
    if(ControllerInputDown(controller, FlipInput(fstate.Facing, BUTTON_RIGHT)) and bit.band(fstate.StateFlags, STATE_CANMOVE) ~= 0) then
        dx = fframe.Sheet.WalkForwardSpeed*xsc
    end
    fstate.X = fstate.X + dx

    -- create new fighter frame at the end, after updating state a bunch
    return fstate
end

function CheckActions(fstate, fframe, controller)
    local bufferLength = 10
    
    bufferLength = math.min(bufferLength, CurrentFrame - controller.LastBuffered)

    local actions = fframe.Sheet.Actions
    local perform = nil
    local biggestInput = 0
    for name, action in pairs(actions) do
        local input = bit.bor(action.InputPressed or 0, action.InputHeld or 0)
        if(CanPerformAction(action, fstate, controller, bufferLength) and input >= biggestInput) then
            perform = name
            biggestInput = input
        end
    end

    if(perform ~= nil) then
        -- do buffer cutoff
        controller.LastBuffered = controller.BufferTime
        BeginAction(fstate, fframe, perform)
    end
end

function DrawFighter(fframe)
    local fstate = fframe.State
    local spriteSet = SpriteSets[fframe.Sheet.SpriteSetIndex]
    local tex = SpriteSheets[fframe.Sheet.TextureIndex]

    DrawPose(fframe.Pose, fframe.Skeleton, spriteSet, tex, fstate.X, fstate.Y, 0, fframe.XScale, 1)
end