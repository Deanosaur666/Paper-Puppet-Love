
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

function ControllerMapping(player)
    local keys = {}
    local gpButtons = {}
    local mapping = {
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

        keys[BUTTON_START] = { "kpenter", "enter" }
        keys[BUTTON_CONFIRM] = { "kp1" }
        keys[BUTTON_CANCEL] = { "kp2" }
    end

    -- gamepad stuff

    return mapping

end