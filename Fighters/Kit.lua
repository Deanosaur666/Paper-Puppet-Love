
local kit = BaseFighterSheet()

FighterSheets["Kit"] = kit

kit.SkeletonIndex = "Kitv2Skel"
kit.TextureIndex = "Kit v2.png"
kit.SpriteSetIndex = "Kitv2Sprite"

kit.IdleAnimation = "Idle"

local idle = AddAction(kit, "Idle", "Idle", {
    NextAction = "Idle",
    StateFlags = STATE_IDLE,
})

local jab = AddAction(kit, "Jab", "Punch", {
    ReqStateFlags = STATE_CANATTACK,
})