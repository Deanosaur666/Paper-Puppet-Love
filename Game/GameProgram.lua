
GameProgram = BlankProgram()

TonySkel = Skeletons["Tony"]
TonyTex = SpriteSheets["Tony W.png"]
TonySpriteSet = SpriteSets["Tony"]

KitSkel = Skeletons["Kitv2Skel"]
KitTex = SpriteSheets["Kit v2.png"]
KitSpriteSet = SpriteSets["Kitv2Sprite"]

function GameProgram:Load()
    
end

function GameProgram:Draw()
    local lg = love.graphics

    local tonyPose = SkeletonAnimNameMap["Tony"]["Idle"].Frames[1]
    local kitPose = Pose(KitSkel)

    DrawPose(tonyPose, TonySkel, TonySpriteSet, TonyTex, 200, ScreenHeight - 20, 0, 1, 1)
    DrawPose(kitPose, KitSkel, KitSpriteSet, KitTex, ScreenWidth - 200, ScreenHeight - 20, 0, 1, 1)
end

function GameProgram:Update()

end