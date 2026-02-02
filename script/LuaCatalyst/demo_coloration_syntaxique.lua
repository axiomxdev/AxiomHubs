-- DEMO : Coloration Syntaxique CodeEditor
-- Ce script montre le résultat de l'implémentation de la coloration syntaxique
-- Exécutez ce script dans Roblox pour voir le résultat visuel

print("=== DEMO : Coloration Syntaxique ===")
print("Chargement de ScreenBuilder...")

-- Charger la librairie ScreenBuilder
local ScreenBuilder = loadstring(readfile("script/LuaCatalyst/libs/ScreenBuilder.lua"))()

print("✓ ScreenBuilder chargé")

-- Créer un ScreenGui pour l'affichage
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SyntaxHighlightDemo"
screenGui.ResetOnSpawn = false
screenGui.Parent = game:GetService("CoreGui")

print("✓ ScreenGui créé")

-- Exemple de code Lua à afficher
local exampleLuaCode = [[
-- Fonction d'exemple avec coloration syntaxique
local function calculer(a, b)
    -- Addition de deux nombres
    local resultat = a + b
    
    if resultat > 100 then
        print("Résultat élevé : " .. resultat)
        return true
    else
        print("Résultat normal")
        return false
    end
end

-- Variables
local x = 42
local y = 58
local nom = "AxiomHub"

-- Appel de fonction
calculer(x, y)

-- Boucle
for i = 1, 10 do
    print(i)
end
]]

-- Créer l'éditeur de code avec coloration syntaxique
local editorFrame, textBox = ScreenBuilder.CodeEditor.Create({
    Parent = screenGui,
    Size = UDim2.new(0, 700, 0, 500),
    Position = UDim2.new(0.5, -350, 0.5, -250),
    BackgroundColor3 = Color3.fromRGB(30, 30, 30),  -- Fond sombre
    BorderSizePixel = 0,
    Text = exampleLuaCode
})

print("✓ Éditeur de code créé avec coloration syntaxique")

-- Ajouter un titre
local titleLabel = Instance.new("TextLabel")
titleLabel.Parent = screenGui
titleLabel.Size = UDim2.new(0, 700, 0, 40)
titleLabel.Position = UDim2.new(0.5, -350, 0.5, -290)
titleLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 48)
titleLabel.BorderSizePixel = 0
titleLabel.Text = "DEMO : Éditeur de Code avec Coloration Syntaxique Lua"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold

print("✓ Titre ajouté")

-- Ajouter un bouton pour fermer
local closeButton = Instance.new("TextButton")
closeButton.Parent = screenGui
closeButton.Size = UDim2.new(0, 100, 0, 30)
closeButton.Position = UDim2.new(0.5, 250, 0.5, 260)
closeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeButton.BorderSizePixel = 0
closeButton.Text = "Fermer"
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.TextSize = 14
closeButton.Font = Enum.Font.GothamBold

closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    print("Demo fermée")
end)

print("✓ Bouton de fermeture ajouté")

-- Ajouter un bouton pour basculer vers JSON
local jsonButton = Instance.new("TextButton")
jsonButton.Parent = screenGui
jsonButton.Size = UDim2.new(0, 120, 0, 30)
jsonButton.Position = UDim2.new(0.5, -350, 0.5, 260)
jsonButton.BackgroundColor3 = Color3.fromRGB(50, 120, 200)
jsonButton.BorderSizePixel = 0
jsonButton.Text = "Voir JSON"
jsonButton.TextColor3 = Color3.fromRGB(255, 255, 255)
jsonButton.TextSize = 14
jsonButton.Font = Enum.Font.GothamBold

local showingJSON = false
local exampleJSONCode = [[
{
    "projet": "AxiomHub",
    "version": "1.0.0",
    "actif": true,
    "utilisateurs": 150,
    "fonctionnalites": [
        "Coloration syntaxique",
        "Editeur de code",
        "Support Lua et JSON"
    ],
    "configuration": {
        "theme": "dark",
        "taille": 16,
        "police": "Code"
    },
    "donnees": null
}
]]

jsonButton.MouseButton1Click:Connect(function()
    if showingJSON then
        -- Retour au Lua
        textBox.Text = exampleLuaCode
        textBox:Highlight("lua")
        jsonButton.Text = "Voir JSON"
        titleLabel.Text = "DEMO : Éditeur de Code avec Coloration Syntaxique Lua"
        showingJSON = false
        print("Affichage du code Lua")
    else
        -- Passer au JSON
        textBox.Text = exampleJSONCode
        textBox:Highlight("json")
        jsonButton.Text = "Voir Lua"
        titleLabel.Text = "DEMO : Éditeur de Code avec Coloration Syntaxique JSON"
        showingJSON = true
        print("Affichage du code JSON")
    end
end)

print("✓ Bouton de basculement Lua/JSON ajouté")

-- Ajouter une légende des couleurs
local legendFrame = Instance.new("Frame")
legendFrame.Parent = screenGui
legendFrame.Size = UDim2.new(0, 250, 0, 200)
legendFrame.Position = UDim2.new(0.5, -600, 0.5, -250)
legendFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 48)
legendFrame.BorderSizePixel = 0

local legendTitle = Instance.new("TextLabel")
legendTitle.Parent = legendFrame
legendTitle.Size = UDim2.new(1, 0, 0, 30)
legendTitle.Position = UDim2.new(0, 0, 0, 0)
legendTitle.BackgroundTransparency = 1
legendTitle.Text = "Légende des Couleurs"
legendTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
legendTitle.TextSize = 14
legendTitle.Font = Enum.Font.GothamBold
legendTitle.TextXAlignment = Enum.TextXAlignment.Left
legendTitle.TextXAlignment = Enum.TextXAlignment.Center

local colorLegend = {
    {name = "Mots-clés", color = Color3.fromRGB(86, 156, 214), example = "local, function, if"},
    {name = "Chaînes", color = Color3.fromRGB(206, 145, 120), example = '"texte"'},
    {name = "Nombres", color = Color3.fromRGB(181, 206, 168), example = "42, 3.14"},
    {name = "Commentaires", color = Color3.fromRGB(106, 153, 85), example = "-- comment"},
    {name = "Fonctions", color = Color3.fromRGB(78, 201, 176), example = "print, pairs"},
    {name = "Opérateurs", color = Color3.fromRGB(212, 212, 212), example = "+, -, =, {}"}
}

for i, item in ipairs(colorLegend) do
    local itemLabel = Instance.new("TextLabel")
    itemLabel.Parent = legendFrame
    itemLabel.Size = UDim2.new(1, -10, 0, 25)
    itemLabel.Position = UDim2.new(0, 5, 0, 30 + (i - 1) * 28)
    itemLabel.BackgroundTransparency = 1
    itemLabel.Text = item.name .. ": " .. item.example
    itemLabel.TextColor3 = item.color
    itemLabel.TextSize = 12
    itemLabel.Font = Enum.Font.Code
    itemLabel.TextXAlignment = Enum.TextXAlignment.Left
end

print("✓ Légende des couleurs ajoutée")

print("")
print("=== DEMO PRÊTE ===")
print("✓ La coloration syntaxique est maintenant visible !")
print("✓ Cliquez sur 'Voir JSON' pour tester la coloration JSON")
print("✓ Vous pouvez modifier le texte dans l'éditeur")
print("✓ La coloration se met à jour automatiquement")
print("✓ Cliquez sur 'Fermer' pour fermer la demo")
print("")
