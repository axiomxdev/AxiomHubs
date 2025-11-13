local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 3
UIStroke.Color = Color3.fromRGB(42, 42, 42)

local BTNSize = UDim2.new(0, 248, 0, 50)

local BTNUICorner = Instance.new("UICorner")
BTNUICorner.CornerRadius = UDim.new(0, 8)

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.new(0.4, 0.494118, 0.917647)),
    ColorSequenceKeypoint.new(1, Color3.new(0.462745, 0.294118, 0.635294))
}
UIGradient.Rotation = 86

local BTNTextButton = Instance.new("TextButton")
BTNTextButton.Size = UDim2.new(0, 248, 0, 50)
BTNTextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BTNTextButton.Font = Enum.Font.SourceSansBold
BTNTextButton.TextSize = 32
BTNTextButton.Transparency = 1

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Axiom Hub's"
screenGui.Parent = PlayerGui
screenGui.Enabled = true

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 600, 0, 300)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mainFrame.Parent = screenGui

	local UICornerMF = Instance.new("UICorner")
	UICornerMF.CornerRadius = UDim.new(0, 16)
	UICornerMF.Parent = mainFrame
	
	local UIStrokeMF = UIStroke:Clone()
	UIStrokeMF.Parent = mainFrame
	
	local checkKey = Instance.new("Frame")
	checkKey.Size = BTNSize
	checkKey.Position = UDim2.new(0, 35, 0, 215)
	checkKey.Parent = mainFrame
	
		local UICornerCK = BTNUICorner:Clone()
		UICornerCK.Parent = checkKey
		
		local UIGradientCK = UIGradient:Clone()
		UIGradientCK.Parent = checkKey
		
		local UIStrokeCK = UIStroke:Clone()
		UIStrokeCK.Parent = checkKey
		
		local TextBtnCK = BTNTextButton:Clone()
		TextBtnCK.Text = "Check Key"
		TextBtnCK.Parent = checkKey
		TextBtnCK.TextTransparency = 0

		
		
	local websiteUrl = Instance.new("Frame")
	websiteUrl.Size = BTNSize
	websiteUrl.Position = UDim2.new(0, 317, 0, 215)
	websiteUrl.Parent = mainFrame

		local UICornerWU = BTNUICorner:Clone()
		UICornerWU.Parent = websiteUrl

		local UIGradientWU = UIGradient:Clone()
		UIGradientWU.Parent = websiteUrl

		local UIStrokeWU = UIStroke:Clone()
		UIStrokeWU.Parent = websiteUrl

		local TextBtnWU = BTNTextButton:Clone()
		TextBtnWU.Text = "Website Link"
		TextBtnWU.Parent = websiteUrl
		TextBtnWU.TextTransparency = 0
		
	local KeyInput = Instance.new("TextBox")
	KeyInput.Size = UDim2.new(0, 530, 0, 36)
	KeyInput.Position = UDim2.new(0, 35, 0, 159)
	KeyInput.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
	KeyInput.Font = Enum.Font.Gotham
    KeyInput.TextSize = 18
	KeyInput.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
	KeyInput.TextColor3 = Color3.fromRGB(255,255,255)
    KeyInput.Text = ""
	KeyInput.PlaceholderText = ". . . Enter your key here . . ."
	KeyInput.Parent = mainFrame

		local UICornerKI = BTNUICorner:Clone()
		UICornerKI.Parent = KeyInput

		local UIStrokeKI = UIStroke:Clone()
		UIStrokeKI.Parent = KeyInput
        UIStrokeKI.ApplyStrokeMode = "Border"
		
	local Title = Instance.new("TextLabel")
	Title.BackgroundTransparency = 1
	Title.Position = UDim2.new(0, 0, 0, 20)
	Title.Size = UDim2.new(1, 0, 0, 40)
	Title.Font = Enum.Font.SourceSansBold
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextSize = 48
	Title.Text = "Axiom Hub's, Key System"
    Title.Parent = mainFrame
	
		local UIGradientT = UIGradient:Clone()
		UIGradientT.Parent = Title
	
	local Description = Instance.new("TextLabel")
	Description.BackgroundTransparency = 1
	Description.Position = UDim2.new(0, 35, 0, 75)
	Description.Size = UDim2.new(0, 530, 0, 67)
	Description.Font = Enum.Font.SourceSansBold
	Description.TextColor3 = Color3.fromRGB(255, 255, 255)
	Description.TextSize = 22
	Description.TextWrapped = true
	Description.Text = "Dive into the world of cutting-edge gaming scripts and cheats. Our premium tools transform your gaming experience with unmatched performance and reliability."
	Description.Parent = mainFrame	
		
	TextBtnCK.MouseButton1Click:Connect(function()
		TextBtnCK.Text = "Checking key . . ."
		local keyValue = KeyInput.Text
		if keyValue ~= "" then
			local result = request({
				Url = "https://axiomhub.eu/api/check-key?key=" .. keyValue .. "&userId=" .. LocalPlayer.UserId,
				Method = "GET"
			}).Body
			
			if result then
				local responseData = game:GetService("HttpService"):JSONDecode(result)
				
				if responseData and responseData.valid then
					TextBtnCK.Text = "Key Valid!"
					screenGui:Destroy()
					scripting()
				else
					TextBtnCK.Text = "Invalid Key"
				end
			else
				TextBtnCK.Text = "Connection Error"
				print("Error:", result)
			end
			
			wait(2)
			TextBtnCK.Text = "Check Key"
		else
			TextBtnCK.Text = "Enter a key first"
			wait(2)
			TextBtnCK.Text = "Check Key"
		end
	end)

	TextBtnWU.MouseButton1Click:Connect(function()
		setclipboard("https://axiomhub.eu/")
		TextBtnWU.Text = "Website Link" .. " (Copied!)"
		wait(2)
		TextBtnWU.Text = "Website Link"
	end)

