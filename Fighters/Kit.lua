
local kit = BaseFighterSheet()

FighterSheets["Kit"] = kit

kit.SkeletonIndex = "Kitv2Skel"
kit.TextureIndex = "Kit v2.png"
kit.SpriteSetIndex = "Kitv2Sprite"

kit.IdleAnimation = "Idle"

local idle = AddAction(kit, "Idle", "Idle", nil, nil, {
    NextAction = "Idle",
    StateFlags = STATE_IDLE,

    InputPressed = nil,
    InputHeld = nil,
})

local jab = AddAction(kit, "Jab", "Punch", BUTTON_A, 0, {
    StateFlags = SetStateAttackLevel(0, 1),
    ReqStateFlags = STATE_CANATTACK,
    InputPressed = BUTTON_A,
})