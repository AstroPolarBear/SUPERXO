local Block = require "Block"

function Grid(box_l, box_x, box_y)
    local grid = {}

    local block_l = 152
    local block_x = box_x
    local block_y = box_y
    local block_spacing = 28

    for i = 1, 9 do
        grid[i] = Block(block_l, block_x, block_y)
        block_x = block_x + block_l + block_spacing
        if i % 3 == 0 then
            block_x = box_x
            block_y = block_y + block_l + block_spacing
        end
    end

    return grid
end

return Grid