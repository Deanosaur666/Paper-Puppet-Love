function SaveSkeleton()
    local skeleton = CurrentSkeleton()
    local name = SkeletonName
    if(name == nil or name == "[NEW]") then
        EnterSkeletonName()
        return
    end
    jsonEncodeFile(skeleton, "Resources/skeletons/" .. name)
end

function EnterSkeletonName()
    TextEntryOn = true
    TextEntryPrompt = "Enter skeleton name"
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

IKLockParts = {}
IKAltParts = {}
IKPrevCX = {}
IKPrevCY = {}
IKPrevCRot = {}

ClipboardX = nil
ClipboardY = nil
ClipboardRotation = nil
ClipboardXScale = nil
ClipboardYScale = nil


function IKDrag(skeleton, pose, part, dx, dy, alt)
    -- we want the part's CX and CY to change by dx and dy without changing its actual X and Y
    -- we also want to preserve the part's orignal rotation

    -- dx and dy of zero should do nothing, in theory

    local bp = GetPartBluePrint(part, skeleton)
    local parent = GetParent(part, bp, pose)
    -- parent blueprint
    local pbp = GetPartBluePrint(parent, skeleton)

    local grandparent = GetParent(parent, pbp, pose)
    -- grandparent blueprint
    local gpbp = GetPartBluePrint(grandparent, skeleton)

    grandparent.XScale = Sign(grandparent.XScale)
    grandparent.YScale = Sign(grandparent.YScale)
    parent.XScale = Sign(parent.XScale)
    parent.YScale = Sign(parent.YScale)

    -- great-grandparent rotation
    local ggprot = grandparent.CRotation - grandparent.Rotation -- SUPPOSE this is 0 (no rotation)

    -- parent length, angle
    local x, y = bp.X * parent.XScale, bp.Y  * parent.YScale
    local plen = PointDistance(0, 0, x, y)
    local pangle = math.atan2(y, x) -- SUPPOSE this is -90 (down)
    -- grandparent length, angle
    local gplen = PointDistance(0, 0, pbp.X, pbp.Y)
    local gpangle = math.atan2(pbp.Y * grandparent.YScale, pbp.X * grandparent.XScale) -- SUPOSE this is -90 (down)

    -- we do this to cancel ggprot, so it's as if the gp does not inherit rotation
    local ndx, ndy = RotatePoint(dx, dy, -ggprot) -- SUPPOSE ggprot is zero and so are dx and dy. Thus ndx, ndy = 0

    -- the X and Y of the IK part relative to the grandparent
    local mx, my = RotatePoint(part.CX - grandparent.CX, part.CY - grandparent.CY, -ggprot) -- SUPPOSE these are 0, 100 (IK part 100 pixels below grandparent)

    local gpnewrot = GetIKJointAngle(0, 0, mx + ndx, my + ndy, gplen, plen, alt) -- SUPPOSE the previous suppositions. This should point straight down (-90)

    -- new parent x and y
    local px = math.cos(gpnewrot)*gplen
    local py = math.sin(gpnewrot)*gplen -- SUPPOSE this is 0, 50

    -- IF px, py are 0, 50 and mx are 0, 100, this is -90
    -- THE PROBLEM IS: when dx, dy are 0, gpnewrot doesn't change, but pnewrot does...
    local pnewrot = math.atan2(my + ndy - py, mx + ndx - px) - (gpnewrot - gpangle) -- THIS would make pnewrot 0

    local gpstartrot = grandparent.Rotation or 0
    local pstartrot = parent.Rotation or 0

    grandparent.Rotation = (gpnewrot - gpangle) % (math.pi*2)
    parent.Rotation = (pnewrot - pangle) % (math.pi*2)

    part.Rotation = (part.Rotation or 0) - ((grandparent.Rotation - gpstartrot) + (parent.Rotation - pstartrot))

    
    -- stretching
    local desired_dist = math.max(PointDistance(0, 0, mx + ndx, my + ndy), (gplen + plen)/2)
    if(desired_dist > gplen + plen) then
        local ratio = desired_dist/(gplen + plen)
        local desired_gplen = gplen * ratio
        local desired_plen = plen * ratio

        grandparent.XScale = ratio * Sign(grandparent.XScale)
        grandparent.YScale = ratio * Sign(grandparent.YScale)

        parent.XScale = ratio * Sign(parent.XScale)
        parent.YScale = ratio * Sign(parent.YScale)
    end
