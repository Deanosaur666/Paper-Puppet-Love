
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

tony.Crouch = AddAction(tony, "Crouch", "Crouch", nil, nil,
{
    StateFlags = STATE_IDLE_CROUCHING,
    AnimLoop = true,
})

tony.CrouchDown = AddAction(tony, "Crouch Down", "Crouch Down", nil, nil,
{
    StateFlags = STATE_IDLE_CROUCHING,
    NextAction = "Crouch"
})

tony.CrouchUp = AddAction(tony, "Crouch Up", "Crouch Down", nil, nil,
{
    AnimReverse = true,
    StateFlags = STATE_IDLE,
    NextAction = "Idle"
})

tony.Hurt = AddAction(tony, "Hurt", "Hurt Head", nil, nil, {
    StateFlags = STATE_HURT,
})

tony.Guard = AddAction(tony, "Guard", "Guard", nil, nil, {
    StateFlags = STATE_GUARD,
})

tony.GuardStun = AddAction(tony, "Guard Stun", "Guard Stun", nil, nil, {
    StateFlags = STATE_GUARD,
})

tony.GuardDrop = AddAction(tony, "Guard Drop", "Guard Drop", nil, nil, {
    StateFlags = STATE_CANATTACK,
})

AddAttack(tony, "Jab", "Jab", BUTTON_A, 0, 1, ATTACK_LIGHT, {
    StateFlags = SetStateAttackLevel(0, ATTACK_LIGHT),
    ReqStateFlags = STATE_CANATTACK,
    Startup = 8,
    Active = 1,
    Recovery = 12,
})

AddAttack(tony, "Cross", "Cross", BUTTON_A, 0, 1.5, ATTACK_MEDIUM, {
    StateFlags = SetStateAttackLevel(0, ATTACK_MEDIUM),
    ReqStateFlags = 0,
    CancelReqStateFlags = SetStateAttackPhase(0, PHASE_RECOVERY),
    CancelMaxAttackLevel = ATTACK_LIGHT,
    Startup = 11,
    Active = 10,
    Recovery = 12,
})

AddAttack(tony, "Elbow", "Elbow", BUTTON_A, 0, 2, ATTACK_HEAVY, {
    StateFlags = SetStateAttackLevel(0, ATTACK_HEAVY),
    ReqStateFlags = 0,
    CancelReqStateFlags = SetStateAttackPhase(SetStateAttackLevel(0, ATTACK_MEDIUM), PHASE_RECOVERY),
    CancelMaxAttackLevel = ATTACK_MEDIUM,
    Startup = 16,
    Active = 14,
    Recovery = 12,
})

AddAttack(tony, "L Upper", "Left Uppercut", BUTTON_A, BUTTON_DOWN, 2, ATTACK_MEDIUM, {
    StateFlags = SetStateAttackLevel(0, ATTACK_MEDIUM),
    ReqStateFlags = STATE_CANATTACK,
    CancelReqStateFlags = SetStateAttackPhase(0, PHASE_RECOVERY),
    CancelMaxAttackLevel = ATTACK_LIGHT,
    Startup = 12,
    Active = 15,
    Recovery = 10,
})

AddAttack(tony, "Kick", "Kick", BUTTON_B, 0, 3, ATTACK_HEAVY, {
    StateFlags = SetStateAttackLevel(0, ATTACK_HEAVY),
    ReqStateFlags = STATE_CANATTACK,

    CancelReqStateFlags = SetStateAttackPhase(STATE_ATTACK_CONTACT, PHASE_RECOVERY),
    CancelMaxAttackLevel = ATTACK_MEDIUM,
})

AddAttack(tony, "Roundhouse", "Roundhouse", BUTTON_B, BUTTON_RIGHT, 3.5, ATTACK_SUPERHEAVY, {
    StateFlags = SetStateAttackLevel(0, ATTACK_HEAVY),
    ReqStateFlags = STATE_CANATTACK,

    CancelReqStateFlags = SetStateAttackPhase(STATE_ATTACK_CONTACT, PHASE_RECOVERY),
    CancelMaxAttackLevel = ATTACK_MEDIUM,
})

AddAttack(tony, "Stomp", "Stomp", BUTTON_B, BUTTON_DOWN, 2.5, ATTACK_HEAVY, {
    StateFlags = SetStateAttackLevel(0, ATTACK_HEAVY),
    ReqStateFlags = STATE_CANATTACK,

    CancelReqStateFlags = SetStateAttackPhase(STATE_ATTACK_CONTACT, PHASE_RECOVERY),
    CancelMaxAttackLevel = ATTACK_MEDIUM,
})

