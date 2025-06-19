PriorityQueue = require "PriorityQueue"

function BlankPose()
    return {
        Duration = 0,
        PartFrames = {},
        -- frame specific offset for the whole body
        X = nil,
        Y = nil,
    }
end

function Pose(skeleton)
    
    local frame = BlankPose()
    local partFrames = frame.PartFrames
    local blueprints = skeleton.PartBlueprints
    for i, bp in ipairs(blueprints) do
        partFrames[i] = PartPose(i, nil, 0, 0, 0, nil) -- default values, take from blueprint's defaults
    end

    return frame
end

function CopyPose(pose)
    -- just in case we need to add extra functionality....????
    return deepcopy(pose)
end

-- TODO: Copy and save poses 


function UpdatePose(frame, skeleton)
    for i, pf in ipairs(frame.PartFrames) do
        UpdatePartPose(pf, frame, skeleton)
        pf.CX = pf.CX + (frame.X or 0)
        pf.CY = pf.CY + (frame.Y or 0)
    end
end

function DrawPose(frame, skeleton, spriteset, texture, x, y, rot, xscale, yscale)
    
    xscale = xscale or 1
    yscale = yscale or 1
    rot = rot or 0
    
    local lg = love.graphics

    lg.push("all")
    lg.translate(x + (skeleton.X or 0) + (frame.X or 0), y + (skeleton.Y or 0) + (frame.Y or 0))
    lg.scale(xscale, yscale)
    lg.rotate(rot)


    -- needs to change origin, rotation, and scale based on x, y, rot, xscale, yscale

    local partqueue = PriorityQueue("max")

    for _, part in pairs(frame.PartFrames) do
        if(not part.Hidden) then
            local blueprint = GetPartBluePrint(part, skeleton)
            partqueue:enqueue(part, part.Layer or blueprint.DefLayer)
        end
    end

    while not partqueue:empty() do
        local part = partqueue:dequeue()
        local blueprint = GetPartBluePrint(part, skeleton)
        local sprite = GetPartSprite(part, blueprint, spriteset)
        local xsc, ysc = GetBlueprintScale(blueprint)
        DrawPaperSprite(sprite, texture, part.CX, part.CY, part.CRotation, part.XScale * xsc, part.YScale * ysc)
    end

    lg.pop()
end

function DrawPoseHitballs(pose, skeleton, x, y, rot, xscale, yscale)
    xscale = xscale or 1
    yscale = yscale or 1
    rot = rot or 0
    
    local lg = love.graphics

    lg.push("all")
    lg.setFont(Font_Consolas32)
    lg.translate(x + (skeleton.X or 0) + (pose.X or 0), y + (skeleton.Y or 0) + (pose.Y or 0))
    lg.scale(xscale, yscale)
    lg.rotate(rot)

    for p, part in ipairs(pose.PartFrames) do
        local blueprint = GetPartBluePrint(part, skeleton)
        for i, _ in ipairs(blueprint.Hitballs) do
            local hitball = HitballFromPart(skeleton, part, i)
            local hx = hitball.X
            local hy = hitball.Y
            local hr = hitball.Radius
            local r, g, b = HitballColor(hitball.Flags)
            lg.setColor(r, g, b)
            if(blueprint.IK) then
                lg.line(hx - hr*0.9, hy, hx, hy - hr*0.9, hx + hr*0.9, hy, hx, hy + hr*0.9, hx - hr*0.9, hy)
            end

            if(IKLockParts[p]) then
                lg.line(hx - hr*1.1, hy, hx, hy - hr*1.1, hx + hr*1.1, hy, hx, hy + hr*1.1, hx - hr*1.1, hy)
            end

            if(IKAltParts[p]) then
                local d = math.cos(math.pi/4)*hr / 2
                lg.line(hx - d, hy - d, hx + d, hy + d)
                lg.line(hx - d, hy + d, hx + d, hy - d)
            end

            DrawHitBall(hx, hy, hr, hitball.Flags)

            if(love.keyboard.isDown("l")) then
                PrintCentered(tostring(part.Layer or blueprint.DefLayer), hx, hy)
            end
        end
    end

    lg.pop()
end

function Animation(name)
    return {
        Name = name,
        Frames = {}, -- an array of poses
    }
end