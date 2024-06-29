if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
  end

local Block = require "Block"

local Grid = require "Grid"

local Player = require "Player"
local player_turn = 1

local game_state = {}
game_state.menu = false
game_state.running = true
game_state.pause = false
game_state.game_over = false

function love.load()
    _G.window_w , _G.window_h = love.graphics.getDimensions()
    _G.box_l = 0.6 * window_w
    _G.box_x, _G.box_y = (window_w * 0.2), (window_h * 0.1)

    _G.grid = Grid(box_l, box_x, box_y)
end

function love.mousepressed(x, y, button)
    if button == 1 then
        if game_state.running then
            for i = 1, 9, 1 do
                if grid[i]:pressCheck(x, y, i, player_turn) then
                    player_turn = SwitchTurn(player_turn)
                    CheckWinner(grid)
                end
            end
        end
    end
end

function love.update(dt)

end


function love.draw()
    love.graphics.setColor(0,0,1)
    love.graphics.rectangle("fill", box_x, box_y, box_l, box_l)

    if game_state.running then
        for i = 1, 9, 1 do
            grid[i]:draw()
        end
    end
end