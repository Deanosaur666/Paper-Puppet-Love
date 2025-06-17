
-- paper skeleton has:
-- sprite slots (should match sprite set)
-- paper parts
-- animations, which have:
--      frames, which are collections of parts
require "tables"

function SaveSkeleton()
    local skeleton = CurrentSkeleton()
    local name = SkeletonName
    if(name == nil or name == "[NEW]") then
        EnterSkeletonName()
        return
    end
    jsonEncodeFile(skeleton, "skeletons/" .. name)
end

function EnterSkeletonName()
    TextEntryOn = true
    TextEntered = SkeletonName or ""
    TextEntryFinished = SkeletonNameEntered
end

function SkeletonNameEntered()
    if(TextEntered == "") then
        EnterSkeletonName()
        return
    end
    local skeleton = CurrentSkeleton()
    SkeletonIndex = TextEntered
    SkeletonName = SkeletonIndex
    Skeletons[SkeletonIndex] = skeleton

    SaveSkeleton()
end

function LoadSkeletons()
    local files = love.filesystem.getDirectoryItems("skeletons")
    for _, value in ipairs(files) do
        Skeletons[value] = jsonDecodeFile("skeletons/" .. value)
    end
end

function PaperSkeleton()
    return {
        Name = "",
        PartBlueprints = {}, -- full of PartBluePrints
        Animations = {},
        -- global offset so that 0,0 can be their feet, for example
        X = nil,
        Y = nil
    }
end

function Animation(name)
    return {
        Name = name,
        Frames = {}, -- an array of poses
    }
end

IKLockParts = {}
IKAltParts = {}
IKPrevCX = {}
IKPrevCY = {}
IKPrevCRotation = {}


function IKDrag(skeleton, pose, part, dx, dy)
    -- we want the part's CX and CY to change by dx and dy without changing its actual X and Y
    -- we also want to preserve the part's orignal rotation
end

