Skeletons = {}
SkeletonAnimNameMap = {}

CURRENT_VERSION = "2025.06.29"

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
        Version = CURRENT_VERSION,
    }
end

function LoadSkeletons()
    local files = love.filesystem.getDirectoryItems("Resources/skeletons")
    for _, skelName in ipairs(files) do
        local skeleton = jsonDecodeFile("Resources/skeletons/" .. skelName)
        Skeletons[skelName] = skeleton
        SkeletonAnimNameMap[skelName] = {}

        for _, anim in ipairs(skeleton.Animations) do
            SkeletonAnimNameMap[skelName][anim.Name] = anim
            print(skelName .. " ANIM: " .. anim.Name)
        end
    end
end