function scripting()

-- UI Material ===================================================================================
local Material              = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()

-- Services ======================================================================================
local Players               = game:GetService("Players")
local ReplicatedStorage     = game:GetService("ReplicatedStorage")
local Workspace             = game:GetService("Workspace")
local TweenService          = game:GetService("TweenService")
local HttpService           = game:GetService("HttpService")
local UserInputService      = game:GetService("UserInputService")
local TeleportService       = game:GetService("TeleportService")

-- Variables Services ============================================================================

--#Players
local player                = Players.LocalPlayer

local character             = player.Character or player.CharacterAdded:Wait()
local humanoid              = character:WaitForChild("Humanoid")
local humanoidRootPart      = character:WaitForChild("HumanoidRootPart")

local CoreStats             = player:WaitForChild("CoreStats")
local Honey                 = CoreStats:WaitForChild("Honey")
local Capacity              = CoreStats:WaitForChild("Capacity")
local Pollen                = CoreStats:WaitForChild("Pollen")

--#Workspace
local HivePlatforms         = Workspace:WaitForChild("HivePlatforms")
local HiddenStickers        = Workspace:WaitForChild("HiddenStickers")
local Collectibles          = Workspace:WaitForChild("Collectibles")
local FlowerZones           = Workspace:WaitForChild("FlowerZones")
local Decorations           = Workspace:WaitForChild("Decorations")
local Stump                 = Decorations:WaitForChild("Stump")
local LeaderboardStructures = Workspace:WaitForChild("Leaderboards")
local GatesStructures       = Workspace:WaitForChild("Gates")
local MonsterSpawners       = Workspace:WaitForChild("MonsterSpawners")

