require "sprites"
require "Screens"
require "PaperSprite"

-- in the future, should depend on if we load in editor mode
require "EditorProgram"

if arg[#arg] == "vsc_debug" then 
    require("lldebugger").start()

end

MouseDownPrev = { [1] = false, [2] = false }
MouseDown = { [1] = false, [2] = false }
MousePressed = { [1] = false, [2] = false }

function love.conf(t)
	t.console = true
    love.filesystem.setIdentity("Paper_Puppets_Love")
end

function  love.load()

    ScreenWidth, ScreenHeight = 1440, 810
    love.window.setMode( ScreenWidth, ScreenHeight )
    love.window.setTitle("Paper Puppet Editor")

    LoadSprites()
    LoadSkeletons()

    Font_K = love.graphics.newFont("fonts/KOMTIT.ttf", 20)
    Font_KBig = love.graphics.newFont("fonts/KOMTIT.ttf", 35)
    love.graphics.setFont(Font_K)

    --CurrentProgram = BlankProgram()
    CurrentProgram = EditorProgram

    CurrentProgram:Load()
end


function love.draw()
    CurrentProgram:Draw()
end

function love.keypressed(key, scancode, isrepeat)
    CurrentProgram:KeyPressed(key, scancode, isrepeat)
end

function love.update(dt)
    MouseDown[1] = love.mouse.isDown(1)
    MouseDown[2] = love.mouse.isDown(2)

    MousePressed[1] = MouseDown[1] and not MouseDownPrev[1]
    MousePressed[2] = MouseDown[2] and not MouseDownPrev[2]

    if(MousePressed[1]) then
        CurrentProgram:MousePressed(1)
    elseif(MouseDown[1]) then
        CurrentProgram:MouseHeld(1)
    elseif(MouseDownPrev[1]) then
        CurrentProgram:MouseReleased(1)
    end

    if(MousePressed[2]) then
        CurrentProgram:MousePressed(2)
    elseif(MouseDown[2]) then
        CurrentProgram:MouseHeld(2)
    elseif(MouseDownPrev[2]) then
        CurrentProgram:MouseReleased(2)
    end

    CurrentProgram:Update()

    MouseDownPrev[1] = MouseDown[1]
    MouseDownPrev[2] = MouseDown[2]
end

