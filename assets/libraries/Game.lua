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
        supergrid[i].winner = false
        for j = 1, 9 do
            supergrid[i][j].state = 0
            supergrid[i][j].winner = 0
        end
        mini_winner[i] = false
    end

    supergrid[1].active = true
    supergrid[1].set_cam = true

    show_menu = false

    _G.winner = 0
    _G.player_turn = 1
    _G.tiebreak = false
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
    if to == "modexo" then
        to = "mode"
        Dest = "xo"
    elseif to == "modesuper" then
        to = "mode"
        Dest = "superxo"
    elseif to == "normal" then
        to = Dest
        BotPlay = false
        NewGame()
    elseif to == "bot" then
        to = Dest
        BotPlay = true
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

-- Plays sound effect depending on input
function PlaySound(sound, pitch)
    if pitch == 1 then
        sound:setPitch(0.8)
    elseif pitch == 2 then
        sound:setPitch(1.2)
    else
        sound:setPitch(1)
    end

    -- Allows sound effect to work properly when spamming X and O
    if sound:isPlaying() then
        sound:stop()
        sound:play()
    else
        sound:play()
    end
end

function XorO(block, player)
    if player == 1 then
        block.state = 1
    elseif player == 2 then
        block.state = 2
    end
end

function SwitchTurn(current_turn)
    if current_turn == 1 then
        player = 2
    elseif current_turn == 2 then
        player = 1
    end

    return player
end

-- FOR SUPERXO
-- Switches active board after plyaer turn
function SwitchBoard(b)
    if supergrid[b].state ~= 0 then
        for i = 1, 9 do
            supergrid[i].active = false
        end
        for i = 1, 9 do
            if supergrid[i].state == 0 then
                supergrid[i].active = true
            end
        end
    else
        for i = 1, 9 do
            supergrid[i].active = false
        end
        supergrid[b].active = true
    end
end

-- Makes the mini grid dynamic, changing color on press and showing winner of board.
function DrawMinigrid(i, x, y, boxsize, color)
    if color == "dark" then
        buttons.superxo[i]:draw(x, y, nil, nil, 0, "line")
        love.graphics.setColor(White)
    elseif color == "light" then
        buttons.superxo[i]:draw(x, y, nil, nil, 0, "fill")
        love.graphics.setColor(Black)
    end

    if supergrid[i].state == 1 then
        love.graphics.printf("X", x, y + boxsize - (FontM:getBaseline() / 2), boxsize * 2 + 2, "center")
    elseif supergrid[i].state == 2 then
        love.graphics.printf("O", x, y + boxsize - (FontM:getBaseline() / 2), boxsize * 2 + 2, "center")
    end

    if supergrid[i].active and winner == 0 then
        love.graphics.rectangle("fill", x + (boxsize / 2), y + (boxsize / 2), boxsize, boxsize)
    end
    love.graphics.setColor(White)
end

-- Checks for 3 Xs or 3 Os in a row in all 8 directions.
function CheckWinner(grid)
    for i = 1, 7, 3 do
        if (grid[i].state == grid[i+1].state) and (grid[i].state ~= 0) then
            if grid[i].state == grid[i+2].state then
                sounds.win:play()
                winner = grid[i].state
                
                for j = 0, 2, 1 do
                    grid[i + j].winner = true
                end

                return winner
            end
        end
    end

    for i = 1, 3, 1 do
        if (grid[i].state == grid[i+3].state) and (grid[i].state ~= 0) then
            if grid[i].state == grid[i+6].state then
                sounds.win:play()
                winner = grid[i].state

                for j = 0, 6, 3 do
                    grid[i + j].winner = true
                end

                return winner
            end
        end
    end

    for i = 0, 2, 2 do
        if (grid[1 + i].state == grid[5].state) and (grid[1 + i].state ~= 0) then
            if grid[1 + i].state == grid[9 - i].state then
                sounds.win:play()
                winner = grid[1 + i].state

                local iter = 0
                for count = 1, 3 do
                    grid[(1 + i) + iter].winner = true
                    iter = iter + (4 - i)
                end

                return winner
            end
        end
    end

    for i = 1, 9 do
        if grid[i].state == 0 then
            winner = 0
            return winner
        end
    end

    winner = 3
    return winner
end

function TieBreaker(supergrid)
    if winner == 3 then
        local counter1 = 0
        local counter2 = 0
        for i = 1, 9 do
            if supergrid[i].state == 1 then
                counter1 = counter1 + 1
            elseif supergrid[i].state == 2 then
                counter2 = counter2 + 1
            end
        end

        if counter1 > counter2 then
            _G.winner = 1
            _G.tiebreak = true
        elseif counter2 > counter1 then
            _G.winner = 2
            _G.tiebreak = true
        else
            _G.winner = 3
        end
    end
end

function BotTurn(mode)
    local EmptyBlocks = {}
    local j = 1
    if Timer < 0 and winner == 0 then
        if mode == "xo" then
            for i = 1, 9 do
                if grid[i].state == 0 then
                    EmptyBlocks[j] = i
                    j = j + 1
                end
            end
            local RandomBlock = EmptyBlocks[math.random(j - 1)]
            grid[RandomBlock].state = 2
            PlaySound(sounds.inbetween, player_turn)
            player_turn = SwitchTurn(player_turn)
            _G.winner=CheckWinner(grid)
        elseif mode == "superxo" then
            for i = 1, 9 do
                if supergrid[i].active and not supergrid[i].set_cam then
                    SetCam(i)
                    Timer = 1
                    goto skip
                elseif supergrid[i].active then
                    for k = 1, 9 do
                        if supergrid[i][k].state == 0 then
                            EmptyBlocks[j] = k
                            j = j + 1
                        end
                    end
                    local RandomBlock = EmptyBlocks[math.random(j - 1)]
                    supergrid[i][RandomBlock].state = 2
                    PlaySound(sounds.inbetween, player_turn)
                    supergrid[i].state = CheckWinner(supergrid[i])
                    SwitchBoard(RandomBlock)
                    player_turn = SwitchTurn(player_turn)
                    _G.winner = CheckWinner(supergrid)
                    goto skip
                end
            end
        end

        ::skip::
        for i = 1, j do
            EmptyBlocks[i] = nil
        end
    end
end