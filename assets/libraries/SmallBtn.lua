love.graphics.setDefaultFilter("nearest", "nearest")

mute_b = love.graphics.newImage('assets/sprites/Mute.png')
mute_w = love.graphics.newImage('assets/sprites/Mute_W.png')
audio1_b = love.graphics.newImage('assets/sprites/Audio_1.png')
audio1_w = love.graphics.newImage('assets/sprites/Audio_1W.png')
audio2_b = love.graphics.newImage('assets/sprites/Audio_2.png')
audio2_w = love.graphics.newImage('assets/sprites/Audio_2W.png')
audio3_b = love.graphics.newImage('assets/sprites/Audio_3.png')
audio3_w = love.graphics.newImage('assets/sprites/Audio_3W.png')

player_w = love.graphics.newImage('assets/sprites/Player_W.png')
player_b = love.graphics.newImage('assets/sprites/Player_B.png')
bot_w = love.graphics.newImage('assets/sprites/Bot_W.png')
bot_b = love.graphics.newImage('assets/sprites/Bot_B.png')

pause_b = love.graphics.newImage('assets/sprites/Pause.png')
pause_w = love.graphics.newImage('assets/sprites/Pause_2.png')

function SmallBtn(sprite_w, sprite_b, func, func_param, group)
    return {
        height = sprite_w:getHeight() or 20,
        width = sprite_b:getHeight() or 20,
        func = func or function() print("No function assigned.") end,
        func_param = func_param,
        button_x = 0,
        button_y = 0,
        type = 0,
        group = group or nil,

        draw = function(self, button_x, button_y, type)
            self.button_x = button_x
            self.button_y = button_y

            type = type or self.type
            
            love.graphics.setColor(White)
            if group == "Audio" then
                sprite_w = {mute_w, audio1_w, audio2_w, audio3_w}
                sprite_b = {mute_b, audio1_b, audio2_b, audio3_b}
                
                if type == 0 then
                    love.graphics.rectangle("fill", button_x - 2, button_y - 2, self.width + 4, self.height + 4)
                    love.graphics.draw(sprite_b[AudioLVL], button_x, button_y)
                elseif type == 1 then
                    love.graphics.rectangle("fill", button_x - 1, button_y - 1, self.width + 2, self.height + 2)
                    love.graphics.draw(sprite_w[AudioLVL], button_x, button_y)
                end
                goto skip
            end
                if type == 0 then
                    love.graphics.rectangle("fill", button_x - 2, button_y - 2, self.width + 4, self.height + 4)
                    love.graphics.draw(sprite_b, button_x, button_y)
                elseif type == 1 then
                    love.graphics.rectangle("fill", button_x - 1, button_y - 1, self.width + 2, self.height + 2)
                    love.graphics.draw(sprite_w, button_x, button_y)
                end
            ::skip::
            
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

return SmallBtn