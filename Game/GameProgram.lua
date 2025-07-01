
CurrentFrame = 0

GameProgram = BlankProgram()
DisplayHitballs = true

TonyState = tableMerge(FighterState(), {
    X = -ScreenWidth/4
})

TonyFrame = FighterFrame(TonyState, FighterSheets["Tony"])

KitState = tableMerge(FighterState(), {
    X = ScreenWidth/4,
    Facing = false,
})

KitFrame = FighterFrame(KitState, FighterSheets["Kit"])

function GameProgram:KeyPressed(key, scancode, isrepeat)
    if(key == 'b') then
        DisplayHitballs = not DisplayHitballs
    end
end


function GameProgram:Load()
    P1Controls = ControllerMapping(1)
    P2Controls = ControllerMapping(2)

    P1Controller = Controller(1)
    P2Controller = Controller(2)

    CurrentFrame = 0
end

function GameProgram:Draw()
    local lg = love.graphics
    lg.clear(0.3, 0.3, 0.3)

    lg.translate(ScreenWidth/2, ScreenHeight - 50)


    DrawFighter(TonyFrame)
    DrawFighter(KitFrame)

    if(DisplayHitballs) then
        DrawHitballs(TonyFrame.Hitballs)
        DrawHitballs(KitFrame.Hitballs)
    end
end

function GameProgram:Update()
    CurrentFrame = CurrentFrame + 1

    local tonyAttack = "Jab"
    local kitAttack = "Jab"
    
    UpdateController(P1Controller, P1Controls, CurrentFrame)
    UpdateController(P2Controller, P2Controls, CurrentFrame)

    -- update state with previous state and frame info
    TonyState = UpdateFighter(TonyState, TonyFrame)
    KitState = UpdateFighter(KitState, KitFrame)
    
    -- update frame info based on state and sheet
    TonyFrame = FighterFrame(TonyState, FighterSheets["Tony"])
    KitFrame = FighterFrame(KitState, FighterSheets["Kit"])

    local dx = 10

    if(ControllerInputPressed(P1Controller, BUTTON_A)) then
        --TonyState.Facing = not TonyState.Facing
        BeginAction(TonyState, tonyAttack)
    end

    if(ControllerInputPressed(P2Controller, BUTTON_A)) then
        --KitState.Facing = not KitState.Facing
        BeginAction(KitState, kitAttack)
    end

    if(ControllerInputDown(P1Controller, BUTTON_LEFT)) then
        TonyState.X = TonyState.X - dx
    end
    if(ControllerInputDown(P1Controller, BUTTON_RIGHT)) then
        TonyState.X = TonyState.X + dx
    end

    if(ControllerInputDown(P2Controller, BUTTON_LEFT)) then
        KitState.X = KitState.X - dx
    end
    if(ControllerInputDown(P2Controller, BUTTON_RIGHT)) then
        KitState.X = KitState.X + dx
    end
    
end