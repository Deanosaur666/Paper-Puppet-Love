
CurrentFrame = 0

GameProgram = BlankProgram()
DisplayHitballs = true

StartOffset = ScreenWidth/4

ActiveFighterSheets = {}
ActiveFighterStates = {}
ActiveFighterFrames = {}

ActivePushBoxes = {}

-- a constant??
--PUSHSPEED = 7

ActiveFighterColors = {

} -- the colors of each fighter
ActiveFighterEnemies = {
    [1] = 2, [2] = 1
}

Hurtballs = {
    [1] = nil,
    [2] = nil
}
Hitballs = {
    [1] = nil,
    [2] = nil,
}

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
    ActiveFighterFrames[player] = FighterFrame(ActiveFighterStates[player], ActiveFighterSheets[player], player)

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

Leftwall = nil
Rightwall = nil

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

function GetFighterPushBox(state, sheet)
    
    local rx, ry, rw, rh = sheet.PBX, sheet.PBY, sheet.PBW, sheet.PBH
    if(not state.Facing) then
        rx, ry, rw, rh = FlipRectangle(rx, ry, rw, rh)
    end
    local crx = rx + state.X
    local cry = ry + state.Y

    return {X = rx, Y = ry, CX = crx, CY = cry, W = rw, H = rh}
end

function GameProgram:Update()
    CurrentFrame = CurrentFrame + 1

    Leftwall = ScrollX - (ScreenWidth/2)/Zoom + WallMargin
    Rightwall = ScrollX + (ScreenWidth/2)/Zoom - WallMargin

    local minX = math.huge
    local maxX = -math.huge
    local minY = math.huge
    local maxY = -math.huge

    local maxW = -math.huge

    -- update controllers
    for i, controller in pairs(PlayerControllers) do
        UpdateController(controller, PlayerControls[i], CurrentFrame)
    end

    -- update frames
    for i, state in pairs(ActiveFighterStates) do
        ActiveFighterFrames[i] = FighterFrame(ActiveFighterStates[i], ActiveFighterSheets[i], i)

        local frame = ActiveFighterFrames[i]

        Hurtballs[i] = {}
        Hitballs[i] = {}
        -- hitballs
        for b, ball in ipairs(frame.Hitballs) do
            if(bit.band(ball.Flags, HITBALL_HITTABLE) ~= 0) then
                table.insert(Hurtballs[i], ball)
            end
            if(bit.band(ball.Flags, HITBALL_ACTIVE) ~= 0) then
                table.insert(Hitballs[i], ball)
            end
        end
    end

    -- check for hitball collision
    for i, state in ipairs(ActiveFighterStates) do
        local enemy = ActiveFighterEnemies[i]
        local hurtBy = nil

        for _, ball in ipairs(Hitballs[enemy]) do
            local attacker = ActiveFighterStates[ball.Player]
            -- check if they have hit yet
            if(bit.band(attacker.StateFlags, STATE_ATTACK_CONTACT) == 0) then
                local hit = HitballAtPoint(Hurtballs[i], ball.X, ball.Y, ball.Radius)
                if(hit) then
                    hurtBy = ball
                end
            end
        end

        if(hurtBy) then
            BeginAction(state, ActiveFighterFrames[i], "Hurt")
            local attackData = hurtBy.AttackData -- or AttackData_Power(1)
            state.HurtTime = attackData.Stun
            local knockback = attackData.Knockback
            local attacker = ActiveFighterStates[hurtBy.Player]
            attacker.StateFlags = bit.bor(attacker.StateFlags, STATE_ATTACK_CONTACT)
            if(not attacker.Facing) then
                knockback = -knockback
            end
            state.HurtKnockback = knockback
        end
    end

    -- update state with previous state and frame info
    for i, state in pairs(ActiveFighterStates) do
        ActiveFighterStates[i] = UpdateFighter(state, ActiveFighterFrames[i], PlayerControllers[i], i)

        -- check position for scrolling and wall clamping
        local sheet = ActiveFighterSheets[i]
        local state = ActiveFighterStates[i]

        ActivePushBoxes[i] = GetFighterPushBox(state, sheet)
        local pbox = ActivePushBoxes[i]

        if(pbox.CX < Leftwall) then
            state.X = Leftwall - pbox.X
            pbox.CX = pbox.X + state.X
        end
        if(pbox.CX + pbox.W > Rightwall) then
            state.X = Rightwall - pbox.X - pbox.W
            pbox.CX = pbox.X + state.X
        end

        minX = math.min(minX, pbox.CX)
        maxX = math.max(maxX, pbox.CX + pbox.W)
        minY = math.min(minY, pbox.CY)
        maxY = math.max(maxY, pbox.CY + pbox.H)

        maxW = math.max(maxW, pbox.W)
    end
    --local push = PUSHSPEED
    -- check push boxes
    for i, state in pairs(ActiveFighterStates) do
        --UpdatePushBox(state)
        local p1box = ActivePushBoxes[i]
        for j, box in pairs(ActivePushBoxes) do
            if(j ~= i) then
                local p2box = ActivePushBoxes[j]
                local ix, iy, iw, ih = RectangleIntersection(p1box.CX, p1box.CY, p1box.W, p1box.H,
                                    p2box.CX, p2box.CY, p2box.W, p2box.H)

                if(iw ~= nil) then
                    local s = Sign((p1box.CX + p1box.W/2) - (p2box.CX + p2box.W/2) )
                    --local s = iw
                    state.X = state.X + (s*math.max(5, iw))

                    state.Pushed = true
                end
            end
            
        end
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