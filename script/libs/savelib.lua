-- Lightweight save helper with per-key files and function-safe encoding
local SaveLib = {}

local HttpService = game:GetService("HttpService")
local FOLDER_NAME = "Axiom's Hub"

-- Unique file per place (no keys)
local function buildPath()
    return string.format("%s/%s.json", FOLDER_NAME, tostring(game.PlaceId))
end

-- Ensure folder and file APIs exist
local function ensureInit()
    if not (isfolder and makefolder and isfile and readfile and writefile) then
        return false
    end
    if not isfolder(FOLDER_NAME) then
        makefolder(FOLDER_NAME)
    end
    return true
end

local isReady = ensureInit()

-- Save raw JSON (single file)
function SaveLib.Save(data)
    if not (isReady and data ~= nil) then
        return false
    end
    local path = buildPath()
    local ok = pcall(function()
        writefile(path, HttpService:JSONEncode(data))
    end)
    return ok
end

-- Load raw JSON (single file)
function SaveLib.Load(defaultValue)
    if not isReady then
        return defaultValue
    end
    local path = buildPath()
    if not isfile(path) then
        return defaultValue
    end
    local ok, decoded = pcall(function()
        return HttpService:JSONDecode(readfile(path))
    end)
    if not ok then
        return defaultValue
    end
    return decoded or defaultValue
end

function SaveLib.Exists()
    if not isReady then
        return false
    end
    return isfile(buildPath())
end

return SaveLib
