local Palette = require "Palette"

love.graphics.setDefaultFilter("nearest", "nearest")
player1 = love.graphics.newImage('sprites/X_Black.png')
player2 = love.graphics.newImage('sprites/O_Black.png')

function Block(length, block_x, block_y)
    return {
        b_l = length or 10,
        b_x = block_x or 0,
        b_y = block_y or 0,
        state = 0,

        draw = function (self, b_x, b_y)
            local offset_x, offset_y = 8, 8
            b_x = b_x or self.b_x + offset_x
            b_y = b_y or self.b_y + offset_y

            if self.state == 1 then
                love.graphics.draw(player1, b_x, b_y)
            elseif self.state == 2 then
                love.graphics.draw(player2, b_x, b_y)
            end

        end,

        pressCheck = function (self, mouse_x, mouse_y, index, player)
            if self.state ~= 0 then
                return
            end

            if (mouse_x >= self.b_x) and (mouse_x <= self.b_x + self.b_l) then
                if (mouse_y >= self.b_y) and (mouse_y <= self.b_y + self.b_l) then
                    if player == 1 then
                        grid[index].state = 1
                    elseif player == 2 then
                        grid[index].state = 2
                    end
                    return true
                end
            end
        end
    }

end

return Block