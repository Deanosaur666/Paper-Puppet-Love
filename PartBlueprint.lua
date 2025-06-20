
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
    prog.OffsetX = 20
    prog.OffsetY = 20

    BlueprintIndex = nil
    local skeleton = CurrentSkeleton()
    if(#skeleton.PartBlueprints > 0) then
        BlueprintIndex = 1
    end

    DisplayHitballs = true

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

    function prog:Draw()
        local lg = love.graphics
        lg.push("all")

        DrawEditorBackground()
        lg.setLineWidth(4)

        lg.translate(self.OffsetX, self.OffsetY)
        lg.scale(self.Scale, self.Scale)

        local screenRight = ScreenWidth/self.Scale - self.OffsetX/self.Scale - 20

        local screenTop = (20)/self.Scale - self.OffsetY/self.Scale
        local screenBottom = ScreenHeight/self.Scale - self.OffsetY/self.Scale - 20

        prog.CurrentBlueprintY = screenTop

        local sheet = CurrentTexture()
        local viewW = sheet:getWidth()
        local viewH = sheet:getHeight()

        self.ViewCenterX, self.ViewCenterY, self.ViewW, self.ViewH = sheet:getWidth()/2, sheet:getHeight()/2, sheet:getWidth(), sheet:getHeight()

        DarkGray()
        lg.rectangle("fill", 0, 0, viewW, viewH)
        lg.setColor(1, 1, 1)
        lg.rectangle("line", 0, 0, viewW, viewH)

        lg.line(0, self.ViewCenterY, self.ViewW, self.ViewCenterY)
        lg.line(self.ViewCenterX, 0, self.ViewCenterX, self.ViewH)

        self.SkeletonX, self.SkeletonY = self.ViewCenterX, self.ViewCenterY
        if(skeleton.X ~= nil) then
            self.SkeletonX, self.SkeletonY = self.ViewCenterX, self.ViewH
        end
        self:DrawSkeleton(self.SkeletonX, self.SkeletonY)

        local mx, my = GetRelativeMouse(self.Scale, self.OffsetX, self.OffsetY)

        local button = ClickableButton(0, 0, self.ViewW, self.ViewH, {
            MHeld = self.SetSkeletonXY
        })
        CheckClickableButton(self, button, mx, my)

        lg.circle("line", mx, my, 5)

        local blueprints = skeleton.PartBlueprints
        local currentBP = self:CurrentBlueprint()
        self.ParentBluePrintX = nil
        local spriteSet = CurrentSpriteSet()
        local dx = sheet:getWidth() + 20
        local dy = screenTop
        local maxX = 0
        for i, bp in ipairs(blueprints) do
            lg.setFont(Font_KBig)
            
            local w, h = 200, 100
            if(dy + h > screenBottom) then
                dy = screenTop
                dx = maxX + 20
            end

            local sprite = spriteSet[bp.DefSpriteIndex]
            -- draws an individual blueprint
            if(sprite.Quad ~= nil) then
                _, _, w, h = sprite.Quad:getViewport()
                if(dy + h > screenBottom) then
                    dy = screenTop
                    dx = maxX + 20
                end
                local xsc, ysc = GetBlueprintScale(bp)
                DrawPaperSprite(sprite, CurrentTexture(), dx + sprite.AnchorX, dy + sprite.AnchorY, 0, xsc, ysc)
            end

            if(i == BlueprintIndex) then
                if(sprite.Quad ~= nil) then
                    lg.setColor(0, 1, 0)

                    self.CurrentBlueprintX = screenRight - w
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

                self.ParentBlueprintX = screenRight - w
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
                RPressed = self.SelectParent_Or_CopyHitBall
            })
            CheckClickableButton(self, button, mx, my)

            dy = dy + h + 20
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

    function prog:DrawSkeleton(x, y)
        local lg = love.graphics
        local skeleton = CurrentSkeleton()
        local frame = Pose(skeleton)

        if(self.SkeletonFrame ~= nil and #self.SkeletonFrame.PartFrames == #frame.PartFrames) then
            frame = self.SkeletonFrame
        end

        self.SkeletonFrame = frame

        local mx, my = GetRelativeMouse(self.Scale, self.OffsetX, self.OffsetY)
        
        DrawAndPoseSkeleton(skeleton, frame, x, y, mx, my)
    end

    function prog:Update()
        UpdateZoomAndOffset(self)
    end

    function prog:CurrentBlueprint()
        if(BlueprintIndex == nil) then
            return nil
        end
        local skeleton = CurrentSkeleton()
        return skeleton.PartBlueprints[BlueprintIndex]
    end

    function prog:CreateBlueprint()
        local skeleton = CurrentSkeleton()
        BlueprintIndex = #skeleton.PartBlueprints + 1
        skeleton.PartBlueprints[BlueprintIndex] = PartBlueprint(nil, 0, 0, self.NextSpriteIndex)
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
        elseif(key == 'b') then
            DisplayHitballs = not DisplayHitballs
        elseif(key == "left" and bluePrint ~= nil) then
            bluePrint.DefSpriteIndex = ((bluePrint.DefSpriteIndex - 2) % #spriteSet) + 1
        elseif(key == "right" and bluePrint ~= nil) then
            bluePrint.DefSpriteIndex = (bluePrint.DefSpriteIndex % #spriteSet) + 1
        elseif(key == "up" and BlueprintIndex ~= nil) then
            BlueprintIndex = tablePrevIndex(BlueprintIndex, skeleton.PartBlueprints)
        elseif(key == "down" and BlueprintIndex ~= nil) then
            BlueprintIndex = tableNextIndex(BlueprintIndex, skeleton.PartBlueprints)
        elseif(key == "s") then
            if(love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
                SaveSkeleton(skeleton, SkeletonIndex)
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
        if(love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
            local skeleton = CurrentSkeleton()
            skeleton.X = mx - button.W/2
            skeleton.Y = my - button.H
        end
    end

    function prog:SelectBlueprint(button, mx, my)
        if(BlueprintIndex == button.Index) then
            self:IncrementSprite()
        else
            BlueprintIndex = button.Index
        end
    end

    function prog:SelectParent_Or_CopyHitBall(button, mx, my)
        local currentBP = self:CurrentBlueprint()
        if(love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")) then
            CopyBlueprintHitballs(currentBP, button.Index)
        else
            if(currentBP.ParentIndex == button.Index) then
                currentBP.ParentIndex = nil
            elseif(BlueprintIndex == button.Index) then
                self:DecrementSprite()
            else
                currentBP.ParentIndex = button.Index
            end
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

function CopyBlueprintHitballs(bp, copyIndex)
    bp.Hitballs = CurrentSkeleton().PartBlueprints[copyIndex].Hitballs
end