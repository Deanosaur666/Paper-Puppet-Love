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

        XVelocity = 0,
        YVelocity = 0,

        XAccel = 0,
        YAccel = 0,

        StateFlags = 0,

        -- facing right
        Facing = true,

        -- duration of hurt animation
        -- nil if not being hurt
        HurtTime = nil,

        Freeze = 0,
    }
    state = tableMerge(state, props)

    return state
end

function FighterFrame(fstate, fsheet, player)
    local skeletonName = fsheet.SkeletonIndex
    local skeleton = Skeletons[skeletonName]
    local action = fsheet.Actions[fstate.CurrentAction]
    local anim = action.Animation
    --local pose = anim.Frames[fstate.CurrentFrame]
    local pose = GetAnimationFrame(action, fstate)
    
    local attackData = action.AttackData

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

        Player = player,

        Skeleton = skeleton,
        Action = action,
        Animation = anim,
        Pose = pose,
        Hitballs = GetPoseHitballs(pose, skeleton, fstate.X, fstate.Y, xsc, 1, {
            AttackData = attackData,
            Player = player,
        }),
        XScale = xsc,

        GoToFront = false,
        GoToBack = false,
    }

    return fframe
end

-- fsheet is only needed if fframe is nil
-- might be useful for rollback. IDK
function UpdateFighter(fstate, fframe, controller, player, fsheet)
    
    fstate = deepcopy(fstate) -- make a new state, just in case old was stored in state history
    
    if(fstate.Freeze > 0) then
        fstate.Freeze = fstate.Freeze - 1
        return fstate
    end

    if(fframe == nil) then
        fframe = FighterFrame(fstate, fsheet, player)
    end

    fsheet = fframe.Sheet

    local xsc = 1
    if(not fstate.Facing) then
        xsc = -1
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

    if(fstate.CurrentFrame == action.StepStart and action.StepDistance ~= 0) then
        fstate.XVelocity = GetVelocity(action.StepDistance, fframe.Sheet.BaseFriction)
        if(not fstate.Facing) then
            fstate.XVelocity = -fstate.XVelocity
        end
        fstate.XAccel = fframe.Sheet.BaseFriction
    end

    local pose = GetAnimationFrame(action, fstate)
    if(pose == nil) then
        local triggered = ActivateTrigger(fstate, fframe, "end")
        
        if(not triggered) then
            local next = action.NextAction
            
            -- handling hops
            if(next == "Hop") then
                local gravity = fsheet.Gravity
                
                if(fstate.CurrentAction == "N Hop Start") then
                    fstate.YVelocity = -GetVelocity(fsheet.NHopHeight, gravity)
                    fstate.YAccel = gravity
                elseif(fstate.CurrentAction == "F Hop Start") then
                    fstate.XVelocity = fsheet.FHopSpeed*xsc
                    fstate.XAccel = 0
                    fstate.YVelocity = -GetVelocity(fsheet.FHopHeight, gravity)
                    fstate.YAccel = gravity
                elseif(fstate.CurrentAction == "B Hop Start") then
                    fstate.XVelocity = -fsheet.BHopSpeed*xsc
                    fstate.XAccel = 0
                    fstate.YVelocity = -GetVelocity(fsheet.BHopHeight, gravity)
                    fstate.YAccel = gravity
                end
            end

            BeginAction(fstate, fframe, next or "Idle")
        end
        
    end

    CheckActions(fstate, fframe, controller)

    local currentAction = fsheet.Actions[fstate.CurrentAction]
    -- check triggers
    -- release trigger
    
    if(currentAction.InputPressed ~= nil) then
       
        if(not ControllerInputDown(controller, currentAction.InputPressed)) then
            ActivateTrigger(fstate, fframe, "release")
        end
    end

    local dx = 0

    if(bit.band(fstate.StateFlags, STATE_CANMOVE) ~= 0) then

        local walked = false
        if(ControllerInputDown(controller, BUTTON_GUARD)) then
            ContinueAction(fstate, fframe, "Guard")
        
        -- hop
        elseif(ControllerInputDown(controller, BUTTON_UP)) then
            
            -- forward hop
            if(ControllerInputDown(controller, FlipInput(fstate.Facing, BUTTON_RIGHT))) then
                BeginAction(fstate, fframe, "F Hop Start")

            -- back hop
            elseif(ControllerInputDown(controller, FlipInput(fstate.Facing, BUTTON_LEFT))) then
                BeginAction(fstate, fframe, "B Hop Start")

            -- neutral hop
            else
                BeginAction(fstate, fframe, "N Hop Start")
                
            end

        elseif(ControllerInputDown(controller, BUTTON_DOWN) or fstate.CurrentAction == "Crouch Down") then
            if(fstate.CurrentAction ~= "Crouch") then
                ContinueAction(fstate, fframe, "Crouch Down")
            else
                ContinueAction(fstate, fframe, "Crouch")
            end
        elseif(ControllerInputDown(controller, FlipInput(fstate.Facing, BUTTON_LEFT))) then
            dx = - fframe.Sheet.WalkBackSpeed*xsc
            ContinueAction(fstate, fframe, "BWalk")
            walked = true
        elseif(ControllerInputDown(controller, FlipInput(fstate.Facing, BUTTON_RIGHT))) then
            dx = fframe.Sheet.WalkForwardSpeed*xsc
            ContinueAction(fstate, fframe, "FWalk")
            walked = true
        -- TODO: Crouching
        elseif(fstate.CurrentAction == "Crouch Up" or fstate.CurrentAction == "Crouch") then
            ContinueAction(fstate, fframe, "Crouch Up")
        else
            ContinueAction(fstate, fframe, "Idle")
        end
    end
    fstate.X = fstate.X + dx

    if(fstate.XVelocity ~= 0) then
        fstate.X = fstate.X + fstate.XVelocity
        local xvelsign = Sign(fstate.XVelocity)
        fstate.XVelocity = fstate.XVelocity - fstate.XAccel*xvelsign
        if(Sign(fstate.XVelocity) ~= xvelsign) then
            fstate.XVelocity = 0
            fstate.XAccel = 0
        end
    end

    if(fstate.YVelocity ~= 0) then
        fstate.Y = fstate.Y + fstate.YVelocity
        fstate.YVelocity = fstate.YVelocity + fstate.YAccel

        -- landing
        if(fstate.Y >= 0) then
            fstate.Y = 0
            fstate.YVelocity = 0
            fstate.XVelocity = 0
            if(action.LandAction) then
                BeginAction(fstate, fframe, action.LandAction)
            else
                ActivateTrigger(fstate, fframe, "land")
            end
        end
    end

    if(fstate.CurrentAction == "Guard" and not ControllerInputDown(controller, BUTTON_GUARD)) then
        BeginAction(fstate, fframe, "Guard Drop")
    end

    -- create new fighter frame at the end, after updating state a bunch
    return fstate
