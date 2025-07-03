
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

Zoom = 1
MinZoom = 0.4
MaxZoom = 1.1
ScrollX = 0
-- ScrollY might not really be used...
ScrollY = 0

WallMargin = 50

function GameProgram:Draw()
    local lg = love.graphics
    lg.clear(0.3, 0.3, 0.3)

    lg.translate(ScreenWidth/2, ScreenHeight*0.6)
    lg.scale(Zoom)
    lg.translate(-ScrollX, -ScrollY)
    lg.translate(0, ScreenHeight*0.4 - 80)

    -- vertical line at center of stage
    lg.line(0, -ScreenHeight/Zoom, 0, 0)
    -- horizontal line
    lg.line(ScrollX - (ScreenWidth/2)/Zoom, 0, ScrollX + (ScreenWidth/2)/Zoom, 0)

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

    local minX = math.huge
    local maxX = -math.huge
    local minY = math.huge
    local maxY = -math.huge

    local maxW = -math.huge

    -- update controllers
    for i, controller in pairs(PlayerControllers) do
        UpdateController(controller, PlayerControls[i], CurrentFrame)
    end

    -- update state and frame with previous state and frame info
    for i, state in pairs(ActiveFighterStates) do
        ActiveFighterStates[i], ActiveFighterFrames[i] = UpdateFighter(state, ActiveFighterFrames[i], PlayerControllers[i])

        local sheet = ActiveFighterSheets[i]
        local state = ActiveFighterStates[i]
        local rx, ry, rw, rh = sheet.PBX, sheet.PBY, sheet.PBW, sheet.PBH
        if(not state.Facing) then
            rx, ry, rw, rh = FlipRectangle(rx, ry, rw, rh)
        end

        local crx = rx + state.X
        local cry = ry + state.Y

        local leftwall = ScrollX - (ScreenWidth/2)/Zoom + WallMargin
        local rightwall = ScrollX + (ScreenWidth/2)/Zoom - WallMargin

        if(crx < leftwall) then
            state.X = leftwall - rx
            crx = rx + state.X
        end
        if(crx + rw > rightwall) then
            state.X = rightwall - rx - rw
            crx = rx + state.X
        end

        minX = math.min(minX, crx)
        maxX = math.max(maxX, crx + rw)
        minY = math.min(minY, cry)
        maxY = math.max(maxY, cry + rh)

        maxW = math.max(maxW, rw)
    end

    -- adjust zoom and scroll based on min and max x and y
    
    local middleX = (minX + maxX)/2
    local xRange = maxX - minX
    ScrollX = middleX
    local newZoom = ScreenWidth/(xRange + maxW*2)
    Zoom = Clamp(newZoom, MinZoom, MaxZoom)

end

function StartGame()
    CurrentFrame = 0

    AddActiveFighter(1, "Tony")
    AddActiveFighter(2, "Kit")
end

function UpdateGame()

end