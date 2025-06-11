
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

end


function love.draw()

end

function love.keypressed(key, scancode, isrepeat)
    
end

function love.update(dt)

end

