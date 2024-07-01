function SwitchTurn(current_turn)
    if current_turn == 1 then
                                                                    player = 2
    elseif current_turn == 2 then
        player = 1
    end

    return player
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

    if (grid[1].state == grid[5].state) and (grid[1].state ~= 0) then
        if grid[1].state == grid[9].state then
            print("Game Over! Player " .. grid[1].state .. " wins!")
            winner = grid[1].state
            return winner
        end
    end

    if (grid[3].state == grid[5].state) and (grid[3].state ~= 0) then
        if grid[3].state == grid[7].state then
            print("Game Over! Player " .. grid[3].state .. " wins!")
            winner = grid[3].state
            return winner
        end
    end

    for i = 1, 9 do
        if grid[i].state == 0 then
            return
        end
    end

    winner = 0
    return winner
end