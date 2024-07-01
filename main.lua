local Block = require "Block"
local Grid = require "Grid"
local Button = require "Button"
local Player = require "Player"

local player_turn = 1

local game_state = {}
game_state.menu = true
game_state.running = false
game_state.pause = false
game_state.game_over = false

local buttons = {
    menu = {},
    running = {},
    pause = {},
    game_over = {}
}

function NewGame()
    for i = 1, 9 do
        grid[i].state = 0
    end
end

function ChangeState(from, to)
    if to == "running" then
        NewGame()
    end
    game_state[from] = false
    game_state[to] = true
end

function love.load()
    _G.window_w , _G.window_h = love.graphics.getDimensions()
    _G.box_l = 0.6 * window_w
    _G.box_x, _G.box_y = (window_w * 0.2), (window_h * 0.1)

    _G.grid = Grid(box_l, box_x, box_y)

    buttons.menu.play_game = Button("Play", ChangeState, "menu", "running", 100, 20)
    buttons.menu.exit_game = Button("Exit", love.event.quit, nil, nil, 100, 20)

    buttons.game_over.restart = Button("Restart", ChangeState, "game_over", "running", 100, 20)
    buttons.game_over.quit = Button("Return to Menu", ChangeState, "game_over", "menu", 100, 20)
end

function love.mousepressed(x, y, button)
    if button == 1 then
        if game_state.running then
            for i = 1, 9 do
                if grid[i]:pressCheck(x, y, i, player_turn) then
                    player_turn = SwitchTurn(player_turn)
                    _G.winner = CheckWinner(grid)
                    if winner then
                        ChangeState("running", "game_over")
                    end
                end
            end
        elseif game_state.menu then
            for i in pairs(buttons.menu) do
                buttons.menu[i]:pressCheck(x, y)
            end
        elseif game_state.game_over then
            for i in pairs(buttons.game_over) do
                buttons.game_over[i]:pressCheck(x, y)
            end
        end
    end
end

function love.update(dt)

end


function love.draw()
    if game_state.running then
        love.graphics.setColor(0,0,1)
        love.graphics.rectangle("fill", box_x, box_y, box_l, box_l)

        for i = 1,9 do
            grid[i]:draw()
        end

    elseif game_state.menu then
        buttons.menu.play_game:draw(10, 20, 35, 2)
        buttons.menu.exit_game:draw(10, 50, 35, 2)

    elseif game_state.game_over then
        buttons.game_over.restart:draw(10, 20, 30, 2)
        buttons.game_over.quit:draw(10, 50, 5, 2)

        love.graphics.setColor(1, 1, 1)
        if winner ~= 0 then
            love.graphics.print("Player " .. winner .. " wins!", 10, 70)
        else
            love.graphics.print("Tie!", 10, 70)
        end
            
    end
end