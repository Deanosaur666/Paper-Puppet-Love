
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
    AnimLoop = true,
})

tony.FWalk = AddAction(tony, "FWalk", "Walk", nil, nil,
{
    StateFlags = STATE_IDLE,
    AnimLoop = true,
})

tony.BWalk = AddAction(tony, "BWalk", "Walk", nil, nil,
{
    StateFlags = STATE_IDLE,
    AnimReverse = true,
    AnimLoop = true,
    AnimSpeed = 0.8,
})

tony.Hurt = AddAction(tony, "Hurt", "Hurt Head", nil, nil, {
    StateFlags = STATE_HURT,
})

AddAction(tony, "Jab", "Jab", BUTTON_A, 0, {
    StateFlags = SetStateAttackLevel(0, ATTACK_LIGHT),
    ReqStateFlags = STATE_CANATTACK,
    Startup = 8,
    Active = 1,
    Recovery = 12,
})

AddAction(tony, "Cross", "Cross", BUTTON_A, 0, {
    StateFlags = SetStateAttackLevel(0, ATTACK_MEDIUM),
    CancelReqStateFlags = SetStateAttackPhase(0, PHASE_RECOVERY),
    CancelMaxAttackLevel = ATTACK_LIGHT,
    Startup = 11,
    Active = 10,
    Recovery = 12,
})

AddAction(tony, "Elbow", "Elbow", BUTTON_A, 0, {
    StateFlags = SetStateAttackLevel(0, ATTACK_HEAVY),
    CancelReqStateFlags = SetStateAttackPhase(SetStateAttackLevel(0, ATTACK_MEDIUM), PHASE_RECOVERY),
    CancelMaxAttackLevel = ATTACK_MEDIUM,
    Startup = 16,
    Active = 14,
    Recovery = 12,
})

AddAction(tony, "L Upper", "Left Uppercut", BUTTON_A, BUTTON_DOWN, {
    StateFlags = SetStateAttackLevel(0, ATTACK_MEDIUM),
    ReqStateFlags = STATE_CANATTACK,
    CancelReqStateFlags = SetStateAttackPhase(0, PHASE_RECOVERY),
    CancelMaxAttackLevel = ATTACK_LIGHT,
    Startup = 12,
    Active = 15,
    Recovery = 10,
})

AddAction(tony, "Kick", "Kick", BUTTON_B, 0, {
    StateFlags = SetStateAttackLevel(0, ATTACK_HEAVY),
    ReqStateFlags = STATE_CANATTACK,
})

AddAction(tony, "Roundhouse", "Roundhouse", BUTTON_B, BUTTON_RIGHT, {
    StateFlags = SetStateAttackLevel(0, ATTACK_HEAVY),
    ReqStateFlags = STATE_CANATTACK,
})

AddAction(tony, "Stomp", "Stomp", BUTTON_B, BUTTON_DOWN, {
    StateFlags = SetStateAttackLevel(0, ATTACK_HEAVY),
    ReqStateFlags = STATE_CANATTACK,
})