repeat task.wait(0.1) until getgenv().AxiomHubUiConstante

local Notification

task.spawn(function()
    pcall(function()
        Notification = loadstring(game:HttpGet("https://axiomhub.eu/lua/tools/notify.lua"))()
        loadstring(game:HttpGet("https://axiomhub.eu/lua/tools/antiafk.lua"))()
    end)
end)

local OtherGui = getgenv().AxiomHubUiConstante.New({
	Title = "Other"
})

OtherGui.Button({
    Text = "Discord",
    Callback = function()
        if httprequest then
            httprequest({
                Url = 'http://127.0.0.1:6463/rpc?v=1',
                Method = 'POST',
                Headers = {
                    ['Content-Type'] = 'application/json',
                    Origin = 'https://discord.com'
                },
                Body = HttpService:JSONEncode({
                    cmd = 'INVITE_BROWSER',
                    nonce = HttpService:GenerateGUID(false),
                    args = {code = 'Fc3A9mFYde'}
                })
            })
            Notification.new("success", "Discord", "Invite Sent", 3)
        else
            setclipboard('https://discord.gg/Fc3A9mFYde')
            Notification.new("success", "Discord", "Link Copied To Clipboard", 3)
        end
    end
})

OtherGui.Button({
    Text = "Server Hop",
    Callback = function()
        loadstring(game:HttpGet("https://axiomhub.eu/lua/tools/serverhop.lua"))()
    end
})

OtherGui.Button({
    Text = "Find Empty Server",
    Callback = function()
        loadstring(game:HttpGet("https://axiomhub.eu/lua/tools/emptyserver.lua"))()
    end
})