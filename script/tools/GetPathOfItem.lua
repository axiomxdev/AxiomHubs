-- À utiliser dans un LocalScript
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- Fonction pour détecter le clic droit
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    -- Vérifier si l'entrée est un clic droit (MouseButton2) et que l'événement n'est pas traité par le jeu (ex. chat)
    if input.UserInputType == Enum.UserInputType.MouseButton2 and not gameProcessedEvent then
        -- Obtenir l'élément ciblé dans le monde 3D
        local target = mouse.Target
        if target then
            print("Objet 3D ciblé :")
            print(" - Nom : ", target.Name)
            print(" - Classe : ", target.ClassName)
            print(" - Chemin : ", target:GetFullName())
            if target:IsA("BasePart") then -- Vérifier si l'objet a une propriété Position
                print(" - Position : ", target.Position)
            else
                print(" - Position : N/A (pas un BasePart)")
            end
        else
            print("Aucun objet 3D ciblé dans le monde.")
        end

        -- Obtenir les éléments GUI sous le curseur
        local guiObjects = player.PlayerGui:GetGuiObjectsAtPosition(mouse.X, mouse.Y)
        if #guiObjects > 0 then
            print("Éléments GUI sous le curseur :")
            for i, gui in pairs(guiObjects) do
                print(" - " .. i .. ". Nom : ", gui.Name)
                print("   - Classe : ", gui.ClassName)
                print("   - Chemin : ", gui:GetFullName())
                print("   - Visible : ", gui.Visible)
                -- Ajouter des propriétés spécifiques si c'est un GuiObject
                if gui:IsA("GuiObject") then
                    print("   - Position : ", gui.Position)
                    print("   - Taille : ", gui.Size)
                end
            end
        else
            print("Aucun élément GUI ciblé.")
        end
    end
end)