--[[
    Axiom Hub | Loomian Legacy Script
    Revised & Corrected based on Proven Methods
]]

-- UI Material
local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()

-- Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

-- Variables & Game Table
local MainGame
local found = false

-- 1. MainGame Detection (Restored Active Method)
if getgc then
    for _, v in pairs(getgc(true)) do
        if typeof(v) == "table" and rawget(v, "DataManager") then
            MainGame = v
            found = true
            break
        end
    end
end

if not found and debug and debug.getregistry then
    for _, v in pairs(debug.getregistry()) do
        if typeof(v) == "table" and rawget(v, "DataManager") then
            MainGame = v
            found = true
            break
        end
    end
end

local UI = Material.Load({
    Title = "Axiom Hub | Loomian Legacy",
    Style = 1,
    SizeX = 550,
    SizeY = 400,
    Theme = "Dark"
})

if not MainGame then
    UI.Banner({
        Text = "Error: Could not find MainGame table. Your executor might not support getgc()."
    })
    warn("Axiom Hub: Failed to find MainGame table.")
    return
end

-- Helper for Context (SecureCall)
local set_thread_context = setthreadcontext or function(_) end
local function SecureCall(func, ...)
    set_thread_context(2)
    return func(...)
end

-------------------------------------------------------------------
-- SETTINGS
-------------------------------------------------------------------
getgenv().AxiomSettings = {
    AutoHeal = false,
    InfiniteRepel = false,
    SkipDialogue = false,
    FastBattle = false,
    AutoFish = false,
    AutoFishOnlyItems = false,
    AutoHunt = false,
    AutoBattle = false,
    AutoBuyDisc = false,
    SelectedDisc = "Normal Disc",
    Capture = {
        Enabled = false,
        Disc = "Normal Disc",
        Gleam = false,
        Gamma = false,
        NotOwned = false,
        Spare = false,
        CustomList = {}
    },
    Misc = {
        NoNewMoves = false,
        NoSwitch = false,
        NoNick = false,
        NoProgress = false
    }
}
local Settings = getgenv().AxiomSettings

-------------------------------------------------------------------
-- UTILITIES & HELPERS
-------------------------------------------------------------------
local function GetCurrentBattle()
    return MainGame.Battle and MainGame.Battle.currentBattle or nil
end

local function GetActiveLoomian()
    local b = GetCurrentBattle()
    return b and b.yourSide.active[1] or nil
end

local function IsHealthFull()
    return MainGame.Network:get("PDS", "areFullHealth")
end

-------------------------------------------------------------------
-- FEATURES: AUTO HEAL
-------------------------------------------------------------------
local function FuncAutoHeal()
    while Settings.AutoHeal do
        task.wait(1)
        pcall(function()
            if Settings.AutoHeal then
                local currentChunk = MainGame.DataManager.currentChunk
                if currentChunk and MainGame.MasterControl.WalkEnabled and MainGame.Menu.enabled and not GetCurrentBattle() then
                    if not IsHealthFull() then
                        if currentChunk.data.HasOutsideHealers then
                            MainGame.Network:get("heal", nil, "HealMachine1")
                        else
                            -- Blackout Logic
                            local blackoutTo = currentChunk.regionData and currentChunk.regionData.BlackOutTo or currentChunk.data.blackOutTo
                            
                            if blackoutTo then
                                MainGame.MasterControl.WalkEnabled = false
                                MainGame.Utilities.FadeOut(1)
                                MainGame.Utilities.TeleportToSpawnBox()
                                currentChunk:unbindIndoorCam()
                                currentChunk:destroy()
                                
                                -- Load Healer Chunk
                                SecureCall(function() 
                                    MainGame.DataManager:loadChunk(blackoutTo)
                                end)
                                
                                MainGame.MasterControl.WalkEnabled = true
                            end
                        end
                    end
                end
            end
        end)
    end
end

-------------------------------------------------------------------
-- FEATURES: INFINITE REPEL
-------------------------------------------------------------------
local function FuncInfiniteRepel()
    while Settings.InfiniteRepel do
        task.wait(0.5)
        if MainGame.Repel then
            if Settings.InfiniteRepel then
                MainGame.Repel.steps = 100
            end
        end
    end
    -- Reset on disable
    if MainGame.Repel and MainGame.Repel.steps > 100 then
        MainGame.Repel.steps = 0
    end
