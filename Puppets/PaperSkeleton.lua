Skeletons = {}

function PaperSkeleton()
    return {
        Name = "",
        PartBlueprints = {}, -- full of PartBluePrints
        Animations = {},
        -- global offset so that 0,0 can be their feet, for example
        X = nil,
        Y = nil,
        -- Used for ease of use in animation editor
        IdlePose = nil,
    }
end

function LoadSkeletons()
    local files = love.filesystem.getDirectoryItems("Resources/skeletons")
    for _, value in ipairs(files) do
        Skeletons[value] = jsonDecodeFile("Resources/skeletons/" .. value)
    end
end