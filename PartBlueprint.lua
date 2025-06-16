
-- paper part blueprint has:
-- parent (a hand is parented to an arm, which is parented to upper arm, which is parented to body)
-- parent offset ()
-- ik flag (for hands and feet that can drag limbs)
-- position lock flag (for elbows and stuff that can't be moved from anchor)

-- TODO: add hit balls to part blueprints

bit = require 'bit'
require "Math"
require "Hitballs"

function PartBlueprint(parentIndex, x, y, defSpriteIndex)
    return {
        ParentIndex = parentIndex,
        X = x,
        Y = y,
        DefSpriteIndex = defSpriteIndex,
        DefLayer = 0,
        IK = false,
        PositionLock = false,
        Hitballs = {},
        FlippedX = false,
        FlippedY = false,
    }
end

function PartBlueprintEditor()
    local prog = BlankProgram()
    prog.Scale = 0.5
    prog.OffsetX = 100
    prog.OffsetY = 100

    prog.BlueprintIndex = nil
    local skeleton = CurrentSkeleton()
    if(#skeleton.PartBlueprints > 0) then
        prog.BlueprintIndex = 1
    end

    prog.NextSpriteIndex = 1

    prog.CurrentBlueprintX = nil
    prog.CurrentBlueprintY = 0
    prog.CurrentBlueprintW = 0
    prog.CurrentBlueprintH = 0

    prog.ParentBluePrintX = nil
    prog.ParentBlueprintY = 0
    prog.ParentBlueprintW = 0
    prog.ParentBlueprintH = 0

    prog.ViewCenterX = 0
    prog.ViewCenterY = 0

    prog.ViewW = 0
    prog.ViewH = 0

    MouseDragX = nil
    MouseDragY = nil

    prog.SkeletonFrame = nil
    prog.SkeletonX = 0
    prog.SkeletonY = 0
    prog.CurrentPart = nil
    prog.CurrentHitball = nil

    prog.CurrentPartStartCRotation = 0
    prog.CurrentPartStartCX = 0
    prog.CurrentPartStartCY = 0
    prog.CurrentPartStartXScale = 0
    prog.CurrentPartStartYScale = 0
    prog.PartDragMX = 0
    prog.PartDragMY = 0

    function prog:Draw()
        local lg = love.graphics
        lg.push("all")

        lg.clear(0.4, 0.4, 0.4)

        local str = "Current Skeleton: " .. SkeletonIndex
        lg.print(str, 10, 0)

        local skeleton = CurrentSkeleton()

        lg.setFont(Font_K)

        str = "Current Part Blueprint: " .. tostring(self.BlueprintIndex or 0) .. "/" .. tostring(#skeleton.PartBlueprints)
        lg.print(str, 10, 20)

        lg.scale(self.Scale, self.Scale)
        lg.translate(self.OffsetX, self.OffsetY)

        local screenWidth = ScreenWidth/self.Scale - self.OffsetX*2
        local screenHeight = ScreenHeight/self.Scale - self.OffsetY*2

        local sheet = CurrentTexture()

        self.ViewCenterX, self.ViewCenterY, self.ViewW, self.ViewH = sheet:getWidth()/2, sheet:getHeight()/2, sheet:getWidth(), sheet:getHeight()

        lg.rectangle("line", 0, 0, sheet:getWidth(), sheet:getHeight())
        lg.line(0, self.ViewCenterY, self.ViewW, self.ViewCenterY)
        lg.line(self.ViewCenterX, 0, self.ViewCenterX, self.ViewH)

        self.SkeletonX, self.SkeletonY = self.ViewCenterX, self.ViewCenterY
        if(skeleton.X ~= nil) then
            self.SkeletonX, self.SkeletonY = self.ViewCenterX, self.ViewH
        end
        self:DrawSkeleton(self.SkeletonX, self.SkeletonY)

        local mx, my = GetRelativeMouse(self.Scale, self.OffsetX, self.OffsetY)

        local button = ClickableButton(0, 0, self.ViewW, self.ViewH, {
            RHeld = self.SetSkeletonXY
        })
        CheckClickableButton(self, button, mx, my)

        lg.circle("line", mx, my, 5)

        local blueprints = skeleton.PartBlueprints
        local currentBP = self:CurrentBlueprint()
        self.ParentBluePrintX = nil
        local spriteSet = CurrentSpriteSet()
        local dx = sheet:getWidth() + 10
        local dy = 10
        local maxX = 0
        for i, bp in ipairs(blueprints) do
            lg.setFont(Font_KBig)
            
            local w, h = 200, 100
            if(dy + h > screenHeight) then
                dy = 10
                dx = maxX + 10
            end

            local sprite = spriteSet[bp.DefSpriteIndex]
            -- draws an individual blueprint
            if(sprite.Quad ~= nil) then
                _, _, w, h = sprite.Quad:getViewport()
                if(dy + h > screenHeight) then
                    dy = 10
                    dx = maxX + 10
                end
                local xsc, ysc = GetBlueprintScale(bp)
                DrawPaperSprite(sprite, CurrentTexture(), dx + sprite.AnchorX, dy + sprite.AnchorY, 0, xsc, ysc)
            end

            if(i == self.BlueprintIndex) then
                if(sprite.Quad ~= nil) then
                    lg.setColor(0, 1, 0)

                    self.CurrentBlueprintX = screenWidth - w
                    self.CurrentBlueprintW = w
                    self.CurrentBlueprintH = h
                end
                lg.setColor(1, 0, 0)
            end
            if(i == currentBP.ParentIndex) then
                lg.setColor(1, 1, 0)
                lg.print("P", dx + 10, dy + 40)
                lg.rectangle("line", dx + w/3, dy + h/3, w/3, h/3)
                lg.setColor(1, 1, 1)

                self.ParentBlueprintX = screenWidth - w
                self.ParentBlueprintY = self.CurrentBlueprintY + self.CurrentBlueprintH + 10
                self.ParentBlueprintW = w
                self.ParentBlueprintH = h
            end
            lg.print(tostring(i) .. " - L " .. bp.DefLayer, dx + 10, dy + 10)
            if(bp.IK) then
                lg.print("IK", dx + 10, dy + 60)
            end
            if(bp.PositionLock) then
                lg.print("PL", dx + 10, dy + 80)
            end
            if(bp.FlippedX or bp.FlippedY) then
                local str = "Flipped "
                if(bp.FlippedX) then
                    str = str .. "X"
                end
                if(bp.FlippedY) then
                    str = str .. "Y"
                end
                lg.print(str, dx + 10, dy + 100)
            end
            lg.rectangle("line", dx, dy, w, h)
            lg.circle("line", dx + sprite.AnchorX, dy + sprite.AnchorY, 5)
            maxX = math.max(maxX, dx + w)

            lg.setColor(1, 1, 1)

            local button = ClickableButton(dx, dy, w, h, {
                Index = i,
                LPressed = self.SelectBlueprint,
                RPressed = self.SelectParent
            })
            CheckClickableButton(self, button, mx, my)

            dy = dy + h + 2
        end

        -- draws the current blueprint in the top right
        if(self.CurrentBlueprintX ~= nil) then
            local sprite = spriteSet[self:CurrentBlueprint().DefSpriteIndex]

            lg.setColor(0, 1, 1)
            lg.rectangle("line", self.CurrentBlueprintX, self.CurrentBlueprintY, self.CurrentBlueprintW, self.CurrentBlueprintH)
            lg.setColor(1, 1, 1)
            local xsc, ysc = GetBlueprintScale(self:CurrentBlueprint())
            DrawPaperSprite(sprite, CurrentTexture(), self.CurrentBlueprintX + sprite.AnchorX, self.CurrentBlueprintY + sprite.AnchorY, 0, xsc, ysc)

            for _, ball in ipairs(currentBP.Hitballs) do
                DrawHitBall(self.CurrentBlueprintX + sprite.AnchorX + ball.X, self.CurrentBlueprintY + sprite.AnchorY + ball.Y, ball.Radius, ball.Flags)
            end

            local button = ClickableButton(self.CurrentBlueprintX, self.CurrentBlueprintY, self.CurrentBlueprintW, self.CurrentBlueprintH, {
                LPressed = self.SetOffset,
                RPressed = self.StartHitball,
            })
            CheckClickableButton(self, button, mx, my)

        end

        -- draws the parent below it
        if(self.ParentBlueprintX ~= nil and blueprints[currentBP.ParentIndex] ~= nil) then
            local sprite = spriteSet[blueprints[currentBP.ParentIndex].DefSpriteIndex]

            lg.setColor(0, 0, 1)
            lg.rectangle("line", self.ParentBlueprintX, self.ParentBlueprintY, self.ParentBlueprintW, self.ParentBlueprintH)
            lg.setColor(1, 1, 1)
            DrawPaperSprite(sprite, CurrentTexture(), self.ParentBlueprintX + sprite.AnchorX, self.ParentBlueprintY + sprite.AnchorY)

            local button = ClickableButton(self.ParentBlueprintX, self.ParentBlueprintY, self.ParentBlueprintW, self.ParentBlueprintH, {
                LPressed = self.SetParentOffset,
            })
            CheckClickableButton(self, button, mx, my)

        end

        -- ball creation
        if(MouseDown[2] and MouseDragX ~= nil) then
            lg.setColor(1, 1, 0)
            lg.circle("line", MouseDragX, MouseDragY, PointDistance(MouseDragX, MouseDragY, mx, my))
            lg.setColor(1, 1, 1)
        end

        lg.pop()
        
        
    end

    -- this is just used for flipping
    function GetBlueprintScale(bp)
        local xsc = 1
        local ysc = 1
        if(bp.FlippedX) then
            xsc = -1
        end
        if(bp.FlippedY) then
            ysc = -1
        end

        return xsc, ysc
    end 

    function prog:DrawSkeleton(x, y)
        local lg = love.graphics
        local skeleton = CurrentSkeleton()
        local frame = Pose(skeleton)

        if(self.SkeletonFrame ~= nil and #self.SkeletonFrame.PartFrames == #frame.PartFrames) then
            frame = self.SkeletonFrame
        end

        self.SkeletonFrame = frame

        local mx, my = GetRelativeMouse(self.Scale, self.OffsetX, self.OffsetY)
        local partFrame = frame.PartFrames[self.BlueprintIndex]

        UpdatePose(frame, skeleton)
        DrawPose(frame, skeleton, CurrentSpriteSet(), CurrentTexture(), x, y)
        DrawPoseHitballs(frame, skeleton, x, y)

        if(not MouseDown[1]) then
            local hitballs = GetPoseHitballs(frame, skeleton)
            local ball = HitballAtPoint(hitballs, mx - x, my - y, 0)
            if(ball ~= nil) then
                self.CurrentBall = ball
                self.CurrentPart = ball.Part
            else
                self.CurrentBall = nil
                self.CurrentPart = nil
            end
        end

        local part = self.CurrentPart
        local ball = self.CurrentBall

        if(MousePressed[1] and part ~= nil) then
            self.CurrentPartStartRotation = part.Rotation
            self.CurrentPartStartCX = part.CX
            self.CurrentPartStartCY = part.CY
            self.CurrentPartStartXScale = part.XScale or 1
            self.CurrentPartStartYScale = part.YSCale or 1
            self.PartDragMX = mx
            self.PartDragMY = my
        end

        if(part ~= nil) then
            lg.setColor(1, 1, 0)
            lg.circle("line", ball.X + x, ball.Y + y, ball.Radius)

            if(MouseDown[1]) then
                local px, py = part.CX + x + skeleton.X, part.CY + y + skeleton.Y
                lg.circle("line", px, py, 20)
                lg.line(px, py, mx, my)

                -- shift for translate
                if(love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
                    
                -- ctrl for scale
                elseif(love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
                    local dx, dy = RotatePoint(mx - self.PartDragMX, my - self.PartDragMY, -part.CRotation)
                    -- dy = -dy
                    part.XScale = self.CurrentPartStartXScale * ((ball.Radius+dx) / ball.Radius)
                    part.YScale = self.CurrentPartStartYScale * ((ball.Radius+dy) / ball.Radius)
                -- no key for rotate
                else
                    local startangle = math.atan2(self.PartDragMY - py, self.PartDragMX - px)
                    local newangle = math.atan2(my - py, mx - px)

                    part.Rotation = self.CurrentPartStartRotation + (newangle - startangle)
                end
            end
        end
    end

    function prog:Update()
    
    end

    function prog:CurrentBlueprint()
        if(self.BlueprintIndex == nil) then
            return nil
        end
        local skeleton = CurrentSkeleton()
        return skeleton.PartBlueprints[self.BlueprintIndex]
    end

    function prog:CreateBlueprint()
        local skeleton = CurrentSkeleton()
        self.BlueprintIndex = #skeleton.PartBlueprints + 1
        skeleton.PartBlueprints[self.BlueprintIndex] = PartBlueprint(nil, 0, 0, self.NextSpriteIndex)
        self.NextSpriteIndex = self.NextSpriteIndex + 1
        if(self.NextSpriteIndex > #CurrentSpriteSet()) then
            self.NextSpriteIndex = 1
        end
    end

    function prog:KeyPressed(key, scancode, isrepeat)
        local skeleton = CurrentSkeleton()
        local bluePrint = self:CurrentBlueprint()
        local spriteSet = CurrentSpriteSet()
        if(key == "n") then
            self:CreateBlueprint()
        elseif(key == "left" and bluePrint ~= nil) then
            bluePrint.DefSpriteIndex = ((bluePrint.DefSpriteIndex - 2) % #spriteSet) + 1
        elseif(key == "right" and bluePrint ~= nil) then
            bluePrint.DefSpriteIndex = (bluePrint.DefSpriteIndex % #spriteSet) + 1
        elseif(key == "up" and self.BlueprintIndex ~= nil) then
            self.BlueprintIndex = ((self.BlueprintIndex - 2) % #skeleton.PartBlueprints) + 1
        elseif(key == "down" and self.BlueprintIndex ~= nil) then
            self.BlueprintIndex = (self.BlueprintIndex % #skeleton.PartBlueprints) + 1
        elseif(key == "s") then
            if(love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
                Skeletons[#Skeletons + 1] = PaperSkeleton()
                prog.CurrentBlueprintX = nil
                prog.ParentBlueprintX = nil
                SkeletonIndex = (SkeletonIndex % #Skeletons) + 1
            elseif(love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
                SaveSkeleton(skeleton, SkeletonIndex)
            else
                prog.CurrentBlueprintX = nil
                prog.ParentBlueprintX = nil
                SkeletonIndex = (SkeletonIndex % #Skeletons) + 1
            end
        elseif(key == "i" and bluePrint ~= nil) then
            bluePrint.IK = not bluePrint.IK
        elseif(key == "p" and bluePrint ~= nil) then
            bluePrint.PositionLock = not bluePrint.PositionLock
        -- flip X or Y (with shift held)
        elseif(key == "f") then
            if(love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
                    bluePrint.FlippedY = not bluePrint.FlippedY
            else
                bluePrint.FlippedX = not bluePrint.FlippedX
            end
        -- shift + . or , will fine-tune the layering
        elseif(key == "," and bluePrint ~= nil) then
            if(love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
                bluePrint.DefLayer = bluePrint.DefLayer - 0.1
            else
                bluePrint.DefLayer = bluePrint.DefLayer - 1
            end
            
        elseif(key == "." and bluePrint ~= nil) then
            if(love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
                bluePrint.DefLayer = bluePrint.DefLayer + 0.1
            else
                bluePrint.DefLayer = bluePrint.DefLayer + 1
            end
        end

    end

    function prog:MouseReleased(mb)
        local mx, my = GetRelativeMouse(self.Scale, self.OffsetX, self.OffsetY)
        local skeleton = CurrentSkeleton()
        local currentBP = self:CurrentBlueprint()
        if(mb == 2 and MouseDragX ~= nil) then
            local spriteSet = CurrentSpriteSet()
            local sprite = spriteSet[currentBP.DefSpriteIndex]
            local _, _, sw, sh = sprite.Quad:getViewport()
            local clickX = MouseDragX - self.CurrentBlueprintX - sprite.AnchorX
            local clickY = MouseDragY - self.CurrentBlueprintY - sprite.AnchorY
            local radius = math.max(PointDistance(MouseDragX, MouseDragY, mx, my), math.min(sw, sh)/4)
            local deleted = false

            local i = 1
            while(i <= #currentBP.Hitballs) do
                local ball = currentBP.Hitballs[i]
                if(PointDistance(ball.X, ball.Y, clickX, clickY) <= math.min(sw, sh)/4) then
                    table.remove(currentBP.Hitballs, i)
                    i = i - 1
                    deleted = true
                end
                i = i + 1
            end

            if(not deleted) then
                table.insert(currentBP.Hitballs, Hitball(clickX, clickY, radius, HITBALL_HITTABLE))
            end

            MouseDragX = nil
            MouseDragY = nil

        end
    end

    function prog:SetOffset(button, mx, my)
        local currentBP = self:CurrentBlueprint()
        local spriteSet = CurrentSpriteSet()
        local sprite = spriteSet[currentBP.DefSpriteIndex]
        currentBP.X = mx - self.CurrentBlueprintX - sprite.AnchorX
        currentBP.Y = my - self.CurrentBlueprintY - sprite.AnchorY
    end

    function prog:SetParentOffset(button, mx, my)
        local skeleton = CurrentSkeleton()
        local currentBP = self:CurrentBlueprint()
        local parent = skeleton.PartBlueprints[currentBP.ParentIndex]
        local spriteSet = CurrentSpriteSet()
        local sprite = spriteSet[parent.DefSpriteIndex]
        currentBP.X = mx - self.ParentBlueprintX - sprite.AnchorX
        currentBP.Y = my - self.ParentBlueprintY - sprite.AnchorY
    end

    function prog:StartHitball(button, mx, my)
        MouseDragX = mx
        MouseDragY = my
    end

    function prog:SetSkeletonXY(button, mx, my)
        local skeleton = CurrentSkeleton()
        skeleton.X = mx - button.W/2
        skeleton.Y = my - button.H
    end

    function prog:SelectBlueprint(button, mx, my)
        if(self.BlueprintIndex == button.Index) then
            self:IncrementSprite()
        else
            self.BlueprintIndex = button.Index
        end
    end

    function prog:SelectParent(button, mx, my)
        local currentBP = self:CurrentBlueprint()
        if(currentBP.ParentIndex == button.Index) then
            currentBP.ParentIndex = nil
        elseif(self.BlueprintIndex == button.Index) then
            self:DecrementSprite()
        else
            currentBP.ParentIndex = button.Index
        end
    end

    function prog:IncrementSprite()
        local bluePrint = self:CurrentBlueprint()
        local spriteSet = CurrentSpriteSet()
        bluePrint.DefSpriteIndex = (bluePrint.DefSpriteIndex % #spriteSet) + 1
    end

    function prog:DecrementSprite()
        local bluePrint = self:CurrentBlueprint()
        local spriteSet = CurrentSpriteSet()
        bluePrint.DefSpriteIndex = ((bluePrint.DefSpriteIndex - 2) % #spriteSet) + 1
    end

    return prog
end