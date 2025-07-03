
-- Tony will use the tony texture, tony spriteset, and tony skeleton
-- He will use some of the animations from the tony skeleton for his attacks and actions (but others may be used by someone else)

local tony = BaseFighterSheet()

FighterSheets["Tony"] = tony

tony.SkeletonIndex = "Tony"
tony.TextureIndex = "Tony R2.png"
tony.SpriteSetIndex = "Tony"

tony.IdleAnimation = "Idle"

local idle = AddAction(tony, "Idle", "Idle", nil, nil, {
    NextAction = "Idle",
    StateFlags = STATE_IDLE,
})

local jab = AddAction(tony, "Jab", "Jab", BUTTON_A, 0, {
    StateFlags = SetStateAttackLevel(0, 1),
    ReqStateFlags = STATE_CANATTACK,
    Startup = 8,
    Active = 1,
    Recovery = 12,
})

print("JAB INPUT PRESSED: " .. jab.InputPressed)

AddAction(tony, "Kick", "Kick", BUTTON_B, 0, {
    StateFlags = SetStateAttackLevel(0, 2),
    ReqStateFlags = STATE_CANATTACK,
    CancelReqStateFlags = SetStateAttackPhase(0, PHASE_RECOVERY),
    CancelMaxAttackLevel = ATTACK_LIGHT,
    InputPressed = BUTTON_B,
})