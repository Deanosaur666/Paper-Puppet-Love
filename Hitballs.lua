require "Math"

-- hitball flags
HITBALL_HITTABLE = 1
HITBALL_ACTIVE = 2

function Hitball(x, y, radius, flags)
    return {
        X = x,
        Y = y,
        Radius = radius,
        Flags = flags
    }
end

function HitballFromPart(skeleton, partframe, ballnum)
    local blueprint = GetPartBluePrint(partframe, skeleton)
    local hitball = blueprint.Hitballs[ballnum]
    local scale = math.min(partframe.XScale, partframe.YScale)
    
    local x, y = hitball.X * scale, hitball.Y * scale
    x, y = RotatePoint(x, y, partframe.CRotation)

    x = x + partframe.CX
    y = y + partframe.CY

    local radius = hitball.Radius * scale * (partframe.HitballScale[ballnum] or 1)
    local flags = partframe.HitballFlags[ballnum] or hitball.Flags

    local ball = Hitball(x, y, radius, flags)
    ball.Part = partframe
    ball.Index = ballnum
    return ball
end

function DrawHitBall(x, y, radius, flags)
    local lg = love.graphics
    lg.push("all")
    if(bit.band(flags, HITBALL_HITTABLE) ~= 0) then
        if(bit.band(flags, HITBALL_ACTIVE) ~= 0) then
            lg.setColor(1, 0, 0)
        else
            lg.setColor(0, 0, 1)
        end
    else
        if(bit.band(flags, HITBALL_ACTIVE) ~= 0) then
            lg.setColor(1, 0, 1)
        else
            lg.setColor(0.5, 0.5, 0.5)
        end
    end
    lg.circle("line", x, y, radius)
    lg.pop()
end

function GetPoseHitballs(pose, skeleton)
    local balls = {}
    for _, part in pairs(pose.PartFrames) do
        local blueprint = GetPartBluePrint(part, skeleton)
        for i, _ in ipairs(blueprint.Hitballs) do
            local hitball = HitballFromPart(skeleton, part, i)
            table.insert(balls, hitball)
        end
    end
    return balls
end

function HitballAtPoint(hitballs, x, y, radius)
    local closest = nil
    local dist = math.huge -- infinity
    radius = radius or 0

    for _, ball in ipairs(hitballs) do
        local bdist = PointDistance(x, y, ball.X, ball.Y)
        if(bdist < dist and bdist < ball.Radius + radius) then
            closest = ball
            dist = bdist
            print("Ball found")
        end
        -- print("Ball distance " .. bdist .. " ball at " .. ball.X .. ", " .. ball.Y .. " point at " .. x .. ", " .. y)
    end

    return closest
end