
-- directions
BUTTON_NEUTRAL = 0
BUTTON_RIGHT = 1
BUTTON_LEFT = 2
BUTTON_UP = 4
BUTTON_DOWN = 8

BUTTON_DOWNRIGHT = bit.bor(BUTTON_DOWN, BUTTON_RIGHT)
BUTTON_DOWNLEFT = bit.bor(BUTTON_DOWN, BUTTON_LEFT)
BUTTON_UPRIGHT = bit.bor(BUTTON_UP, BUTTON_RIGHT)
BUTTON_UPLEFT = bit.bor(BUTTON_UP, BUTTON_LEFT)

BUTTON_DIRECTIONS = bit.bor(BUTTON_DOWN, BUTTON_UP, BUTTON_LEFT, BUTTON_RIGHT)

-- buttons
BUTTON_A = 16
BUTTON_B = 32
BUTTON_S = 64
BUTTON_EX = 128
BUTTON_DASH = 256
BUTTON_GUARD = 512

-- menu buttons
BUTTON_START = 1024
BUTTON_CONFIRM = 2048
BUTTON_CANCEL = 2048*2

BUTTON_MENUBUTTONS = bit.bor(BUTTON_START, BUTTON_CONFIRM, BUTTON_CANCEL)

BUTTON_FIRST = BUTTON_RIGHT
BUTTON_LAST = BUTTON_CANCEL

MAX_INPUTS = 100

function FlipInput(facing, input)
    -- no change if facing right
    if(facing) then
        return input
    end

    if(bit.band(input, BUTTON_RIGHT) ~= 0) then
        input = bit.bor(bit.band(input, bit.bnot(BUTTON_RIGHT)), BUTTON_LEFT)
    elseif(bit.band(input, BUTTON_LEFT) ~= 0) then
        input = bit.bor(bit.band(input, bit.bnot(BUTTON_LEFT)), BUTTON_RIGHT)
    end

    return input
end

function Controller(player)
    return {
        Player = player,
        PressedThisFrame = 0,
        PressedLastFrame = 0,

        -- record of previous inputs
        InputFrame = {},
        InputTime = {},

        -- input buffering
        LastBuffered = 0,
        BufferTime = 0,
    }
end

function ControllerMapping(player)
    local keys = {}
    local gpButtons = {}
    local mapping = {
        Player = player,
        Keys = keys,
        GPButtons = gpButtons,
    }

    -- keys
    if(player == 1) then
        keys[BUTTON_A] = { "j", "u" }
        keys[BUTTON_B] = { "k" }
        keys[BUTTON_S] = { "l", "o" }
        keys[BUTTON_EX] = { "i", "o" }

        keys[BUTTON_GUARD] = { "q", "lshift", "u" }
        keys[BUTTON_DASH] = { "e", "lctrl" }

        keys[BUTTON_UP] = { "w", "space" }
        keys[BUTTON_DOWN] = { "s" }
        keys[BUTTON_LEFT] = { "a" }
        keys[BUTTON_RIGHT] = { "d" }

        keys[BUTTON_START] = { "tab" }
        keys[BUTTON_CONFIRM] = { "j" }
        keys[BUTTON_CANCEL] = { "k" }

    elseif (player == 2) then
        keys[BUTTON_A] = { "kp1", "kp4" }
        keys[BUTTON_B] = { "kp2" }
        keys[BUTTON_S] = { "kp3", "kp6" }
        keys[BUTTON_EX] = { "kp5", "kp6" }

        keys[BUTTON_GUARD] = { "kp0", "rshift", "kp4" }
        keys[BUTTON_DASH] = { "kp.", "rctrl" }

        keys[BUTTON_UP] = { "up" }
        keys[BUTTON_DOWN] = { "down" }
        keys[BUTTON_LEFT] = { "left" }
        keys[BUTTON_RIGHT] = { "right" }

        keys[BUTTON_START] = { "kpenter", "return" }
        keys[BUTTON_CONFIRM] = { "kp1" }
        keys[BUTTON_CANCEL] = { "kp2" }
    end

    -- gamepad stuff

    return mapping

end

function GetButtons(controls)
    
    local button = BUTTON_FIRST
    local input = 0

    -- iterate through all buttons
    while(button <= BUTTON_LAST) do
        local keys = controls.Keys[button]

        for _, key in ipairs(keys) do
            if(love.keyboard.isDown(key)) then
                input = bit.bor(input, button)
            end
        end

        -- TODO: check gamepad input

        button = button * 2
    end

    -- SOCD
    local updown = bit.bor(BUTTON_UP, BUTTON_DOWN)
    local leftright = bit.bor(BUTTON_LEFT, BUTTON_RIGHT)

    if(bit.band(input, updown) == updown) then
        input = bit.band(input, bit.bnot(updown))
    end
    if(bit.band(input, leftright) == leftright) then
        input = bit.band(input, bit.bnot(leftright))
    end

    return input

