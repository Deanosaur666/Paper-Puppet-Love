require "Math"

function BlankProgram()
    local prog = {}

    function prog:Load()
        -- nothing
    end

    function prog:Update()
        -- nothing
    end

    function prog:Draw()
        -- nothing
    end

    function prog:KeyPressed(key, scancode, isrepeat)
        -- nothing
    end

    function prog:TextInput(t)
        -- nothing
    end

    function prog:MousePressed(mb)
        -- nothing
    end

    function prog:MouseHeld(mb)
        -- nothing
    end

    function prog:MouseReleased(mb)
        -- nothing
    end

    return prog
end

function ClickableButton(x, y, w, h, props)
    local button = {
        X = x,
        Y = y,
        W = w,
        H = h
    }

    function button.LPressed(prog, button, mx, my)
        -- nothing
    end
    function button.RPressed(prog, button, mx, my)
        -- nothing
    end
    function button.MPressed(prog, button, mx, my)
        -- nothing
    end
    function button.LHeld(prog, button, mx, my)
        -- nothing
    end
    function button.RHeld(prog, button, mx, my)
        -- nothing
    end
    function button.MHeld(prog, button, mx, my)
        -- nothing
    end
    function button.LReleased(prog, button, mx, my)
        -- nothing
    end
    function button.RReleased(prog, button, mx, my)
        -- nothing
    end
    function button.MReleased(prog, button, mx, my)
        -- nothing
    end

    for k, v in pairs(props) do
        button[k] = v
    end

    return button
end

function CheckClickableButton(prog, button, mx, my)
    if(not PointInRectangle(mx, my, button.X, button.Y, button.W, button.H)) then
        return
    end
    if(MousePressed[1]) then
        button.LPressed(prog, button, mx, my)
    end
    if(MousePressed[2]) then
        button.RPressed(prog, button, mx, my)
    end
    if(MousePressed[3]) then
        button.MPressed(prog, button, mx, my)
    end
    if(MouseDown[1]) then
        button.LHeld(prog, button, mx, my)
    end
    if(MouseDown[2]) then
        button.RHeld(prog, button, mx, my)
    end
    if(MouseDown[3]) then
        button.MHeld(prog, button, mx, my)
    end
    if(MouseDownPrev[1] and not MouseDown[1]) then
        button.LReleased(prog, button, mx, my)
    end
    if(MouseDownPrev[2] and not MouseDown[2]) then
        button.RReleased(prog, button, mx, my)
    end
    if(MouseDownPrev[3] and not MouseDown[3]) then
        button.MReleased(prog, button, mx, my)
    end
end

function GetRelativeMouse(scale, offsetX, offsetY)
    local mx, my = love.mouse.getPosition()

    mx = (mx / scale) - offsetX
    my = (my / scale) - offsetY
    
    return mx, my
end


function DrawCheckButton(prog, button, text, mx, my)
    local lg = love.graphics
    CheckClickableButton(prog, button, mx, my)

    lg.setColor(1, 1, 0)
    
    lg.rectangle("fill", button.X, button.Y, button.W, button.H)
    lg.setColor(0, 0, 0)
    lg.rectangle("line",  button.X, button.Y, button.W, button.H)
    
    lg.setFont(Font_KBig)
    PrintCentered(text, button.X + button.W/2, button.Y + button.H/2)
    
end