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

function SwitchBoard(b)
    if supergrid[b].state ~= 0 then
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

function CheckWinner(grid)
    for i = 1, 7, 3 do
        if (grid[i].state == grid[i+1].state) and (grid[i].state ~= 0) then
            if grid[i].state == grid[i+2].state then
                print("Game Over! Player " .. grid[i].state .. " wins!")
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
                print("Game Over! Player " .. grid[i].state .. " wins!")
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
                print("Game Over! Player " .. grid[1 + i].state .. " wins!")
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