--#ReplicatedStorage
local Events                = ReplicatedStorage:WaitForChild("Events")
local ClaimHive             = Events:WaitForChild("ClaimHive")
local ToolCollect           = Events:WaitForChild("ToolCollect")
local PlayerHiveCommand     = Events:WaitForChild("PlayerHiveCommand")
local ToyEvent              = Events:WaitForChild("ToyEvent")
local HiddenStickerEvent    = Events:WaitForChild("HiddenStickerEvent")
local PlayerActivesCommand  = Events:WaitForChild("PlayerActivesCommand")
local GiveQuestFromPool     = Events:WaitForChild("GiveQuestFromPool")
local CompleteQuestFromPool = Events:WaitForChild("CompleteQuestFromPool")

local args = {
    [1] = "Riley Bee"
}

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("CompleteQuestFromPool"):FireServer(unpack(args))

local args = {
    [1] = "Riley Bee"
}

game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("GiveQuestFromPool"):FireServer(unpack(args))

-- Variables Script ==============================================================================

getgenv().AutoFarm          = false
getgenv().AutoDig           = false
getgenv().AutoDispenser     = false
getgenv().AutoSprinkler     = false
getgenv().AutoQuest         = false

local SpeedHack             = 30
local defaultWalkSpeed      = 20
local speedHackConnection   = nil
local isSpeedHackActive     = false

local AutoFarmSpeed         = 30
local AutoFarmMethode       = "Tween"
local AutoFarmField         = "Sunflower"
 
local Hive                  = nil
local MaxRangedField        = 100

-- CFRAME FIELD ==================================================================================

local CFrameField = {
    ["Bamboo"]         = { CFrame = CFrame.new(132,  20,  -27 ), Zone = FlowerZones:WaitForChild("Bamboo Field"      )},
    ["Blue Flower"]    = { CFrame = CFrame.new(148,  4,   101 ), Zone = FlowerZones:WaitForChild("Blue Flower Field" )},
    ["Cactus"]         = { CFrame = CFrame.new(-194, 68,  -106), Zone = FlowerZones:WaitForChild("Cactus Field"      )},
    ["Clover"]         = { CFrame = CFrame.new(155,  34,  195 ), Zone = FlowerZones:WaitForChild("Clover Field"      )},
    ["Coconut"]        = { CFrame = CFrame.new(-262, 72,  466 ), Zone = FlowerZones:WaitForChild("Coconut Field"     )},
    ["Dandelion"]      = { CFrame = CFrame.new(-34,  4,   221 ), Zone = FlowerZones:WaitForChild("Dandelion Field"   )},
    ["Mountain"]       = { CFrame = CFrame.new(76,   176, -165), Zone = FlowerZones:WaitForChild("Mountain Top Field")},
    ["Mushroom"]       = { CFrame = CFrame.new(-97,  4,   119 ), Zone = FlowerZones:WaitForChild("Mushroom Field"    )},
    ["Pepper"]         = { CFrame = CFrame.new(-488, 124, 536 ), Zone = FlowerZones:WaitForChild("Pepper Patch"      )},
    ["PineTreeForest"] = { CFrame = CFrame.new(-327, 68,  -184), Zone = FlowerZones:WaitForChild("Pine Tree Forest"  )},
    ["Pineapple"]      = { CFrame = CFrame.new(251,  68,  -208), Zone = FlowerZones:WaitForChild("Pineapple Patch"   )},
    ["Pumpkin"]        = { CFrame = CFrame.new(-202, 68,  -185), Zone = FlowerZones:WaitForChild("Pumpkin Patch"     )},
    ["Rose"]           = { CFrame = CFrame.new(-326, 20,  127 ), Zone = FlowerZones:WaitForChild("Rose Field"        )},
    ["Spider"]         = { CFrame = CFrame.new(-45,  20,  -5  ), Zone = FlowerZones:WaitForChild("Spider Field"      )},
    ["Stump"]          = { CFrame = CFrame.new(420,  96,  -175), Zone = FlowerZones:WaitForChild("Stump Field"       )},
    ["Strawberry"]     = { CFrame = CFrame.new(-179, 20,  -5  ), Zone = FlowerZones:WaitForChild("Strawberry Field"  )},
    ["Sunflower"]      = { CFrame = CFrame.new(-217, 4,   178 ), Zone = FlowerZones:WaitForChild("Sunflower Field"   )},
}

