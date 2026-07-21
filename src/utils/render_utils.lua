
-- helper func to draw a text field
local function textField(text, pos, colors, warning, size)
    local font = love.graphics.setNewFont(math.max(8, math.floor(12 * size)))

    local backgroundColor = colors[1]
    local outlineColor = colors[2]
    local textColor = colors[3]
    local warningColor = colors[4]

    local offset = 1.5 * size

    local font = love.graphics.getFont()
    local textWidth = font:getWidth(text)
    local textHeight = font:getHeight(text)
    local oldLineWidth = love.graphics.getLineWidth()

    local lineWidth = 2 * size

    local newPos = {
        pos[1] - textWidth / 2 - offset,
        pos[2] - textHeight / 2 - offset
    }

    local fillWidth = 2 * offset + textWidth
    local fillHeight = 2 * offset + textHeight

    love.graphics.setLineWidth(lineWidth)
    love.graphics.setColor(backgroundColor)
    love.graphics.rectangle("fill", newPos[1], newPos[2], fillWidth, fillHeight)
    if warning then
        outlineColor, textColor = warningColor, warningColor
    end
    love.graphics.setColor(outlineColor)
    love.graphics.rectangle("line", newPos[1], newPos[2], fillWidth, fillHeight)
    love.graphics.setColor(textColor)
    -- its dublicate cuz it makes the font more readable against msaa
    love.graphics.print(text, newPos[1] + offset, newPos[2] + offset)
    love.graphics.print(text, newPos[1] + offset, newPos[2] + offset)
    love.graphics.setLineWidth(oldLineWidth)
end


return {
    -- draws each segment from tail to head (holy totally not copy pasted code)
    drawBody = function(segmentPos, radii, outlineWidth, colors)
        local minX, minY = math.huge, math.huge
        local maxX, maxY = -math.huge, -math.huge
        local padding = (outlineWidth and outlineWidth > 0) and outlineWidth or 0

        for i = 1, #segmentPos do
            local x, y = segmentPos[i][1], segmentPos[i][2]
            local r = radii[i] + padding
            minX = math.min(minX, x - r)
            minY = math.min(minY, y - r)
            maxX = math.max(maxX, x + r)
            maxY = math.max(maxY, y + r)
        end
        -- doesnt do anything really after 8
        local steps = 8

        if outlineWidth and outlineWidth > 0 and colors[1] then
            love.graphics.setColor(colors[2])
            for i = 1, #segmentPos do
                love.graphics.circle("fill", segmentPos[i][1], segmentPos[i][2], radii[i] + outlineWidth)
            end
            for i = 1, #segmentPos - 1 do
                local x1, y1 = segmentPos[i][1], segmentPos[i][2]
                local x2, y2 = segmentPos[i+1][1], segmentPos[i+1][2]
                local r1, r2 = radii[i] + outlineWidth, radii[i+1] + outlineWidth
                for step = 1, steps do
                    local t = step / (steps + 1)
                    love.graphics.circle("fill", x1 * (1 - t) + x2 * t, y1 * (1 - t) + y2 * t, r1 * (1 - t) + r2 * t)
                end
            end
        end

        love.graphics.stencil(function()
            for i = 1, #segmentPos do
                love.graphics.circle("fill", segmentPos[i][1], segmentPos[i][2], radii[i])
            end
            for i = 1, #segmentPos - 1 do
                local x1, y1 = segmentPos[i][1], segmentPos[i][2]
                local x2, y2 = segmentPos[i+1][1], segmentPos[i+1][2]
                local r1, r2 = radii[i], radii[i+1]
                for step = 1, steps do
                    local t = step / (steps + 1)
                    love.graphics.circle("fill", x1 * (1 - t) + x2 * t, y1 * (1 - t) + y2 * t, r1 * (1 - t) + r2 * t)
                end
            end
        end, 'replace', 1)

        love.graphics.setStencilTest('greater', 0)
        love.graphics.setColor(colors[1])
        love.graphics.rectangle("fill", minX - 10, minY - 10, (maxX - minX) + 20, (maxY - minY) + 20)
        love.graphics.setStencilTest()
    end,

    -- debug overlay
    debugOverlay = function (segmentPos, angles, radii, angleLimits, colors, size, targetPos, sightDir)
        local oldLineWidth = love.graphics.getLineWidth()

        local lineWidth = 1.5 * size
        local lineOfSightDist = 100
        love.graphics.setLineStyle('smooth')
        -- draw links between segments
        love.graphics.setLineWidth(lineWidth)
        for i = 1, #segmentPos - 1 do
            love.graphics.setColor(colors[2])
            love.graphics.line(
                segmentPos[i][1], segmentPos[i][2],
                segmentPos[i + 1][1], segmentPos[i + 1][2]
            )
        end
        love.graphics.setColor(colors[1])
        love.graphics.line(
            segmentPos[1][1], segmentPos[1][2],
            segmentPos[1][1] + lineOfSightDist * math.cos(sightDir[1]),
            segmentPos[1][2] + lineOfSightDist * math.sin(sightDir[1])
        )
        love.graphics.setColor(colors[4])
        love.graphics.line(
            segmentPos[1][1], segmentPos[1][2],
            targetPos[1], targetPos[2]
        )
        love.graphics.setLineWidth(oldLineWidth)
        -- visualize segment thickness
        for i = 1, #segmentPos do
            love.graphics.setLineWidth(lineWidth * 4)
            love.graphics.setColor(colors[1])
            love.graphics.circle('line', segmentPos[i][1], segmentPos[i][2], radii[i])
            love.graphics.setLineWidth(lineWidth)
            love.graphics.setColor(colors[2])
            love.graphics.circle('line', segmentPos[i][1], segmentPos[i][2], radii[i])

        end
        -- draw the relative angles of the segments
        textField('TAIL', {segmentPos[#segmentPos][1], segmentPos[#segmentPos][2]}, colors, false, size)
        for i = #segmentPos - 1, 2, -1 do
            local text = tostring(math.ceil(math.deg(angles[i]))) .. '°'
            -- a visual warning if the angle clamping broke again
            if angles[i] > angleLimits[i] or angles[i] < -angleLimits[i] then
                textField(text, {segmentPos[i][1], segmentPos[i][2]}, colors, true, size)
            else
                textField(text, {segmentPos[i][1], segmentPos[i][2]}, colors, false, size)
            end
        end
        textField('HEAD', {segmentPos[1][1], segmentPos[1][2]}, colors, false, size)
    end,

    drawDot = function(pos, color, thickness)
        love.graphics.setColor(color)
        love.graphics.circle('fill', pos[1], pos[2], thickness)
    end
}