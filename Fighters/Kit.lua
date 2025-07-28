
local kit = BaseFighterSheet()

local kitTable = LoadCSVTable("Sheets/KitAttacks.csv")

--kitTable[1] = {Hello = 1, Goodbye = 2, GoodEvening = 3,}


for _,line in ipairs(kitTable) do
    --print("Line: " .. tostring(line) )
    for index, value in pairs(line) do
        print(index .. ":" .. value)
    end
end


FighterSheets["Kit"] = kit

kit.SkeletonIndex = "Kitv2Skel"
kit.TextureIndex = "Kit v2.png"
kit.SpriteSetIndex = "Kitv2Sprite"


ParseAttackTable(kitTable, kit)

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

kit.Crouch = AddAction(kit, "Crouch", "Crouch", nil, nil,
{
    StateFlags = STATE_IDLE_CROUCHING,
    AnimLoop = true,
})

kit.CrouchDown = AddAction(kit, "Crouch Down", "Crouch Down", nil, nil,
{
    StateFlags = STATE_IDLE_CROUCHING,
    NextAction = "Crouch"
})

kit.CrouchUp = AddAction(kit, "Crouch Up", "Crouch Down", nil, nil,
{
    AnimReverse = true,
    StateFlags = STATE_IDLE,
    NextAction = "Idle"
})


kit.Hurt = AddAction(kit, "Hurt", "Hurt Head", nil, nil, {
    StateFlags = STATE_HURT,
})

kit.Guard = AddAction(kit, "Guard", "Guard", nil, nil, {
    StateFlags = STATE_GUARD,
})

kit.GuardStun = AddAction(kit, "Guard Stun", "Guard Stun", nil, nil, {
    StateFlags = STATE_GUARD,
})

kit.GuardDrop = AddAction(kit, "Guard Drop", "Guard Drop", nil, nil, {
    StateFlags = STATE_CANATTACK,
})

--[[
local jab = AddAttack(kit, "Jab", "Punch", BUTTON_A, 0, 1, ATTACK_LIGHT, {
    StateFlags = SetStateAttackLevel(0, 1),
    ReqStateFlags = STATE_CANATTACK,
    Startup = 8,
    Active = 3,
    Recovery = 10, -- 3 fake recovery frames?
})

AddAttack(kit, "Cross", "Cross", BUTTON_A, 0, 1.5, ATTACK_MEDIUM, {
    StateFlags = SetStateAttackLevel(0, ATTACK_MEDIUM),
    ReqStateFlags = 0,
    CancelReqStateFlags = SetStateAttackPhase(0, PHASE_RECOVERY),
    CancelMaxAttackLevel = ATTACK_LIGHT,
    Startup = 10,
    Active = 7,
    Recovery = 14,
})

AddAttack(kit, "High Kick", "High Kick", BUTTON_B, BUTTON_LEFT, 3, ATTACK_HEAVY, {
    StateFlags = SetStateAttackLevel(0, 2),
    ReqStateFlags = STATE_CANATTACK,
    CancelReqStateFlags = SetStateAttackPhase(0, PHASE_RECOVERY),
    CancelMaxAttackLevel = ATTACK_LIGHT,
    Startup = 10,
    Active = 6,
    Recovery = 14, -- 4 fake recovery frames
    AnimStart = 1,
})

AddAttack(kit, "Far Kick", "Far Spin Kick", BUTTON_B, 0, 3, ATTACK_SUPERHEAVY, {
    StateFlags = SetStateAttackLevel(0, 2),
    ReqStateFlags = STATE_CANATTACK,
    CancelReqStateFlags = SetStateAttackPhase(0, PHASE_RECOVERY),
    CancelMaxAttackLevel = ATTACK_LIGHT,
    Startup = 12,
    Active = 3,
    Recovery = 16, 
    AnimStart = 1,
})

AddAttack(kit, "Knee", "Knee", BUTTON_B, BUTTON_RIGHT, 3, ATTACK_HEAVY, {
    StateFlags = SetStateAttackLevel(0, 2),
    ReqStateFlags = STATE_CANATTACK,
    CancelReqStateFlags = SetStateAttackPhase(0, PHASE_RECOVERY),
    CancelMaxAttackLevel = ATTACK_LIGHT,
    Startup = 13,
    Active = 6,
    Recovery = 8, -- 4 fake recovery frames
    AnimStart = 1,
})

AddAttack(kit, "Crouch Punch", "Crouch Punch", BUTTON_A, BUTTON_DOWN,1, ATTACK_LIGHT, {
    ReqStateFlags = STATE_CANATTACK,
    CancelReqStateFlags = SetStateAttackPhase(0, PHASE_RECOVERY),
    CancelMaxAttackLevel = ATTACK_LIGHT,
    Startup = 8,
    Active = 1,
    Recovery = 8,
})
--]]