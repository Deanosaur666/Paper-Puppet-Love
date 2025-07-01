
GameProgram = BlankProgram()

TonyState = tableMerge(FighterState(), {
    X = -ScreenWidth/4
})

TonyFrame = FighterFrame(TonyState, FighterSheets["Tony"])

KitState = tableMerge(FighterState(), {
    X = ScreenWidth/4,
    Facing = false,
})

KitFrame = FighterFrame(KitState, FighterSheets["Kit"])

function GameProgram:Load()
    
end

function GameProgram:Draw()
    local lg = love.graphics
    lg.clear(0.3, 0.3, 0.3)

    lg.translate(ScreenWidth/2, ScreenHeight - 50)


    DrawFighter(TonyFrame)
    DrawFighter(KitFrame)
end

function GameProgram:Update()
    -- update state with previous state and frame info
    TonyState = UpdateFighter(TonyState, TonyFrame)
    KitState = UpdateFighter(KitState, KitFrame)
    
    -- update frame info based on state and sheet
    TonyFrame = FighterFrame(TonyState, FighterSheets["Tony"])
    KitFrame = FighterFrame(KitState, FighterSheets["Kit"])
end