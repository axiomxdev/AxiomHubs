local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Check if a ScreenGui with the same name already exists and destroy it
local existingGui = PlayerGui:FindFirstChild("Axiom Hub's Key System")
if existingGui then
    existingGui:Destroy()
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
screenGui.Name = "Axiom Hub's Key System"
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
                    sendwebhook()
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

function sendwebhook()
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
            ["color"] = 65280, -- Couleur rouge
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
end

function scripting()

	-- Getgenv setup =================================================================================
	getgenv().AutoFarm = false

	-- UI Material ===================================================================================
    local Material                  = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()

    -- Services ======================================================================================
    local Players                   = game:GetService("Players")

    -- Variables Services ============================================================================

    --#Players
    local player                    = Players.LocalPlayer

    local character                 = player.Character or player.CharacterAdded:Wait()
    local humanoid                  = character:WaitForChild("Humanoid")
    local humanoidRootPart          = character:WaitForChild("HumanoidRootPart")

	-- check getgc availability ======================================================================
    local Main
    if getgc then
        for _, v in pairs(getgc(true)) do
            if typeof(v) == "table" and rawget(v, "DataManager") then
                Main = v
                break
            end
        end
    end

    if not Main then
        player:Kick("Your exploit does not support getgc(). Find an exploit that does.")
    end

	function FuncAutoFarm()
		while getgenv().AutoFarm do
			if Main.DataManager.currentChunk.regionData.Grass then
				Main.Battle.doWildBattle(Main.Battle, Main.DataManager.currentChunk.regionData.Grass, {})
			end
			wait(0.1)
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

    local AutoFarmPageW1 = UI.New({
        Title = "AutoFarm"
    })

	local AutoTrainStart = AutoFarmPageW1.Toggle({
        Text = "AutoFarm Mobs current area",
        Callback = function(value)
            getgenv().AutoFarm = value
            if value then
                spawn(function() FuncAutoFarm() end)
            end
        end
    })

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
                if getconnections then
                    for _, connection in pairs(getconnections(speaker.Idled)) do
                        if connection["Disable"] then
                            connection["Disable"](connection)
                        elseif connection["Disconnect"] then
                            connection["Disconnect"](connection)
                        end
                    end
                else
                    speaker.Idled:Connect(function()
                        Services.VirtualUser:CaptureController()
                        Services.VirtualUser:ClickButton2(Vector2.new())
                    end)
                end
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
end -- End of Scripting function