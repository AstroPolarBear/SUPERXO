-- require("lovedebug")

local Block = require "Block"
local Grid = require "Grid"
local Button = require "Button"
local Player = require "Player"
local Palette = require "Palette"

local player_turn = 1

function NewGame()
    for i = 1, 9 do
        grid[i].state = 0
    end
end

function Pause()
    if game_state.paused then
        game_state.paused = false
    else
        game_state.paused = true
    end
end

function ChangeState(from, to)
    if to == "running" then
        NewGame()
    end

    for i in pairs(game_state) do
        game_state[i] = false
    end

    game_state[to] = true
end

function love.load()
    _G.window_w , _G.window_h = love.graphics.getDimensions()
    _G.box_l = 0.6 * window_w
    _G.box_x, _G.box_y = (window_w * 0.2), (window_h * 0.1)

    _G.grid = Grid(box_l, box_x, box_y)

    _G.game_state = {}
    game_state.menu = true
    game_state.running = false
    game_state.paused = false
    game_state.game_over = false

    _G.buttons = {
        menu = {},
        running = {},
        paused = {},
        game_over = {}
    }
    buttons.menu.play_game = Button("Play", ChangeState, "menu", "running", 100, 20)
    buttons.menu.exit_game = Button("Exit", love.event.quit, nil, nil, 100, 20)
    
    buttons.game_over.restart = Button("Restart", ChangeState, "game_over", "running", 100, 20)
    buttons.game_over.quit = Button("Return to Menu", ChangeState, "game_over", "menu", 100, 20)
    
    buttons.running.pause = Button("P", Pause, nil, nil, 20, 20)
    
    buttons.paused.resume = Button("Resume", Pause, nil, nil, 100, 20)
    buttons.paused.quit = Button("Return to Menu", ChangeState, "running", "menu", 100, 20)
end

function love.mousepressed(x, y, button)
    if button == 1 then
        if game_state.running and game_state.paused then
            for i in pairs(buttons.paused) do
                buttons.paused[i]:pressCheck(x, y)
            end
        elseif game_state.running then
            for i in pairs(buttons.running) do
                buttons.running[i]:pressCheck(x, y)
            end
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
        White()
        love.graphics.rectangle("fill", box_x, box_y, box_l, box_l)

        for i = 1,9 do
            Black()
            grid[i]:draw()
        end
        
        if game_state.paused then
            love.graphics.setColor(0, 0, 0, 0.8)
            love.graphics.rectangle("fill", 0, 0, window_w, window_h)

            buttons.paused.resume:draw(10, 20, 25, 2)
            buttons.paused.quit:draw(10, 50, 3, 2)
        else
            buttons.running.pause:draw((window_w - 30), 20, 5, 2)
        end

    elseif game_state.menu then
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("Super Tic Tac Toe!", (window_w * 0.415), (window_h * 0.3))

        buttons.menu.play_game:draw((window_w * 0.5 - 60), (window_h * 0.5), 35, 2)
        buttons.menu.exit_game:draw((window_w * 0.5 - 60), (window_h * 0.5 + 30), 35, 2)
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