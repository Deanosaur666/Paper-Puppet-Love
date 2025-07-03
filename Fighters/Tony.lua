
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

AddAction(tony, "Jab", "Jab", {
    StateFlags = SetStateAttackLevel(0, 1),
    ReqStateFlags = STATE_CANATTACK,
    InputPressed = BUTTON_A,
    Startup = 8,
    Active = 1,
    Recovery = 12,
})

AddAction(tony, "Kick", "Kick", {
    StateFlags = SetStateAttackLevel(0, 2),
    ReqStateFlags = STATE_CANATTACK,
    CancelReqStateFlags = SetStateAttackPhase(0, PHASE_RECOVERY),
    CancelMaxAttackLevel = ATTACK_LIGHT,
    InputPressed = BUTTON_B,
})