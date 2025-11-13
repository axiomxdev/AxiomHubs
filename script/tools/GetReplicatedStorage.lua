-- À utiliser dans un LocalScript
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Fonction récursive pour lister tous les enfants d'un objet
local function listContents(obj, indentLevel)
    indentLevel = indentLevel or 0
    local indent = string.rep("  ", indentLevel)
    local result = {}
    
    for _, child in pairs(obj:GetChildren()) do
        table.insert(result, indent .. child.Name .. " (" .. child.ClassName .. ")")
        -- Lister les sous-enfants récursivement
        local subContents = listContents(child, indentLevel + 1)
        for _, subLine in pairs(subContents) do
            table.insert(result, subLine)
        end
    end
    
    return result
end

-- Obtenir le contenu de ReplicatedStorage
local contents = listContents(ReplicatedStorage)

-- Afficher le contenu sous forme de texte
print("Contenu de ReplicatedStorage :")
for _, line in ipairs(contents) do
    print(line)
end

-- Copier le contenu dans le presse-papiers (optionnel)
local fullText = table.concat(contents, "\n")
setclipboard(fullText)
print("Contenu de ReplicatedStorage copié dans le presse-papiers !")
