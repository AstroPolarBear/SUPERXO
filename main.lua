-- require("lovedebug")

local rs = require "resolution_solution"
local Block = require "Block"
local Grid = require "Grid"
local Button = require "Button"
local Player = require "Player"
local Palette = require "Palette"

-- Screen Scaling --
rs.conf({
    game_width = 240 * 4,
    game_height = 135 * 4,
    scale_mode = rs.PIXEL_PERFECT_MODE
})
love.graphics.setDefaultFilter("nearest", "nearest")

rs.setMode(rs.game_width, rs.game_height)

love.resize = function(w, h)
    rs.resize(w, h)
end

function ScaleFont(BaseSize, BaseWidth, NewWidth)
    return BaseSize * (BaseWidth / NewWidth)
end

rs.resize_callback = function()
    -- font = love.graphics.newFont("Pixeltype.ttf", math.max(math.min(rs.game_zone.w * 0.03, rs.game_zone.h * 0.03), 30))
    FontL = love.graphics.newFont("Pixeltype.ttf", ScaleFont(96, 240 * 4, rs.game_width))
    FontM = love.graphics.newFont("Pixeltype.ttf", ScaleFont(48, 240 * 4, rs.game_width))
    FontS = love.graphics.newFont("Pixeltype.ttf", ScaleFont(24, 240 * 4, rs.game_width))
    love.graphics.setFont(FontM)
end


-- Resets game boards for both game modes
function NewGame()
    for i = 1, 9 do
        grid[i].state = 0
        grid[i].winner = false
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

-- In-Game menu button
function ShowMenu()
    if show_menu then
        show_menu = false
    else
        show_menu = true
    end
end

-- Changes game state
function ChangeState(to)
    -- When switching to either game mode, starts a new game
    if to == "xo" or to == "superxo" then
        NewGame()
    end

    for i in pairs(game_state) do
        game_state[i] = false
    end

    game_state[to] = true
end

-- Switches board on screen for Super game mode
function SetCam(grid)
    for i = 1,9 do
        supergrid[i].set_cam = false
    end

    supergrid[grid].set_cam = true
end

function love.load()
    -- For scaling
    rs.resize_callback()

    -- Custom Cursor
    _G.cursor1 = love.mouse.newCursor("sprites/Cursor1.png", 0, 0)
    _G.cursor2 = love.mouse.newCursor("sprites/Cursor2.png", 0, 0)
    _G.cursor3 = love.mouse.newCursor("sprites/Cursor3.png", 0, 0)
    love.mouse.setCursor(cursor1)

    -- Initiates game board
    _G.grid_area = love.graphics.newImage('sprites/Grid_Black2.png')

    -- Assigns screen size and board size to variables
    _G.window_w , _G.window_h = rs.game_width, rs.game_height
    _G.box_l = grid_area:getWidth()
    _G.box_x, _G.box_y = (window_w * 0.5) - (box_l * 0.5), (window_h * 0.5) - (box_l * 0.5)

    -- Creates a single tic tac toe board
    _G.grid = Grid(box_l, box_x, box_y)

    -- Creates 9 tic tac toe boards to be inside one table for Super mode
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

    -- Table of game states, menu is enabled by default
    _G.game_state = {}
    game_state.menu = true
    game_state.xo = false
    game_state.superxo = false

    -- Table to store buttons for each game state
    _G.buttons = {
        menu = {},
        xo = {},
        superxo = {},
    }

    -- Box sizes
    _G.sizeL_h = 0.15 * rs.game_height
    _G.sizeL_w = 0.80 * rs.game_width

    _G.sizeM_h = 0.10 * rs.game_height
    _G.sizeM_w = 0.20 * rs.game_width

    -- Creating buttons for each game state
    buttons.menu.play_standard = Button("STANDARD", ChangeState, "xo", sizeL_w, sizeL_h)
    buttons.menu.play_super = Button("SUPER", ChangeState, "superxo", sizeL_w, sizeL_h)
    buttons.menu.exit_game = Button("EXIT", love.event.quit, nil, sizeL_w, sizeL_h)

    buttons.xo.options = Button("P", ShowMenu, nil, 20, 20)
    buttons.xo.restart = Button("Restart", NewGame, nil, sizeM_w, sizeM_h)
    buttons.xo.quit = Button("Menu", ChangeState, "menu", sizeM_w, sizeM_h)

    buttons.superxo.options = Button("P", ShowMenu, nil, 20, 20)
    buttons.superxo.restart = Button("Restart", NewGame, nil, sizeM_w, sizeM_h)
    buttons.superxo.quit = Button("Menu", ChangeState, "menu", sizeM_w, sizeM_h)
    for i = 1,9 do
        buttons.superxo[i] = Button("", SetCam, i, 20, 20)
    end


    -- Initiating player turn, only the first game starts with player 1
    player_turn = 1
end

-- Press F11 for fullscreen
function love.keypressed(key, scancode, isrepeat)
	if key == "f11" then
		fullscreen = not fullscreen
		love.window.setFullscreen(fullscreen, "desktop")
	end
end

