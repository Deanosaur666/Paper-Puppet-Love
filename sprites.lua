-- load all sprites in the sprite folder and store them in a table for
-- easy access by key (for convenient serialization of things that reference sprites)

function LoadSprites()

    local dir  = "sprites"

    local files = love.filesystem.getDirectoryItems( dir)

    -- these are the textures we will use for creating part sprites
    SpriteSheets = {}
    -- the names of the files, saved just in case
    SpriteSheetFiles = {}

    for index, value in ipairs(files) do
        print(value)
        local spr = love.graphics.newImage(dir .. "/" ..value)
        table.insert(SpriteSheets, spr)
        table.insert(SpriteSheetFiles, value)
    end



end