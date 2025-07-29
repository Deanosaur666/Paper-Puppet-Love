
function BeginAction(fstate, fframe, actionName)
    local action = fframe.Sheet.Actions[actionName]
    fstate.CurrentAction = actionName
    fstate.CurrentFrame = 0
    fstate.StateFlags = action.StateFlags
    fstate.HurtTime = nil

    if(bit.band(action.StateFlags, STATE_ATTACK_LEVEL) ~= 0) then
        fframe.GoToFront = true
    end
end

function ContinueAction(fstate, fframe, actionName)
    if(fstate.CurrentAction ~= actionName) then
        BeginAction(fstate, fframe, actionName)
    end
end

function ActionInputted(action, fstate, controller, buffer)
     local inputted = true

     -- controller isn't nil
    if(controller) then
        inputted = (action.InputPressed == 0 or InputBuffered(controller, action.InputPressed, buffer)) and 
                    (action.InputHeld == 0 or ControllerInputDown(controller, FlipInput(fstate.Facing, action.InputHeld), buffer))
    end
    if(not inputted) then
        return false
    end

    return true
end

function CanPerformAction(action, fstate)
    if(action.TriggerFrom ~= "" and action.TriggerFrom ~= nil) then
        if(fstate.CurrentAction ~= action.TriggerFrom) then
            return false
        elseif(action.Trigger == "" or action.Trigger == "input") then
            return true
        end
    end

    local cancelMaxAtkLevel = action.AttackLevel - 1
    local cancelReqFlags = bit.bor(PHASE_RECOVERY)
    local reqFlags = STATE_CANATTACK

    local canCancel = bit.band(fstate.StateFlags, cancelReqFlags) == cancelReqFlags -- and action.CancelReqStateFlags ~= 0
        and GetStateAttackLevel(fstate.StateFlags) <= cancelMaxAtkLevel

    local canPerform = bit.band(fstate.StateFlags, reqFlags) == reqFlags --and action.ReqStateFlags ~= 0

    --local canPerform = bit.band(fstate.StateFlags, action.ReqStateFlags) == action.ReqStateFlags and action.ReqStateFlags ~= 0
    --local canCancel = bit.band(fstate.StateFlags, action.CancelReqStateFlags) == action.CancelReqStateFlags  and action.CancelReqStateFlags ~= 0
    --    and GetStateAttackLevel(fstate.StateFlags) <= action.CancelMaxAttackLevel
    
    -- right now we don't worry about any sort of cancel cost
    return canPerform or canCancel
end

-- just go through every action, and see if the trigger matches
function ActivateTrigger(fstate, fframe, trigger)
    --local sheet = fframe.Sheet
    local currentAction = fstate.CurrentAction

    local actions = fframe.Sheet.Actions

    for name, action in pairs(actions) do
        
        if(action.TriggerFrom == currentAction and action.Trigger == trigger) then
            if(fstate.CurrentFrame >= action.TriggerStart and (fstate.CurrentFrame <= action.TriggerEnd or action.TriggerEnd == -1)) then
                BeginAction(fstate, fframe, name)
                return true
            end
            
        end
    end

    return false
end

function CheckActions(fstate, fframe, controller)
    local bufferLength = 10
    
    bufferLength = math.min(bufferLength, GameState.CurrentFrame - controller.LastBuffered)

    local actions = fframe.Sheet.Actions
    local perform = nil
    local biggestInput = 0
    for name, action in pairs(actions) do
        local input = bit.bor(action.InputPressed or 0, action.InputHeld or 0)

        if(ActionInputted(action, fstate, controller,bufferLength) and CanPerformAction(action, fstate) and input >= biggestInput) then
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