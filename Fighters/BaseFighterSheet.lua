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