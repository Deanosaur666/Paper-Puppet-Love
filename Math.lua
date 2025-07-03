
function GetIKJointAngle(sx, sy, tx, ty, l1, l2, alt)    
    local dx = tx-sx
    local dy = ty-sy
    local dist = PointDistance(sx, sy, tx, ty)
    
    local beta = math.atan2(dy, dx)

    if(dist >= l1 + l2 or dist <= math.abs(l1 - l2)) then
        return beta
    end

    local alpha = math.acos( (dist*dist + l1*l1 - l2*l2) / (2*dist*l1) )

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

function PointInRectangle(px, py, rx, ry, rw, rh)
    return (px >= rx and px < rx + rw) and
            (py >= ry and py < ry + rh)
end

function RectangleCollision(r1x, r1y, r1w, r1h, r2x, r2y, r2w, r2h)
  return (r1x + r1w >= r2x and      -- r1 right edge past r2 left
      r1x <= r2x + r2w and          -- r1 left edge past r2 right
      r1y + r1h >= r2y and          -- r1 top edge past r2 bottom
      r1y <= r2y + r2h)             -- r1 bottom edge past r2 top

end

-- flip a rectangle horizontally
-- we don't change anything but rx
function FlipRectangle(rx, ry, rw, rh)
    rx = -rx - rw
    return rx, ry, rw, rh
end

function Sign(n)
   return n == 0 and 0 or math.abs(n)/n 
end

function Clamp(n, lower, upper)
    return math.min(math.max(n, lower), upper)
end