local Notification = loadstring(game:HttpGet("https://axiomhub.eu/lua/tools/notify.lua"))()

Notification.new("info", "Server Hop", "Looking For A Server", 2)

local placeId = getgenv().ServerHopPlaceId or game.PlaceId

local serverListUrl = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Desc&limit=100"

local visitedServers = { game.JobId }
local foundServerId

pcall(function()
    if not isfolder("Axiom'sHub") then
        makefolder("Axiom'sHub")
    end

    visitedServers = game:GetService("HttpService"):JSONDecode(
        readfile("Axiom'sHub/ServerHop.json")
    )
end)

local function saveVisitedServers()
    pcall(function()
        writefile(
            "Axiom'sHub/ServerHop.json",
            game:GetService("HttpService"):JSONEncode(visitedServers)
        )
    end)
end

local function searchServer()
    while task.wait() do
        local response = game:GetService("HttpService"):JSONDecode(
            game:HttpGetAsync(serverListUrl)
        )

        local nextCursor = response.nextPageCursor

        for _, server in next, response.data do
            local isValid =
                type(server) == "table"
                and server.id
                and tonumber(server.playing)
                and tonumber(server.maxPlayers)
                and tonumber(server.maxPlayers) > tonumber(server.playing)
                and server.id ~= game.JobId
                and not table.find(visitedServers, server.id)

            if isValid then
                foundServerId = server.id

                Notification.new("info", "Server Hop", "Teleporting To Server\n" .. server.id, 5)

                table.insert(visitedServers, server.id)
                saveVisitedServers()

                game:GetService("TeleportService"):TeleportToPlaceInstance(placeId, server.id)
                wait(5)
            end
        end

        if nextCursor then
            local cursorIndex = serverListUrl:find("&cursor=")
            if cursorIndex then
                serverListUrl = serverListUrl:gsub(serverListUrl:sub(cursorIndex), "")
            end

            serverListUrl = serverListUrl .. "&cursor=" .. nextCursor
        else
            break
        end
    end
end

searchServer()

if foundServerId == nil then
    visitedServers = { game.JobId }
    saveVisitedServers()
    searchServer()
end

if foundServerId == nil then
    Notification.new("error", "Server Hop", "No Server Found", 3)
end