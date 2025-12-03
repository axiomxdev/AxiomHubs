local localPlayer = game:GetService("Players"):WaitForChild("LocalPlayer")

function missing(t, f, fallback)
    if type(f) == t then return f end
    return fallback
end

local VirtualUser = game:GetService("VirtualUser")

getconnections = missing("function", getconnections or get_signal_cons)

if getconnections then
    for _, connection in pairs(getconnections(localPlayer.Idled)) do
        if connection["Disable"] then
            connection["Disable"](connection)
        elseif connection["Disconnect"] then
            connection["Disconnect"](connection)
        end
    end
else
    localPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end