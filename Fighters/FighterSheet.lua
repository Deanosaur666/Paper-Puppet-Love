-- state flags
STATE_CANMOVE = 2^0
STATE_CANATTACK = 2^1
STATE_IDLE = bit.bor(STATE_CANMOVE, STATE_CANATTACK)

-- stores all fighter sheets
FighterSheets = {}

function BaseFighterSheet()
    return {
        SkeletonIndex = nil,
        TextureIndex = nil,
        SpriteSetIndex = nil,

        WalkForwardSpeed = 10,
        WalkBackSpeed = -8,

        -- a string
        IdleAnimation = nil,

        -- each action will have a reference to an animation
        -- this includes attacks
        Actions = {}
    }
end

-- actions
-- actions are tied to a single animation, and have state and input information
function AddAction(fighterSheet, actionName, animName, props)
    fighterSheet.Actions[actionName] = Action(fighterSheet, animName, props)
    return action
end

function Action(fighterSheet, animName, props)
    props = props or {}
    local action = {
        Animation = SkeletonAnimNameMap[fighterSheet.SkeletonIndex][animName],
        NextAction = nil,

        StateFlags = 0,
        ReqStateFlags = 0,

        Startup = 0,
        Active = 0,
        Recovery = 0,
    }
    for k, v in pairs(props) do
        action[k] = v
    end

    return action
end