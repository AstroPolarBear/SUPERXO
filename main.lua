if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
  end

function love.load()
    

end

function love.update(dt)

end


function love.draw()
    local window_w , window_h = love.graphics.getDimensions()
    local box_l = 0.6 * window_w
    local box_x, box_y = (window_w * 0.2), (window_h * 0.1)

    love.graphics.setColor(0,0,1)
    love.graphics.rectangle("fill", box_x, box_y, box_l, box_l)

    local slot_l = 0.3 * box_l
    local slot_x = box_x
    local slot_y = box_y

    love.graphics.setColor(1,1,1)
    for i = 1, 3, 1 do
        for j = 1, 3, 1 do
            love.graphics.rectangle("fill", slot_x, slot_y, slot_l, slot_l)
            slot_x = slot_x + slot_l + (0.05 * box_l)            
        end
        slot_x = box_x
        slot_y = slot_y + slot_l + (0.05 * box_l)
    end
end

function love.mousepressed(mx, my, button)
    if button == 1 and then
        
    end
end