local dir  = "Resources/sounds"
local files = love.filesystem.getDirectoryItems(dir)

SFX = {}

for _, value in ipairs(files) do
    local sound = love.audio.newSource(dir .. "/" ..value, "static")
    --spr:setFilter("nearest", "nearest")
    value = string.sub(value, 5, -5)
    SFX[value] = sound
end