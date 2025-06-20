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

    prog.LeftPanelWidth = 200
    prog.BottomPanelHeight = 150

    prog.Scale = 0.5
    prog.OffsetX = prog.LeftPanelWidth + 20
    prog.OffsetY = 20

    DisplayHitballs = true

    prog.ViewCenterX = 0
    prog.ViewCenterY = 0

    prog.ViewW = 0
    prog.ViewH = 0

    CurrentAnimationIndex = 0
    CurrentFrameIndex = 0

    function prog:Draw()
        
        local skeleton = CurrentSkeleton()
        local frame = Pose(skeleton)

        prog.CurrentAnimation = skeleton.Animations[CurrentAnimationIndex]
        local anim = prog.CurrentAnimation

        local lg = love.graphics
        lg.push("all")

        DrawEditorBackground()
        lg.setLineWidth(4)

        lg.translate(self.OffsetX, self.OffsetY)
        lg.scale(self.Scale, self.Scale)

        local screenWidth = ScreenWidth/self.Scale - self.OffsetX
        local screenHeight = ScreenHeight/self.Scale - self.OffsetY

        

        local sheet = CurrentTexture()
        self.ViewCenterX, self.ViewCenterY, self.ViewW, self.ViewH = sheet:getWidth()/2, sheet:getHeight()/2, sheet:getWidth(), sheet:getHeight()

        local viewW = sheet:getWidth()
        local viewH = sheet:getHeight()
        
        -- the basic rectangle for the sheet
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
        --self:DrawSkeleton(self.SkeletonX, self.SkeletonY)
        local x = self.SkeletonX
        local y = self.SkeletonY
        
        
        if(anim ~= nil and anim.Frames[CurrentFrameIndex] ~= nil) then
            self.SkeletonFrame = anim.Frames[CurrentFrameIndex]
        end

        if(self.SkeletonFrame ~= nil and #self.SkeletonFrame.PartFrames == #frame.PartFrames) then
            frame = self.SkeletonFrame
        end

        self.SkeletonFrame = frame

        

        local mx, my = GetRelativeMouse(self.Scale, self.OffsetX, self.OffsetY)
        
        -- the MEAT of the thing
        DrawAndPoseSkeleton(skeleton, frame, x, y, mx, my)

        if(anim ~= nil and anim.Frames[CurrentFrameIndex] ~= nil) then
            anim.Frames[CurrentFrameIndex] = self.SkeletonFrame
        end

        lg.pop()

        self:DrawControlPanels()
    end

    function prog:DrawControlPanels()
        local lg = love.graphics
        local mx, my = GetRelativeMouse(1, 0, 0)
        local skeleton = CurrentSkeleton()
        local frame = self.SkeletonFrame

        lg.setLineWidth(3)

        DarkGray()
        lg.rectangle("fill", 0, 0, self.LeftPanelWidth, ScreenHeight)
        lg.setColor(0.5, 0.5, 0.5)
        lg.rectangle("fill", self.LeftPanelWidth, ScreenHeight - self.BottomPanelHeight, ScreenWidth - self.LeftPanelWidth, self.BottomPanelHeight)

        lg.setColor(1, 1, 1)
        lg.rectangle("line", 0, 0, self.LeftPanelWidth, ScreenHeight)
        lg.rectangle("line", self.LeftPanelWidth, ScreenHeight - self.BottomPanelHeight, ScreenWidth - self.LeftPanelWidth, self.BottomPanelHeight)

        White()
        lg.setFont(Font_K)
        local str = "Current Skeleton: " .. SkeletonIndex
        lg.print(str, 10, 0)

        local aName = "None"
        if(prog.CurrentAnimation ~= nil) then
            aName = prog.CurrentAnimation.Name
        end
        local str = "Current Animation: " .. aName
        lg.print(str, 10, 20)

        local totalFrames = 0
        if(anim ~= nil) then
            totalFrames = #anim.Frames
        end

        local str = "Current Frame: " .. tostring(CurrentFrameIndex) .. "/" .. totalFrames
        lg.print(str, 10, 40)

        -- Special features

        -- Animation list
        local dy = ScreenHeight/5 
        local dx = ScreenWidth/5
        local y = 20
        local x = 20

        local w = ScreenWidth/4
        local h = ScreenHeight/7

        lg.setFont(Font_KBig)

        lg.setColor(1, 1, 1)
        PrintCentered("Select Animation", x + w/2, y + h/2)

        local deleteAnimButton = ClickableButton(x + w, y, 300, 100, {
            LPressed = self.DeleteAnimation,
        })
        DrawCheckButton(self, deleteAnimButton, "Delete Animation", mx, my)

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


        

        local saveAnimButton = ClickableButton(10, 20, 300, 120, {
            LPressed = SaveSkeleton,
        })
        DrawCheckButton(self, saveAnimButton, "Save Skeleton", mx, my)

        local newFrameButton = ClickableButton(320, 20, 300, 120, {
            LPressed = prog.NewFrame,
        })
        DrawCheckButton(self, newFrameButton, "New Frame", mx, my)

        local delFrameButton = ClickableButton(640, 20, 300, 120, {
            LPressed = prog.DeleteFrame,
        })
        DrawCheckButton(self, delFrameButton, "Delete Frame", mx, my)

        local copyFrameButton = ClickableButton(960, 20, 300, 120, {
            LPressed = prog.CopyFrame,
        })
        DrawCheckButton(self, copyFrameButton, "Copy Frame", mx, my)

        local pasteFrameButton = ClickableButton(960 + 320, 20, 300, 120, {
            LPressed = prog.PasteFrame,
        })
        DrawCheckButton(self, pasteFrameButton, "Paste Frame", mx, my)
    end

    function prog:SetAnimation(button, mx, my)
        CurrentAnimationIndex = button.Index

        CurrentFrameIndex = 1

    end

    function prog:DeleteAnimation(button, mx, my)
        if(CurrentAnimationIndex ~= 0) then 
            table.remove(skeleton.Animations, CurrentAnimationIndex)
            CurrentAnimationIndex = 0

        end
        
    end

    function prog:NewAnimation(button, mx, my)
        TextEntryOn = true
        TextEntered = ""
        TextEntryFinished = prog.CreateAnimation
    end

    function prog:NewFrame()
        if(CurrentAnimationIndex ~= 0) then 
            local anim = prog.CurrentAnimation
            table.insert(anim.Frames, CopyPose(anim.Frames[CurrentFrameIndex] or BlankPose()))
            CurrentFrameIndex = CurrentFrameIndex + 1
        end
    end

    function prog:DeleteFrame()
        if(CurrentAnimationIndex ~= 0) then 
            local anim = prog.CurrentAnimation
            table.remove(anim.Frames, CurrentFrameIndex)
            CurrentFrameIndex = math.max(1, CurrentFrameIndex - 1)
            
        end
    end

    function prog:CopyFrame()
        if(CurrentAnimationIndex ~= 0) then 
            local anim = prog.CurrentAnimation
            prog.ClipboardPose = CopyPose(anim.Frames[CurrentFrameIndex])
        end
    end

    function prog:PasteFrame()
        if(CurrentAnimationIndex ~= 0 and prog.ClipboardPose ~= nil) then 
            local anim = prog.CurrentAnimation
            anim.Frames[CurrentFrameIndex] = CopyPose(prog.ClipboardPose)
        end
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

        CurrentFrameIndex = 1

        table.insert(anim.Frames, BlankPose())
        
        
        --SaveSkeleton()
    end

    function prog:Update()
        UpdateZoomAndOffset(self)
    end

    function prog:KeyPressed(key, scancode, isrepeat)
        local totalFrames = 0
        if(prog.CurrentAnimation ~= nil) then
            totalFrames = #prog.CurrentAnimation.Frames
        end
       
       
        if(key == "right") then
            CurrentFrameIndex = CurrentFrameIndex + 1
            if(CurrentFrameIndex > totalFrames) then
                CurrentFrameIndex = 1
            end
        elseif(key == "left") then
            CurrentFrameIndex = CurrentFrameIndex - 1
            if(CurrentFrameIndex < 1) then
                CurrentFrameIndex = totalFrames
            end
        elseif(key == "n") then
            prog:NewFrame()
        elseif(key == 'b') then
            DisplayHitballs = not DisplayHitballs
        end
    end


    return prog

end