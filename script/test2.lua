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

-- i dont know good arguments lol
local args = {
    
}

Main.Battle.useMove(unpack(args))
