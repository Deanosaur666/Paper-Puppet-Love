
GameProgram = BlankProgram()

TonySkel = Skeletons["Tony"]
TonyTex = SpriteSheets["Tony W.png"]
TonySpriteSet = SpriteSets["Tony"]

KitSkel = Skeletons["Kitv2Skel"]
KitTex = SpriteSheets["Kit v2.png"]
--KitTex = SpriteSheets["Agent J.png"]
KitSpriteSet = SpriteSets["Kitv2Sprite"]

function GameProgram:Load()
    
end

function GameProgram:Draw()
    local lg = love.graphics
    lg.clear(0.3, 0.3, 0.3)

    local tonyPose = SkeletonAnimNameMap["Tony"]["Idle"].Frames[1]
    local kitPose = SkeletonAnimNameMap["Kitv2Skel"]["Idle"].Frames[1]

    DrawPose(tonyPose, TonySkel, TonySpriteSet, TonyTex, 200, ScreenHeight - 20, 0, 1, 1)
    DrawPose(kitPose, KitSkel, KitSpriteSet, KitTex, ScreenWidth - 200, ScreenHeight - 20, 0, -1, 1)
end

function GameProgram:Update()

end