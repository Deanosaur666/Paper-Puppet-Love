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
    prog.BottomPanelHeight = 120

    prog.LeftPanelYScroll = 10

    prog.Scale = 0.5
    prog.OffsetX = prog.LeftPanelWidth + 20
    prog.OffsetY = 20

    prog.TimeLineStart = 1

    DisplayHitballs = true

    prog.ViewCenterX = 0
    prog.ViewCenterY = 0

    prog.ViewW = 0
    prog.ViewH = 0

    CurrentAnimationIndex = 0
    CurrentFrameIndex = 0

    prog.OnionSkinPrev = true
    prog.OnionSkinNext = false

    prog.Playing = false
    prog.Looping = false
    prog.FrameTimeLeft = 0
    prog.PlayTime = 0

    function prog:Draw()
        
        local skeleton = CurrentSkeleton()
        local frame = Pose(skeleton)

        self.CurrentAnimation = skeleton.Animations[CurrentAnimationIndex]
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
        
        -- onion skin
        local prevFrame = nil
        if(anim ~= nil) then
            prevFrame = anim.Frames[CurrentFrameIndex - 1]
        end

        local nextFrame = nil
        if(anim ~= nil) then
            nextFrame = anim.Frames[CurrentFrameIndex + 1]
        end

        if(prevFrame ~= nil and self.OnionSkinPrev) then
            lg.setColor(1, 0.9, 0.9, 0.5)
            DrawPose(prevFrame, skeleton, CurrentSpriteSet(), CurrentTexture(), x, y)
        end

        if(nextFrame ~= nil and self.OnionSkinNext) then
            lg.setColor(0.5, 0.5, 1, 0.4)
            DrawPose(nextFrame, skeleton, CurrentSpriteSet(), CurrentTexture(), x, y)
        end

        lg.setColor(1, 1, 1, 1)

        -- the MEAT of the thing
        DrawAndPoseSkeleton(skeleton, frame, x, y, mx, my)

        if(anim ~= nil and anim.Frames[CurrentFrameIndex] ~= nil) then
            anim.Frames[CurrentFrameIndex] = self.SkeletonFrame
        end

        lg.pop()

        self:DrawControlPanels()
    end

    function prog:DrawControlPanels()

        if(self.Playing) then
            self:PlayAnimationStep()
        end

        local lg = love.graphics

        lg.push("all")

        local mx, my = GetRelativeMouse(1, 0, 0)
        local skeleton = CurrentSkeleton()
        local frame = self.SkeletonFrame
        local anim = prog.CurrentAnimation

        lg.setLineWidth(3)

        
        -- draw bottom panel background
        lg.setColor(0.5, 0.5, 0.5)
        lg.rectangle("fill", self.LeftPanelWidth, ScreenHeight - self.BottomPanelHeight, ScreenWidth - self.LeftPanelWidth, self.BottomPanelHeight)
        lg.setColor(1, 1, 1)
        lg.rectangle("line", self.LeftPanelWidth, ScreenHeight - self.BottomPanelHeight, ScreenWidth - self.LeftPanelWidth, self.BottomPanelHeight)

        lg.setFont(Font_Consolas16)

        -- frame buttons

        local w = self.LeftPanelWidth * 0.4
        local dx = w + 10
        local h = 30
        local x = self.LeftPanelWidth + 10
        local y = ScreenHeight - self.BottomPanelHeight + 10

        local playButton = ClickableButton(x, y, w, h, {
            Looping = false,
            LPressed = self.PlayAnimation,
        })
        if(self.Playing and not self.Looping) then
            DrawCheckButton(self, playButton, "Play", mx, my, 1, 0, 0)
        else
            DrawCheckButton(self, playButton, "Play", mx, my)
        end

        x = x + dx

        local playLoopButton = ClickableButton(x, y, w, h, {
            Looping = true,
            LPressed = self.PlayAnimation,
        })
        if(self.Playing and self.Looping) then
            DrawCheckButton(self, playLoopButton, "Loop", mx, my, 1, 0, 0)
        else
            DrawCheckButton(self, playLoopButton, "Loop", mx, my)
        end

        x = x + dx

        local saveAnimButton = ClickableButton(x, y, w, h, {
            LPressed = SaveSkeleton,
        })
        DrawCheckButton(self, saveAnimButton, "Save", mx, my)

        x = x + dx

        local newFrameButton = ClickableButton(x, y, w, h, {
            LPressed = prog.NewFrame,
        })
        DrawCheckButton(self, newFrameButton, "New", mx, my)

        x = x + dx

        local delFrameButton = ClickableButton(x, y, w, h, {
            LPressed = prog.DeleteFrame,
        })
        DrawCheckButton(self, delFrameButton, "Delete", mx, my)

        x = x + dx

        local copyFrameButton = ClickableButton(x, y, w, h, {
            LPressed = prog.CopyFrame,
        })
        DrawCheckButton(self, copyFrameButton, "Copy", mx, my)

        x = x + dx

        local pasteFrameButton = ClickableButton(x, y, w, h, {
            LPressed = prog.PasteFrame,
        })
        DrawCheckButton(self, pasteFrameButton, "Paste", mx, my)

        x = x + dx

        w = self.LeftPanelWidth * 0.8
        dx = w + 10


        local pasteFrameButton = ClickableButton(x, y, w, h, {
            LPressed = function(prog) prog.OnionSkinPrev = not prog.OnionSkinPrev end,
        })
        if(self.OnionSkinPrev) then
            DrawCheckButton(self, pasteFrameButton, "Onion Skin (P)", mx, my, 1, 0, 0)
        else
            DrawCheckButton(self, pasteFrameButton, "Onion Skin (P)", mx, my)
        end

        x = x + dx

        local pasteFrameButton = ClickableButton(x, y, w, h, {
            LPressed = function(prog) prog.OnionSkinNext = not prog.OnionSkinNext end,
        })
        if(self.OnionSkinNext) then
            DrawCheckButton(self, pasteFrameButton, "Onion Skin (N)", mx, my, 1, 0, 0)
        else
            DrawCheckButton(self, pasteFrameButton, "Onion Skin (N)", mx, my)
        end

        x = x + dx

        -- draw the timeline
        lg.setLineWidth(2)
        local frameStartX = self.LeftPanelWidth + 10
        local frameHeight = 30
        local frameLineHeight = 40
        local frameWidth = 15
        local framePattern = 2
        x = frameStartX - (self.TimeLineStart - 1)*frameWidth
        y = ScreenHeight - frameLineHeight - 10

        lg.setColor(1, 1, 1)
        lg.setFont(Font_Consolas16)

        for i=1, self.TimeLineStart+ScreenWidth/frameWidth do
            lg.line(x, y + (frameLineHeight - frameHeight), x + frameWidth, y + (frameLineHeight - frameHeight))
            lg.line(x, y + frameLineHeight, x + frameWidth, y + frameLineHeight)

            if(i % framePattern == 0) then
                lg.line(x, y, x, y + frameLineHeight)
                lg.print(i, x + 4, y - 6)
            else
                lg.line(x, y + (frameLineHeight - frameHeight), x, y + (frameLineHeight - frameHeight) + frameHeight)
            end

            x = x + frameWidth
        end

        x = frameStartX - (self.TimeLineStart - 1)*frameWidth
        y = y + (frameLineHeight - frameHeight)

        if(anim ~= nil) then
            for i, frame in ipairs(anim.Frames) do
                local duration = math.max(frame.Duration, 1)
                local w = duration * frameWidth
                if(i == CurrentFrameIndex) then
                    lg.setColor(1, 0, 0)
                else
                    lg.setColor(1, 1, 1)
                end

                lg.rectangle("fill", x, y, w, frameHeight)

                lg.setColor(0, 0, 0)
                lg.rectangle("line", x, y, w, frameHeight)

                local button = ClickableButton(x, y, w, h, {
                    Index = i,
                    LPressed = function(prog, button) CurrentFrameIndex = button.Index end
                })
                CheckClickableButton(self, button, mx, my)

                lg.print(frame.Duration, x + 3, y + 10)

                x = x + w
            end
        end

        if(self.Playing) then
            lg.setColor(1, 1, 1)
            local x = frameStartX + self.PlayTime*frameWidth
            local y = ScreenHeight - frameLineHeight - 10
            local h = frameLineHeight + 10

            lg.line(x, y, x, y + h)
        end


        -- draw left panel background
        DarkGray()
        lg.rectangle("fill", 0, 0, self.LeftPanelWidth, ScreenHeight)
        lg.setColor(1, 1, 1)
        lg.rectangle("line", 0, 0, self.LeftPanelWidth, ScreenHeight)

        -- Animation list
        local w = self.LeftPanelWidth * 0.9
        local h = w/4

        local x = (self.LeftPanelWidth - w)/2
        local y = self.LeftPanelYScroll
        local dy = h * 1.2

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
        end

        y = y + dy

        local newButton = ClickableButton(x, y, w, h, {
            LPressed = prog.NewAnimation,
        })

        DrawCheckButton(self, newButton, "(New Animation)", mx, my)

        y = y + dy

        local renameButton = ClickableButton(x, y, w, h, {
            LPressed = prog.RenameAnimation,
        })

        DrawCheckButton(self, renameButton, "(Rename Animation)", mx, my)

        y = y + dy

        local deleteAnimButton = ClickableButton(x, y, w, h, {
            LPressed = self.DeleteAnimation,
        })
        DrawCheckButton(self, deleteAnimButton, "(Delete Animation)", mx, my)

        lg.pop()
        
    end

    function prog:PlayAnimation(button, mx, my)
        if(self.Playing) then
            self.Playing = false
        else
            local anim = prog.CurrentAnimation
            self.Looping = button.Looping
            if(anim ~= nil) then
                CurrentFrameIndex = 1
                self.Playing = true
                self.PlayTime = 1
                local frame = anim.Frames[CurrentFrameIndex]
                self.FrameTimeLeft = frame.Duration
            end
        end
    end

    function prog:PlayAnimationStep()
        local anim = prog.CurrentAnimation
        self.PlayTime = self.PlayTime + 1
        self.FrameTimeLeft = self.FrameTimeLeft - 1
        if(self.FrameTimeLeft <= 0) then
            CurrentFrameIndex = CurrentFrameIndex + 1
            local frame = anim.Frames[CurrentFrameIndex]
            if(frame == nil) then
                if(self.Looping) then
                    CurrentFrameIndex = 1
                    local frame = anim.Frames[CurrentFrameIndex]
                    self.FrameTimeLeft = frame.Duration
                    self.PlayTime = 1
                else
                    CurrentFrameIndex = CurrentFrameIndex - 1
                    self.Playing = false
                end
            else
                self.FrameTimeLeft = frame.Duration
            end
        end
    end

    function prog:SetAnimation(button, mx, my)
        CurrentAnimationIndex = button.Index

        CurrentFrameIndex = 1

    end

    function prog:DeleteAnimation(button, mx, my)
        local skeleton = CurrentSkeleton()
        if(CurrentAnimationIndex ~= 0) then 
            table.remove(skeleton.Animations, CurrentAnimationIndex)
            CurrentAnimationIndex = 0

            SkeletonModified = true
        end
        
    end

    function prog:NewAnimation(button, mx, my)
        TextEntryOn = true
        TextEntryPrompt = "Name new animation"
        TextEntered = ""
        TextEntryFinished = prog.CreateAnimation

        SkeletonModified = true
    end

    function prog:NewFrame()
        if(CurrentAnimationIndex ~= 0) then 
            local anim = prog.CurrentAnimation
            table.insert(anim.Frames, CurrentFrameIndex + 1, CopyPose(anim.Frames[CurrentFrameIndex] or BlankPose()))
            CurrentFrameIndex = CurrentFrameIndex + 1
            SkeletonModified = true
        end
    end

    function prog:DeleteFrame()
        if(CurrentAnimationIndex ~= 0) then 
            local anim = prog.CurrentAnimation
            table.remove(anim.Frames, CurrentFrameIndex)
            CurrentFrameIndex = math.max(1, CurrentFrameIndex - 1)
            SkeletonModified = true
        end


    end

    function prog:CopyFrame()
        if(CurrentAnimationIndex ~= 0) then 
            local anim = prog.CurrentAnimation
            local pose = anim.Frames[CurrentFrameIndex]
            if(pose == nil) then
                pose = self.SkeletonFrame
            end
            prog.ClipboardPose = CopyPose(pose)
        end
    end

    function prog:PasteFrame()
        if(CurrentAnimationIndex ~= 0 and prog.ClipboardPose ~= nil) then 
            local anim = prog.CurrentAnimation
            anim.Frames[CurrentFrameIndex] = CopyPose(prog.ClipboardPose)
            SkeletonModified = true
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
        
        SkeletonModified = true
        
        --SaveSkeleton()
    end

    function prog:RenameAnimation(button, mx, my)
        TextEntryOn = true
        TextEntryPrompt = "Rename animation"
        TextEntered = ""
        TextEntryFinished = prog.AnimationRenamed
    end

    function prog:AnimationRenamed()
        if(TextEntered == "") then
            prog:RenameAnimation()
            return
        end

        local anim = prog.CurrentAnimation
        anim.Name = TextEntered

        SkeletonModified = true
    end

    function prog:Update()
        UpdateZoomAndOffset(self)

        local mx, my = GetRelativeMouse(1, 0, 0)
        if(mx < self.LeftPanelWidth) then
            self.LeftPanelYScroll = self.LeftPanelYScroll + MouseWheel * 20
        elseif(my > ScreenHeight - self.BottomPanelHeight) then
            self.TimeLineStart = math.max(1, self.TimeLineStart - MouseWheel)
        end
    end

    function prog:KeyPressed(key, scancode, isrepeat)
        local totalFrames = 0
        if(prog.CurrentAnimation ~= nil) then
            totalFrames = #prog.CurrentAnimation.Frames
        end
       
        local anim = self.CurrentAnimation
       
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
        elseif(key == "up" and anim ~= nil) then
            local frame = anim.Frames[CurrentFrameIndex]
            frame.Duration = frame.Duration + 1
            SkeletonModified = true
        elseif(key == "down") then
            local frame = anim.Frames[CurrentFrameIndex]
            frame.Duration = math.max(1, frame.Duration - 1)
            SkeletonModified = true
        elseif(key == "n") then
            prog:NewFrame()
        elseif(key == 'b') then
            DisplayHitballs = not DisplayHitballs
        end
    end


    return prog

end