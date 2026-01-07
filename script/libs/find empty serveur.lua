local Notification = loadstring(game:HttpGet("https://axiomhub.eu/lua/tools/notify.lua"))()

-- Initialize failed server list
if not getgenv().FailedServerID then
    getgenv().FailedServerID = {}
end

-- Determine place ID
if not ThePlaceID or ThePlaceID == 0 then
    ThePlaceID = game.PlaceId
end

-- Notify user
Notification.new("info", "Notification", "Checking Servers!", 9e9)

-- Variables
local lowestPlayers = math.huge
local apiUrl = "https://games.roblox.com/v1/games/" .. ThePlaceID .. "/servers/Public?sortOrder=Asc&limit=100"
local bestServer
local currentServerInfo

-- Loop through all pages of server list
while task.wait() do
    local response = game:GetService("HttpService"):JSONDecode(game:HttpGetAsync(apiUrl))
    local nextCursor = response.nextPageCursor

    for _, server in next, response.data do
        if typeof(server) == "table"
            and server.id
            and tonumber(server.playing)
            and not table.find(getgenv().FailedServerID, server.id)
        then
            -- Save current server info
            if server.id == game.JobId then
                currentServerInfo = server
            end

            -- Check if this server is better (less players, or same players but lower ping)
            if lowestPlayers > server.playing
                or (bestServer and lowestPlayers == server.playing
                and tonumber(server.ping)
                and tonumber(bestServer.ping)
                and server.ping < bestServer.ping)
            then
                lowestPlayers = server.playing
                bestServer = server
            end
        end
    end

    -- Handle pagination
    if nextCursor then
        local cursorIndex = apiUrl:find("&cursor=")
        if cursorIndex then
            apiUrl = apiUrl:gsub(apiUrl:sub(cursorIndex), "")
        end
        apiUrl = apiUrl .. "&cursor=" .. nextCursor
    else
        break
    end
end

-- Check if current server is already the best
local playerCount = #game:GetService("Players"):GetChildren() - 1

if bestServer.id == game.JobId
    or (lowestPlayers == playerCount
    and tonumber(currentServerInfo.ping)
    and tonumber(bestServer.ping)
    and currentServerInfo.ping < bestServer.ping)
then
    return Notification.new("warn", "Notification", "Your current server is the most empty server atm", 2)
end

-- Teleport to better server
Notification.new("success", "Notification", "Teleporting To Server\n" .. bestServer.id, 2)
table.insert(getgenv().FailedServerID, bestServer.id)

game:GetService("TeleportService"):TeleportToPlaceInstance(ThePlaceID, bestServer.id)