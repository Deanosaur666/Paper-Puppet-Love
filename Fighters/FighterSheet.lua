-- basic fighter sheet that other fighters effectively inherit from

-- a fighter has:
-- a skeleton
-- a texture
-- a spriteset

-- base values for movement speed, health, et cetera
-- actions (animations tied to states or attacks)

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

function AddAction(fighterSheet, actionName, action)
    fighterSheet.Actions[actionName] = action
    return action
end

function Action(animName, props)
    local action = {
        AnimName = animName,
        NextAction = nil,
        Startup = 0,
        Active = 0,
        Recovery = 0,
    }
    for k, v in pairs(props) do
        action[k] = v
    end

    return action
end