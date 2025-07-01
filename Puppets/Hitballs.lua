-- hitball flags
HITBALL_HITTABLE = 1
HITBALL_ACTIVE = 2

HITBALL_STATES = {
    0, -- not hittable, not active
    1, -- hittable, not active
    2, -- Active, not hitabble
    3, -- Hittable, active
}

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
    local scale = math.min(math.abs(partframe.XScale), math.abs(partframe.YScale))
    
    local x, y = hitball.X, hitball.Y
    local xsc, ysc = GetBlueprintScale(blueprint)

    x = x * partframe.XScale * xsc
    y = y * partframe.YScale * ysc
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

function HitballColor(flags)
    if(bit.band(flags, HITBALL_HITTABLE) ~= 0) then
        -- non-disjoint active
        if(bit.band(flags, HITBALL_ACTIVE) ~= 0) then
            return 1, 0, 0
        -- regular hurtball
        else
            return 0, 0, 1
        end
    -- unhittable
    else
        -- disjoint active
        if(bit.band(flags, HITBALL_ACTIVE) ~= 0) then
            return 0.5, 0, 0.5
        -- intangible
        else
            return 0.2, 0.2, 0.2
        end
    end
end

function DrawHitBall(x, y, radius, flags)
    local lg = love.graphics
    lg.push("all")
    local r, g, b = HitballColor(flags)
    lg.setColor(r, g, b)
    lg.circle("line", x, y, radius)
    lg.pop()
end

function DrawHitballs(hitballs)    
    local lg = love.graphics

    lg.push("all")

    for _, hitball in ipairs(hitballs) do
        local hx = hitball.X
        local hy = hitball.Y
        local hr = hitball.Radius
        local r, g, b = HitballColor(hitball.Flags)
        lg.setColor(r, g, b)

        DrawHitBall(hx, hy, hr, hitball.Flags)        
    end

    lg.pop()
end

function GetPoseHitballs(pose, skeleton, x, y, xscale, yscale)
    x = x or 0
    y = y or 0
    xscale = xscale or 1
    yscale = yscale or 1
    
    local balls = {}
    for p, part in ipairs(pose.PartFrames) do
        local blueprint = GetPartBluePrint(part, skeleton)
        for h, _ in ipairs(blueprint.Hitballs) do
            local hitball = HitballFromPart(skeleton, part, h)
            hitball.X = (hitball.X + (skeleton.X or 0)) * xscale + x
            hitball.Y = (hitball.Y + (skeleton.Y or 0)) * yscale + y
            hitball.PartIndex = p
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
        end
    end

    return closest
end