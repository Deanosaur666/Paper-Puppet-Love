require "sprites"

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
end


function love.draw()

    -- just for fun/testing purposes
    if(#SpriteSheets >= 3) then
        love.graphics.draw(SpriteSheets[2], 10, 10)
    end
end

function love.keypressed(key, scancode, isrepeat)
    
end

function love.update(dt)

end

