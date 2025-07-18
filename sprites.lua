-- load all sprites in the sprite folder and store them in a table for
-- easy access by key (for convenient serialization of things that reference sprites)


function LoadSprites()

    -- sheets
    local dir  = "Resources/sprites/sheets"
    local files = love.filesystem.getDirectoryItems(dir)

    -- these are the textures we will use for creating part sprites
    SpriteSheets = {}
    -- the names of the files, saved just in case
    SpriteSheetFiles = {}

    for _, value in ipairs(files) do
        local spr = love.graphics.newImage(dir .. "/" ..value)
        --spr:setFilter("nearest", "nearest")
        SpriteSheets[value] = spr
        table.insert(SpriteSheetFiles, value)
    end

    -- effects
    dir  = "Resources/sprites/effects"
    files = love.filesystem.getDirectoryItems(dir)

    GFX = {}
    for _, value in ipairs(files) do
        local spr = love.graphics.newImage(dir .. "/" ..value)
        local name = string.match(value, "[^%d%s]+")
        local number = tonumber(string.match(value, "%d+"))

        if(not GFX[name]) then
            GFX[name] = {}
        end
        GFX[name][number] = spr

    end

end