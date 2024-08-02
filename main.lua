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

    for i = 1, 9 do
        supergrid[i].active = false
        supergrid[i].set_cam = false
        supergrid[i].state = 0
        for j = 1, 9 do
            supergrid[i][j].state = 0
        end
    end

    supergrid[1].active = true
    supergrid[1].set_cam = true

    show_menu = false

    winner = 0
end

function ShowMenu()
    if show_menu then
        show_menu = false
    else
        show_menu = true
    end
end

function ChangeState(from, to)
    if to == "xo" or to == "superxo" then
        NewGame()
    end

    for i in pairs(game_state) do
        game_state[i] = false
    end

    game_state[to] = true
end

function SetCam(grid)
    for i = 1,9 do
        supergrid[i].set_cam = false
    end

    supergrid[grid].set_cam = true
end

function love.load()
    _G.window_w , _G.window_h = love.graphics.getDimensions()
    _G.grid_area = love.graphics.newImage('sprites/Grid_Black.png')
    _G.box_l = grid_area:getWidth()
    _G.box_x, _G.box_y = (window_w * 0.5) - (box_l * 0.5), (window_h * 0.5) - (box_l * 0.5)

    _G.grid = Grid(box_l, box_x, box_y)
    _G.supergrid = {}

    for i = 1,9 do
        supergrid[i] = Grid(box_l, box_x, box_y)
        supergrid[i].active = false
        supergrid[i].set_cam = false
    end


    -- _G.bg_x = 20
    -- _G.bg_y = 20
    -- _G.star_size = 5
    -- _G.bg_counter = 0

    _G.game_state = {}
    game_state.menu = true
    game_state.xo = false
    game_state.superxo = false
    game_state.pick_mode = false

    _G.buttons = {
        menu = {},
        xo = {},
        superxo = {},
        pick_mode = {}
    }

    buttons.menu.play_game = Button("Play", ChangeState, "menu", "pick_mode", 100, 20)
    buttons.menu.exit_game = Button("Exit", love.event.quit, nil, nil, 100, 20)

    buttons.xo.options = Button("P", ShowMenu, nil, nil, 20, 20)
    buttons.xo.restart = Button("Restart", NewGame, nil, nil, 100, 20)
    buttons.xo.quit = Button("Return to Menu", ChangeState, "xo", "menu", 100, 20)

    buttons.superxo.options = Button("P", ShowMenu, nil, nil, 20, 20)
    buttons.superxo.restart = Button("Restart", NewGame, nil, nil, 100, 20)
    buttons.superxo.quit = Button("Return to Menu", ChangeState, "xo", "menu", 100, 20)
    for i = 1,9 do
        buttons.superxo[i] = Button("", SetCam, i, nil, 20, 20)
    end

    buttons.pick_mode.normal = Button("X O", ChangeState, "pick_mode", "xo", 100, 20)
    buttons.pick_mode.super = Button("SUPER X O", ChangeState, "pick_mode", "superxo", 100, 20)
    buttons.pick_mode.back = Button("BACK", ChangeState, "pick_mode", "menu", 100, 20)
end

