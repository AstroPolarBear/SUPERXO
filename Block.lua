function Block(length, block_x, block_y)
    return {
        b_l = length or 10,
        b_x = block_x or 0,
        b_y = block_y or 0,
        state = 0,

        draw = function (self, b_x, b_y)
            self.b_x = b_x or self.b_x
            self.b_y = b_y or self.b_y

            love.graphics.setColor(1,1,1)

            love.graphics.rectangle("fill", self.b_x, self.b_y, self.b_l, self.b_l)

            love.graphics.setColor(0,0,0)

            if self.state == 1 then
                love.graphics.setLineWidth(5)
                love.graphics.line(self.b_x, self.b_y, self.b_x + self.b_l, self.b_y + self.b_l)
                love.graphics.line(self.b_x, self.b_y  + self.b_l, self.b_x + self.b_l, self.b_y)
            elseif self.state == 2 then
                local circle_x = self.b_x + (self.b_l / 2)
                local circle_y = self.b_y + (self.b_l / 2)
                local circle_r = self.b_l / 2
                love.graphics.circle("line", circle_x, circle_y, circle_r)
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