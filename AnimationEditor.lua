require "PartBlueprint"

function AnimationEditor()
    local prog = BlankProgram()

    prog.Scale = 0.5
    prog.OffsetX = 100
    prog.OffsetY = 100

    BlueprintIndex = nil
    local skeleton = CurrentSkeleton()
    if(#skeleton.PartBlueprints > 0) then
        BlueprintIndex = 1
    end

    DisplayHitballs = true

    -- copied from blueprint editor
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

    function prog:Draw()
        
        local lg = love.graphics
        lg.push("all")

        lg.clear(0.4, 0.4, 0.4)

        lg.scale(self.Scale, self.Scale)
        lg.translate(self.OffsetX, self.OffsetY)

        local screenWidth = ScreenWidth/self.Scale - self.OffsetX
        local screenHeight = ScreenHeight/self.Scale - self.OffsetY

        

        local sheet = CurrentTexture()
        self.ViewCenterX, self.ViewCenterY, self.ViewW, self.ViewH = sheet:getWidth()/2, sheet:getHeight()/2, sheet:getWidth(), sheet:getHeight()
        
        -- the basic rectangle for the sheet
        lg.rectangle("line", 0, 0, sheet:getWidth(), sheet:getHeight())
        lg.line(0, self.ViewCenterY, self.ViewW, self.ViewCenterY)
        lg.line(self.ViewCenterX, 0, self.ViewCenterX, self.ViewH)

        self.SkeletonX, self.SkeletonY = self.ViewCenterX, self.ViewCenterY
        if(skeleton.X ~= nil) then
            self.SkeletonX, self.SkeletonY = self.ViewCenterX, self.ViewH
        end
        --self:DrawSkeleton(self.SkeletonX, self.SkeletonY)
        local x = self.SkeletonX
        local y = self.SkeletonY
        
        local skeleton = CurrentSkeleton()
        local frame = Pose(skeleton)

        if(self.SkeletonFrame ~= nil and #self.SkeletonFrame.PartFrames == #frame.PartFrames) then
            frame = self.SkeletonFrame
        end

        self.SkeletonFrame = frame

        local mx, my = GetRelativeMouse(self.Scale, self.OffsetX, self.OffsetY)
        
        -- the MEAT of the thing
        DrawAndPoseSkeleton(skeleton, frame, x, y, mx, my)

        -- Special features

        


        lg.pop()
    end




    return prog

end