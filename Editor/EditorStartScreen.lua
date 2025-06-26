function SelectionMenu()
    local prog = BlankProgram()

    SheetIndex = nil
    SpriteSetIndex = nil
    SkeletonIndex = nil

    SpriteSets["[NEW]"] = nil
    Skeletons["[NEW]"] = nil

    prog.SheetNames = {}
    prog.SpriteSetNames = {}
    prog.SkeletonNames = {}

    prog.ScrollY = 0

    -- not used
    for _, filename in ipairs(SpriteSheetFiles) do
        table.insert(prog.SheetNames, filename)
    end
    table.sort(prog.SheetNames)
    
    for i, _ in pairs(SpriteSets) do
        table.insert(prog.SpriteSetNames, i)
    end
    table.sort(prog.SpriteSetNames)

    for i, _ in pairs(Skeletons) do
        table.insert(prog.SkeletonNames, i)
    end
    table.sort(prog.SkeletonNames)

    function prog:Draw()
        local lg = love.graphics
        lg.push("all")



        DrawEditorBackground()
        lg.setLineWidth(3)

        lg.setColor(1, 1, 1)

        lg.setFont(Font_Consolas16)

        local mx, my = GetRelativeMouse(1, 0, 0)

        local dx = ScreenWidth/5
        local dy = ScreenHeight/10
        local w = dx*0.75
        local h = dy*0.75

        local x = dx + (dx-w)/2
        local y = dy + self.ScrollY

        local sheet = nil
        if(SheetIndex ~= nil) then
            sheet = CurrentTexture()
        end

        if(sheet ~= nil) then
            local w = sheet:getWidth()
            local h = sheet:getHeight()

            lg.draw(sheet, ScreenWidth/2 - w/2, ScreenHeight/2 - h/2)
        end

        -- textures
        PrintCentered("Select texture", x + w/2, y + h/2)
        y = y + dy

        for i, filename in ipairs(SpriteSheetFiles) do
            local button = ClickableButton(x, y, w, h, {
                LPressed = prog.SetTexture,
                FileName = filename,
                Index = i
            })
            CheckClickableButton(self, button, mx, my)

            lg.setColor(1, 1, 0)
            if(i == SheetIndex) then
                lg.setColor(1, 0, 0)
            end
            lg.rectangle("fill", x, y, w, h)
            lg.setColor(0, 0, 0)
            lg.rectangle("line", x, y, w, h)
            PrintCentered(filename, x + w/2, y + h/2)
            y = y + dy
        end

        -- sprite sets
        y = dy + self.ScrollY
        x = x + dx
        lg.setColor(1, 1, 1)
        PrintCentered("Select spriteset", x + w/2, y + h/2)
        y = y + dy
        
        for _, i in ipairs(self.SpriteSetNames) do
            local button = ClickableButton(x, y, w, h, {
                LPressed = prog.SetSpriteSet,
                Index = i
            })
            CheckClickableButton(self, button, mx, my)

            lg.setColor(1, 1, 0)
            if(i == SpriteSetIndex) then
                lg.setColor(1, 0, 0)
            end
            lg.rectangle("fill", x, y, w, h)
            lg.setColor(0, 0, 0)
            lg.rectangle("line", x, y, w, h)
            PrintCentered(i, x + w/2, y + h/2)
            y = y + dy
        end

        -- new sprite set
        local button = ClickableButton(x, y, w, h, {
            LPressed = prog.CreateSpriteSet,
        })
        CheckClickableButton(self, button, mx, my)

        lg.setColor(1, 1, 0)
        lg.rectangle("fill", x, y, w, h)
        lg.setColor(0, 0, 0)
        lg.rectangle("line", x, y, w, h)
        PrintCentered("NEW", x + w/2, y + h/2)

        -- skeletons
        y = dy + self.ScrollY
        x = x + dx
        lg.setColor(1, 1, 1)
        PrintCentered("Select skeleton", x + w/2, y + h/2)
        y = y + dy
        
        for _, i in ipairs(self.SkeletonNames) do
            local button = ClickableButton(x, y, w, h, {
                LPressed = prog.SelectSkeleton,
                Index = i
            })
            CheckClickableButton(self, button, mx, my)

            lg.setColor(1, 1, 0)
            if(i == SkeletonIndex) then
                lg.setColor(1, 0, 0)
            end
            lg.rectangle("fill", x, y, w, h)
            lg.setColor(0, 0, 0)
            lg.rectangle("line", x, y, w, h)
            PrintCentered(i, x + w/2, y + h/2)
            y = y + dy
        end

        -- new skeleton
        local button = ClickableButton(x, y, w, h, {
            LPressed = prog.CreateSkeleton,
        })
        CheckClickableButton(self, button, mx, my)

        lg.setColor(1, 1, 0)
        lg.rectangle("fill", x, y, w, h)
        lg.setColor(0, 0, 0)
        lg.rectangle("line", x, y, w, h)
        PrintCentered("NEW", x + w/2, y + h/2)

        -- finish
        x = ScreenWidth/2 - w/2
        y = dy/3 + self.ScrollY
        local button = ClickableButton(x, y, w, h, {
            LPressed = prog.Finished,
        })
        CheckClickableButton(self, button, mx, my)
        lg.setColor(1, 1, 0)
        if(not FilesSelected()) then
            lg.setColor(0.2, 0.2, 0.2)
        end
        lg.rectangle("fill", x, y, w, h)
        lg.setColor(0, 0, 0)
        lg.rectangle("line", x, y, w, h)
        PrintCentered("FINISHED", x + w/2, y + h/2)


        lg.pop()
    end

    function prog:Update()
        self.ScrollY = self.ScrollY + MouseWheel * 25
    end

    function prog:SetTexture(button, mx, my)
        SheetIndex = button.Index
    end

    function prog:SetSpriteSet(button, mx, my)
        SpriteSetIndex = button.Index
        SpriteSetName = SpriteSetIndex
    end

    function prog:CreateSpriteSet()
        -- new sprite set
        SpriteSetIndex = "[NEW]"
        if(SpriteSets[SpriteSetIndex] == nil) then
            table.insert(self.SpriteSetNames, 1, SpriteSetIndex)
        end
        SpriteSetName = nil
        local spriteSet = {}
        SpriteSets[SpriteSetIndex] = spriteSet
    end

    function prog:SelectSkeleton(button, mx, my)
        SkeletonIndex = button.Index
        SkeletonName = SkeletonIndex
    end

    function prog:CreateSkeleton()
        -- new sprite set
        SkeletonIndex = "[NEW]"
        if(Skeletons[SkeletonIndex] == nil) then
            table.insert(self.SkeletonNames, 1, SkeletonIndex)
        end
        SkeletonName = nil
        Skeletons[SkeletonIndex] = PaperSkeleton()
    end

    function prog:Finished()
        if(not FilesSelected()) then
            return
        end
        CurrentScreen = PaperSpriteEditor()
    end

    return prog
end

function FilesSelected()
    return (SheetIndex and SpriteSetIndex and SkeletonIndex)
end