local MobsField = {
    ["Bamboo"]         = {MonsterSpawners:WaitForChild("Rhino Cave 2"   ), MonsterSpawners:WaitForChild("Rhino Cave 3"    )},
    ["Blue Flower"]    = {MonsterSpawners:WaitForChild("Rhino Cave 1"   )},
    ["Clover"]         = {MonsterSpawners:WaitForChild("Rhino Bush"     ), MonsterSpawners:WaitForChild("Ladybug Bush"    )},
    ["Mushroom"]       = {MonsterSpawners:WaitForChild("MushroomBush"   )},
    ["PineTreeForest"] = {MonsterSpawners:WaitForChild("ForestMantis1"  )},
    ["Pineapple"]      = {MonsterSpawners:WaitForChild("PineappleBeetle"), MonsterSpawners:WaitForChild("PineappleMantis1")},
    ["Rose"]           = {MonsterSpawners:WaitForChild("RoseBush"       ), MonsterSpawners:WaitForChild("RoseBush2"       )},
    ["Spider"]         = {MonsterSpawners:WaitForChild("Spider Cave"    )},
    ["Strawberry"]     = {MonsterSpawners:WaitForChild("Ladybug Bush 2" ), MonsterSpawners:WaitForChild("Ladybug Bush 3"  )},
}

-- DISPENSER NAME ================================================================================

local DispenserName = {
    "Strawberry Dispenser"      ,
    "Ant Pass Dispenser"        ,
    "Blueberry Dispenser"       ,
    "Coconut Dispenser"         ,
    "Free Ant Pass Dispenser"   ,
    "Free Robo Pass Dispenser"  ,
    "Free Royal Jelly Dispenser",
    "Glue Dispenser"            ,
    "Honey Dispenser"           ,
    "Treat Dispenser"
}

-- AutoQuest Settings ============================================================================

local AutoQuestSettings = {
    ["Blue Pollen" ] = "Mountain",
    ["Red Pollen"  ] = "Mountain",
    ["White Pollen"] = "Spider"
}

-- Basic Functions ===============================================================================

--#Player was killed
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid", 5)
    humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
end)

--#getTableKeys
local function getTableKeys(tbl)
    local keys = {}
    for key, _ in pairs(tbl) do
        table.insert(keys, key)
    end
    table.sort(keys)
    return keys
end

--#roundCFrame
local function roundCFrame(cframe)
    return CFrame.new(math.floor(cframe.X), math.floor(cframe.Y + 0.5), math.floor(cframe.Z))
end

--#slideToPosition
local function slideToPosition(targetCFrame, speed)

    local distance = (targetCFrame.Position - humanoidRootPart.CFrame.Position).Magnitude
    local time = distance / (speed*2)

    local tweenInfo = TweenInfo.new(
        time,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out,
        0,
        false,
        0
    )

    local tween = TweenService:Create(humanoidRootPart, tweenInfo, {
        CFrame = targetCFrame
    })

    tween:Play()
    tween.Completed:Wait()
end

-- Claim Hive ====================================================================================

local function findHive()
    for _, platform in pairs(HivePlatforms:GetChildren()) do
        if platform.Name == "Platform" then
            local playerRef = platform:FindFirstChild("PlayerRef")
            if playerRef and tostring(playerRef.Value) == tostring(player.Name) then
                return platform
            end
        end
    end

    for _, platform in pairs(HivePlatforms:GetChildren()) do
        if platform.Name == "Platform" then
            local playerRef = platform:FindFirstChild("PlayerRef")
            if playerRef and playerRef.Value == nil then
                return platform
            end
        end
    end
    return nil
end

Hive = findHive()
if Hive then
    ClaimHive:FireServer(tonumber(tostring(Hive.Hive.Value):match("%d+")))
else
    warn("Aucune ruche disponible pour le joueur.")
