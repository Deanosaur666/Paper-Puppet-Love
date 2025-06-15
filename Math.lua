function GetIKJointAngle(sx, sy, tx, ty, l1, l2, alt)    
    local dx = tx-sx
    local dy = ty-sy
    local dist = math.sqrt(dx*dx + dy*dy)
    
    local beta = math.atan2(dy, dx)

    if(dist > l1 + l2 or dist < math.abs(l1 - l2)) then
        return beta
    end

    local alpha = math.acos( (dist^2 + l1^2 - l2^2) / (2*dist*l1) )

    if(alt) then
        alpha = math.pi*2 - alpha
    end

    return alpha + beta
end

function RotatePoint(x, y, rot)
    local nx = x*math.cos(rot) - y*math.sin(rot)
    local ny = y*math.cos(rot) + x*math.sin(rot)

    return nx, ny
end

function PointDistance(x1, y1, x2, y2)
    local dx = x2-x1
    local dy = y2-y1
    return math.sqrt( (dx*dx) + (dy*dy) )
end