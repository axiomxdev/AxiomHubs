local function roundCFrame(cframe)
    return CFrame.new(math.floor(cframe.X), math.floor(cframe.Y + 0.5), math.floor(cframe.Z))
end

-- Exemple d'utilisation
local newCFrame = roundCFrame(Hive.Platform.CFrame)
print(newCFrame)