end

-- SpeedHack ====================================================================================

local function updateSpeed(humanoid, speed)
    if humanoid and humanoid.WalkSpeed ~= speed then
        humanoid.WalkSpeed = speed
    end
end

-- HideObject ===================================================================================

local function hideObject(canBeCollided)
    local targetTransparency = canBeCollided and 1 or 0
    local foldersToProcess = {
        Decorations,
        LeaderboardStructures,
        GatesStructures
    }

    local function processObject(object)
        if object:IsA("BasePart") or object:IsA("MeshPart") then
            object.CanCollide = not canBeCollided
            object.Transparency = targetTransparency
        elseif object:IsA("Model") or object:IsA("Folder") then
            for _, child in ipairs(object:GetDescendants()) do
                processObject(child)
            end
        end
    end

    for _, folder in ipairs(foldersToProcess) do
        if folder then
            for _, child in ipairs(folder:GetDescendants()) do
                processObject(child)
            end
        end
    end

    Stump.Part.Transparency = 0
    Stump.Part.CanCollide = true

    if not canBeCollided then
        for _,gates in ipairs(GatesStructures:GetChildren()) do
            gates.Door.Transparency = 0.5
            gates.Door.CanCollide = false
        end
    end
end

-- AutoQuest ====================================================================================

--#AutoQuest Brown Bear
local function FuncAutoQuestBrownBear()

    local args = {
        [1] = "Brown Bear"
    }

    while getgenv().AutoQuest do
        

        task.wait()
    end
end

-- AutoFarm ======================================================================================

local function WalkToWithConsecutiveAirJumps(destination, speed)
    local character = player.Character
    local humanoid = character:WaitForChild("Humanoid")
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    local ObstacleDetectionDistance = 16 
    local TargetDistanceThreshold = 50

    if not humanoid or not humanoidRootPart then return end

    local targetPosition = Vector3.new(destination.X, humanoidRootPart.Position.Y, destination.Z)

    while (humanoidRootPart.Position - targetPosition).Magnitude > TargetDistanceThreshold and getgenv().AutoFarm do
        local direction = (targetPosition - humanoidRootPart.Position).Unit
        local raycastResult = Workspace:Raycast(
            humanoidRootPart.Position,
            direction * ObstacleDetectionDistance,
            RaycastParams.new()
        )

        if raycastResult and raycastResult.Instance ~= character and raycastResult.Instance:FindFirstAncestorOfClass("Model") ~= character then
            -- Obstacle détecté
            humanoid.JumpPower = 100
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            humanoid.WalkSpeed = speed
            humanoid:MoveTo(targetPosition)
        else
            -- Pas d'obstacle direct
            humanoid.WalkSpeed = speed
            humanoid:MoveTo(targetPosition)
        end

        task.wait(0.1)
    end
    humanoid:MoveTo(targetPosition)
end

