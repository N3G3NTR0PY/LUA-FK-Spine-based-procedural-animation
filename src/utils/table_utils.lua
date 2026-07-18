return {
    -- this is where i discovered the for loop accepts step as an argument when reading stack overflow xd
    reverse = function(tab)
        local result = {}
        for i = #tab, 1, -1 do
            table.insert(result, tab[i])
        end
    end
}