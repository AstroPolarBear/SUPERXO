local rs = require "assets/libraries/scaling/resolution_solution"
local Block = require "assets/libraries/Block"
local Grid = require "assets/libraries/Grid"
local Button = require "assets/libraries/Button"
local Player = require "assets/libraries/Player"
local Palette = require "assets/libraries/Palette"

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
    FontL = love.graphics.newFont("assets/fonts/Pixeltype.ttf", ScaleFont(96, 240 * 4, rs.game_width))
    FontM = love.graphics.newFont("assets/fonts/Pixeltype.ttf", ScaleFont(48, 240 * 4, rs.game_width))
    FontS = love.graphics.newFont("assets/fonts/Pixeltype.ttf", ScaleFont(32, 240 * 4, rs.game_width))
    love.graphics.setFont(FontM)
end

-- Debug
if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
    require("lldebugger").start()
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
            supergrid[i][j].winner = false
        end
        mini_winner[i] = false
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

    -- Restart animations/sounds
    RestartDelayOrder()
end

-- Switches board on screen for Super game mode
function SetCam(grid)
    for i = 1,9 do
        supergrid[i].set_cam = false
    end

    supergrid[grid].set_cam = true
end

function Delay()
    for i in pairs(game_state) do
        if game_state[i] then
            for j in pairs(delay_order[i]) do
                if Timer < 0 and not delay_order[i][j] then
                    delay_order[i][j] = true
                    audio_order[i][j]:play()
                    if j == 1 then
                        Timer = 1.5
                    else
                        Timer = 0.5
                    end
                elseif delay_order[i][j] then
                    goto next
                else
                    return
                end
                ::next::
            end
        end
    end
end

function RestartDelayOrder()
    for i in pairs(game_state) do
        for j = 1, delay_instances[i] do
            delay_order[i][j] = false
        end
    end
    Timer = 1
end

