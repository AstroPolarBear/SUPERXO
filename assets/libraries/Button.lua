function Button(text, func, func_param, width, height)
    return {
        width = width or 100,
        height = height or 100,
        func = func or function() print("No function assigned.") end,
        func_param = func_param,
        text = text or "Empty",
        button_x = 0,
        button_y = 0,
        text_x = 0,
        text_y = 0,
        type = 0,

        font = love.graphics.getFont(),
        draw = function(self, button_x, button_y, font, text_x, text_y, type)
            self.button_x = button_x
            self.button_y = button_y

            type = type or self.type

            if font then
                love.graphics.setFont(font)
            end

            if text_x then
                self.text_x = text_x + self.button_x
            else
                self.text_x = self.button_x
            end

            if text_y then
                self.text_y = text_y + self.button_y
            else
                self.text_y = self.button_y + (self.height / 2) - font:getBaseline() / 2
            end
            
            if type == 0 then
                love.graphics.setColor(White)
                love.graphics.rectangle("line", self.button_x, self.button_y, self.width, self.height)

                love.graphics.printf(self.text, self.text_x, self.text_y, self.width, "center")
            elseif type == 1 then
                love.graphics.setColor(White)
                love.graphics.rectangle("fill", self.button_x, self.button_y, self.width, self.height)

                love.graphics.setColor(Black)
                love.graphics.printf(self.text, self.text_x, self.text_y, self.width, "center")
            else
                love.graphics.setColor(White)
                love.graphics.rectangle(type, self.button_x, self.button_y, self.width, self.height)
            end

            love.graphics.setFont(FontM)
            love.graphics.setColor(White)
        end,

        pressCheck = function (self, mouse_x, mouse_y, IsHover)
            if (mouse_x >= self.button_x) and (mouse_x <= self.button_x + self.width) then
                if (mouse_y >= self.button_y) and (mouse_y <= self.button_y + self.height) then
                    if func and not IsHover then
                        PlaySound(sounds.inbetween)
                        if self.func_param then
                            self.func(self.func_param)
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