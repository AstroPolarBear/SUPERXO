local Block = require "Block"

function Grid(box_l, box_x, box_y)
    local grid = {}

    local block_l = 152
    local block_x = box_x
    local block_y = box_y
    local block_spacing = 28

    local counter = 1

    for i = 1, 3, 1 do
        for j = 1, 3, 1 do
            grid[counter] = Block(block_l, block_x, block_y)
            block_x = block_x + block_l + block_spacing
            counter = counter + 1
        end
        block_x = box_x
        block_y = block_y + block_l + block_spacing
    end

    return grid
end

return Grid