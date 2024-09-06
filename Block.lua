local Palette = require "Palette"

love.graphics.setDefaultFilter("nearest", "nearest")
p1_b = love.graphics.newImage('sprites/X_Black.png')
p1_w = love.graphics.newImage('sprites/X_White2.png')
p2_b = love.graphics.newImage('sprites/O_Black.png')
p2_w = love.graphics.newImage('sprites/O_White2.png')

function Block(length, block_x, block_y)
    return {
        b_l = length or 10,
        b_x = block_x or 0,
        b_y = block_y or 0,
        state = 0,
        winner = false,

        draw = function (self, b_x, b_y)
            local offset_x, offset_y = 8, 8
            b_x = b_x or self.b_x + offset_x
            b_y = b_y or self.b_y + offset_y
            L = 8
            love.graphics.setColor(White)

            if self.state == 1 and self.winner == true then
                love.graphics.draw(p1_w, b_x, b_y)
            elseif self.state == 1 then
                love.graphics.draw(p1_b, b_x, b_y)
            elseif self.state == 2 and self.winner == true then
                love.graphics.draw(p2_w, b_x, b_y)
            elseif self.state == 2 then
                love.graphics.draw(p2_b, b_x, b_y)
            end

        end,

        pressCheck = function (self, mouse_x, mouse_y)
            if self.state ~= 0 then
                return
            end

            if (mouse_x >= self.b_x) and (mouse_x <= self.b_x + self.b_l) then
                if (mouse_y >= self.b_y) and (mouse_y <= self.b_y + self.b_l) then
                    return true
                end
            end
        end
    }

end

return Block