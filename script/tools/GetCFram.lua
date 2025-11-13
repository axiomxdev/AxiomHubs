-- Services nécessaires
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

-- Obtenir le joueur local
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Fonction pour obtenir et copier la position CFrame
local function getAndCopyCFrame()
    local currentCFrame = humanoidRootPart.CFrame
    local cframeString = tostring(currentCFrame)
    
    -- Extraire les coordonnées X, Y, Z
    local x, y, z = currentCFrame.X, currentCFrame.Y, currentCFrame.Z
    
    -- Arrondir les valeurs à l'entier le plus proche
    local roundedX = math.round(x)
    local roundedY = math.round(y)
    local roundedZ = math.round(z)
    
    -- Afficher la valeur complète
    print("Position CFrame actuelle: " .. cframeString)
    
    -- Afficher la version arrondie (X, Y, Z seulement)
    print(string.format("Position arrondie: (%d, %d, %d)", roundedX, roundedY, roundedZ))
    
    -- Copier dans le clipboard (les coordonnées arrondies)
    pcall(function()
        setclipboard(roundedX .. ", " .. roundedY .. ", " .. roundedZ)
        print("Coordonnées arrondies copiées dans le clipboard!")
    end)
end

-- Activation avec la touche 'P'
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.P then
        getAndCopyCFrame()
    end
end)

print("Appuie sur P pour obtenir et copier le CFrame")