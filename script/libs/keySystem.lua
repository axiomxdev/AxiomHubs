
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
	
function scripting()

end