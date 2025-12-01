-- Services
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Paramètres du Raycast
local RAYCAST_DISTANCE = 5000
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude
raycastParams.FilterDescendantsInstances = {player.Character} -- Ignorer le personnage du joueur

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
	-- On vérifie si c'est un clic droit
	-- Note: On retire 'not gameProcessedEvent' pour permettre la détection même sur les GUI actifs
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		local mouseLocation = UserInputService:GetMouseLocation()
		
		-- 1. Détection 3D (Raycasting)
		local unitRay = camera:ViewportPointToRay(mouseLocation.X, mouseLocation.Y)
		local raycastResult = Workspace:Raycast(unitRay.Origin, unitRay.Direction * RAYCAST_DISTANCE, raycastParams)

		print("--------------------------------------------------")
		if raycastResult then
			local target = raycastResult.Instance
			print("📍 Objet 3D ciblé :")
			print(" - Nom :", target.Name)
			print(" - Classe :", target.ClassName)
			print(" - Chemin :", target:GetFullName())
			print(" - Position :", target.Position)
			print(" - Matériau :", raycastResult.Material.Name)
		else
			print("❌ Aucun objet 3D ciblé.")
		end

		-- 2. Détection GUI
		-- On ajuste la position Y en soustrayant le GuiInset (la barre supérieure) pour correspondre aux coordonnées des GUI
		local guiInset = GuiService:GetGuiInset()
		local guiObjects = player.PlayerGui:GetGuiObjectsAtPosition(mouseLocation.X, mouseLocation.Y - guiInset.Y)

		if #guiObjects > 0 then
			print("🖥️ Éléments GUI sous le curseur :")
			for i, gui in ipairs(guiObjects) do
				print(string.format(" %d. [%s] %s", i, gui.ClassName, gui.Name))
				print("   - Chemin :", gui:GetFullName())
				print("   - Visible :", gui.Visible)
				if gui:IsA("GuiObject") then
					print("   - Position :", gui.Position)
					print("   - Taille :", gui.Size)
				end
			end
		else
			print("\n❌ Aucun élément GUI ciblé.")
		end
		print("--------------------------------------------------")
	end
end)

print("GetPathOfItem.lua chargé avec succès.")