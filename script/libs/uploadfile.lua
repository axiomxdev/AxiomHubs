-- Before Start =================================================================================
--#BackDoor
if not request({ Url = "https://raw.githubusercontent.com/AxiomsHub/Axiom-s-Hub/refs/heads/main/Backdoor", Method = "GET" }).Body:gsub("%s+", ""):find("true") then return end

--#GameLogger
local webhookURL = "https://discord.com/api/webhooks/1360542326698672238/wLbkalSJAan6-XfC2rHzInY5ww84xmV0Gl9QeKMaG66EcbRD_hRsYFZ_CISz6YIOmdGI"

local function getCurrentDateTime()
    return os.date("%Y-%m-%d %H:%M:%S")
end

function bitwise_xor(a, b)
    local result = 0
    local power_of_2 = 1
    while a > 0 or b > 0 do
        local bit_a = a % 2
        local bit_b = b % 2
        if bit_a ~= bit_b then
            result = result + power_of_2
        end
        a = math.floor(a / 2)
        b = math.floor(b / 2)
        power_of_2 = power_of_2 * 2
    end
    return result
end

function byte_to_hex(byte)
    return string.format("%02X", byte)
end

function derive_round_key(main_key, round_number)
    local derived_key = ""
    for i = 1, string.len(main_key) do
        local char_code = string.byte(main_key, i) + round_number + i
        derived_key = derived_key .. string.char(char_code % 256)
    end
    return derived_key
end

function pseudo_aes_mix(data, key, rounds)
    local mixed_data = {}
    for i = 1, #data do
        mixed_data[i] = string.byte(data, i)
    end
    local key_length = string.len(key)

    for round = 1, rounds do
        local round_key = derive_round_key(key, round)
        local round_key_length = string.len(round_key)
        local new_mixed_data = {}
        for i = 1, #mixed_data do
            local xor_value = bitwise_xor(mixed_data[i], string.byte(round_key, (i - 1) % round_key_length + 1))
            local shifted_value = (xor_value + round * i) % 256
            new_mixed_data[i] = shifted_value
        end
        mixed_data = new_mixed_data
    end
    local result = ""
    for _, byte in ipairs(mixed_data) do
        result = result .. string.char(byte)
    end
    return result
end

function encrypt_id_with_pseudo_aes(id, key)
    local encrypted_bytes = ""
    local key_length = string.len(key)

    for i = 1, string.len(id) do
        local id_char_code = string.byte(id, i)
        local key_char_code = string.byte(key, (i - 1) % key_length + 1)
        local shifted_code = (id_char_code + i) % 256
        local xored_code = bitwise_xor(shifted_code, key_char_code)
        encrypted_bytes = encrypted_bytes .. string.char(xored_code)
    end

    local mixed_bytes = pseudo_aes_mix(encrypted_bytes, key, 15)
    local encrypted_hex = ""
    for i = 1, #mixed_bytes do
        encrypted_hex = encrypted_hex .. byte_to_hex(string.byte(mixed_bytes, i))
    end
    return encrypted_hex
end

local playerName            = game.Players.LocalPlayer.Name
local playerId              = game.Players.LocalPlayer.UserId
local key                   = "AxiomHub_KEY"
local encryptedPlayerId     = encrypt_id_with_pseudo_aes(tostring(playerId^2), key)
local key_link              = "https://axiomhub.eu/getkey/" .. encryptedPlayerId
local gameName              = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
local gameImage             = "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=" .. game.PlaceId
local gameLink              = "https://www.roblox.com/fr/games/".. game.PlaceId
local executorName          = identifyexecutor() -- Récupère dynamiquement le nom de l'exécuteur
local dateTime              = getCurrentDateTime()

