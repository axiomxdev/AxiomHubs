local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()

-- Déclarations globales
getgenv().esp = false
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local workspace = game:GetService("Workspace")
local camera = workspace.CurrentCamera

-- Liste des parties du corps à vérifier
local bodyParts = {
    "Head"
}

-- Création d'un Highlight de base
local Highlight = Instance.new("Highlight")
Highlight.Name = "highlight"
Highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
Highlight.FillTransparency = 1 -- Par défaut, pas de remplissage
Highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Couleur de remplissage par défaut

-- Fonction pour vérifier la visibilité avec raycasting
local function isVisible(targetPart)
    if not targetPart or not camera then return false end
    
    local rayOrigin = camera.CFrame.Position
    local rayDirection = (targetPart.Position - rayOrigin).Unit * 1000
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {player.Character} -- Ignore le joueur
    raycastParams.FilterType = Enum.RaycastFilterType.Exclude
    
    local raycastResult = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
    
    return not raycastResult or raycastResult.Instance:IsDescendantOf(targetPart.Parent)
end

-- Fonction pour mettre à jour l'ESP
local function updateESP()
    if not getgenv().esp then
        -- Désactiver l'ESP : supprimer tous les highlights
        for _, v in pairs(workspace:GetChildren()) do
            for _, part in pairs(v:GetChildren()) do
                local highlight = part:FindFirstChild("highlight")
                if highlight then
                    highlight:Destroy()
                end
            end
        end
        return
    end

    for _, v in pairs(workspace:GetChildren()) do
        if v:IsA("Model") and v:FindFirstChild("Head") and v ~= player.Character then
            -- Vérifier chaque partie du corps
            for _, partName in pairs(bodyParts) do
                local part = v:FindFirstChild(partName)
                if part then
                    local highlight = part:FindFirstChild("highlight")
                    
                    -- Créer un highlight si inexistant
                    if not highlight then
                        local newHighlight = Highlight:Clone()
                        newHighlight.Adornee = part -- Associer le highlight à la partie spécifique
                        newHighlight.Parent = part
                        highlight = newHighlight
                    end
                    
                    -- Mettre à jour la visibilité
                    local visible = isVisible(part)
                    highlight.FillTransparency = visible and 0.5 or 1
                end
            end
            highlight:Clone().Parent = v -- Cloner le highlight pour chaque partie
        end
    end
end

-- Connexion à la mise à jour de la position
player.CharacterAdded:Connect(function(character)
    local rootPart = character:WaitForChild("HumanoidRootPart", 5)
    if rootPart then
        rootPart:GetPropertyChangedSignal("Position"):Connect(function()
            task.wait()
            updateESP()
        end)
    end
end)

-- Vérification initiale du personnage
if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
    player.Character.HumanoidRootPart:GetPropertyChangedSignal("Position"):Connect(function()
        task.wait()
        updateESP()
    end)
end

-- Mise à jour périodique
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().esp then
            updateESP()
        end
    end
end)

-- Création de l'interface UI
local UI = Material.Load({
    Title = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
    Style = 3,
    SizeX = 500,
    SizeY = 350,
    Theme = "Dark"
})

local MainPage = UI.New({
    Title = "Main Controls"
})

-- Toggle pour activer/désactiver l'ESP
local ESP_BOT = MainPage.Toggle({
    Text = "ESP BOT",
    Callback = function(Value)
        getgenv().esp = Value
        updateESP() -- Mise à jour immédiate
    end,
})

-- ColorPicker pour choisir la couleur de l'ESP
local MyColorPicker = MainPage.ColorPicker({
    Text = "ESP BOT Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        Highlight.OutlineColor = color
        Highlight.FillColor = color
        for _, v in pairs(workspace:GetChildren()) do
            for _, part in pairs(v:GetChildren()) do
                local highlight = part:FindFirstChild("highlight")
                if highlight then
                    highlight.OutlineColor = color
                    highlight.FillColor = color
                end
            end
        end
    end
})

local Misc = UI.New({
    Title = "Misc"
})

local AntiAFK = Misc.Button({
    Text = "Anti AFK",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/NoTwistedHere/Roblox/main/AntiAFK.lua"))()
    end
})

local Discord = Misc.Button({
    Text = "🌐 Discord",
    Callback = function()
        setclipboard("https://discord.gg/3k5q8a7")
        UI.Banner({
            Text = "Discord link copied to clipboard!"
        })
    end
})