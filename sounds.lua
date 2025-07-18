local dir  = "Resources/sfx"
local files = love.filesystem.getDirectoryItems(dir)

SFX = {}

for _, value in ipairs(files) do
    local sound = love.audio.newSource(dir .. "/" ..value, "static")
    --spr:setFilter("nearest", "nearest")
    value = string.sub(value, 1, -5)
    SFX[value] = sound
end

function PlaySFX(sound)
    SFX[sound]:stop()
    SFX[sound]:play()
end