local function FuncAutoFarm()    
    while getgenv().AutoFarm do        
        -- Récupérer les références actuelles du personnage
        local currentCharacter = player.Character
        local currentHumanoidRootPart = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
        local currentHumanoid = currentCharacter and currentCharacter:FindFirstChild("Humanoid")

        -- Vérification de la validité du personnage et de ses composants
        if not currentCharacter or not currentHumanoidRootPart or not currentHumanoid or currentHumanoid.Health <= 0 then
            character = player.Character or player.CharacterAdded:Wait()
            humanoid = character:WaitForChild("Humanoid")
            humanoidRootPart = character:WaitForChild("HumanoidRootPart")
            task.wait(1) -- Pause plus longue si le personnage est mort
            continue
        end

        local FieldInfo = CFrameField[AutoFarmField]
        local FieldZone = FieldInfo.Zone
        local TargetFieldCFrame = FieldInfo.CFrame

        local currentPollen = Pollen.Value
        local currentCapacity = Capacity.Value
        local currentHive = Hive
        local currentHivePlatformCFrame = currentHive and roundCFrame(currentHive.Platform.CFrame)
        local currentPlayerCFrame = currentHumanoidRootPart.CFrame
        local currentPlayerPosition = currentPlayerCFrame.Position
        local zonePosition = FieldZone.Position
        local zoneHalfSize = nil

        if AutoFarmField == "Stump" then
            zoneHalfSize = Vector3.new(20, 20, 20)
        else
            zoneHalfSize = FieldZone.Size / 2
        end

        if Pollen.Value >= Capacity.Value then
            if Hive then

                if AutoFarmMethode == "Tween" then
                    slideToPosition(roundCFrame(Hive.Platform.CFrame), AutoFarmSpeed)
                else
                    slideToPosition(roundCFrame(Hive.Platform.CFrame), AutoFarmSpeed)
                    --WalkToWithConsecutiveAirJumps(roundCFrame(Hive.Platform.CFrame), AutoFarmSpeed)
                end

                task.wait()

                PlayerHiveCommand:FireServer("ToggleHoneyMaking")
                while Pollen.Value >= 1 and getgenv().AutoFarm do
                    task.wait()
                end
                task.wait(2)
            end
        end

        -- Vérifier si nous sommes hors de la zone et nous y rendre si nécessaire
        local relativePosToZone = currentPlayerPosition - zonePosition
        if math.abs(relativePosToZone.X) >= zoneHalfSize.X or math.abs(relativePosToZone.Z) >= zoneHalfSize.Z then
            print("Hors de la zone, retour au champ")
            local targetPosition = TargetFieldCFrame.Position
            if AutoFarmMethode == "Tween" then
                slideToPosition(CFrame.new(targetPosition.X, targetPosition.Y, targetPosition.Z), AutoFarmSpeed)
            elseif AutoFarmMethode == "Walk" then
                slideToPosition(CFrame.new(targetPosition.X, targetPosition.Y, targetPosition.Z), AutoFarmSpeed)
            end
            continue
        end

        -- Collecter les collectibles proches
        for _, collectible in pairs(Collectibles:GetChildren()) do
            local collectiblePosition = collectible.Position
            local relativePosToZoneCollectible = collectiblePosition - zonePosition

            if math.abs(relativePosToZoneCollectible.X) <= zoneHalfSize.X and
               math.abs(relativePosToZoneCollectible.Z) <= zoneHalfSize.Z and
               math.abs(currentPlayerCFrame.Y - collectible.CFrame.Y) <= 5 then

                local targetCollectiblePosition = Vector3.new(collectiblePosition.X, currentPlayerCFrame.Y, collectiblePosition.Z)

                if AutoFarmMethode == "Tween" then
                    slideToPosition(CFrame.new(targetCollectiblePosition.X, targetCollectiblePosition.Y, targetCollectiblePosition.Z), AutoFarmSpeed)
                elseif AutoFarmMethode == "Walk" then
                    humanoid.WalkSpeed = AutoFarmSpeed
                    humanoid:MoveTo(targetCollectiblePosition)
                end

                if not getgenv().AutoFarm then
                    break
                end
            end
        end

        task.wait()
    end
end

-- Auto Sprinkler ================================================================================

function FuncAutoSprinkler()
    while getgenv().AutoSprinkler do
        local args = {
            [1] = {
                ["Name"] = "Sprinkler Builder"
            }
        }

        PlayerActivesCommand:FireServer(unpack(args))

        task.wait(2)
    end
end

-- AutoDig =======================================================================================

function FuncAutoDig()
    while getgenv().AutoDig do
        if character and humanoid and humanoid.Health > 0 then
            ToolCollect:FireServer()
        end
        task.wait()
    end
end

-- AutoDispenser =================================================================================

function FuncAutoClaimDispenser()
    while getgenv().AutoDispenser do
        for _,v in pairs(DispenserName) do
            local args = {
                [1] = v
            }

            ToyEvent:FireServer(unpack(args))
        end
        task.wait(5)
    end
end