end


-------------------------------------------------------------------
-- FEATURES: AUTO HUNT / ENCOUNTER (Scanning Method)
-------------------------------------------------------------------
local OnStepTakenFunc = nil
local dbg = debug or getgenv().debug

-- Scan for onStepTaken in WalkEvents.beginLoop upvalues
if MainGame.WalkEvents and MainGame.WalkEvents.beginLoop and dbg and dbg.getupvalues and dbg.getinfo then
    for _, val in pairs(dbg.getupvalues(MainGame.WalkEvents.beginLoop)) do
        if typeof(val) == "function" then
            local info = dbg.getinfo(val)
            if info and info.name == "onStepTaken" then
                OnStepTakenFunc = val
                break
            end
        end
    end
else
    -- Fallback/Warn if debug lib missing
    warn("Axiom Hub: Debug library missing or MainGame structure changed. Auto Hunt may not work.")
end

local function FuncAutoHunt()
    while Settings.AutoHunt do
        task.wait(0.1)
        if OnStepTakenFunc then
            -- Only if walking enabled, menu enabled, no battle
            if MainGame.MasterControl.WalkEnabled and MainGame.Menu.enabled and not GetCurrentBattle() then
                local success, err = pcall(function()
                    OnStepTakenFunc(true)
                end)
                if not success then
                    warn("Auto Hunt Error: " .. tostring(err))
                    Settings.AutoHunt = false 
                end
            end
        end
    end
end

-------------------------------------------------------------------
-- FEATURES: AUTO FISH (Reverted to Hook Method)
-------------------------------------------------------------------
local originalOnWaterClicked = MainGame.Fishing.OnWaterClicked
MainGame.Fishing.OnWaterClicked = function(...)
    if Settings.AutoFish then
         return -- Skip mechanics
    end
    return originalOnWaterClicked(...)
end

local function CustomFishMiniGame()
    local currentChunk = MainGame.DataManager.currentChunk
    local fishingSpot = nil
    
    if currentChunk.regionData.Fishing then fishingSpot = currentChunk.regionData.Fishing end
    
    if not fishingSpot then return false end
    local spotId = fishingSpot.id or fishingSpot
    
    local waterPart = nil
    if currentChunk.map then
         for _, child in pairs(currentChunk.map:GetChildren()) do
             if child.Name == "Water" then waterPart = child end
         end
    end
    
    if waterPart then
         local castOrigin = waterPart.Position + Vector3.new(0, waterPart.Size.Y - 5, 0)
         local result, fshModel = MainGame.Network:get("PDS", "fish", castOrigin, spotId)
         
         if result then
             -- Got a bite?
             local biteResult = select(2, MainGame.Network:get("PDS", "fish", castOrigin, spotId))
             if biteResult and biteResult.delay then
                 return 0.9, MainGame.Network:get("PDS", "fshchi", biteResult.id), fishingSpot
             end
         end
    end
    return false
end

local function FuncAutoFish()
    while Settings.AutoFish do
        task.wait(0.5)
        local pct, result, spot = CustomFishMiniGame()
        if pct then
            if result == true and not Settings.AutoFishOnlyItems then
                MainGame.Battle:doWildBattle(spot, { dontExclaim = true, fshPct = pct })
            else
                MainGame.Network:post("PDS", "reelIn")
            end
        end
    end
end

-------------------------------------------------------------------
-- FEATURES: AUTO BUY DISC (From loomian_.lua)
-------------------------------------------------------------------
local function FuncAutoBuyDisc()
    while Settings.AutoBuyDisc do
        task.wait(5)
        pcall(function()
            local bag = MainGame.Network:get("PDS", "getBagPouch", 3)
            local count = 0
            
            local DiscIds = {
                ["Normal Disc"] = 0,
                ["Advanced Disc"] = 2,
                ["Hyper Disc"] = 3,
                ["Ace Disc"] = 4 
            }
            local idToBuy = DiscIds[Settings.SelectedDisc]
            
            for _, item in pairs(bag) do
                if item.name == Settings.SelectedDisc then count = item.count end
            end
            
            if count < 10 and idToBuy then
                MainGame.Network:post("Shop", "buyItem", idToBuy, 10)
            end
        end)
    end
