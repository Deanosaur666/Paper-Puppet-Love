
CurrentFrame = 0

GameProgram = BlankProgram()
DisplayHitballs = true

StartOffset = ScreenWidth/4

ActiveFighterSheets = {}
ActiveFighterStates = {}
ActiveFighterFrames = {}

Controllers = {}
ControlMappings = {}

function AddActiveFighter(player, sheetName)
    ActiveFighterSheets[player] = FighterSheets[sheetName]
    local x = -StartOffset
    local facing = true
    if(player == 2) then
        x = StartOffset
        facing = false
    end
    ActiveFighterStates[player] = FighterState({
        X = x,
        Facing = facing
    })
    ActiveFighterFrames[player] = FighterFrame(ActiveFighterStates[player], ActiveFighterSheets[player])

    BeginAction(ActiveFighterStates[player], ActiveFighterFrames[player], "Idle")
end

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


    PlayerControls = { P1Controls, P2Controls }
    PlayerControllers = { P1Controller, P2Controller }

    StartGame()
end

function GameProgram:Draw()
    local lg = love.graphics
    lg.clear(0.3, 0.3, 0.3)

    lg.translate(ScreenWidth/2, ScreenHeight - 50)

    for i, frame in pairs(ActiveFighterFrames) do
        DrawFighter(frame)
        if(DisplayHitballs) then
            DrawHitballs(frame.Hitballs)
            local sheet = ActiveFighterSheets[i]
            local state = ActiveFighterStates[i]
            local rx, ry, rw, rh = sheet.PBX, sheet.PBY, sheet.PBW, sheet.PBH
            if(not state.Facing) then
                rx, ry, rw, rh = FlipRectangle(rx, ry, rw, rh)
            end

            rx = rx + state.X
            ry = ry + state.Y

            lg.push("all")

            lg.setColor(0, 1, 1)
            lg.rectangle("line", rx, ry, rw, rh)

            lg.pop()
        end
    end
end

function GameProgram:Update()
    CurrentFrame = CurrentFrame + 1

    -- update controllers
    for i, controller in pairs(PlayerControllers) do
        UpdateController(controller, PlayerControls[i], CurrentFrame)
    end

    -- update state and frame with previous state and frame info
    for i, state in pairs(ActiveFighterStates) do
        ActiveFighterStates[i], ActiveFighterFrames[i] = UpdateFighter(state, ActiveFighterFrames[i], PlayerControllers[i])
    end
    
end

function StartGame()
    CurrentFrame = 0

    AddActiveFighter(1, "Tony")
    AddActiveFighter(2, "Kit")
end

function UpdateGame()

end