local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()

getgenv().InfiniteCurrency = false
getgenv().FreeGamepasses = false
getgenv().CurrencyMultiplier = 500

local Players = game:GetService("Players")
getgenv().player = Players.LocalPlayer

local UserInputService = game:GetService("UserInputService")
local playerGui = player:WaitForChild("PlayerGui")
getgenv().mainGui = playerGui:WaitForChild("MainGui")

getgenv().workspace = game:GetService("Workspace")
getgenv().ReplicatedStorage = game:GetService("ReplicatedStorage")

local function MineChest(Chest)
    ReplicatedStorage.Services.TreasureChestSpawner.ChestHit:FireServer(Chest)
end

local function GetChestHits(Name)
    if Name == "CoinChest" then
        return 10
    else
        return 20
    end
end

local function Gamepass(Path)
    if FreeGamepasses == true then
        Path.Value = true
    else
        Path.Value = false
    end
end

local function AddCallBackClose(path)
    local header = path:WaitForChild("Header")
    local closeButton = header:WaitForChild("xButton")

    if closeButton:IsA("TextButton") or closeButton:IsA("ImageButton") then
        closeButton.MouseButton1Click:Connect(function()
            path.Visible = false
        end)
    end
end

-- Mettre à jour la liste des GUI pour ne garder que ceux qui restent
pcall(function()
    local guis = {
        "RobotUpgrades",
        "BackpackFull",
        "LoyaltyProgram",
        "SettingsMenu",
        "RegenerateCave",
        "Rebirths",
        "MinerLog", -- Sera renommé MainQuest
        "Index", -- Sera renommé RobotSkin
        "RobotQuest",
        "SuperRebirths",
        "TowerSkins",
        "CaveRace",
        "WheelSpins",
        "Dungeons"
    }

    for _, guiName in pairs(guis) do
        local gui = mainGui:WaitForChild(guiName)
        AddCallBackClose(gui)
    end
end)

-- Fonctions pour basculer la visibilité des GUI restants
local function RobotUpgrade()
    local robotUpgrades = mainGui:WaitForChild("RobotUpgrades")
    robotUpgrades.Visible = not robotUpgrades.Visible
end

local function BackpackFull()
    local backpackFull = mainGui:WaitForChild("BackpackFull")
    backpackFull.Visible = not backpackFull.Visible
end

local function LoyaltyProgram()
    local loyaltyProgram = mainGui:WaitForChild("LoyaltyProgram")
    loyaltyProgram.Visible = not loyaltyProgram.Visible
end

local function SettingsMenu()
    local settingsMenu = mainGui:WaitForChild("SettingsMenu")
    settingsMenu.Visible = not settingsMenu.Visible
end

local function RegenerateCave()
    local regenerateCave = mainGui:WaitForChild("RegenerateCave")
    regenerateCave.Visible = not regenerateCave.Visible
end

local function Rebirths()
    local rebirths = mainGui:WaitForChild("Rebirths")
    rebirths.Visible = not rebirths.Visible
end

local function MainQuest()
    local mainQuest = mainGui:WaitForChild("MinerLog")
    mainQuest.Visible = not mainQuest.Visible
end

local function RobotSkin()
    local robotSkin = mainGui:WaitForChild("Index")
    robotSkin.Visible = not robotSkin.Visible
end

local function RobotQuest()
    local robotQuest = mainGui:WaitForChild("RobotQuest")
    robotQuest.Visible = not robotQuest.Visible
end

local function SuperRebirths()
    local superRebirths = mainGui:WaitForChild("SuperRebirths")
    superRebirths.Visible = not superRebirths.Visible
end

local function TowerSkins()
    local towerSkins = mainGui:WaitForChild("TowerSkins")
    towerSkins.Visible = not towerSkins.Visible
end

local function CaveRace()
    local caveRace = mainGui:WaitForChild("CaveRace")
    caveRace.Visible = not caveRace.Visible
end

local function WheelSpins()
    local wheelSpins = mainGui:WaitForChild("WheelSpins")
    wheelSpins.Visible = not wheelSpins.Visible
end

local function Dungeons()
    local dungeons = mainGui:WaitForChild("Dungeons")
    dungeons.Visible = not dungeons.Visible
end

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

local InfiniteCurrencyToggle = MainPage.Toggle({
    Text = "Infinite Money / Gems",
    Callback = function(Value)
        getgenv().InfiniteCurrency = Value
        if Value then
            spawn(function()
                while task.wait(1) and InfiniteCurrency == true do
                    for i, v in pairs(workspace.TreasureChest:GetChildren()) do
                        player.Character.HumanoidRootPart.CFrame = v.Neon.CFrame
                        for i = 1, CurrencyMultiplier * GetChestHits(tostring(v.Name)) do
                            MineChest(workspace:WaitForChild("TreasureChest"):WaitForChild(tostring(v.Name)))
                        end
                    end
                end
            end)
        end

        if Value then
            UI.Banner({
                Text = "It may take time while waiting for a chest to appear !"
            })
        end
    end,
    Enabled = false
})

local GamepassToggle = MainPage.Toggle({
    Text = "Free Gamepasses",
    Callback = function(Value)
        getgenv().FreeGamepasses = Value
        for i, v in pairs(game:GetService("Players").LocalPlayer.Data.GamePasses:GetChildren()) do
            Gamepass(v)
        end
    end,
    Enabled = false
})