end

-------------------------------------------------------------------
-- FEATURES: HOOKS & MISC
-------------------------------------------------------------------
-- Battle Message Hook
if MainGame.BattleGui then
    local originalBattleMsg = MainGame.BattleGui.message
    MainGame.BattleGui.message = function(self, ...)
        local args = {...}
        local msg = args[1]
        
        if type(msg) == "string" then
            if Settings.Misc.NoNewMoves and msg:find("reassign its moves") then return {}, true end
            if Settings.Misc.NoSwitch and msg:find("Will you switch Loomians") then return {}, true end
            if Settings.Misc.NoNick and msg:find("Give a nickname") then return {}, true end
        end
        
        if Settings.SkipDialogue then
            return {}, true
        end
        return originalBattleMsg(self, ...)
    end
end

-- NPC Chat Hook
if MainGame.NPCChat then
    local originalSay = MainGame.NPCChat.Say
    MainGame.NPCChat.Say = function(self, ...)
         if Settings.SkipDialogue then return end
         return originalSay(self, ...)
    end
end

-- Mastery Progress Hook
if MainGame.Menu and MainGame.Menu.mastery then
    local oldShowProgress = MainGame.Menu.mastery.showProgressUpdate
    MainGame.Menu.mastery.showProgressUpdate = function(...)
        if Settings.Misc.NoProgress then return end
        return oldShowProgress(...)
    end
end

-- Fast Battle Hooks
if MainGame.BattleGui then
    local originalSetCam = MainGame.BattleGui.setCameraIfLookingAway
    MainGame.BattleGui.setCameraIfLookingAway = function(self, battleData)
        if Settings.FastBattle and battleData then battleData.fastForward = true end
        local res = originalSetCam(self, battleData)
        if Settings.FastBattle and battleData then battleData.fastForward = false end
        return res
    end
    
    if MainGame.RoundedFrame then
        local originalFill = MainGame.RoundedFrame.setFillbarRatio
        MainGame.RoundedFrame.setFillbarRatio = function(...)
            local args = {...}
            if Settings.FastBattle and GetCurrentBattle() then
                args[3] = false -- instant
            end
            return originalFill(unpack(args))
        end
    end
end

-------------------------------------------------------------------
-- FEATURES: BATTLE LOOP
-------------------------------------------------------------------
local function FuncAutoBattle()
    while Settings.AutoBattle or Settings.Capture.Enabled do
         task.wait(0.5) 
         if not Settings.AutoBattle and not Settings.Capture.Enabled then break end

         local battle = GetCurrentBattle()
         if battle and battle.state == "input" then
              local active = GetActiveLoomian()
              local wild = battle.kind == "wild"
              local actionTaken = false
              
              -- CATCH LOGIC
              if wild and Settings.Capture.Enabled then
                   local shouldCatch = false
                   if Settings.Capture.NotOwned and not active.owned then shouldCatch = true end
                   if Settings.Capture.Gleam and (active.shiny and active.shiny >= 1) then shouldCatch = true end
                   if Settings.Capture.Gamma and (active.shiny and active.shiny == 2) then shouldCatch = true end
                   if table.find(Settings.Capture.CustomList, active.name:lower()) then shouldCatch = true end
                   if Settings.Capture.Spare and (active.hp / active.maxhp < 0.2) then shouldCatch = true end
                   
                   if shouldCatch then
                        local bag = MainGame.Network:get("PDS", "getBagPouch", 3)
                        local discId = nil
                         for _, item in pairs(bag) do
                             if item.name == Settings.Capture.Disc then discId = item.id break end
                         end
                         
                         if discId then
                             actionTaken = true
                             MainGame.BattleGui:exitButtonsMain()
                             MainGame.BattleGui.inputEvent:fire("useitem " .. discId)
                             task.wait(1.5)
                         end
                   end
              end
              
              -- AUTO BATTLE
              if Settings.AutoBattle and not actionTaken then
                   pcall(function()
                        MainGame.BattleGui:mainButtonClicked(1) -- Fight
                        MainGame.BattleGui:onMoveClicked(1) -- Spam move 1
                   end)
              end
         end
    end