-- TakeAllSticker

function FuncTakeAllSticker()
    for i = 1, 259 do

        local args = {
            [1] = i
        }

        HiddenStickerEvent:FireServer(unpack(args))
    end
end

-- UI Material Create ============================================================================

local UI = Material.Load({
    Title = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
    Style = 1,
    SizeX = 500,
    SizeY = 350,
    Theme = "Dark" -- Light, Dark, Mocha, Aqua, ou Jester
})

--#AutoFarm
local AutoFarm = UI.New({ Title = "Auto Farm" })

local AutoFarmField_ = AutoFarm.Dropdown({
    Text = "Field ",
    Default = "Sunflower",
    Options = getTableKeys(CFrameField),
    Callback = function(value)
        AutoFarmField = value
    end
})

local AutoFarmMethode_ = AutoFarm.Dropdown({
    Text = "AutoFarm Methode ",
    Default = "Tween",
    Options = {"Tween", "Walk"},
    Callback = function(value)
        AutoFarmMethode = value
    end
})

local AutoFarmToggle = AutoFarm.Toggle({
    Text = "AutoFarm",
    Callback = function(value)
        if getgenv().AutoQuest and value then
            UI.Banner({
                Text = "disable auto quest before !"
            })
            return
        end
        getgenv().AutoFarm = value
        hideObject(value)
        if value then
            spawn( function() FuncAutoFarm() end)
        end
    end
})

local AutoFarmSpeed_ = AutoFarm.Slider({
    Text = "AutoFarm Speed",
    Callback = function(value)
        AutoFarmSpeed = value
    end,
    Min = 30,
    Max = 100,
    Def = 30,
})

local AutoDigToggle = AutoFarm.Toggle({
    Text = "AutoDig",
    Callback = function(value)
        getgenv().AutoDig = value
        if value then
            FuncAutoDig()
        end
    end
})

local AutoSprinkler = AutoFarm.Toggle({
    Text = "Auto Sprinkler",
    Callback = function(value)
        getgenv().AutoSprinkler = value
        if value then
            FuncAutoSprinkler()
        end
    end
})

--#Teleport
local Teleport = UI.New({ Title = "Teleport" })

local TeleportField = Teleport.Dropdown({
    Text = "Field ",
    Default = "Sunflower",
    Options = getTableKeys(CFrameField)
})

local TeleportToField = Teleport.Button({
    Text = "Teleport to Field",
    Callback = function()
        local selectedField = TeleportField:GetValue()
        if selectedField and CFrameField[selectedField] then
            slideToPosition(CFrameField[selectedField].CFrame, 100)
        else
            UI.Banner({ Text = "Please select a valid field!" })
        end
    end
})

local TeleportToHive = Teleport.Button({
    Text = "Teleport to Hive",
    Callback = function()
        if Hive then
            slideToPosition(roundCFrame(Hive.Platform.CFrame), 100)
        else
            UI.Banner({
                Text = "No hive available!"
            })
        end
    end
})

--#AutoQuest
local AutoQuest = UI.New({
    Title = "Auto Quest"
})

local AutoQuestBrownBear = AutoQuest.Toggle({
    Text = "Auto Quest Brown Bear",
    Callback = function(value)
        if getgenv().AutoFarm and value then
            UI.Banner({
                Text = "disable auto farm before !"
            })
            return
        end
        getgenv().AutoQuest = value
        if value then
            FuncAutoQuestBrownBear()
        end
    end
})

--#Other
local Other = UI.New({
    Title = "Other"
})

local AutoDispenser = Other.Toggle({
    Text = "Auto Dispenser",
    Callback = function(value)
        getgenv().AutoDispenser = value
        if value then
            FuncAutoClaimDispenser()
        end
    end
})

local TakeAllSticker = Other.Button({
    Text = "Take all sticker",
    Callback = function()
        FuncTakeAllSticker()
    end
})

