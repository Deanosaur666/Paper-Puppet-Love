
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

function DrawAndPoseSkeleton(skeleton, pose, x, y, mx, my)
    local lg = love.graphics

    UpdatePose(pose, skeleton)
    DrawPose(pose, skeleton, CurrentSpriteSet(), CurrentTexture(), x, y)
    if(DisplayHitballs) then
        DrawPoseHitballs(pose, skeleton, x, y)
    end

    if(not MouseDown[1]) then
        local hitballs = GetPoseHitballs(pose, skeleton)
        local ball = HitballAtPoint(hitballs, mx - x, my - y, 0)
        if(ball ~= nil) then
            CurrentBall = ball
            CurrentPart = ball.Part
        else
            CurrentBall = nil
            CurrentPart = nil
        end
    end

    local part = CurrentPart
    local ball = CurrentBall

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
    end

    if(part ~= nil) then
        lg.setColor(1, 1, 0)
        lg.circle("line", ball.X + x, ball.Y + y, ball.Radius)

        if(MouseDown[1]) then
            local px, py = part.CX + x + (skeleton.X or 0), part.CY + y + (skeleton.Y or 0)
            lg.circle("line", px, py, 20)
            lg.line(px, py, mx, my)

            -- shift for translate
            if(love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
                local dx, dy = mx - PartDragMX, my - PartDragMY
                dx, dy = RotatePoint(dx, dy, -(part.CRotation - part.Rotation))
                local blueprint = GetPartBluePrint(part, skeleton)
                if(not blueprint.PositionLock) then
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
            end
        elseif(MouseDown[2]) then
            part.X = 0
            part.Y = 0
            part.XScale = 1
            part.YScale = 1
            part.Rotation = 0
        end
    end
end
