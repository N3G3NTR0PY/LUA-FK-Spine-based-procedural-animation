return {
    parseBody = function(body, unitScale, size)
        local radii, relativeAngleLimits = {}, {}
        for i = 1, #body - 1, 2 do
            table.insert(radii, #body[i] * unitScale * size)
            table.insert(relativeAngleLimits, math.rad(body[i + 1]))
        end
        return radii, relativeAngleLimits
    end
}