end

function UpdateController(controller, controls, currentframe)
    controller.PressedLastFrame = controller.PressedThisFrame
    controller.PressedThisFrame = 0
    controller.PressedThisFrame = GetButtons(controls)
    -- remove menu buttons so they don't end up in timeline
    controller.PressedThisFrame = bit.band(controller.PressedThisFrame, bit.bnot(BUTTON_MENUBUTTONS))

    if(controller.PressedThisFrame ~= controller.PressedLastFrame) then
        table.insert(controller.InputFrame, 1, controller.PressedLastFrame)
        table.insert(controller.InputTime, 1, currentframe)
    end

    while(#controller.InputTime > MAX_INPUTS) do
        table.remove(controller.InputFrame)
        table.remove(controller.InputTime)
    end
end

function ControllerInputDown(controller, button)
    if(button == nil) then
        return false
    end
    return bit.band(controller.PressedThisFrame, button) ~= 0
end

function ControllerInputDownLastFrame(controller, button)
    return bit.band(controller.PressedLastFrame, button) ~= 0
end

-- this one will get buffering added in
function ControllerInputPressed(controller, button)
    if(button == nil) then
        return false
    end
    return bit.band(controller.PressedThisFrame, button) ~= 0 and 
            bit.band(controller.PressedLastFrame, button) == 0
end

function ControllerInputReleased(controller, button)
    if(button == nil) then
        return false
    end
    return bit.band(controller.PressedThisFrame, button) == 0 and 
            bit.band(controller.PressedLastFrame, button) ~= 0
end


function InputBuffered(controller, button, bufferLength)
    if(button == nil) then
        return false
    end
    local lastPressed = nil
    local lastNotPressed = nil

    -- if nil, become 10
    bufferLength = bufferLength or 10

    local maxTime = math.max(60, bufferLength*4)

    for i = 1, #controller.InputFrame, 1 do
        local input = controller.InputFrame[i]
        local time = controller.InputTime[i]

        if(lastNotPressed == nil and bit.band(input, button) == button) then
            lastPressed = time
        end

        if(lastPressed ~= nil and not (bit.band(input, button) == button)) then
            lastNotPressed = time
        end

        if(CurrentFrame - time > maxTime and lastPressed == nil) then
            return false
        end

        if(lastPressed ~= nil and lastNotPressed ~= nil) then
            if(CurrentFrame - lastPressed < bufferLength) then
                -- we use this for "lastbuffered" so once an attack is performed...
                -- we don't check the buffer for inputs that occurred BEFORE it was buffered
                controller.BufferTime = lastPressed
                return true
            else
                return false
            end
        end
    end

    return false
end

-- Has the button been held for at LEAST [length] frames?
function ControllerInputHeld(controller, button, length)
    if (not ControllerInputDown(controller, button) or (not ControllerInputDownLastFrame(controller, button))) then
        return false
    end

    for i = 1, #controller.InputFrame, 1 do
        local input = controller.InputFrame[i]
        local time = controller.InputTime[i]

        -- we are progressing BACK in time...
        -- So if it is late enough (within the window), and not pressed...
        -- then the button has not been held for long enough
        if(time > CurrentFrame - length and bit.band(input, button) ~= button) then
            return false
        end

        if(time < CurrentFrame - length) then
            return true
        end
    end

    return true
end

function CheckDashShortcut(controller, dir, input, bufferLength)
    local i = 1
    local time = nil

    bufferLength = bufferLength or 14
    
    -- start with the second input, and go back to find ther non-input
    -- loop through inputs to find the non-input
    while bit.band(input, dir) ~= 0 do
        input = controller.InputFrame[i]
        time = controller.InputTime[i]
        i = i + 1

        if(i > #controller.InputFrame) then
            return false
        end

        if(CurrentFrame - time > bufferLength) then
            return false
        end
    end
    -- if we exit the while loop, we've found a "direction release" within time (the "middle" of the input)
    -- then we go again to find the first input
    
    -- loop through non-inputs
    while bit.band(input, dir) ~= dir do
        input = controller.InputFrame[i]
        time = controller.InputTime[i]
        i = i + 1

        if(i > #controller.InputFrame) then
            return false
        end

        if(CurrentFrame - time > bufferLength) then
            return false
        end
    end
    -- if we exit, we've found the first input

    return true
end