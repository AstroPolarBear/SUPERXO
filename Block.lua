function Block(length, block_x, block_y)
    return {
        b_l = length or 10,
        b_x = block_x or 0,
        b_y = block_y or 0,

        draw = function (self, b_x, b_y)
            self.b_x = b_x or self.b_x
            self.b_y = b_y or self.b_y

            love.graphics.setColor(1,1,1)

            love.graphics.rectangle("fill", self.b_x, self.b_y, self.b_l, self.b_l)

            love.graphics.setColor(0,0,0)
        end
    }

end

return Block