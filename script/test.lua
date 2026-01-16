    -- Services ======================================================================================
    local Players                   = game:GetService("Players")
    local TeleportService           = game:GetService("TeleportService")
    local TweenService              = game:GetService("TweenService")

    -- Variables Services ============================================================================

    --#Players
    local player                    = Players.LocalPlayer

    local character                 = player.Character or player.CharacterAdded:Wait()
    local humanoid                  = character:WaitForChild("Humanoid")
    local humanoidRootPart          = character:WaitForChild("HumanoidRootPart")

    --#Player was killed
    player.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
        humanoid = character:WaitForChild("Humanoid", 5)
        humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
    end)

	local function slideToPosition(targetCFrame, time)
        local tweenInfo = TweenInfo.new(
            time, -- Durée
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
        tween.Completed:Wait()
    end

local args = {
	"Criminal",
	"jobPad"
}
game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("RequestStartJobSession"):FireServer(unpack(args))

-- Find all ATMs from spawners
local CriminalATMSpawners = game:GetService("Workspace"):WaitForChild("Game"):WaitForChild("Jobs"):WaitForChild("CriminalATMSpawners")
local ATMs = {}

for _, spawner in pairs(CriminalATMSpawners:GetChildren()) do
	local criminalATM = spawner:FindFirstChild("CriminalATM")
	if criminalATM then
		local atm = criminalATM:FindFirstChild("ATM")
		if atm then
            local billboard = atm:FindFirstChild("ATMIconBillboard")
            if billboard then
			    table.insert(ATMs, {criminalATM = criminalATM, atm = atm})
            end
		end
	end
end

if #ATMs > 0 then
	local atmData = ATMs[1] -- Use first available ATM
	slideToPosition(atmData.atm.CFrame, 0)
	
	task.wait(0.5)
	
	-- Start ATM bust
	local args = {
		atmData.criminalATM
	}
	game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AttemptATMBustStart"):InvokeServer(unpack(args))
	
	-- Wait 6 seconds
	task.wait(6)
	
	-- Complete ATM bust
	local args = {
		atmData.criminalATM
	}
	game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("AttemptATMBustComplete"):InvokeServer(unpack(args))
else
	print("No ATMs found!")
end
