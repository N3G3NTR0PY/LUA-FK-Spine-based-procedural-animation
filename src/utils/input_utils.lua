return {
    getMovementDir = function()
        local dir = {0, 0}

        if love.keyboard.isDown('w') then 
            dir[2] = dir[2] - 1
        end
        if love.keyboard.isDown('s') then
            dir[2] = dir[2] + 1
        end
        if love.keyboard.isDown('a') then
            dir[1] = dir[1] - 1
        end
        if love.keyboard.isDown('d') then
            dir[1] = dir[1] + 1
        end

        return dir
    end
}
