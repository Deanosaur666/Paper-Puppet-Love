require "PartBlueprint"

-- TODO:
--[[
    Set the "Idle Pose" with a button  (I)
    Create a new frame  (Button or N)
    Change Animations (List of buttons)
    Change frames with arrow keys (left right)
    Change frame duration with UP/Down




]]

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

    CurrentAnimationIndex = 0

    function prog:Draw()
        
        local skeleton = CurrentSkeleton()
        local frame = Pose(skeleton)

        prog.CurrentAnimation = skeleton.Animations[CurrentAnimationIndex]

        local lg = love.graphics
        lg.push("all")

        lg.clear(0.4, 0.4, 0.4)

        lg.setFont(Font_K)
        local str = "Current Skeleton: " .. SkeletonIndex
        lg.print(str, 10, 0)

        local aName = "None"
        if(prog.CurrentAnimation ~= nil) then
            aName = prog.CurrentAnimation.Name
        end
        local str = "Current Animation: " .. aName
        lg.print(str, 10, 20)
        


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
        
        

        if(self.SkeletonFrame ~= nil and #self.SkeletonFrame.PartFrames == #frame.PartFrames) then
            frame = self.SkeletonFrame
        end

        self.SkeletonFrame = frame

        local mx, my = GetRelativeMouse(self.Scale, self.OffsetX, self.OffsetY)
        
        -- the MEAT of the thing
        DrawAndPoseSkeleton(skeleton, frame, x, y, mx, my)

        -- Special features

        -- Animation lis
        local dy = ScreenHeight/5 
        local dx = ScreenWidth/5
        local y = 20
        local x = sheet:getWidth() + 10

        local w = ScreenWidth/4
        local h = ScreenHeight/7

        lg.setFont(Font_KBig)

        lg.setColor(1, 1, 1)
        PrintCentered("Select Animation", x + w/2, y + h/2)
        y = y + dy

        for i, anim in ipairs(skeleton.Animations) do
            local button = ClickableButton(x, y, w, h, {
                LPressed = prog.SetAnimation,
                Animation = anim,
                Index = i
            })
            CheckClickableButton(self, button, mx, my)

            lg.setColor(1, 1, 0)
            if(i == CurrentAnimationIndex) then
                lg.setColor(1, 0, 0)
            end
            lg.rectangle("fill", x, y, w, h)
            lg.setColor(0, 0, 0)
            lg.rectangle("line", x, y, w, h)
            PrintCentered(anim.Name, x + w/2, y + h/2)
            y = y + dy

            if(y > prog.ViewW - h) then
                y = 20 + dy
                x = x + w + 10
            end
        end

        local newButton = ClickableButton(x, y, w, h, {
            LPressed = prog.NewAnimation,
        })
        CheckClickableButton(self, newButton, mx, my)
        lg.setColor(1, 1, 1)
        lg.rectangle("fill", x, y, w, h)
        lg.setColor(0, 0, 0)
        lg.rectangle("line", x, y, w, h)
        PrintCentered("(NEW Animation)", x + w/2, y + h/2)


        lg.pop()
    end

    function prog:SetAnimation(button, mx, my)
        CurrentAnimationIndex = button.Index
    end

    function prog:NewAnimation(button, mx, my)
        TextEntryOn = true
        TextEntered = ""
        TextEntryFinished = prog.CreateAnimation
    end

    function prog:CreateAnimation()
        if(TextEntered == "") then
            prog:NewAnimation()
            return
        end
    
        local skeleton = CurrentSkeleton()
        local anim = Animation(TextEntered)
        table.insert(skeleton.Animations, anim)

        CurrentAnimationIndex = #skeleton.Animations
        
        
        SaveSkeleton()
    end


    return prog

end