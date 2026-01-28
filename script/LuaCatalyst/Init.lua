-- Wait for game to load
while not game:IsLoaded() or not game:GetService("CoreGui") or not game:GetService("Players").LocalPlayer or not game:GetService("Players").LocalPlayer.PlayerGui do wait() end

-- Services cache
local Services = {
    Players = game:GetService("Players"),
    CoreGui = game:GetService("CoreGui"),
    TweenService = game:GetService("TweenService"),
    UserInputService = game:GetService("UserInputService")
}

local version = "0.0.1"
local folderpath = "LuaCatalyst"
local folderpathID = folderpath .. "/" ..game.GameId

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
        folderpath,
        folderpath .. "/Images",
        folderpathID,
        folderpathID .. "/Scripts",
        folderpathID .. "/Workspaces"
    }
    
    for _, folder in ipairs(folders) do
        if not isfolder(folder) then
            makefolder(folder)
        end
    end
	
    -- Fetch and save images
    local images = {
        {name = "ai.png", url = "https://axiomhub.eu/lua/LuaCatalyst/images/ai.png"},
        {name = "script.png", url = "https://axiomhub.eu/lua/LuaCatalyst/images/script.png"}
    }
    
    for _, img in ipairs(images) do
        local data = Request(img.url)
        if data then
            writefile(folderpath .. "/Images/" .. img.name, data)
        end
    end
    
    print("LuaCatalyst files initialized.")
end

if not isfolder(folderpath) then
    InitFiles()
end

-- Screen setup
_G.ScreenGUII = Instance.new("ScreenGui", PlayerGui)

local X = _G.ScreenGUII.AbsoluteSize.x
local Y = _G.ScreenGUII.AbsoluteSize.y

local ImageLabel = Instance.new("ImageLabel", _G.ScreenGUII)
ImageLabel.Size = UDim2.new(0, X, 0, Y + 50)
ImageLabel.BackgroundColor3 = Color3.new(0, 0, 0)
ImageLabel.Position = UDim2.new(0, 0, 0, -50)
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

-- Input handling functions
local function HandleMenuSwap()
    if MenuSwapBool then
        MenuSwapBool = false
        local MenuSwap = menuFrames.MenuSwap
        local rotationTween = Services.TweenService:Create(
            MenuSwap.Background.Icon, 
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {Rotation = MenuSwap.Background.Icon.Rotation + 180}
        )
        rotationTween:Play()
        
        local currentY = tonumber(string.sub(tostring(ImageLabel.Position.Y.Scale), 1, 5)) or 0
        local targetY = (currentY == -0.03) and (-50 - X) or (-50)
        
        local positionTween = Services.TweenService:Create(
            ImageLabel, 
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), 
            {Position = UDim2.new(0, 0, 0, targetY)}
        )
        positionTween:Play()
        
        task.wait(0.5)
        MenuSwapBool = true
    end
end

local function LoadModule(name, url)
    if not _G[name .. "Boolean"] then
        loadstring(game:HttpGet(url))()
    end
end

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

    local isHovering = false
    
    -- Hover effect
    item.MouseEnter:Connect(function()
        isHovering = true
        button[("IconHitArea_" .. button.Name)].BackgroundTransparency = 0.85
    end)
    
    item.MouseLeave:Connect(function()
        isHovering = false
        button[("IconHitArea_" .. button.Name)].BackgroundTransparency = 1
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

-- Create menu items
local menuItems = {
    {
        name = "SettingsModule", 
        order = 1, 
        icon = "rbxasset://textures/ui/Settings/MenuBarIcons/GameSettingsTab.png",
        onClick = function()
            LoadModule("SettingsModule", "https://raw.githubusercontent.com/OuiSom89/ScriptTool/main/Modules/SettingsModule.lua")
        end
    },
    {
        name = "ScriptWritter", 
        order = 2, 
        icon = getcustomasset(folderpath .. "/Images/script.png"),
        onClick = function()
            LoadModule("ScriptWritter", "https://raw.githubusercontent.com/OuiSom89/ScriptTool/main/Modules/ScriptWritter.lua")
        end
    },
    {
        name = "MenuSwap", 
        order = 3, 
        icon = "rbxasset://textures/WindControl/ArrowDown.png",
        onClick = HandleMenuSwap
    }
}

for _, itemConfig in ipairs(menuItems) do
    menuFrames[itemConfig.name] = CreateMenuItem(itemConfig.name, itemConfig.order, itemConfig.icon, itemConfig.onClick)
end