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
            supergrid[i].active = true
        end
        supergrid[b].active = false
    else
        for i = 1, 9 do
            supergrid[i].active = false
        end
        supergrid[b].active = true
    end
end

function CheckWinner(grid)
    for i = 1, 7, 3 do
        if (grid[i].state == grid[i+1].state) and (grid[i].state ~= 0) then
            if grid[i].state == grid[i+2].state then
                print("Game Over! Player " .. grid[i].state .. " wins!")
                winner = grid[i].state
                return winner
            end
        end
    end

    for i = 1, 3, 1 do
        if (grid[i].state == grid[i+3].state) and (grid[i].state ~= 0) then
            if grid[i].state == grid[i+6].state then
                print("Game Over! Player " .. grid[i].state .. " wins!")
                winner = grid[i].state
                return winner
            end
        end
    end

    for i = 0, 2, 2 do
        if (grid[1 + i].state == grid[5].state) and (grid[1 + i].state ~= 0) then
            if grid[1 + i].state == grid[9 - i].state then
                print("Game Over! Player " .. grid[1 + i].state .. " wins!")
                winner = grid[1 + i].state
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