
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
        end
    end

    local canPerform = bit.band(fstate.StateFlags, action.ReqStateFlags) == action.ReqStateFlags and action.ReqStateFlags ~= 0
    local canCancel = bit.band(fstate.StateFlags, action.CancelReqStateFlags) == action.CancelReqStateFlags  and action.CancelReqStateFlags ~= 0
        and GetStateAttackLevel(fstate.StateFlags) <= action.CancelMaxAttackLevel
    
    -- right now we don't worry about any sort of cancel cost
    return canPerform or canCancel
end

function ActivateTrigger(currentAction, trigger)
    
end