-- Detects mouse presses for each gamestate
function love.mousepressed(x, y, button)
    -- Grab coordinates after scaling
    x, y = rs.to_game(x, y)

    -- Make sure its left click
    if button == 1 then
        -- On press, uses Cursor 3
        love.mouse.setCursor(cursor3)


        if game_state.xo then

            -- Only menu buttons are active if Game over
            if winner ~= 0 then
                goto next
            end
            
            -- Places X or O on board depending on player turn
            for i = 1, 9 do
                if grid[i]:pressCheck(x, y) then
                    XorO(grid[i], player_turn)
                    player_turn = SwitchTurn(player_turn)
                    _G.winner = CheckWinner(grid)
                end
            end


        end

        if game_state.superxo then
            
            -- Only menu buttons are active if Game over
            if winner ~= 0 then
                goto next
            end

            -- Places X or O on the active board, depending on player turn
            for i = 1, 9 do
                if supergrid[i].active and supergrid[i].set_cam then
                    for j = 1, 9 do
                        if supergrid[i][j]:pressCheck(x, y) then
                            XorO(supergrid[i][j], player_turn)
                            supergrid[i].state = CheckWinner(supergrid[i])
                            SwitchBoard(j)
                            player_turn = SwitchTurn(player_turn)
                            _G.winner = CheckWinner(supergrid)
                        end
                    end
                end
            end

        end

        ::next::
        -- Buttons
        for i in pairs(game_state) do
            if game_state[i] then
                for j in pairs(buttons[i]) do
                    buttons[i][j]:pressCheck(x,y)
                end
            end
        end

    end
end

-- Switch to default cursor after mouse button is released
function love.mousereleased(x, y, button)
    if button == 1 then
        love.mouse.setCursor(cursor1)
    end
end

-- Changes cursor if its placed on clickable areas of the board or buttons
function love.mousemoved(x, y)
    x, y = rs.to_game(x, y)
    if game_state.xo then

        if winner ~= 0 then
            goto next
        end

        for i = 1, 9 do
            if grid[i]:pressCheck(x, y) then
                love.mouse.setCursor(cursor2)
                return
            end
        end

    end

    if game_state.superxo then
            
        if winner ~= 0 then
            goto next
        end

        for i = 1, 9 do
            if supergrid[i].active and supergrid[i].set_cam then
                for j = 1, 9 do
                    if supergrid[i][j]:pressCheck(x, y) then
                        love.mouse.setCursor(cursor2)
                        return
                    end
                end
            end
        end

    end

    ::next::
    for i in pairs(game_state) do
        if game_state[i] then
            for j in pairs(buttons[i]) do
                if buttons[i][j]:pressCheck(x, y, true) then
                    love.mouse.setCursor(cursor2)
                    buttons[i][j].type = 1
                    return
                else
                    buttons[i][j].type = 0
                end
            end
        end
    end

    love.mouse.setCursor(cursor1)
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
    -- For Scaling
    rs.push()
    local old_x, old_y, old_w, old_h = love.graphics.getScissor()
    love.graphics.setScissor(rs.get_game_zone())

    love.graphics.setBackgroundColor(Black)
    love.graphics.setLineWidth(2)

    if game_state.xo then
        love.graphics.setColor(White)
        love.graphics.setLineWidth(4)
        love.graphics.rectangle("line", box_x - 8, box_y - 8, box_l + 16, box_l + 16)
        love.graphics.setLineWidth(2)
        love.graphics.setColor(White)
        love.graphics.rectangle("fill", box_x, box_y, box_l, box_l)
        love.graphics.draw(grid_area, box_x, box_y)

        for i = 1,9 do
            grid[i]:draw()
        end

        -- During gameplay
        if winner == 0 then
            love.graphics.setColor(White)
            love.graphics.print("PLAYING:", 10, 70)
            love.graphics.print("Player " .. player_turn, 10, 100)
        end

        -- Menu
        buttons.xo.options:draw((window_w - 30), 20, FontS)
        if show_menu or winner ~= 0 then
            buttons.xo.restart:draw((window_w - 10 - sizeM_w), 45, FontM)
            buttons.xo.quit:draw((window_w - 10 - sizeM_w), 55 + sizeM_h, FontM)
        end

        -- Game over
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
        love.graphics.setLineWidth(2)
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

        -- Mini grid to switch board on screen
        local minigrid_x = window_w - 80
        local minigrid_y = window_h - 80
        local minigrid_spacing = 5
        for i = 1, 9 do

            buttons.superxo[i]:draw(minigrid_x, minigrid_y, nil, nil, 0, "line")
            if supergrid[i].active then
                love.graphics.setColor(White)
                love.graphics.rectangle("fill", minigrid_x + 5, minigrid_y + 5, 10, 10)
            end

            if supergrid[i].set_cam then
                buttons.superxo[i]:draw(minigrid_x, minigrid_y, nil, nil, 0, "fill")
                if supergrid[i].active then
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

        -- During gameplay
        if winner == 0 then
            love.graphics.setColor(White)
            love.graphics.print("TURN: Player " .. player_turn, 10, 90)
            for i = 1, 9 do
                if supergrid[i].active then
                    love.graphics.print("ACTIVE: Board " .. i, 10, 90 + (10 + sizeM_h))
                end
                if supergrid[i].set_cam then
                    love.graphics.print("VIEWING: Board " .. i, 10, 90 + (10 + sizeM_h)*2)
                end
            end
        end

        -- Menu
        buttons.superxo.options:draw((window_w - 30), 20, FontS)
        if show_menu or winner ~= 0 then
            buttons.superxo.restart:draw((window_w - 10 - sizeM_w), 45, FontM)
            buttons.superxo.quit:draw((window_w - 10 - sizeM_w), 55 + sizeM_h, FontM)
        end

        -- Game over
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

        buttons.menu.play_standard:draw((window_w * 0.5 - sizeL_w * 0.5), (window_h * 0.4), FontL)
        buttons.menu.play_super:draw((window_w * 0.5 - sizeL_w * 0.5), (window_h * 0.4 + sizeL_h + 10), FontL)
        buttons.menu.exit_game:draw((window_w * 0.5 - sizeL_w * 0.5), (window_h * 0.4  + (sizeL_h + 10) * 2), FontL)

    end
    love.graphics.setScissor(old_x, old_y, old_w, old_h)
    rs.pop()
end