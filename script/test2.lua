local Main

if getgc then
    for _, v in pairs(getgc(true)) do
        if typeof(v) == "table" and rawget(v, "DataManager") then
            Main = v
            break
        end
    end
end


if Main and Main.DataManager and Main.DataManager.currentChunk and Main.DataManager.currentChunk.regionData and Main.DataManager.currentChunk.regionData.Grass then
    Main.Battle.doWildBattle(Main.Battle, Main.DataManager.currentChunk.regionData.Grass, {})
end

local args = {
    [1] = Main.Battle.currentBattle,
    [2] = Main.Battle.currentBattle.yourSide.foe.active[1],
    [3] = {
        type = Main.Battle.currentBattle.lastRequest.active[1].moves[1].type,
        name = Main.Battle.currentBattle.lastRequest.active[1].moves[1].move,
        effectType = "Move",
        id = Main.Battle.currentBattle.lastRequest.active[1].moves[1].id,
        category = Main.Battle.currentBattle.lastRequest.active[1].moves[1].category
    },
    [4] = tostring(Main.Battle.currentBattle.yourSide.foe.active[1].energy) .. "/" .. tostring(Main.Battle.currentBattle.yourSide.foe.active[1].maxEnergy),
    [5] = Main.Battle.currentBattle.yourSide.active[1],
    [6] = {
        type = "Simple"
    }
}

Main.Battle.useMove(unpack(args))
