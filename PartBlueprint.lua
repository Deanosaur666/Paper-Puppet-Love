
-- paper part blueprint has:
-- parent (a hand is parented to an arm, which is parented to upper arm, which is parented to body)
-- parent offset ()
-- ik flag (for hands and feet that can drag limbs)
-- position lock flag (for elbows and stuff that can't be moved from anchor)

-- TODO: add hit balls to part blueprints

-- hitball flags
HITBALL_HITTABLE = 1
HITBALL_ACTIVE = 2

function Hitball(x, y, radius, defFlags)
    return {
        X = x,
        Y = y,
        Radius = radius,
        DefFlags = defFlags
    }
end

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

    prog.CurrentBlueprintX = nil
    prog.CurrentBlueprintY = 0
    prog.CurrentBlueprintW = 0
    prog.CurrentBlueprintH = 0

    prog.SkeletonX = 0
    prog.SkeletonY = 0

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

        lg.rectangle("line", 0, 0, sheet:getWidth(), sheet:getHeight())

        local mx, my = GetRelativeMouse(self.Scale, self.OffsetX, self.OffsetY)

        lg.circle("line", mx, my, 5)

        local blueprints = skeleton.PartBlueprints
        local currentBP = self:CurrentBlueprint()
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
                DrawPaperSprite(sprite, CurrentTexture(), dx - sprite.AnchorX, dy - sprite.AnchorY, 0, xsc, ysc)
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
                lg.setColor(0, 1, 0)
                lg.print("P", dx + 10, dy + 40)
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

            dy = dy + h + 2
        end

        -- draws the current blueprint in the top right
        if(self.CurrentBlueprintX ~= nil) then
            local sprite = spriteSet[self:CurrentBlueprint().DefSpriteIndex]

            lg.setColor(0, 1, 1)
            lg.rectangle("line", self.CurrentBlueprintX, self.CurrentBlueprintY, self.CurrentBlueprintW, self.CurrentBlueprintH)
            lg.setColor(1, 1, 1)
            local xsc, ysc = GetBlueprintScale(self:CurrentBlueprint())
            DrawPaperSprite(sprite, CurrentTexture(), self.CurrentBlueprintX - sprite.AnchorX, self.CurrentBlueprintY - sprite.AnchorY, 0, xsc, ysc)

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

    function prog:DrawSkeleton()
        local skeleton = CurrentSkeleton()
        local blueprints = {}
        for _, bp in pairs(skeleton.PartBlueprints) do
            table.insert(blueprints, bp)
        end
        table.sort(blueprints, function(a, b) return a.DefLayer > b.DefLayer end)
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
        skeleton.PartBlueprints[self.BlueprintIndex] = PartBlueprint(nil, 0, 0, 1)
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
            end
            SkeletonIndex = (SkeletonIndex % #Skeletons) + 1
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
        elseif(key == "," and bluePrint ~= nil) then
            bluePrint.DefLayer = bluePrint.DefLayer - 1
        elseif(key == "." and bluePrint ~= nil) then
            bluePrint.DefLayer = bluePrint.DefLayer + 1
        elseif(tonumber(key) and bluePrint ~= nil) then
            local keyNum = tonumber(key)
            local pIndex = bluePrint.ParentIndex or 0
            local newIndex = tonumber(tostring(pIndex) .. key)
            if(newIndex == 0 or newIndex > #skeleton.PartBlueprints) then
                bluePrint.ParentIndex = nil
            else
                bluePrint.ParentIndex = newIndex
            end
        end

    end

    function prog:MousePressed(mb)

    end

    return prog
end