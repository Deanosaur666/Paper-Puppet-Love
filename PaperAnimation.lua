PriorityQueue = require "PriorityQueue"

function Frame()
    return {
        Duration = 0,
        PartFrames = {},
        -- frame specific offset for the whole body
        X = nil,
        Y = nil,
    }
end

function DefaultFrame(skeleton)
    
    local frame = Frame()
    local partFrames = frame.PartFrames
    local blueprints = skeleton.PartBlueprints
    for i, bp in ipairs(blueprints) do
        partFrames[i] = PartFrame(i, nil, 0, 0, 0, nil) -- default values, take from blueprint's defaults
    end

    return frame
end

function UpdateFrame(frame, skeleton)
    for i, pf in ipairs(frame.PartFrames) do
        UpdatePartFrame(pf, frame, skeleton)
    end
end

function DrawFrame(frame, skeleton, spriteset, texture, x, y, rot, xscale, yscale)
    
    xscale = xscale or 1
    yscale = yscale or 1
    rot = rot or 0
    
    local lg = love.graphics

    lg.push("all")
    lg.translate(x + (skeleton.X or 0) + (frame.X or 0), y + (skeleton.Y or 0) + (frame.Y or 0))
    lg.scale(xscale, yscale)
    lg.rotate(rot)


    -- needs to change origin, rotation, and scale based on x, y, rot, xscale, yscale

    local partqueue = PriorityQueue("max")

    for _, part in pairs(frame.PartFrames) do
        local blueprint = GetPartBluePrint(part, skeleton)
        partqueue:enqueue(part, part.Layer or blueprint.DefLayer)
    end

    while not partqueue:empty() do
        local part = partqueue:dequeue()
        local blueprint = GetPartBluePrint(part, skeleton)
        local sprite = GetPartSprite(part, blueprint, spriteset)
        local xsc, ysc = GetBlueprintScale(blueprint)
        DrawPaperSprite(sprite, texture, part.CX, part.CY, part.CRotation, part.XScale * xsc, part.YScale * ysc)
    end

    lg.pop()
end