end

function DrawAndPoseSkeleton(skeleton, pose, x, y, mx, my)
    DraggedPart = nil
    ScrollLock = false
    
    local lg = love.graphics
    lg.push("all")

    lg.setLineWidth(2)

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
        CurrentPartStartYScale = part.YScale or 1
        PartDragMX = mx
        PartDragMY = my
        BlueprintIndex = ball.PartIndex
        ClickedPart = part
        ClickedBall = ball
    end

    if(part ~= nil) then
        ScrollLock = true
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
                    IKPrevCRot[p] = parts[p].CRotation
                end
            end

            -- shift for translate
            if(love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
                local dx, dy = mx - PartDragMX, my - PartDragMY

                if(blueprint.IK) then
                    -- drag with IK
                    IKDrag(skeleton, pose, part, dx, dy, IKAltParts[partIndex])
                    PartDragMX = mx
                    PartDragMY = my

                    DraggedPart = part

                elseif(not blueprint.PositionLock) then
                    -- this is how much we're moving it in it's own local rotated space
                    -- that is, the actual change in X and Y to achieve this visible X and Y change

                    dx, dy = RotatePoint(dx, dy, -(part.CRotation - part.Rotation))

                    if(blueprint.ParentIndex ~= nil) then
                        local parent = GetParent(part, blueprint, pose)
                        dx = dx * parent.XScale
                        dy = dy * parent.YScale
                    end

                    part.X = CurrentPartStartX + dx
                    part.Y = CurrentPartStartY + dy
                end
                
            -- ctrl for scale
            elseif(love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
                local dx, dy = RotatePoint(mx - PartDragMX, my - PartDragMY, -part.CRotation)

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

                DraggedPart = part
            end


            -- to update part relative positions before we change them back with below
            UpdatePose(pose, skeleton)

            for p, on in pairs(IKLockParts) do
                -- drag with IK to previous position
                local ikpart = parts[p]
                if(on and ikpart ~= DraggedPart) then
                    -- drag back
                    local dx, dy = IKPrevCX[p] - ikpart.CX, IKPrevCY[p] - ikpart.CY
                    IKDrag(skeleton, pose, ikpart, dx, dy, IKAltParts[p])
                end
            end

            UpdatePose(pose, skeleton)

            for p, on in pairs(IKLockParts) do
                -- drag with IK to previous position
                local ikpart = parts[p]
                if(on and ikpart ~= DraggedPart) then
                    -- rotate back
                    local drotation = ikpart.CRotation - IKPrevCRot[p]
                    ikpart.Rotation = ikpart.Rotation - drotation
                end
            end
            
        elseif(MousePressed[2]) then
            -- shift for reset hitballs and sprite
            if(love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
                fillArray(part.HitballFlags, HITBALL_HITTABLE)
                fillArray(part.HitballScale, 1)
                part.SpriteIndex = nil
                part.Layer = nil
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

        -- hiding and unhiding part with H
        if(KeysPressed["h"]) then
            part.Hidden = not part.Hidden
        end

        -- copying global transforms
        if(KeysPressed["c"]) then
            ClipboardX = part.CX
            ClipboardY = part.CY
            ClipboardRotation = part.CRotation
            ClipboardXScale = part.XScale
            ClipboardYScale = part.YScale
        end

        -- pasting global transforms
        if(KeysPressed["v"] and ClipboardX ~= nil) then
            local dx = ClipboardX - part.CX
            local dy = ClipboardY - part.CY
            local drot = ClipboardRotation - part.CRotation
            if(blueprint.IK) then
                IKDrag(skeleton, pose, part, dx, dy, IKAltParts[partIndex])
                UpdatePose(pose, skeleton)
            else
                local prot = part.CRotation - part.Rotation
                local pxscale = 1
                local pyscale = 1

                if(blueprint.ParentIndex ~= nil) then
                    local parent = GetParent(part, blueprint, pose)
                    pxscale = parent.XScale
                    pyscale = parent.YScale
                end

                dx, dy = RotatePoint(dx, dy, -prot)
                dx = dx * pxscale
                dy = dy * pyscale

                part.X = part.X + dx
                part.Y = part.Y + dy
            end

            part.Rotation = part.Rotation + drot
            part.XScale = ClipboardXScale
            part.YScale = ClipboardYScale
        end
    end

    lg.pop()
end
