function BlankPose()
    return {
        Duration = 1,
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
        partFrames[i] = PartPose(skeleton, i) -- default values, take from blueprint's defaults
    end

    return frame
end

function TweenedPose(skeleton, pose1, pose2, ratio)
    local newPose = BlankPose()

    local partFrames = newPose.PartFrames
    local blueprints = skeleton.PartBlueprints
    for i, bp in ipairs(blueprints) do
        --partFrames[i] = PartPose(skeleton, i) -- default values, take from blueprint's defaults
        if(bp.IK_State ~= nil and bit.band(bp.IK_State, IK_ON) ~= 0) then
            --partFrames[i] = deepcopy(pose1.PartFrames[i])
            
            --TweenedPartPoseIK(skeleton, newPose, bp, pose1.PartFrames[i], pose2.PartFrames[i], ratio)
            
        else
            --partFrames[i] = deepcopy(pose1.PartFrames[i])
            --partFrames[i] = TweenedPartPose(skeleton, pose1.PartFrames[i], pose2.PartFrames[i], ratio)
        end
        partFrames[i] = TweenedPartPose(skeleton, pose1.PartFrames[i], pose2.PartFrames[i], ratio)
        
    end

    return newPose
end

require "Editor"
function TweenedPartPoseIK(skeleton, pose, bp, p1, p2, ratio) 
     
    
    IKDrag(skeleton, pose, p1, (p2.CX - p1.CX)*ratio, (p2.CY - p1.CY)*ratio, bit.band(bp.IK_State, IK_ALT) ~= 0)

    --return pose.partFrames
end

function TweenedPartPose(skeleton, p1, p2, ratio)
   local np = CopyPose(p1)
   if(math.random(0, 10) > 5) then
   --     np = CopyPose(p2)
   end

   local lerp = function (n1, n2, ratio)
        return n1 + ((n2-n1)*ratio)
   end
   -- for rotation, we need to get closest difference
   local rotlerp = function (a1, a2, ratio)
    local diff = a1 - a2
    diff = (diff + math.pi) % (math.pi*2) - math.pi    
    
    return a1 + ((diff)*ratio)
        
   end

   np.Rotation = rotlerp(p1.Rotation, p2.Rotation, ratio)
   --np.CRotation = rotlerp(p1.CRotation, p2.CRotation, ratio)
   np.X = lerp(p1.X, p2.X, ratio)
   np.Y = lerp(p1.Y, p2.Y, ratio)
   --np.CX = lerp(p1.CX, p2.CX, ratio)
   --np.CY = lerp(p1.CY, p2.CY, ratio)
   np.XScale = lerp(p1.XScale, p2.XScale, ratio)
   np.YScale = lerp(p1.YScale, p2.YScale, ratio)

   return np

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
    lg.translate(x, y)
    lg.scale(xscale, yscale)
    lg.translate(skeleton.X or 0, skeleton.Y or 0)
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
        
        -- this is used for IK stretching, so the X scale visually remains at 1, rather than stretching
        if(part.XScaleLock == true) then
            xsc = (1/part.XScale) * Sign(xsc)
        end

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
            if(bit.band(blueprint.IK_State or 0, IK_ON) ~= 0) then
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

function GetAnimationFrame(anim, time, loop)
    local duration = 0
    for _, f in ipairs(anim.Frames) do
        duration = duration + f.Duration
    end
    if(loop) then
        time = time % duration
    end
    
    local counter = 0
    for _, f in ipairs(anim.Frames) do
        counter = counter + f.Duration
        if(counter > time) then
            return f
        end
    end

    return nil
end