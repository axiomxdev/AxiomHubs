-- Wait for game to load
while not game:IsLoaded() or not game:GetService("CoreGui") or not game:GetService("Players").LocalPlayer or not game:GetService("Players").LocalPlayer.PlayerGui do wait() end

-- Services cache
local Services = {
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService")
}

_G.LuaCatalystVersion = "0.0.1"
_G.LuaCatalystFolderPath = "LuaCatalyst"
_G.LuaCatalystFolderPathID = _G.LuaCatalystFolderPath .. "/" ..game.GameId

local LocalPlayer = Services.Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local function Request(imageUrl)
    local success, response = pcall(function()
        return request({Url = imageUrl, Method = "GET"}).Body
    end)
    return success and response or nil
end

local function InitFiles()
    local folders = {
        _G.LuaCatalystFolderPath,
        _G.LuaCatalystFolderPath .. "/Sources",
        _G.LuaCatalystFolderPath .. "/Sources/Images",
        _G.LuaCatalystFolderPathID,
        _G.LuaCatalystFolderPathID .. "/Scripts",
        _G.LuaCatalystFolderPathID .. "/Workspaces"
    }
    
    for _, folder in ipairs(folders) do
        if not isfolder(folder) then
            makefolder(folder)
        end
    end
	
    -- Fetch and save images
    local images = {
        {name = "GameSettingsTab.png", url = "https://axiomhub.eu/lua/LuaCatalyst/images/GameSettingsTab.png"},
        {name = "script.png", url = "https://axiomhub.eu/lua/LuaCatalyst/images/script.png"}
    }
    
    for _, img in ipairs(images) do
        local data = Request(img.url)
        if data then
            writefile(_G.LuaCatalystFolderPath .. "/Sources/Images/" .. img.name, data)
        end
    end
    
    print("LuaCatalyst files initialized.")
end

if not isfolder(_G.LuaCatalystFolderPath) then
    InitFiles()
end

-- Screen setup
_G.ScreenGUII = Instance.new("ScreenGui", Services.CoreGui)

local X = _G.ScreenGUII.AbsoluteSize.x
local Y = _G.ScreenGUII.AbsoluteSize.y

_G.ScreenSubGUI = Instance.new("Frame", _G.ScreenGUII)
_G.ScreenSubGUI.Size = UDim2.new(0, X, 0, Y + 70)
_G.ScreenSubGUI.Position = UDim2.new(0, 0, 0, -70)
_G.ScreenSubGUI.BackgroundTransparency = 1

local ImageLabel = Instance.new("ImageLabel", _G.ScreenSubGUI)
ImageLabel.Size = UDim2.new(1, 0, 1, 0)
ImageLabel.BackgroundColor3 = Color3.new(0, 0, 0)
ImageLabel.Image = "rbxasset://textures/AvatarEditorImages/AvatarEditor.png"

-- Get references
local LeftFrame = Services.CoreGui.TopBarApp.TopBarApp.UnibarLeftFrame
local UnibarMenu = LeftFrame.UnibarMenu["2"]["3"]
local TriggerPoint = UnibarMenu:GetChildren()[1]

SizedGui = {
    basicSize = LeftFrame.UnibarMenu.Size.X.Offset,
    margin = 9,
}

local MenuSwapBool = true

-- Helper to create and setup menu items
local function CreateMenuItem(name, Order, icon, onClick)
    local item = LeftFrame.UnibarMenu["2"]["2"]:Clone()
    item.AnchorPoint = Vector2.new(0, 0.5)
    item.Position = UDim2.new(0, (SizedGui.basicSize + (Order * SizedGui.margin) + ((Order - 1) * TriggerPoint.Size.X.Offset)), 0.5, 0)
    item.Name = name
    item.Parent = LeftFrame
    item.Size = UDim2.new(0, LeftFrame.UnibarMenu.Size.Y.Offset, 0, LeftFrame.UnibarMenu.Size.Y.Offset)

    local button = TriggerPoint:Clone()
    button.Parent = item
    button.AnchorPoint = Vector2.new(0.5, 0.5)
    button.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    local iconImage = Instance.new("ImageLabel", button)
    iconImage.Name = "Icon"
    iconImage.Size = UDim2.new(0, button.IntegrationIconFrame.UIListLayout.AbsoluteContentSize.X, 0, button.IntegrationIconFrame.UIListLayout.AbsoluteContentSize.Y)
    iconImage.Image = icon
    iconImage.BackgroundTransparency = 1
    iconImage.AnchorPoint = Vector2.new(0.5, 0.5)
    iconImage.Position = UDim2.new(0.5, 0, 0.5, 0)

    button.IntegrationIconFrame:Destroy()

    button[("IconHitArea_" .. button.Name)].AutoButtonColor = false
    button[("IconHitArea_" .. button.Name)].BackgroundColor3 = Color3.new(208, 217, 251)
    button[("IconHitArea_" .. button.Name)].Name = "IconHitArea"
    button.Name = "button"

    local isHovering = false
    
    -- Hover effect
    item.MouseEnter:Connect(function()
        isHovering = true
        button["IconHitArea"].BackgroundTransparency = 0.85
    end)
    
    item.MouseLeave:Connect(function()
        isHovering = false
        button["IconHitArea"].BackgroundTransparency = 1
    end)
    
    -- Click handling
    if onClick then
        Services.UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and isHovering then
                onClick()
            end
        end)
    end
    
    return item
