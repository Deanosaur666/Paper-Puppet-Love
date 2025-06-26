SpriteSets = {}

function LoadSpriteSet(filename)
    filename = "Resources/spritesets/" .. filename
    local spriteSet = {}
    for line in love.filesystem.lines(filename) do
		table.insert(spriteSet, PaperSpriteFromString(line))
	end
    return spriteSet
end

function LoadSpriteSets()
    local dir  = "Resources/spritesets"

    local files = love.filesystem.getDirectoryItems(dir)
    for _, value in ipairs(files) do
        SpriteSets[value] = LoadSpriteSet(value)
    end

    if(#SpriteSets > 0) then
        SpriteSetIndex = 1
    end
end

function PaperSprite(quad, anchorX, anchorY)
    return {Quad = quad, AnchorX = anchorX, AnchorY = anchorY}
end

-- texture override exists so we can swap out sprites easily enough
-- needs rotation and scale
function DrawPaperSprite(sprite, texture, x, y, rot, xscale, yscale)

    xscale = xscale or 1
    yscale = yscale or 1
    rot = rot or 0

    -- we need to use the anchors for rotation and scale
    local lg = love.graphics
    lg.push("all")
    
    lg.translate(x, y)
    
    lg.rotate(rot)

    lg.scale(xscale, yscale)

    lg.translate(-sprite.AnchorX, -sprite.AnchorY)

    --lg.translate(sprite.AnchorX, sprite.AnchorY)
    

    -- needs to use rotation and scale
    -- love.graphics.draw(texture, sprite.Quad, x - (sprite.AnchorX*xscale), y - (sprite.AnchorY*yscale))
    love.graphics.draw(texture, sprite.Quad, 0, 0)

    lg.pop()
end


function PaperSpriteToString(sprite)
   
    local qx, qy, qw, qh = 0, 0, 0, 0
    local sw, sh = 0, 0
    if(sprite.Quad ~= nil) then
        qx, qy, qw, qh = sprite.Quad:getViewport()
        sw, sh = sprite.Quad:getTextureDimensions( )
    end
    

    return stringjoin({qx, qy, qw, qh, sw, sh, sprite.AnchorX, sprite.AnchorY}, ":")
end

function PaperSpriteFromString(str)
    local split = stringsplit(str, ":")
    local qx, qy, qw, qh, sw, sh, ax, ay =
        split[1], split[2], split[3], split[4], split[5], split[6], split[7], split[8]
    
    return PaperSprite(love.graphics.newQuad(qx, qy, qw, qh, sw, sh), ax, ay)
end