
-- Tony will use the tony texture, tony spriteset, and tony skeleton
-- He will use some of the animations from the tony skeleton for his attacks and actions (but others may be used by someone else)

local tony = BaseFighterSheet()

FighterSheets["Tony"] = tony

tony.SkeletonIndex = "Tony"
tony.TextureIndex = "Tony R2.png"
tony.SpriteSetIndex = "Tony"

tony.IdleAnimation = "Idle"

local idle = AddAction(tony, "Idle", "Idle", {
    NextAction = "Idle",
    StateFlags = STATE_IDLE,
})

local jab = AddAction(tony, "Jab", "Jab", {
    ReqStateFlags = STATE_CANATTACK,
})