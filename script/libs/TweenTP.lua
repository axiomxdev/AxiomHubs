-- Services nécessaires
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

-- Obtenir le joueur local
local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

-- Fonction pour faire glisser le personnage
local function slideToPosition(targetCFrame)
    local tweenInfo = TweenInfo.new(
        5, -- Durée de 5 secondes
        Enum.EasingStyle.Linear, -- Mouvement linéaire
        Enum.EasingDirection.Out,
        0, -- Pas de répétition
        false, -- Pas d'aller-retour
        0 -- Pas de délai
    )
    
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {
        CFrame = targetCFrame
    })
    
    tween:Play()
end

-- Exemple : Glisser vers une position prédéfinie avec 'G'
game:GetService("UserInputService").InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.G then
        local targetCFrame = CFrame.new(50, 5, 50)
        slideToPosition(targetCFrame)
        print("Glissement vers la position en cours...")
    end
end)

print("Appuie sur G pour glisser")