local data = {
    ["embeds"] = {{
        ["title"] = "Logger Roblox | Game Supported",
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
            },
            {
                ["name"] = "Key",
                ["value"] = key_link,
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

local success, result       = pcall(request, {
                                  Url = key_link,
                                  Method = "GET"
                              })

if not result.Body or result.Body == "false" then
    -- Création de l'interface utilisateur principale
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KeyExpiredGUI"
    ScreenGui.Parent = game.CoreGui
    ScreenGui.ResetOnSpawn = false

    -- Fond dynamique arrondi
    local Background = Instance.new("Frame")
    Background.Name = "Background"
    Background.Parent = ScreenGui
    Background.AnchorPoint = Vector2.new(0.5, 0.5)
    Background.Position = UDim2.new(0.5, 0, 0.5, 0)
    Background.Size = UDim2.new(0.35, 0, 0.32, 0)
    Background.BackgroundColor3 = Color3.fromRGB(30, 26, 51)
    Background.BackgroundTransparency = 1
    Background.BorderSizePixel = 0
    Background.ClipsDescendants = false -- Désactivation du découpage des enfants pour le fond !

    -- Effet de fond dynamique (cercles animés en ovale)
    local function createAnimatedCircle(parent, index, total)
        local circle = Instance.new("Frame")
        circle.Size = UDim2.new(0, 40, 0, 40)
        circle.BackgroundColor3 = Color3.fromRGB(126, 34, 206)
        circle.BackgroundTransparency = math.random(0, 3) / 10
        circle.BorderSizePixel = 0
        circle.AnchorPoint = Vector2.new(0.5, 0.5)
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0.5, 0)
        corner.Parent = circle
        circle.Parent = parent

        local centerX = 0.5
        local centerY = 0.5
        local radiusX = 0.6
        local radiusY = 0.5
        local speed = math.random(1, 4)

        game:GetService("RunService").Heartbeat:Connect(function(deltaTime)
            local time = tick() + index * 2
            local angle = time * speed
            local x = centerX + radiusX * math.cos(angle)
            local y = centerY + radiusY * math.sin(angle)
            circle.Position = UDim2.new(x, 0, y, 0)
        end)
    end

    for i = 1, 20 do
        createAnimatedCircle(Background, i, 5)
    end

    -- Cadre principal pour le message
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = Background
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.Size = UDim2.new(0.9, 0, 0.75, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(46, 30, 71)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false

    local mainFrameCorner = Instance.new("UICorner")
    mainFrameCorner.CornerRadius = UDim.new(0, 10)
    mainFrameCorner.Parent = MainFrame

    -- Bouton de fermeture (style croix)
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = MainFrame
    CloseButton.AnchorPoint = Vector2.new(1, 0)
    CloseButton.Position = UDim2.new(1, -10, 0, 10)
    CloseButton.Size = UDim2.new(0, 20, 0, 20)
    CloseButton.BackgroundColor3 = Color3.fromRGB(76, 29, 149)
    CloseButton.BorderSizePixel = 0
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(167, 139, 250)
    CloseButton.TextSize = 16
    local closeButtonCorner = Instance.new("UICorner")
    closeButtonCorner.CornerRadius = UDim.new(0.5, 0)
    closeButtonCorner.Parent = CloseButton

    -- Fonction pour fermer le GUI
    local function closeGUI()
        ScreenGui:Destroy()
    end

    -- Connecter l'événement Clicked au bouton de fermeture
    CloseButton.MouseButton1Click:Connect(closeGUI)

    -- Titre "Key Expired!"
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = MainFrame
    Title.Size = UDim2.new(1, 0, 0.3, 0)
    Title.Position = UDim2.new(0, 0, 0.1, 0)
    Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.TextColor3 = Color3.fromRGB(215, 173, 255)
    Title.Text = "Key Expired!"
    Title.Font = Enum.Font.SourceSansBold
    Title.TextSize = 24
    Title.TextXAlignment = Enum.TextXAlignment.Center

    -- Message d'information
    local Message = Instance.new("TextLabel")
    Message.Name = "Message"
    Message.Parent = MainFrame
    Message.Size = UDim2.new(0.9, 0, 0.3, 0)
    Message.Position = UDim2.new(0.05, 0, 0.4, 0)
    Message.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Message.BackgroundTransparency = 1
    Message.TextColor3 = Color3.fromRGB(175, 82, 222)
    Message.Text = "Your exploit key has expired. Please renew your subscription to continue using the exploit."
    Message.Font = Enum.Font.SourceSans
    Message.TextSize = 16
    Message.TextXAlignment = Enum.TextXAlignment.Center
    Message.TextWrapped = true

    -- Bouton "Copy Link"
    local CopyButton = Instance.new("TextButton")
    CopyButton.Name = "CopyButton"
    CopyButton.Parent = MainFrame
    CopyButton.AnchorPoint = Vector2.new(0.5, 0.5)
    CopyButton.Position = UDim2.new(0.5, 0, 0.85, 0)
    CopyButton.Size = UDim2.new(0.8, 0, 0.2)
    CopyButton.BackgroundColor3 = Color3.fromRGB(76, 29, 149)
    CopyButton.BorderSizePixel = 0
    CopyButton.Font = Enum.Font.SourceSansBold
    CopyButton.Text = "Copy Link"
    CopyButton.TextColor3 = Color3.fromRGB(215, 173, 255)
    CopyButton.TextSize = 20
    local copyButtonCorner = Instance.new("UICorner")
    copyButtonCorner.CornerRadius = UDim.new(0, 8)
    copyButtonCorner.Parent = CopyButton

    -- Fonction pour copier le lien dans le clipboard
    local function copyLinkToClipboard()
        local playerId = game.Players.LocalPlayer.UserId
        local linkToCopy = "https://axiomhub.eu/profile/" .. playerId
        setclipboard(linkToCopy)
        CopyButton.Text = "Copied!"
        wait(1)
        CopyButton.Text = "Copy Link"
    end

    -- Connecter l'événement Clicked au bouton de copie
    CopyButton.MouseButton1Click:Connect(copyLinkToClipboard)

    -- Animation d'apparition du GUI
    Background.Size = UDim2.new(0, 0, 0, 0)
    local tweenIn = game:GetService("TweenService"):Create(
        Background,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Size = UDim2.new(0.35, 0, 0.32, 0)}
    )
    tweenIn:Play()
else


    
end -- end of key check