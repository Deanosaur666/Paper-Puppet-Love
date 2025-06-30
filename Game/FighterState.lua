-- an instance of a fighter on screen
-- needs: a reference to a Fighter sheet
-- x, y, facing, current animation, current frame

function FighterState()
    return {
        -- basically their current animation
        CurrentAction = nil,
        CurrentFrame = 0,
        FrameTimeLeft = 0,

        X = 0,
        Y = 0,

        -- facing right
        Facing = true,
    }
end