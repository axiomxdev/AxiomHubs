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