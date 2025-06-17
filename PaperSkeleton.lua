
-- paper skeleton has:
-- sprite slots (should match sprite set)
-- paper parts
-- animations, which have:
--      frames, which are collections of parts
require "tables"

function SaveSkeleton()
    local skeleton = CurrentSkeleton()
    local name = SkeletonName
    if(name == nil or name == "[NEW]") then
        EnterSkeletonName()
        return
    end
    jsonEncodeFile(skeleton, "skeletons/" .. name)
end

function EnterSkeletonName()
    TextEntryOn = true
    TextEntered = SkeletonName or ""
    TextEntryFinished = SkeletonNameEntered
end

function SkeletonNameEntered()
    if(TextEntered == "") then
        EnterSkeletonName()
        return
    end
    local skeleton = CurrentSkeleton()
    SkeletonIndex = TextEntered
    SkeletonName = SkeletonIndex
    Skeletons[SkeletonIndex] = skeleton

    SaveSkeleton()
end

function LoadSkeletons()
    local files = love.filesystem.getDirectoryItems("skeletons")
    for _, value in ipairs(files) do
        Skeletons[value] = jsonDecodeFile("skeletons/" .. value)
    end
end

function PaperSkeleton()
    return {
        Name = "",
        PartBlueprints = {}, -- full of PartBluePrints
        Animations = {},
        -- global offset so that 0,0 can be their feet, for example
        X = nil,
        Y = nil
    }
end

function Animation(name)
    return {
        Name = name,
        Frames = {},
    }
end