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

        draw = function(self, button_x, button_y, text_x, text_y)
            self.button_x = button_x
            self.button_y = button_y
            self.text_x = text_x
            self.text_y = text_y
        end
    }
end