local AutoSpeedHack = Other.Toggle({
    Text = "Speed Hack",
    Callback = function(value)
        isSpeedHackActive = value
        if humanoid then
            if value then
                if not speedHackConnection then
                    speedHackConnection = game:GetService("RunService").Heartbeat:Connect(function()
                        updateSpeed(humanoid, SpeedHack)
                    end)
                end
            else
                updateSpeed(humanoid, defaultWalkSpeed)
                if speedHackConnection then
                    speedHackConnection:Disconnect()
                    speedHackConnection = nil
                end
            end
        end
    end
})

local AutoSpeedHackSpeed = Other.Slider({
    Text = "Vitesse du Speed Hack",
    Callback = function(value)
        SpeedHack = value
        if humanoid and isSpeedHackActive then
            updateSpeed(humanoid, SpeedHack)
        end
    end,
    Min = 20,
    Max = 100,
    Def = 30,
})

--#Stats
local Stats = UI.New({
    Title = "Stats"
})

--#Misc
local Misc = UI.New({
    Title = "Misc"
})

local ServerHop = Misc.Button({
    Text = " 🔄 Server Hop", -- Icône et texte plus clair
    Callback = function()
        local success, result = pcall(function()
            local servers = {}
            local placeId = game.PlaceId -- Utilise une variable pour la clarté
            local url = string.format(
                "https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100&excludeFullGames=true",
                placeId
            )
            local req = httprequest({ Url = url })
            local body = HttpService:JSONDecode(req.Body)

            if body and body.data then
                for i, v in next, body.data do
                    if type(v) == "table" and tonumber(v.playing) and tonumber(v.maxPlayers) and v.playing < v.maxPlayers and v.id ~= JobId then
                        table.insert(servers, 1, v.id)
                    end
                end
            end

            if #servers > 0 then
                local randomServerId = servers[math.random(1, #servers)]
                TeleportService:TeleportToPlaceInstance(placeId, randomServerId, Players.LocalPlayer)
            else
                UI.Banner({ Text = "No available servers found." }) -- Message plus précis
            end
        end)

        if success then
            UI.Banner({ Text = "Attempting to teleport to a new server..." }) -- Indique l'action en cours
        else
            UI.Banner({ Text = "Server hop failed! Please try again." }) -- Message d'erreur clair
            warn("Server Hop Error:", result) -- Affiche l'erreur dans la console
        end
    end
})

local AntiAFK = Misc.Button({
    Text = " 🎮 Anti AFK",
    Callback = function()
        local success, result = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/NoTwistedHere/Roblox/main/AntiAFK.lua"))()
        end)
        if not success then
            UI.Banner({
                Text = "Failed to load Anti-AFK script ! Try other exploit !"
            })
        else
            UI.Banner({
                Text = "Anti-AFK script loaded!"
            })
        end
    end
})

local Discord = Misc.Button({
    Text = " 🌐 Discord",
    Callback = function()
        local discordLink = "https://discord.gg/wx9gV9Z7Yy"

        local function copyToClipboard()
            local success, result = pcall(function()
                setclipboard(discordLink)
            end)
            
            if success then
                UI.Banner({Text = "Discord link copied to clipboard!"})
            else
                UI.Banner({Text = "Failed to copy Discord link!"})
            end
        end

        if httprequest then
            local success, result = pcall(function()
                local url = "http://127.0.0.1:6463/rpc?v=1"
                local headers = {
                    ["Content-Type"] = "application/json",
                    Origin = "https://discord.com"
                }
                local body = HttpService:JSONEncode({
                    cmd = "INVITE_BROWSER",
                    nonce = HttpService:GenerateGUID(false),
                    args = {code = "wx9gV9Z7Yy"}
                })

                httprequest({Url = url, Method = "POST", Headers = headers, Body = body})
            end)

            if success then
                UI.Banner({Text = "Attempted to open Discord invite in browser!"})
            else
                print("HTTP Request Failed:", result)
                copyToClipboard()
            end
        else
            copyToClipboard()
        end
    end
})

end