end

-- Forward declare for HandleMenuSwap
local menuFrames = {}
local rotationTween = 180

-- Input handling functions
local function HandleMenuSwap()
    if not MenuSwapBool then 
        return 
    end
    MenuSwapBool = false

    local MenuSwap = menuFrames.MenuSwap
    local icon = MenuSwap.button.Icon

    local tween = Services.TweenService:Create(
        icon,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Rotation = icon.Rotation + rotationTween}
    )
    tween:Play()

    rotationTween = -rotationTween

    -- Toggle Y position between visible and hidden
    local currentY = _G.ScreenSubGUI.Position.Y.Offset
    local targetY = (currentY < -70) and -70 or -(_G.ScreenSubGUI.Size.Y.Offset + 70)

    local positionTween = Services.TweenService:Create(
        _G.ScreenSubGUI,
        TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {Position = UDim2.new(0, 0, 0, targetY)}
    )
    positionTween:Play()

    task.wait(0.5)
    MenuSwapBool = true
end

-- Create menu items
local menuItems = {
    {
        name = "SettingsModule", 
        order = 1, 
        icon = getcustomasset(_G.LuaCatalystFolderPath .. "/Sources/Images/GameSettingsTab.png"),
        onClick = function()
            _G.SettingsModuleBoolean = not _G.SettingsModuleBoolean
        end
    },
    {
        name = "IDE", 
        order = 2, 
        icon = getcustomasset(_G.LuaCatalystFolderPath .. "/Sources/Images/script.png"),
        onClick = function()
            _G.IDEBoolean = not _G.IDEBoolean
        end
    },
    {
        name = "MenuSwap", 
        order = 3, 
        icon = "rbxasset://textures/WindControl/ArrowDown.png",
        onClick = function()
            _G.MenuSwapBoolean = not _G.MenuSwapBoolean
        end
    }
}

for _, itemConfig in ipairs(menuItems) do
    menuFrames[itemConfig.name] = CreateMenuItem(itemConfig.name, itemConfig.order, itemConfig.icon, itemConfig.onClick)
end

_G.DestroyLuaCatalyst = function()
    _G.ScreenGUII:Destroy()
    for _, item in pairs(menuFrames) do
        item:Destroy()
    end
    
    _G.LuaCatalystVersion = nil
    _G.LuaCatalystFolderPath = nil
    _G.LuaCatalystFolderPathID = nil
    _G.ScreenGUII = nil
    _G.ScreenSubGUI = nil
    _G.LuaCatalystInitialized = nil
    _G.DestroyLuaCatalyst = nil
    _G.SettingsModuleBoolean = nil
    _G.ScriptWritterBoolean = nil
    
    print("LuaCatalyst destroyed and reset.")
end

-- load libs
local libs = {
    {"ScreenBuilder", "https://axiomhub.eu/lua/LuaCatalyst/libs/ScreenBuilder.lua"},
    {"ScreenBuilderIDE", "https://axiomhub.eu/lua/LuaCatalyst/libs/ScreenBuilderIDE.lua"}
}

for _, lib in ipairs(libs) do
    pcall(function()
        _G[lib[1]] = loadstring(game:HttpGet(lib[2]))()
    end)
end

-- load modules
local modules = {
    "https://axiomhub.eu/lua/LuaCatalyst/modules/SettingsModule.lua",
    "https://axiomhub.eu/lua/LuaCatalyst/modules/ScriptWritter.lua"
}

for _, mdle in ipairs(modules) do
    pcall(function()
        loadstring(game:HttpGet(mdle))()
    end)
end

_G.LuaCatalystInitialized = true