local MultiplierSlider = MainPage.Slider({
    Text = "Currency Multiplier",
    Callback = function(Value)
        getgenv().CurrencyMultiplier = Value
    end,
    Min = 100,
    Max = 1000,
    Def = 500
})

local GUI = UI.New({
    Title = "GUI"
})

local RobotUpgradeButton = GUI.Button({
    Text = "Robot Upgrade",
    Callback = function()
        RobotUpgrade()
    end
})

local BackpackFullButton = GUI.Button({
    Text = "Backpack Full",
    Callback = function()
        BackpackFull()
    end
})

local LoyaltyProgramButton = GUI.Button({
    Text = "Loyalty Program",
    Callback = function()
        LoyaltyProgram()
    end
})

local SettingsMenuButton = GUI.Button({
    Text = "Settings Menu",
    Callback = function()
        SettingsMenu()
    end
})

local RegenerateCaveButton = GUI.Button({
    Text = "Regenerate Cave",
    Callback = function()
        RegenerateCave()
    end
})

local RebirthsButton = GUI.Button({
    Text = "Rebirths",
    Callback = function()
        Rebirths()
    end
})

local MainQuestButton = GUI.Button({
    Text = "Main Quest",
    Callback = function()
        MainQuest()
    end
})

local RobotSkinButton = GUI.Button({
    Text = "Robot Skin",
    Callback = function()
        RobotSkin()
    end
})

local RobotQuestButton = GUI.Button({
    Text = "Robot Quest",
    Callback = function()
        RobotQuest()
    end
})

local SuperRebirthsButton = GUI.Button({
    Text = "Super Rebirths",
    Callback = function()
        SuperRebirths()
    end
})

local TowerSkinsButton = GUI.Button({
    Text = "Tower Skins",
    Callback = function()
        TowerSkins()
    end
})

local CaveRaceButton = GUI.Button({
    Text = "Cave Race",
    Callback = function()
        CaveRace()
    end
})

local WheelSpinsButton = GUI.Button({
    Text = "Wheel Spins",
    Callback = function()
        WheelSpins()
    end
})

local DungeonsButton = GUI.Button({
    Text = "Dungeons",
    Callback = function()
        Dungeons()
    end
})

-- Page Misc
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

--[[
getgenv().workspace = game:GetService("Workspace")
getgenv().partitions = workspace:WaitForChild("Dungeon"):WaitForChild("Partitions")

getgenv().player = game:GetService("Players").LocalPlayer
getgenv().character = player.Character or player.CharacterAdded:Wait()
getgenv().humanoidRootPart = character:WaitForChild("HumanoidRootPart")

getgenv().ReplicatedStorage = game:GetService("ReplicatedStorage")
getgenv().remotes = ReplicatedStorage.Remotes

-- Forcer la caméra en première personne
local camera = workspace.CurrentCamera
player.CameraMode = Enum.CameraMode.LockFirstPerson

-- Lancer le donjon
remotes.startDungeon:FireServer()

task.wait(2)

local positions = {}

local function collectWallsAndEndWalls(obj)
    for _, child in pairs(obj:GetChildren()) do
        if (child.Name == "EndWall" or child.Name == "Wall") and child:IsA("BasePart") then
            table.insert(positions, {
                Name = child.Name,
                Position = child.Position,
                Path = child:GetFullName(),
                CFrame = child.CFrame,
                Part = child
            })
        end
        collectWallsAndEndWalls(child)
    end
end

for _, child in pairs(partitions:GetChildren()) do
    if child.Name == "DungeonRock" and child:IsA("Model") then
        print("DungeonRock trouvé !")
        collectWallsAndEndWalls(child)
    end
end

table.sort(positions, function(a, b)
    local distanceA = (a.Position - humanoidRootPart.Position).Magnitude
    local distanceB = (b.Position - humanoidRootPart.Position).Magnitude
    return distanceA < distanceB
end)

for i, v in pairs(positions) do
    -- Téléporter le personnage à la position de l'objet
    player.Character.HumanoidRootPart.CFrame = v.CFrame
    
    -- Attendre 5 secondes
    task.wait(5)
    
    -- Forcer la caméra à cibler l'objet (v.Part)
    camera.CameraSubject = v.Part
    camera.CFrame = CFrame.new(v.Part.Position + Vector3.new(0, 2, 0), v.Part.Position) -- Ajuster la caméra pour regarder l'objet
    
    -- Attendre un court instant pour s'assurer que le personnage est bien positionné
    task.wait(0.1)
    
    -- Simuler l'effet d'un clic gauche en invoquant breakDungeonWall
    local breakDungeonWallRemote = remotes:FindFirstChild("breakDungeonWall")
    if breakDungeonWallRemote then
        -- Essayer différentes variations d'arguments
        print("Tentative d'interaction avec " .. v.Path)
        breakDungeonWallRemote:FireServer(v.Part) -- Argument de base : la partie
        task.wait(0.1)
        breakDungeonWallRemote:FireServer(v.Part, v.Position) -- Avec la position
        task.wait(0.1)
        breakDungeonWallRemote:FireServer(v.Part, v.CFrame) -- Avec le CFrame
    else
        warn("RemoteEvent 'breakDungeonWall' non trouvé dans ReplicatedStorage.Remotes !")
    end
end
]]