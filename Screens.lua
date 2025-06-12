function BlankProgram()
    local prog = {}

    prog.Load = function ()
        -- nothing
    end

    prog.Update = function ()
        -- nothing
    end

    prog.Draw = function ()
        -- nothing
    end

    return prog
end

function GetRelativeMouse(scale, offsetX, offsetY)
    local mx, my = love.mouse.getPosition()

    mx = (mx / scale) - offsetX
    my = (my / scale) - offsetY
    
    return mx, my
end