function DrawAndPoseSkeleton(skeleton, pose, x, y, mx, my)
    local lg = love.graphics

    local spriteSet = CurrentSpriteSet()
    local texture = CurrentTexture()
    local parts = pose.PartFrames

    -- we ensure part's new relative transforms are updated
    UpdatePose(pose, skeleton)

    -- the actual figure
    DrawPose(pose, skeleton, spriteSet, texture, x, y)
    
    -- drawing the hit balls
    if(DisplayHitballs) then
        DrawPoseHitballs(pose, skeleton, x, y)
    end

    -- we only reset current ball and part when mouse isn't down
    if(not MouseDown[1]) then
        local hitballs = GetPoseHitballs(pose, skeleton)
        local ball = HitballAtPoint(hitballs, mx - x, my - y, 0)
        if(ball ~= nil) then
            CurrentBall = ball
            CurrentPart = ball.Part
            CurrentPartIndex = ball.PartIndex
        else
            CurrentBall = nil
            CurrentPart = nil
            CurrentPartIndex = nil
        end
    end

    local part = CurrentPart
    local partIndex = CurrentPartIndex
    local ball = CurrentBall
    local blueprint = nil
    if(part) then
        blueprint = GetPartBluePrint(part, skeleton)
    end

    -- when you first click, we reset lots of stuff, find part's starting transforms
    if(MousePressed[1] and part ~= nil) then
        CurrentPartStartRotation = part.Rotation
        CurrentPartStartCX = part.CX
        CurrentPartStartCY = part.CY
        CurrentPartStartX = part.X
        CurrentPartStartY = part.Y
        CurrentPartStartXScale = part.XScale or 1
        CurrentPartStartYScale = part.YSCale or 1
        PartDragMX = mx
        PartDragMY = my
        BlueprintIndex = ball.PartIndex
        ClickedPart = part
        ClickedBall = ball
    end

    if(part ~= nil) then
        lg.setColor(1, 1, 0)
        lg.circle("line", ball.X + x, ball.Y + y, ball.Radius*0.9)

        if(MouseDown[1]) then
            local px, py = part.CX + x + (skeleton.X or 0), part.CY + y + (skeleton.Y or 0)
            lg.circle("line", px, py, 20)
            lg.line(px, py, mx, my)

            for p, on in pairs(IKLockParts) do
                -- record previous postion
                if(on) then
                    IKPrevCX[p] = parts[p].CX
                    IKPrevCY[p] = parts[p].CY
                    IKPrevCRotation[p] = parts[p].CRotation
                end
            end

            -- shift for translate
            if(love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
                local dx, dy = mx - PartDragMX, my - PartDragMY
                
                -- this is how much we're moving it in it's own local rotated space
                -- that is, the actual change in X and Y to achieve this visible X and Y change
                dx, dy = RotatePoint(dx, dy, -(part.CRotation - part.Rotation))

                if(blueprint.IK) then
                    -- drag with IK
                    IKDrag(skeleton, pose, part, dx, dy)
                    PartDragMX = mx
                    PartDragMY = my

                elseif(not blueprint.PositionLock) then
                    part.X = CurrentPartStartX + dx
                    part.Y = CurrentPartStartY + dy
                end
                
            -- ctrl for scale
            elseif(love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
                local dx, dy = RotatePoint(mx - PartDragMX, my - PartDragMY, -part.CRotation)
                -- dy = -dy
                part.XScale = CurrentPartStartXScale * ((ball.Radius+dx) / ball.Radius)
                part.YScale = CurrentPartStartYScale * ((ball.Radius+dy) / ball.Radius)
            -- no key for rotate
            else
                local startangle = math.atan2(PartDragMY - py, PartDragMX - px)
                local newangle = math.atan2(my - py, mx - px)

                part.Rotation = CurrentPartStartRotation + (newangle - startangle)
                PartDragMX = mx
                PartDragMY = my
                CurrentPartStartRotation = part.Rotation
            end


            -- to update part relative positions before we change them back with below
            UpdatePose(pose, skeleton)

            for p, on in pairs(IKLockParts) do
                -- drag with IK to previous position
                local ikpart = parts[p]
                if(on) then
                    ikpart.Rotation = ikpart.Rotation + (IKPrevCRotation[p] - ikpart.CRotation)
                    -- drag back
                    local dx, dy = ikpart.CX - IKPrevCX[p], ikpart.CY - IKPrevCY[p]
                    IKDrag(skeleton, pose, ikpart, dx, dy)
                end
            end
            
        elseif(MousePressed[2]) then
            -- shift for reset hitballs and sprite
            if(love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
                part.HitballFlags = {}
                part.HitballScale = {}
                part.SpriteIndex = nil
            -- no keys for reset transforms
            else
                part.X = 0
                part.Y = 0
                part.XScale = 1
                part.YScale = 1
                part.Rotation = 0
            end
        elseif(MousePressed[3]) then
            -- ctrl for IK lock
            if(love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
                if(blueprint.IK) then
                    IKAltParts[partIndex] = not IKAltParts[partIndex]
                end
            -- alt for IK alt
            else
                if(blueprint.IK) then
                    IKLockParts[partIndex] = not IKLockParts[partIndex]
                end
            end
        end

        -- mouse wheel up or down
        if(MouseWheel ~= 0 and part ~= nil) then
            local wheel = Sign(MouseWheel)
            -- L for layer
            if(love.keyboard.isDown("l")) then
                part.Layer = (part.Layer or blueprint.DefLayer) + wheel
            
            -- shift for change sprite
            elseif(love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
                part.SpriteIndex = tableChangeIndex((part.SpriteIndex or blueprint.DefSpriteIndex), spriteSet, wheel)
            
            -- ctrl for ball size
            elseif(love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
                part.HitballScale[ball.Index] = Clamp((part.HitballScale[ball.Index] or 1) + wheel*0.1, 0.1, 10)
            
            -- alt for flipping
            elseif(love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt")) then
                if(wheel == -1) then
                    part.XScale = (part.XScale or 1) * -1
                else
                    part.YScale = (part.YScale or 1) * -1
                end
            
            -- no keys for change ball flags
            else
                local ballNum = ball.Index
                part.HitballFlags[ball.Index] = (ball.Flags + wheel) % #HITBALL_STATES
            end
        end
    end
end
