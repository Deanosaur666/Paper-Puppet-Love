
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

    DrawHitballs(TonyFrame.Hitballs)
    DrawHitballs(KitFrame.Hitballs)
end

function GameProgram:Update()
    -- update state with previous state and frame info
    TonyState = UpdateFighter(TonyState, TonyFrame)
    KitState = UpdateFighter(KitState, KitFrame)
    
    -- update frame info based on state and sheet
    TonyFrame = FighterFrame(TonyState, FighterSheets["Tony"])
    KitFrame = FighterFrame(KitState, FighterSheets["Kit"])

    -- flip
    if(KeysPressed["f"]) then
        TonyState.Facing = not TonyState.Facing
        KitState.Facing = not KitState.Facing
    end

    local dx = 20

    if(love.keyboard.isDown("left")) then
        if(AltDown) then
            TonyFrame.Skeleton.X = TonyFrame.Skeleton.X - dx
            KitFrame.Skeleton.X = KitFrame.Skeleton.X - dx
        else
            TonyState.X = TonyState.X - dx*TonyFrame.XScale
            KitState.X = KitState.X - dx*KitFrame.XScale
        end
    end
    if(love.keyboard.isDown("right")) then
        if(AltDown) then
            TonyFrame.Skeleton.X = TonyFrame.Skeleton.X + dx
            KitFrame.Skeleton.X = KitFrame.Skeleton.X + dx
        else
            TonyState.X = TonyState.X + dx*TonyFrame.XScale
            KitState.X = KitState.X + dx*KitFrame.XScale
        end
    end
end