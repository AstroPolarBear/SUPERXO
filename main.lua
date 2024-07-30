require("lovedebug")

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

    show_menu = false

    winner = nil
end

function ShowMenu()
    if show_menu then
        show_menu = false
    else
        show_menu = true
    end
end

function ChangeState(from, to)
    if to == "xo" then
        NewGame()
    end

    for i in pairs(game_state) do
        game_state[i] = false
    end

    game_state[to] = true
end

function love.load()
    _G.window_w , _G.window_h = love.graphics.getDimensions()
    _G.grid_area = love.graphics.newImage('sprites/Grid_Black.png')
    _G.box_l = grid_area:getWidth()
    _G.box_x, _G.box_y = (window_w * 0.5) - (box_l * 0.5), (window_h * 0.5) - (box_l * 0.5)

    _G.grid = Grid(box_l, box_x, box_y)
    

    -- _G.bg_x = 20
    -- _G.bg_y = 20
    -- _G.star_size = 5
    -- _G.bg_counter = 0

    _G.game_state = {}
    game_state.menu = true
    game_state.xo = false
    game_state.pick_mode = false

    _G.buttons = {
        menu = {},
        xo = {},
        pick_mode = {}
    }

    buttons.menu.play_game = Button("Play", ChangeState, "menu", "pick_mode", 100, 20)
    buttons.menu.exit_game = Button("Exit", love.event.quit, nil, nil, 100, 20)
    
    buttons.xo.options = Button("P", ShowMenu, nil, nil, 20, 20)
    buttons.xo.restart = Button("Restart", NewGame, nil, nil, 100, 20)
    buttons.xo.quit = Button("Return to Menu", ChangeState, "xo", "menu", 100, 20)

    buttons.pick_mode.normal = Button("X O", ChangeState, "pick_mode", "xo", 100, 20)
    buttons.pick_mode.super = Button("SUPER X O", nil, nil, nil, 100, 20)
    buttons.pick_mode.back = Button("BACK", ChangeState, "pick_mode", "menu", 100, 20)
end

function love.mousepressed(x, y, button)
    if button == 1 then

        if game_state.xo then
            
            if not winner then
                for i = 1, 9 do
                    if grid[i]:pressCheck(x, y, i, player_turn) then
                        player_turn = SwitchTurn(player_turn)
                        _G.winner = CheckWinner(grid)
                    end
                end
            end

        end

        for i in pairs(game_state) do
            if game_state[i] then
                for j in pairs(buttons[i]) do
                    buttons[i][j]:pressCheck(x,y)
                end
            end
        end
        
    end
end

function love.update(dt)
    -- bg_counter = bg_counter + 1
    -- if bg_counter == 60 then
    --     _G.bg_star = true
    -- elseif bg_counter == 90 then
    --     bg_star = false
    --     bg_counter = 0
    -- end
end

function love.draw()
    love.graphics.setBackgroundColor(Black)
    if game_state.xo then
        love.graphics.setColor(White)
        love.graphics.setLineWidth(4)
        love.graphics.rectangle("line", box_x - 8, box_y - 8, box_l + 16, box_l + 16)
        love.graphics.setColor(White)
        love.graphics.rectangle("fill", box_x, box_y, box_l, box_l)
        love.graphics.draw(grid_area, box_x, box_y)

        for i = 1,9 do
            grid[i]:draw()
        end
        
        buttons.xo.options:draw((window_w - 30), 20, 5, 2)

        if not winner then
            love.graphics.setColor(White)        
            love.graphics.print("PLAYING:", 10, 70)
            love.graphics.print("Player " .. player_turn, 10, 90)            
        end

        if show_menu or winner then
            buttons.xo.restart:draw(5, 5, 30, 2)
            buttons.xo.quit:draw(5, 45, 4, 2)
        end

        if winner then
            love.graphics.setColor(White)
            if winner ~= 0 then
                love.graphics.print("Player " .. winner .. " wins!", 10, 70)
            else
                love.graphics.print("Tie!", 10, 70)
            end
        end

    elseif game_state.menu then
        love.graphics.setColor(White)
        -- love.graphics.rectangle("fill", bg_x, bg_y, star_size, star_size)
        -- if bg_star == true then
        --     love.graphics.rectangle("fill", bg_x + star_size, bg_y, star_size, star_size)
        --     love.graphics.rectangle("fill", bg_x , bg_y + star_size, star_size, star_size)
        --     love.graphics.rectangle("fill", bg_x, bg_y - star_size, star_size, star_size)
        --     love.graphics.rectangle("fill", bg_x - star_size, bg_y, star_size, star_size)
        -- end
        love.graphics.print("Super Tic Tac Toe!", (window_w * 0.415), (window_h * 0.3))

        buttons.menu.play_game:draw((window_w * 0.5 - 60), (window_h * 0.5), 35, 2)
        buttons.menu.exit_game:draw((window_w * 0.5 - 60), (window_h * 0.5 + 30), 35, 2)
    elseif game_state.pick_mode then
        buttons.pick_mode.normal:draw((window_w * 0.5 - 60), (window_h * 0.3), 35, 2)
        buttons.pick_mode.super:draw((window_w * 0.5 - 60), (window_h * 0.3 + 30), 15, 2)
        buttons.pick_mode.back:draw((window_w * 0.5 - 60), (window_h * 0.3 + 60), 35, 2)
    end
end