end

function DrawFighter(fframe)
    local fstate = fframe.State
    local spriteSet = SpriteSets[fframe.Sheet.SpriteSetIndex]
    local tex = SpriteSheets[fframe.Sheet.TextureIndex]

    local xoffset = 0
    local yoffset = 0

    if(fstate.Freeze and fstate.Freeze > 0 and fstate.HurtTime and fstate.HurtTime > 0) then
        xoffset = ((GameState.CurrentFrame % 3) - 1)*5
        --yoffset = xoffset/2
    end

    DrawPose(fframe.Pose, fframe.Skeleton, spriteSet, tex, fstate.X + xoffset, fstate.Y + yoffset, 0, fframe.XScale, 1)
end

function HurtFighter(state, frame, attackData, attacker, hitball)

    local hurtTime
    local knockback
    local freeze
    -- not guarding
    if(bit.band(state.StateFlags, STATE_GUARD) == 0) then
        PlaySFX("Hit")

        AddGFX("Hit", hitball.X, hitball.Y, 0, 30)

        BeginAction(state, frame, "Hurt")
        hurtTime = attackData.Stun
        knockback = attackData.Knockback
        attacker.StateFlags = bit.bor(attacker.StateFlags, STATE_ATTACK_HIT)
        freeze = attackData.HitFreeze

    -- guarding
    else
        PlaySFX("Guard")

        AddGFX("Guard", hitball.X, hitball.Y, 0, 30)

        BeginAction(state, frame, "Guard Stun")
        hurtTime = attackData.GuardStun
        knockback = attackData.GuardKnockback
        freeze = attackData.GuardHitFreeze
    end
    
    state.HurtTime = hurtTime
    attacker.StateFlags = bit.bor(attacker.StateFlags, STATE_ATTACK_CONTACT)
    if(not attacker.Facing) then
        knockback = -knockback
    end
    
    state.XVelocity = GetVelocity(knockback, frame.Sheet.StunFriction)
    state.XAccel = frame.Sheet.StunFriction

    state.Freeze = freeze
    attacker.Freeze = freeze

    ActiveFighterFrames[attacker.Player].GoToFront = true
end