end


-------------------------------------------------------------------
-- UI: MATERIAL INTERFACE
-------------------------------------------------------------------
local PageMain = UI.New({ Title = "Main" })

PageMain.Toggle({
    Text = "Auto Heal (Outdoor & Center)",
    Callback = function(v)
        Settings.AutoHeal = v
        if v then task.spawn(FuncAutoHeal) end
    end,
    Enabled = Settings.AutoHeal
})
PageMain.Toggle({
    Text = "Infinite Repel",
    Callback = function(v)
        Settings.InfiniteRepel = v
        if v then task.spawn(FuncInfiniteRepel) end
    end,
    Enabled = Settings.InfiniteRepel
})

local PageFarming = UI.New({ Title = "Farming" })

PageFarming.Toggle({
    Text = "Auto Hunt (Encounter)",
    Callback = function(value)
        Settings.AutoHunt = value
        if value then
            task.spawn(function() FuncAutoHunt() end)
        end
    end,
    Enabled = Settings.AutoHunt
})

PageFarming.Toggle({
    Text = "Auto Battle (Trainer - Move 1)",
    Callback = function(v) 
        Settings.AutoBattle = v 
        if v then task.spawn(FuncAutoBattle) end
    end,
    Enabled = Settings.AutoBattle
})

local PageCatch = UI.New({ Title = "Catching" })

PageCatch.Toggle({
    Text = "Enable Capture",
    Callback = function(v) Settings.Capture.Enabled = v end
})

PageCatch.Dropdown({
    Text = "Select Disc to Use/Buy",
    Options = {"Ace Disc", "Hyper Disc", "Advanced Disc", "Normal Disc"},
    Callback = function(v) 
        Settings.Capture.Disc = v 
        Settings.SelectedDisc = v
    end
})
PageCatch.Toggle({ Text = "Catch Gleaming", Callback = function(v) Settings.Capture.Gleam = v end })
PageCatch.Toggle({ Text = "Catch Gamma", Callback = function(v) Settings.Capture.Gamma = v end })
PageCatch.Toggle({ Text = "Catch Not Owned", Callback = function(v) Settings.Capture.NotOwned = v end })
PageCatch.Toggle({ Text = "Use Spare (Low HP)", Callback = function(v) Settings.Capture.Spare = v end })

PageCatch.Toggle({
    Text = "Auto Buy Disc (< 10)",
    Callback = function(v) 
        Settings.AutoBuyDisc = v 
        if v then task.spawn(FuncAutoBuyDisc) end
    end
})

local PageMisc = UI.New({ Title = "Misc" })
PageMisc.Toggle({ Text = "Skip Dialogue", Callback = function(v) Settings.SkipDialogue = v end })
PageMisc.Toggle({ Text = "Fast Battle", Callback = function(v) Settings.FastBattle = v end })
PageMisc.Toggle({ Text = "No Trade/Nick Requests", Callback = function(v) 
    Settings.Misc.NoNewMoves = v 
    Settings.Misc.NoSwitch = v
    Settings.Misc.NoNick = v
end})
PageMisc.Toggle({ Text = "Disable Mastery Notification", Callback = function(v) Settings.Misc.NoProgress = v end })

PageMisc.Toggle({ 
    Text = "Auto Fish", 
    Callback = function(v) 
        Settings.AutoFish = v
        if v then task.spawn(FuncAutoFish) end
    end 
})
PageMisc.Toggle({ Text = "Auto Fish (Items Only)", Callback = function(v) Settings.AutoFishOnlyItems = v end })

PageMisc.Button({
    Text = "Server Hop",
    Callback = function()
         loadstring(game:HttpGet("https://raw.githubusercontent.com/thedragonslayer2/Misc/main/Server%20Hop"))()
    end
})

PageMisc.Button({
    Text = "Auto Disc Drop (External)",
    Callback = function()
         loadstring(game:HttpGet("https://raw.githubusercontent.com/thedragonslayer2/MrJack-Game-List/main/Functions/Loomian%20Legacy%20-%20306964494/Disc%20Drop.lua"))()
    end
})

print("Axiom Hub: Loomian Legacy Full Loaded")
