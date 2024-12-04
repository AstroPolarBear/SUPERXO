json = require "assets/libraries/json"

function SaveData(key, value)
    local content = json.encode(value)
    local savefile = assert(io.open(key, "w"))
    savefile:write(content)
    io.close(savefile)
end

function LoadData(key)
    local value
    local savefile = io.open(key, "r")
    if savefile then
        local content = savefile:read("*all")
        value = json.decode(content)
        io.close(savefile)
    end
    return value
end

function VolCont(init)
    local playervol = LoadData("playervol")
    if not playervol then
        playervol = {1}

        SaveData("playervol", playervol)
    end

    if init then
        goto skip
    end

    if playervol[1] == 1.5 then
        playervol[1] = 0
    elseif playervol[1] ~= 1.5 then
        playervol[1] = playervol[1] + 0.5
    end

    SaveData("playervol", playervol)

    ::skip::
    local vol1 = 0.35 * playervol[1]
    local vol2 = 0.75 * playervol[1]
    AudioLVL = (playervol[1] * 2) + 1
    
    sounds.logo:setVolume(vol1)
    sounds.inbetween:setVolume(vol1)
    sounds.game_start:setVolume(vol1)
    sounds.win:setVolume(vol2)
end