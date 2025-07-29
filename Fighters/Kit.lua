
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
