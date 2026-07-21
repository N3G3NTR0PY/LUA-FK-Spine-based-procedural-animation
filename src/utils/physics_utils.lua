return {
    createBody = function(headPos, segments, direction, spacing)
        -- fill up all the tables
        local segmentPos, relativeAngles, absoluteAngles = {}, {}, {}
        local sightDir = direction
        segmentPos[1] = {headPos[1], headPos[2]}
        relativeAngles[1] = direction
        absoluteAngles[1] = direction
        for i = 2, #segments do
            table.insert(segmentPos, {
                segmentPos[i - 1][1] - spacing * math.cos(direction),
                segmentPos[i - 1][2] - spacing * math.sin(direction)
            })
            relativeAngles[i] = 0
            absoluteAngles[i] = direction
        end
        return segmentPos, relativeAngles, absoluteAngles, {sightDir}
    end,

    moveBody = function(segments, relativeAngles, absoluteAngles, segmentPos, targetPos, sightDir, spacing, speed, turnSpeed, angleLimits, snapDistance, damping)
        -- find distance to target
        local targetDirX = targetPos[1] - segmentPos[1][1]
        local targetDirY = targetPos[2] - segmentPos[1][2]
        local targetAngle = math.atan2(targetDirY, targetDirX)
        -- find difference between line of sight and target
        local delta = targetAngle - sightDir[1]
        -- normalize that difference
        while delta > math.pi do
            delta = delta - math.pi * 2
        end
        while delta < -math.pi do
            delta = delta + math.pi * 2
        end
        sightDir[1] = (sightDir[1] + math.pi) % (2 * math.pi) - math.pi
        -- turn towards target
        if delta > 0 then
            sightDir[1] = sightDir[1] + turnSpeed * math.min(delta, 1)
        elseif delta < 0 then
            sightDir[1] = sightDir[1] - turnSpeed * math.min(-delta, 1)
        end
        sightDir[1] = (sightDir[1] + math.pi) % (2 * math.pi) - math.pi
        -- find x and y vectors to move forward towards line of sightlizard, {960, 340}, 1, math.pi, mousePos, 1
        local distance = math.sqrt(targetDirX * targetDirX + targetDirY * targetDirY)
        local dirX = distance * math.cos(sightDir[1])
        local dirY = distance * math.sin(sightDir[1])
        -- move head forward and snap it to the target with easing based on speed when its close
        if distance > 0 then
            if distance > snapDistance then
                segmentPos[1][1] = segmentPos[1][1] + dirX / distance * speed
                segmentPos[1][2] = segmentPos[1][2] + dirY / distance * speed
            else
                segmentPos[1][1] = segmentPos[1][1] + targetDirX / distance * distance / speed
                segmentPos[1][2] = segmentPos[1][2] + targetDirY / distance * distance / speed
            end
        end
        -- update the rest of the spine
        for i = 1, #segments - 1 do
            -- find absolute angle
            local dirX = segmentPos[i][1] - segmentPos[i + 1][1]
            local dirY = segmentPos[i][2] - segmentPos[i + 1][2]
            local absoluteAngle = math.atan2(dirY, dirX)
            -- add to table
            absoluteAngles[i] = absoluteAngle
            -- find relative angle
            local relativeAngle = absoluteAngle - (absoluteAngles[i - 1] or 0)
            relativeAngle = (relativeAngle + math.pi) % (2 * math.pi) - math.pi
            -- clamp the relative angle
            if relativeAngle > angleLimits[i] then
                relativeAngle = angleLimits[i]
            elseif relativeAngle < -angleLimits[i] then
                relativeAngle = -angleLimits[i]
            end
            -- add to table
            relativeAngles[i] = relativeAngle
            -- recalculate the absolute angle from clamped relative, skip head
            if i ~= 1 then
                absoluteAngle = absoluteAngles[i - 1] + relativeAngle
            end
            absoluteAngles[#segments] = absoluteAngle
            -- update the table
            absoluteAngles[i] = absoluteAngle
            -- find the updated position before smoothing
            local targetX = segmentPos[i][1] - spacing * math.cos(absoluteAngle)
            local targetY = segmentPos[i][2] - spacing * math.sin(absoluteAngle)
            -- smooth out the movement (basically instead of covering the full distance in a frame move damping% there)
            segmentPos[i + 1][1] = segmentPos[i + 1][1] + (targetX - segmentPos[i+1][1]) * damping
            segmentPos[i + 1][2] = segmentPos[i + 1][2] + (targetY - segmentPos[i+1][2]) * damping
        end
    end,

    moveObject = function(pos, speed, movementDir)
        pos[1] = pos[1] + movementDir[1] * speed
        pos[2] = pos[2] + movementDir[2] * speed
    end
}