function love.load(arg)
    -- Debug
    if arg and arg[#arg] == "-debug" then require("mobdebug").start() end
    -- For scaling
    rs.resize_callback()

    -- Custom Cursor
    _G.cursor1 = love.mouse.newCursor("assets/sprites/Cursor1.png", 0, 0)
    _G.cursor2 = love.mouse.newCursor("assets/sprites/Cursor2.png", 0, 0)
    _G.cursor3 = love.mouse.newCursor("assets/sprites/Cursor3.png", 0, 0)
    love.mouse.setCursor(cursor1)

    -- Initiates game board
    _G.grid_area = love.graphics.newImage('assets/sprites/Grid_Black2.png')
    _G.logo = love.graphics.newImage('assets/sprites/LOGO.png')

    -- Loads in sound files
    _G.sounds = {}
    sounds.logo = love.audio.newSource('assets/sounds/logo-beep.mp3', "static")
    sounds.logo:setVolume(0.5)
    sounds.inbetween = love.audio.newSource('assets/sounds/inbetween-beep.mp3', "static")
    sounds.inbetween:setVolume(0.5)
    sounds.game_start = love.audio.newSource('assets/sounds/game-start-beep.mp3', "static")
    sounds.game_start:setVolume(0.5)
    sounds.win = love.audio.newSource('assets/sounds/winner-beep.mp3', "static")

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

    -- Table to store order of appearance (visual&audio)
    _G.delay_instances = {}
    delay_instances.menu = 4
    delay_instances.xo = 3
    delay_instances.superxo = 4

    _G.delay_order = {}
    _G.audio_order = {}
    for i in pairs(game_state) do
        delay_order[i] = {}
        audio_order[i] = {}
    end

    audio_order["menu"][1] = sounds.logo
    audio_order["xo"][1] = sounds.game_start
    audio_order["superxo"][1] = sounds.game_start
    for i in pairs(game_state) do
        for j = 2, delay_instances[i] do
            audio_order[i][j] = sounds.inbetween
        end
    end

    -- Initiate all orders to the beginning
    RestartDelayOrder()

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
        buttons.superxo[i] = Button("", SetCam, i, 40, 40)
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
                    sounds.inbetween:play()
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
                            sounds.inbetween:play()
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

-- For animation
Counter = 0
mini_winner = {}

function love.update(dt)

    if Timer > -1 then
        Timer = Timer - dt
    end

    Delay()

    if winner ~= 0 then
        if game_state.superxo then
            Counter = Counter + dt
            if Counter >= 0.5 then
                for i = 1,9 do
            if supergrid[i].winner then
                if mini_winner[i] then
                    mini_winner[i] = false
                else
                      mini_winner[i] = true
                    end
                    end
                end
                Counter = 0
            end
        end
    end
end

function love.draw()
    -- For Scaling
    rs.push()
    local old_x, old_y, old_w, old_h = love.graphics.getScissor()
    love.graphics.setScissor(rs.get_game_zone())

    love.graphics.setBackgroundColor(Black)
    love.graphics.setLineWidth(2)

    local leftpos_x = 30
    local leftpos_y = 30
    local rightpos_x = (window_w - 10 - sizeM_w)
    local rightpos_y = 200
    if game_state.xo then
        if delay_order.xo[1] then
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
        end

        if delay_order.xo[3] then
            -- During gameplay
            if winner == 0 then
                love.graphics.setColor(White)
                love.graphics.print("PLAYING:", 10, leftpos_y)
                love.graphics.print("PLAYER " .. player_turn, 10, leftpos_y + 30)
            end
        end

        if delay_order.xo[2] then
            -- Menu
            buttons.xo.options:draw((window_w - 30), 20, FontS)
            if show_menu or winner ~= 0 then
                buttons.xo.restart:draw(rightpos_x, 45, FontM)
                buttons.xo.quit:draw(rightpos_x, 55 + sizeM_h, FontM)
            end
        end
        
        -- Game over
        if winner ~= 0 then
            love.graphics.setColor(White)
            if winner ~= 0 and winner < 3 then
                love.graphics.print("PLAYER " .. winner, rightpos_x, rightpos_y)
                love.graphics.print("WINS!", rightpos_x, rightpos_y + 30)
            else
                love.graphics.print("TIE!", rightpos_x, rightpos_y)
            end
        end
    
    elseif game_state.superxo then
        if delay_order.superxo[1] then
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
        end

        if delay_order.superxo[4] then
            -- Mini grid to switch board on screen
            minigrid_boxsize = 20
            minigrid_x = leftpos_x
            minigrid_y = leftpos_y + 300
            minigrid_spacing = 25
            for i = 1, 9 do

                if supergrid[i].set_cam then
                    minigrid_color = "light"
                else
                    minigrid_color = "dark"
                end


                DrawMinigrid(i, minigrid_x, minigrid_y, minigrid_boxsize, minigrid_color)

                if mini_winner[i] then
                    love.graphics.rectangle("line", minigrid_x - 1, minigrid_y - 1, (minigrid_boxsize * 2) + 2, (minigrid_boxsize * 2) + 2)
                end

                minigrid_x = minigrid_x + 20 + minigrid_spacing
                if i % 3 == 0 then
                    minigrid_x = leftpos_x
                    minigrid_y = minigrid_y + 20 + minigrid_spacing
                end
            end
        end

        if delay_order.superxo[3] then
            -- During gameplay
            local count = 0
            local active = nil
            local nonactive = nil
            if winner == 0 then
                love.graphics.setColor(White)
                love.graphics.print("PLAYING:", 10, leftpos_y)
                love.graphics.print("PLAYER " .. player_turn, 10, leftpos_y + 30)
                for i = 1, 9 do
                    if supergrid[i].active then
                        count = count + 1
                        active = i
                    else
                        nonactive = i
                    end
                    if supergrid[i].set_cam then
                        love.graphics.print("VIEWING:", 10, leftpos_y + 40 + (10 + sizeM_h)*2)
                        love.graphics.print("BOARD " .. i, 10, leftpos_y + 70 + (10 + sizeM_h)*2)
                    end
                end
                if count > 1 then
                    love.graphics.print("ACTIVE:", 10, leftpos_y + 20 + (10 + sizeM_h))
                    love.graphics.print("ALL EXCEPT " .. nonactive, 10, leftpos_y + 50 + (10 + sizeM_h))
                else
                    love.graphics.print("ACTIVE:", 10, leftpos_y + 20 + (10 + sizeM_h))
                    love.graphics.print("BOARD " .. active, 10, leftpos_y + 50 + (10 + sizeM_h))
                end
            end
        end

        if delay_order.superxo[2] then
            -- Menu
            buttons.superxo.options:draw((window_w - 30), 20, FontS)
            if show_menu or winner ~= 0 then
                buttons.superxo.restart:draw((window_w - 10 - sizeM_w), 45, FontM)
                buttons.superxo.quit:draw((window_w - 10 - sizeM_w), 55 + sizeM_h, FontM)
            end
        end

        -- Game over
        if winner ~= 0 then
            love.graphics.setColor(White)
            if winner ~= 0 and winner < 3 then
                love.graphics.print("PLAYER " .. winner, rightpos_x, rightpos_y)
                love.graphics.print("WINS!", rightpos_x, rightpos_y + 30)
            else
                love.graphics.print("TIE!", rightpos_x, rightpos_y)
            end
        end

    elseif game_state.menu then
        love.graphics.setColor(White)
        if delay_order.menu[1] then
            love.graphics.draw(logo, 32 * 4, 8 * 4)
        end
        if delay_order.menu[2] then
            buttons.menu.play_standard:draw((window_w * 0.5 - sizeL_w * 0.5), (window_h * 0.4), FontL)
        end
        if delay_order.menu[3] then
            buttons.menu.play_super:draw((window_w * 0.5 - sizeL_w * 0.5), (window_h * 0.4 + sizeL_h + 10), FontL)
        end    
        if delay_order.menu[4] then    
            buttons.menu.exit_game:draw((window_w * 0.5 - sizeL_w * 0.5), (window_h * 0.4  + (sizeL_h + 10) * 2), FontL)
        end
    end
    love.graphics.setScissor(old_x, old_y, old_w, old_h)
    -- love.graphics.print(Timer, 0, 0)
    rs.pop()
end