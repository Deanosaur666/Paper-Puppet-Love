require "sprites"
require "Screens"
require "PaperSprite"

-- in the future, should depend on if we load in editor mode
require "EditorProgram"

if arg[#arg] == "vsc_debug" then 
    require("lldebugger").start()

end

function love.conf(t)
	t.console = true
    love.filesystem.setIdentity("Paper_Puppets_Love")
end

function  love.load()

    love.window.setMode( 1440, 810 )
    love.window.setTitle("Paper Puppet Editor")

    LoadSprites()

    Font_K = love.graphics.newFont("fonts/KOMTIT.ttf", 20)
    love.graphics.setFont(Font_K)

    --CurrentProgram = BlankProgram()
    CurrentProgram = EditorProgram

    CurrentProgram.Load()
end


function love.draw()
    CurrentProgram.Draw()
end

function love.keypressed(key, scancode, isrepeat)
    
end

function love.update(dt)
    CurrentProgram.Update()
end

