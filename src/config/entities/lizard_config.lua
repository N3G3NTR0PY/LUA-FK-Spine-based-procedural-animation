local colors = require('src.config.color_table')

return {
    unitScale = 16,
    segmentSpacing = 26,

    body = {
        '||', 15,
        '|||', 5,
        '|||', 0,
        '||', 15,
        '||', 5,
        '||', 25,
        '|||', 15,
        '||||', 15,
        '||||', 0,
        '||||', 5,
        '|||', 5,
        '||', 10,
        '|', 15,
        '|', 20,
        '|', 25,
        '|', 30,
        '|', 30,
        '|', 30,
        '|', 30,
    },

    speed = 600,
    turnSpeed = 4,
    snapDistance = 70,

    damping = 0.8,

    outlineWidth = 8,

    bodyColor = colors.lightGreen,
    outlineColor = colors.darkGreen,

    debug = true
}