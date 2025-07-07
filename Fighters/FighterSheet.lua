-- state flags
STATE_CANMOVE = 2^0
STATE_CANATTACK = 2^1
STATE_IDLE = bit.bor(STATE_CANMOVE, STATE_CANATTACK)

STATE_PHASE = 3 * 2^2
STATE_PHASE_SHIFT = 2
STATE_MAX_PHASE = 3

PHASE_STARTUP = 1
PHASE_ACTIVE = 2
PHASE_RECOVERY = 3

function GetStateAttackPhase(state)
    -- just get the attack level bits and shift them
    return bit.rshift(bit.band(state, STATE_PHASE), STATE_PHASE_SHIFT)
end

function SetStateAttackPhase(state, phase)
    -- clear attack level bits
    state = bit.band(state, bit.bnot(STATE_PHASE))
    phase = Clamp(phase, 0, STATE_MAX_PHASE)
    return bit.bor(state, bit.lshift(phase, STATE_PHASE_SHIFT))
end

-- we can have up to 7 attack levels
STATE_ATTACK_LEVEL = 7 * 2^4
STATE_MAX_ATTACK_LEVEL = 7
STATE_ATTACK_LEVEL_SHIFT = 4

ATTACK_LIGHT = 1
ATTACK_MEDIUM = 2
ATTACK_HEAVY = 3
ATTACK_SPECIAL = 4
ATTACK_EX = 5
ATTACK_SUPER = 6

function GetStateAttackLevel(state)
    -- just get the attack level bits and shift them
    return bit.rshift(bit.band(state, STATE_ATTACK_LEVEL), STATE_ATTACK_LEVEL_SHIFT)
end

function SetStateAttackLevel(state, level)
    -- clear attack level bits
    state = bit.band(state, bit.bnot(STATE_ATTACK_LEVEL))
    level = Clamp(level, 0, STATE_MAX_ATTACK_LEVEL)
    return bit.bor(state, bit.lshift(level, STATE_ATTACK_LEVEL_SHIFT))
end

-- attack has contact
STATE_ATTACK_CONTACT = 2^7
-- if this is also true, we hit, but if not, it was guarded
STATE_ATTACK_HIT = 2^8

STATE_HURT = 2^9



-- stores all fighter sheets
FighterSheets = {}

function BaseFighterSheet()
    return {
        SkeletonIndex = nil,
        TextureIndex = nil,
        SpriteSetIndex = nil,

        WalkForwardSpeed = 10,
        WalkBackSpeed = 8,

        -- a string
        IdleAnimation = nil,

        -- each action will have a reference to an animation
        -- this includes attacks
        Actions = {},

        ForwardWalkSpeed = 10,
        BackWalkSpeed = 8,

        -- pushbox
        PBX = -80,
        PBW = 160,
        PBY = -500,
        PBH = 500,
    }
end

-- actions
-- actions are tied to a single animation, and have state and input information
function AddAction(fighterSheet, actionName, animName, inputPressed, inputHeld, props)
    local action = Action(fighterSheet, animName, props)
    action.InputPressed = inputPressed
    action.InputHeld = inputHeld
    action.Name = actionName
    fighterSheet.Actions[actionName] = action
    return action
end

function Action(fighterSheet, animName, props)
    props = props or {}
    local action = {
        Animation = SkeletonAnimNameMap[fighterSheet.SkeletonIndex][animName],
        NextAction = nil,

        StateFlags = 0,
        ReqStateFlags = 0,

        -- flags needed for a cancel
        CancelReqStateFlags = 0,
        CancelMaxAttackLevel = 0,

        Startup = nil,
        Active = nil,
        Recovery = nil,

        InputPressed = nil,
        InputHeld = nil,
    }
    
    for k, v in pairs(props) do
        action[k] = v
    end

    return action
end

function CanPerformAction(action, fstate, controller, buffer)
    local inputted = true
    -- controller isn't nil
    if(controller) then
        inputted = (action.InputPressed == 0 or InputBuffered(controller, action.InputPressed, buffer)) and 
                    (action.InputHeld == 0 or ControllerInputDown(controller, FlipInput(fstate.Facing, action.InputHeld), buffer))
    end
    if(not inputted) then
        return false
    end

    local canPerform = bit.band(fstate.StateFlags, action.ReqStateFlags) == action.ReqStateFlags and action.ReqStateFlags ~= 0
    local canCancel = bit.band(fstate.StateFlags, action.CancelReqStateFlags) == action.CancelReqStateFlags  and action.CancelReqStateFlags ~= 0
        and GetStateAttackLevel(fstate.StateFlags) <= action.CancelMaxAttackLevel
    
    -- right now we don't worry about any sort of cancel cost
    return canPerform or canCancel
end