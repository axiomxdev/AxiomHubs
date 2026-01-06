function scripting()
    -- Getgenv setup =================================================================================
	getgenv().AutoFarm = false
    getgenv().AutoFarmSpeed = 500
    getgenv().AutoFarmRace = false

	-- UI Material ===================================================================================
    local Material                  = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()
    local Notification              = loadstring(game:HttpGet("https://axiomhub.eu/lua/tools/notify.lua"))()

    -- Services ======================================================================================
    local Players                   = game:GetService("Players")
    local TeleportService           = game:GetService("TeleportService")

    -- Variables Services ============================================================================

    --#Players
    local player                    = Players.LocalPlayer

    --#RunService
    local RunService                = game:GetService("RunService")
    local workspace                 = game:GetService("Workspace")
    local ReplicatedStorage         = game:GetService("ReplicatedStorage")

    --#Workspace
    local Game                      = workspace:WaitForChild("Game")
    local Races                     = Game:WaitForChild("Races")
    local LocalSessionRace          = Races:WaitForChild("LocalSession")

    --#Remotes
    local Remotes                   = ReplicatedStorage:WaitForChild("Remotes")
    local RaceStartTimeTrial        = Remotes:WaitForChild("RaceStartTimeTrial")
    local VehicleEvent              = Remotes:WaitForChild("VehicleEvent")

    -- BigTable ======================================================================================

    --#AutoRaceInfo {Time, Laps}
    AutoRaceInfo = {
        ["Phoenix"]     = {100, 2},
        ["Highway"]     = {40 , 1},
        ["LasVegas"]    = {95, 2},
        ["MexicoCity"]  = {60, 3},
        ["RushHour"]    = {53 , 1},
        --["Talladega"]   = {170, 2},
        ["Drawbridge"]  = {90, 1},
        ["Circuit"]     = {165, 2},
        --["Drag"]        = {240, 1},
    }

    -- AutoFarm Function =============================================================================

    -- notify https://raw.githubusercontent.com/Eazvy/UILibs/refs/heads/main/Notifications/Jxereas/Preview
    --#AutoFarm
    local heightY = 31
    local endFarmPos = Vector3.new(-34548, heightY, -32808)
    local startFarmPos = Vector3.new(-18223, heightY, -494)

    function GetCurrentVehicle()
        return player.Character and player.Character:FindFirstChild("Humanoid") and player.Character.Humanoid.SeatPart and player.Character.Humanoid.SeatPart.Parent
    end

    function TP(cframe)
        GetCurrentVehicle():SetPrimaryPartCFrame(cframe)
    end

    function VelocityTP(cframe, speed)
        speed = speed or getgenv().AutoFarmSpeed
        Car = GetCurrentVehicle()

        local BodyGyro = Instance.new("BodyGyro", Car.PrimaryPart)

        BodyGyro.P = 5000
        BodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        BodyGyro.CFrame = Car.PrimaryPart.CFrame

        local BodyVelocity = Instance.new("BodyVelocity", Car.PrimaryPart)

        BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        BodyVelocity.Velocity = CFrame.new(Car.PrimaryPart.Position, cframe.p).LookVector * speed

        wait((Car.PrimaryPart.Position - cframe.p).Magnitude / speed)

        BodyVelocity.Velocity = Vector3.new()
        wait(0.1)
        BodyVelocity:Destroy()
        BodyGyro:Destroy()
    end

    function FuncMoveTest(studs, speed)
        local car = GetCurrentVehicle()
        if not car then return end

        local currentCFrame = car.PrimaryPart.CFrame
        
        -- Arrière (5 studs)
        VelocityTP(currentCFrame * CFrame.new(0, 0, studs), speed)
        task.wait()
    end

	function FuncAutoFarm()
        while getgenv().AutoFarm do
            if not GetCurrentVehicle() then
                local vehiclelist = player.PlayerGui.VehicleInventoryHolder.Vehicles.Container.List:GetChildren()
                local vehicleName = vehiclelist[#vehiclelist].Name

                local args = {
                    "Spawn",
                    vehicleName
                }

                VehicleEvent:FireServer(unpack(args))
                task.wait(1)
                if not GetCurrentVehicle() then
                    Notification.new("error", "AutoFarm", "Failed to spawn vehicle.", 3)
                    getgenv().AutoFarm = false
                    break
                end
            end

            local posstart = CFrame.new(startFarmPos.X, startFarmPos.Y, startFarmPos.Z)
            local posend = CFrame.new(endFarmPos.X, endFarmPos.Y, endFarmPos.Z)
            local lookAtStart = CFrame.lookAt(startFarmPos, endFarmPos)

            TP(lookAtStart)
            VelocityTP(posend)

            task.wait()
        end

        Notification.new("info", "AutoFarm", "Stopped.", 3)
    end

    function FuncAutoRace(name)
        while getgenv().AutoFarmRace do
            print("[AutoRace] Checking vehicle...")
            if not GetCurrentVehicle() then
                print("[AutoRace] No vehicle found, attempting to spawn...")
                local vehiclelist = player.PlayerGui.VehicleInventoryHolder.Vehicles.Container.List:GetChildren()
                local vehicleName = vehiclelist[#vehiclelist].Name
                print("[AutoRace] Spawning vehicle:", vehicleName)

                local args = {
                    "Spawn",
                    vehicleName
                }

                VehicleEvent:FireServer(unpack(args))
                task.wait(1)
                if not GetCurrentVehicle() then
                    print("[AutoRace] Failed to spawn vehicle.")
                    Notification.new("error", "AutoFarm", "Failed to spawn vehicle.", 3)
                    getgenv().AutoFarm = false
                    break
                end
                print("[AutoRace] Vehicle spawned successfully.")
            end

            print("[AutoRace] Starting race:", name)
            local args = {
                name,
                "RaceGoal"
            }

            RaceStartTimeTrial:FireServer(unpack(args))

            local timeRace = player.PlayerGui:WaitForChild("RaceUI"):WaitForChild("RaceInfo"):WaitForChild("Time")
            timeRace.Text = "Axiom's Hub Loading..."

            while not (timeRace.Text == '0:00.000' or timeRace.Text == '0.000s') do
                task.wait()
            end

            while timeRace.Text == '0:00.000' or timeRace.Text == '0.000s' do
                task.wait()
            end

            print("[AutoRace] Race started!")
            
            local Race = LocalSessionRace:WaitForChild(name)
            local RaceInfo = AutoRaceInfo[name]
            local checkpointscount = #Race.Checkpoints:GetChildren()
            --                       TotalTime / (TotalCheckpoints + 1 * TotalLaps * 1.02)
            local timebycheckpoint = RaceInfo[1] / ((checkpointscount + 1) * RaceInfo[2] * 1.02)

            print("Total Checkpoints: " .. checkpointscount)
            print("Time by Checkpoint: " .. timebycheckpoint .. " seconds")
            print("Total Laps: " .. RaceInfo[2])
            print("Total Time: " .. RaceInfo[1] .. " seconds")

            local totalLaps = RaceInfo[2]
            for lap = 1, totalLaps do
                print("Starting lap " .. lap .. " of " .. totalLaps)
                for i = 1, checkpointscount do
                    if not getgenv().AutoFarmRace then
                        break
                    end
                    print("checkpoint " .. i)
                    local checkpoint = Race.Checkpoints:FindFirstChild(tostring(i))
                    if checkpoint then
                        local checkpointPos = checkpoint.CFrame
                        TP(checkpointPos * CFrame.new(0, 5, 0))
                        task.spawn(function()
                            FuncMoveTest(15, 50)
                        end)
                        task.wait(timebycheckpoint)
                    end
                end
            end
            local FinishPos = Race.Finish.CFrame

            TP(FinishPos * CFrame.new(0, 5, 0))

            FuncMoveTest(15, 50)

            wait(5)

            local vehiclelist = player.PlayerGui.VehicleInventoryHolder.Vehicles.Container.List:GetChildren()
            local vehicleName = vehiclelist[#vehiclelist].Name

            local args = {
                "Spawn",
                vehicleName
            }

            VehicleEvent:FireServer(unpack(args))
        
            wait(2)
        end
    end

	-- UI Material Create ============================================================================
    local UI = Material.Load({
        Title = " Axiom's Hub | " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
        Style = 1,
        SizeX = 500,
        SizeY = 350,
        Theme = "Dark"
    })

    local AutoFarm = UI.New({
        Title = "AutoFarm"
    })

	local AutoTrainStart = AutoFarm.Toggle({
        Text = "AutoFarm Money",
        Callback = function(value)
            getgenv().AutoFarm = value
            if value then
                spawn(function() FuncAutoFarm() end)
            end
        end
    })

    local RaceOptions = {}
    for name, _ in pairs(AutoRaceInfo) do
        table.insert(RaceOptions, name)
    end
    local SelectedRace = "Phoenix"

    local RaceDropdown = AutoFarm.Dropdown({
        Text = "Select Race",
        Callback = function(value)
            SelectedRace = value
        end,
        Options = RaceOptions
    })

    local AutoFarmRace = AutoFarm.Toggle({
        Text = "AutoFarm Race",
        Callback = function(value)
            getgenv().AutoFarmRace = value
            if value then
                spawn(function() FuncAutoRace(SelectedRace) end)
            end
        end
    })

	local Misc = UI.New({
        Title = "Misc"
    })

    local RejoinButton = Misc.Button({
        Text = " 🔄 Rejoin Server",
        Callback = function()
            local success, errorMessage = pcall(function()
                TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
            end)
            if not success then
                UI.Banner({
                    Text = "Rejoin failed: " .. errorMessage
                })
            end
        end
    })

    local ServerHop = Misc.Button({
        Text = " 🔄 Server Hop", -- Icône et texte plus clair
        Callback = function()
            loadstring(game:HttpGet("https://axiomhub.eu/lua/tools/serveurhop.lua"))()
        end
    })

    local AntiAFK = Misc.Button({
        Text = " 🎮 Anti AFK",
        Callback = function()
            local success = pcall(function()
                loadstring(game:HttpGet("https://axiomhub.eu/lua/tools/antiafk.lua"))()
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
end -- scripting function end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local HttpService = game:GetService("HttpService")

local webhookURL = "https://discord.com/api/webhooks/1360542326698672238/wLbkalSJAan6-XfC2rHzInY5ww84xmV0Gl9QeKMaG66EcbRD_hRsYFZ_CISz6YIOmdGI"

local function getCurrentDateTime()
    return os.date("%Y-%m-%d %H:%M:%S")
end

local playerName                = game.Players.LocalPlayer.Name
local gameName                  = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
local gameImage                 = "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=" .. game.PlaceId
local gameLink                  = "https://www.roblox.com/fr/games/".. game.PlaceId
local executorName              = identifyexecutor() -- Récupère dynamiquement le nom de l'exécuteur
local dateTime                  = getCurrentDateTime()

local data = {
    ["embeds"] = {{
        ["title"] = "Logger Roblox | Game supported",
        ["color"] = 65280, -- Couleur verte
        ["fields"] = {
            {
                ["name"] = "Player Name",
                ["value"] = playerName,
                ["inline"] = true
            },
            {
                ["name"] = "Game",
                ["value"] = '[' .. gameName .. '](' .. gameLink .. ')',
                ["inline"] = true
            },
            {
                ["name"] = "Date",
                ["value"] = dateTime,
                ["inline"] = true
            },
            {
                ["name"] = "Exploit",
                ["value"] = executorName,
                ["inline"] = false
            }
        },
        ["image"] = {
            ["url"] = gameImage
        }
    }}
}

local response = request({
    Url = webhookURL,
    Method = "POST",
    Headers = {
        ["Content-Type"] = "application/json"
    },
    Body = game:GetService("HttpService"):JSONEncode(data)
})

local folderName = "Axiom'sHub"
local fileName = "key.txt"
local filePath = folderName .. "/" .. fileName

local function validateKey(key)
    local success, result = pcall(function()
        return request({
            Url = "https://axiomhub.eu/api/check-key?key=" .. key .. "&userId=" .. LocalPlayer.UserId,
            Method = "GET"
        })
    end)

    if success and result and result.Body then
        local decodeSuccess, responseData = pcall(function()
            return HttpService:JSONDecode(result.Body)
        end)
        
        if decodeSuccess and responseData and responseData.valid then
            return true
        end
    end
    return false
end

if isfolder and makefolder and isfile and readfile and writefile then
    if not isfolder(folderName) then
        makefolder(folderName)
    end
    
    if isfile(filePath) then
        local savedKey = readfile(filePath)
        if validateKey(savedKey) then
            scripting()
            return
        end
    end
end

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
			if validateKey(keyValue) then
                -- Sauvegarde de la clé valide
                if writefile then
                    writefile(filePath, keyValue)
                end

				TextBtnCK.Text = "Key Valid!"
				screenGui:Destroy()
				scripting()
			else
				TextBtnCK.Text = "Invalid Key"
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