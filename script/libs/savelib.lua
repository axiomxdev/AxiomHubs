local SaveLib = {}

-- Configuration automatique
local FolderName = "Axiom's Hub"
local HttpService = game:GetService("HttpService")
local FilePath = FolderName .. "/" .. tostring(game.PlaceId) .. ".json"

-- Initialisation automatique au chargement
local function AutoInit()
    if not (isfolder and makefolder and isfile and readfile and writefile) then
        return false
    end
    
    if not isfolder(FolderName) then
        makefolder(FolderName)
    end
    return true
end

-- Auto-initialisation
local isInitialized = AutoInit()

-- Sauvegarder des données (automatique)
function SaveLib.Save(data)
    if not isInitialized then
        return false
    end
    
    local success = pcall(function()
        writefile(FilePath, HttpService:JSONEncode(data))
    end)
    
    return success
end

-- Charger des données (automatique)
function SaveLib.Load()
    if not isInitialized or not isfile(FilePath) then
        return nil
    end
    
    local success, result = pcall(function()
        return HttpService:JSONDecode(readfile(FilePath))
    end)
    
    return success and result or nil
end

return SaveLib