function love.mousepressed(x, y, button)
    if button == 1 then

        if game_state.xo then

            if winner ~= 0 then
                goto other
            end
            
            for i = 1, 9 do
                if grid[i]:pressCheck(x, y, player_turn) then
                    player_turn = SwitchTurn(player_turn)
                    _G.winner = CheckWinner(grid)
                end
            end


        end

        if game_state.superxo then
            
            if winner ~= 0 then
                goto other
            end

            for i = 1, 9 do
                if supergrid[i].active and supergrid[i].set_cam then
                    for j = 1, 9 do
                        if supergrid[i][j]:pressCheck(x, y, player_turn) then
                            supergrid[i].state = CheckWinner(supergrid[i])
                            SwitchBoard(j)
                            player_turn = SwitchTurn(player_turn)
                            _G.winner = CheckWinner(supergrid)
                        end
                    end
                end
            end

        end

        ::other::
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

        buttons.xo.options:draw((window_w - 30), 20, 5, 2, "fill")

        if winner == 0 then
            love.graphics.setColor(White)
            love.graphics.print("PLAYING:", 10, 70)
            love.graphics.print("Player " .. player_turn, 10, 90)
        end

        if show_menu or winner ~= 0 then
            buttons.xo.restart:draw(5, 5, 30, 2, "fill")
            buttons.xo.quit:draw(5, 45, 4, 2, "fill")
        end

        if winner ~= 0 then
            love.graphics.setColor(White)
            if winner ~= 0 and winner < 3 then
                love.graphics.print("Player " .. winner .. " wins!", 10, 70)
            else
                love.graphics.print("Tie!", 10, 70)
            end
        end
    
    elseif game_state.superxo then
        love.graphics.setColor(White)
        love.graphics.setLineWidth(4)
        love.graphics.rectangle("line", box_x - 8, box_y - 8, box_l + 16, box_l + 16)
        love.graphics.setColor(White)
        love.graphics.rectangle("fill", box_x, box_y, box_l, box_l)
        love.graphics.draw(grid_area, box_x, box_y)

        for i = 1, 9 do
            if supergrid[i].set_cam then
                for j = 1,9 do
                    supergrid[i][j]:draw()
                end
            end
        end

        local minigrid_x = window_w - 80
        local minigrid_y = window_h - 80
        local minigrid_spacing = 5
        for i = 1, 9 do
            love.graphics.setLineWidth(2)

            buttons.superxo[i]:draw(minigrid_x, minigrid_y, nil, nil, "line")
            if supergrid[i].set_cam then
                love.graphics.setColor(White)
                love.graphics.rectangle("fill", minigrid_x + 5, minigrid_y + 5, 10, 10)
            end

            if supergrid[i].active then
                buttons.superxo[i]:draw(minigrid_x, minigrid_y, nil, nil, "fill")
                if supergrid[i].set_cam then
                    love.graphics.setColor(Black)
                    love.graphics.rectangle("fill", minigrid_x + 5, minigrid_y + 5, 10, 10)
                    love.graphics.setColor(White)
                end
            end

            minigrid_x = minigrid_x + 20 + minigrid_spacing
            if i % 3 == 0 then
                minigrid_x = window_w - 80
                minigrid_y = minigrid_y + 20 + minigrid_spacing
            end
        end
        buttons.superxo.options:draw((window_w - 30), 20, 5, 2, "fill")

        if winner == 0 then
            love.graphics.setColor(White)
            love.graphics.print("PLAYING:", 10, 70)
            love.graphics.print("Player " .. player_turn, 10, 90)
            for i = 1, 9 do
                if supergrid[i].active then
                    love.graphics.print("Board " .. i, 10, 110)
                end
                if supergrid[i].set_cam then
                    love.graphics.print("Viewing Board " .. i, 10, 130)
                end
            end
        end

        if show_menu or winner ~= 0 then
            buttons.superxo.restart:draw(5, 5, 30, 2, "fill")
            buttons.superxo.quit:draw(5, 45, 4, 2, "fill")
        end

        if winner ~= 0 then
            love.graphics.setColor(White)
            if winner ~= 0 and winner < 3 then
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

        buttons.menu.play_game:draw((window_w * 0.5 - 60), (window_h * 0.5), 35, 2, "fill")
        buttons.menu.exit_game:draw((window_w * 0.5 - 60), (window_h * 0.5 + 30), 35, 2, "fill")

    elseif game_state.pick_mode then
        buttons.pick_mode.normal:draw((window_w * 0.5 - 60), (window_h * 0.3), 35, 2, "fill")
        buttons.pick_mode.super:draw((window_w * 0.5 - 60), (window_h * 0.3 + 30), 15, 2, "fill")
        buttons.pick_mode.back:draw((window_w * 0.5 - 60), (window_h * 0.3 + 60), 35, 2, "fill")
    end
end