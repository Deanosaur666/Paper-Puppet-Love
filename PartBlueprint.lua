
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
        Hitballs = {}
    }
end

function PartBlueprintEditor()
    local prog = BlankProgram()
    prog.Scale = 0.5
    prog.OffsetX = 100
    prog.OffsetY = 100

    prog.PartIndex = nil

    function prog:Draw()
        local lg = love.graphics
        lg.push("all")

        lg.clear(0.4, 0.4, 0.4)

        local str = "Current Skeleton: " .. SkeletonIndex
        lg.print(str, 10, 0)

        local skeleton = CurrentSkeleton()

        str = "Current Part Blueprint: " .. tostring(self.PartIndex or 0) .. "/" .. tostring(#skeleton.PartBlueprints)
        lg.print(str, 10, 20)

        lg.scale(self.Scale, self.Scale)
        lg.translate(self.OffsetX, self.OffsetY)

        local screenHeight = ScreenHeight/self.Scale - self.OffsetY*2

        local sheet = CurrentTexture()

        lg.rectangle("line", 0, 0, sheet:getWidth(), sheet:getHeight())

        local mx, my = GetRelativeMouse(self.Scale, self.OffsetX, self.OffsetY)

        lg.circle("line", mx, my, 5)

        lg.pop()
        
        
    end

    function prog:Update()
    
    end

    function prog:KeyPressed(key, scancode, isrepeat)

    end

    function prog:MousePressed(mb)

    end

    return prog
end