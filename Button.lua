function Button(text, func, func_param1, func_param2, width, height)
    return {
        width = width or 100,
        height = height or 100,
        func = func or function() print("No function assigned.") end,
        func_param1 = func_param1,
        func_param2 = func_param2,
        text = text or "Empty",
        button_x = 0,
        button_y = 0,
        text_x = 0,
        text_y = 0,

        draw = function(self, button_x, button_y, text_x, text_y)
            self.button_x = button_x
            self.button_y = button_y

            if text_x then
                self.text_x = text_x + self.button_x
            else
                self.text_x = self.button_x
            end

            if text_y then
                self.text_y = text_y + self.button_y
            else
                self.text_y = self.button_y
            end
            
            love.graphics.setColor(0.6, 0.6, 0.6)
            love.graphics.rectangle("fill", self.button_x, self.button_y, self.width, self.height)

            love.graphics.setColor(0, 0, 0)
            love.graphics.print(self.text, self.text_x, self.text_y)
        end,

        pressCheck = function (self, mouse_x, mouse_y)
            if (mouse_x >= self.button_x) and (mouse_x <= self.button_x + self.width) then
                if (mouse_y >= self.button_y) and (mouse_y <= self.button_y + self.height) then
                    if func then
                        if self.func_param1 and self.func_param2 then
                            self.func(self.func_param1, self.func_param2)
                        elseif self.func_param1 then
                            self.func(self.func_param1)
                        else
                            self.func()
                        end
                    end
                    return true
                end
            end
        end
    }
end

return Button