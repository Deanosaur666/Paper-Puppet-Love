
local kit = BaseFighterSheet()

FighterSheets["Kit"] = kit

kit.SkeletonIndex = "Kitv2Skel"
kit.TextureIndex = "Kit v2.png"
kit.SpriteSetIndex = "Kitv2Sprite"

kit.IdleAnimation = "Idle"

local idle = AddAction(kit, "Idle", "Idle", nil, nil, {
    NextAction = "Idle",
    StateFlags = STATE_IDLE,
    AnimLoop = true,
})

kit.FWalk = AddAction(kit, "FWalk", "Walk", nil, nil,
{
    StateFlags = STATE_IDLE,
    AnimLoop = true,
})

kit.BWalk = AddAction(kit, "BWalk", "Walk", nil, nil,
{
    StateFlags = STATE_IDLE,
    AnimReverse = true,
    AnimLoop = true,
    AnimSpeed = 0.8,
})



kit.Hurt = AddAction(kit, "Hurt", "Hurt Head", nil, nil, {
    StateFlags = STATE_HURT,
})

local jab = AddAttack(kit, "Jab", "Punch", BUTTON_A, 0, 1, {
    StateFlags = SetStateAttackLevel(0, 1),
    ReqStateFlags = STATE_CANATTACK,
    Startup = 8,
    Active = 3,
    Recovery = 10, -- 3 fake recovery frames?

    AnimStart = 8,
    AnimSpeed = 0.5,
})

AddAttack(kit, "Cross", "Cross", BUTTON_A, 0, 1.5, {
    StateFlags = SetStateAttackLevel(0, ATTACK_MEDIUM),
    CancelReqStateFlags = SetStateAttackPhase(0, PHASE_RECOVERY),
    CancelMaxAttackLevel = ATTACK_LIGHT,
    Startup = 10,
    Active = 7,
    Recovery = 14,
})

AddAttack(kit, "Kick", "High Kick", BUTTON_B, 0, 3, {
    StateFlags = SetStateAttackLevel(0, 2),
    ReqStateFlags = STATE_CANATTACK,
    CancelReqStateFlags = SetStateAttackPhase(0, PHASE_RECOVERY),
    CancelMaxAttackLevel = ATTACK_LIGHT,
    Startup = 12,
    Active = 7,
    Recovery = 14, -- 4 fake recovery frames
})

AddAttack(kit, "Crouch Punch", "Crouch Punch", BUTTON_A, BUTTON_DOWN, 1, {
    StateFlags = SetStateAttackLevel(0, ATTACK_MEDIUM),
    ReqStateFlags = STATE_CANATTACK,
    CancelReqStateFlags = SetStateAttackPhase(0, PHASE_RECOVERY),
    CancelMaxAttackLevel = ATTACK_LIGHT,
    Startup = 8,
    Active = 1,
    Recovery = 8,
})