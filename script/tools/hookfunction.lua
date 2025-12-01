local Main

if getgc then
    for _, v in pairs(getgc(true)) do
        if typeof(v) == "table" and rawget(v, "DataManager") then
            Main = v
            break
        end
    end
end

if not Main then 
    warn("Main non trouvé")
    return 
end

local function dumpTable(o, depth, visited)
    depth = depth or 0
    visited = visited or {}
    
    if type(o) == 'table' then
        if visited[o] then return "{CIRCULAR REFERENCE}" end
        visited[o] = true
        
        local s = '{\n'
        for k,v in pairs(o) do
            local key = type(k) == 'number' and '['..k..']' or tostring(k)
            s = s .. string.rep("  ", depth + 1) .. key .. " = " .. dumpTable(v, depth + 1, visited) .. ",\n"
        end
        return s .. string.rep("  ", depth) .. '}'
    else
        return tostring(o)
    end
end

-- Analyse de la fonction
local fn = Main.Battle.useMove
local arity = debug.info(fn, "a")
print("Arity (nombre d'arguments attendus) :", arity) -- Devrait afficher 6

-- Pour remplir correctement la fonction, nous devons savoir ce que sont les arguments 3, 4, 5 et 6.
-- (Le 1er est self, le 2ème est l'attaque).
-- Nous allons installer un "hook" pour espionner les appels légitimes du jeu.

local oldUseMove = Main.Battle.useMove

-- Vérifie si on a déjà hooké pour éviter de le faire 2 fois
if not getgenv().isUseMoveHooked then
    getgenv().isUseMoveHooked = true
    
    Main.Battle.useMove = function(...)

        local content = dumpTable(v)
        
        -- Copie dans le presse-papier (si supporté)
        if setclipboard then
            setclipboard(content)
            print("✅ La table a été copiée dans le presse-papier !")
        end
        
        -- Sauvegarde dans un fichier (si supporté, utile si c'est trop gros pour le clipboard)
        if writefile then
            writefile("TableDump.txt", content)
            print("✅ La table a été sauvegardée dans le fichier 'TableDump.txt'")
        end

        local args = {...}
        local logMsg = "\n[HOOK] Main.Battle.useMove a été appelé !\n"
        logMsg = logMsg .. "Nombre d'arguments reçus : " .. #args .. "\n"
        
        for i, v in ipairs(args) do
            logMsg = logMsg .. "Arg " .. i .. " (" .. typeof(v) .. ") : " .. tostring(v) .. "\n"
            if type(v) == "table" then
                logMsg = logMsg .. "  Contenu de la table :\n"
                for key, val in pairs(v) do
                    logMsg = logMsg .. "    [" .. tostring(key) .. "] = " .. tostring(val) .. "\n"
                end
            end
        end
        logMsg = logMsg .. "--------------------------------------------------"
        
        print(logMsg)
        
        -- Tentative de copie dans le presse-papier
        if setclipboard then
            setclipboard(logMsg)
            print("📋 Les infos ont été copiées dans le presse-papier !")
        end
        
        -- Appelle la vraie fonction pour que le jeu continue de fonctionner
        return oldUseMove(...)
    end
    
    print("✅ Hook installé avec succès sur Main.Battle.useMove")
    print("👉 Fais maintenant une attaque manuellement dans le jeu.")
    print("👉 Regarde la console (F9) pour voir les arguments exacts envoyés.")
else
    print("⚠️ Hook déjà installé.")
end

-- Exemple de structure à remplir une fois les infos récupérées :
-- Main.Battle.useMove(
--     Main.Battle,                                                     -- Arg 1: self
--     Main.Battle.currentBattle.fulfillingRequest.active[1].moves[3],  -- Arg 2: Move
--     ARG_3,                                                           -- Arg 3: ? (Probablement la cible ou un ID)
--     ARG_4,                                                           -- Arg 4: ?
--     ARG_5,                                                           -- Arg 5: ?
--     ARG_6                                                            -- Arg 6: ?
-- )
