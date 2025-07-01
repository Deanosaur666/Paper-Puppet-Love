
GameProgram = BlankProgram()

TonyState = tableMerge(FighterState(), {
    X = -ScreenWidth/4
})

KitState = tableMerge(FighterState(), {
    X = ScreenWidth/4,
    Facing = false,
})

function GameProgram:Load()
    
end

function GameProgram:Draw()
    local lg = love.graphics
    lg.clear(0.3, 0.3, 0.3)

    lg.translate(ScreenWidth/2, ScreenHeight - 50)

    DrawFighter(TonyState, FighterSheets["Tony"])
    DrawFighter(KitState, FighterSheets["Kit"])
end

function GameProgram:Update()

end