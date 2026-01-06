--[[
    Axiom Hub | Loomian Legacy Script
    Refactored & Improved based on available features
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
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer

-- Variables & Game Table
local MainGame = nil
local GetGC = getgc or function() return {} end
local GetUpvalues = debug.getupvalues or getupvalues
local GetInfo = debug.getinfo or getinfo

-- Wait for Game Load (Robust)
local function FindMainGame()
    for _, v in pairs(GetGC(true)) do
        if typeof(v) == "table" and rawget(v, "DataManager") then
            return v
        end
    end
    return nil
end

local UI = Material.Load({
    Title = "Axiom Hub | Loomian Legacy",
    Style = 1,
    SizeX = 550,
    SizeY = 400,
    Theme = "Dark"
})

-- Attempt to find MainGame loop
task.spawn(function()
    local attempts = 0
    while not MainGame and attempts < 20 do
        MainGame = FindMainGame()
        if MainGame then break end
        attempts = attempts + 1
        task.wait(1)
    end

    if not MainGame then
	    -- Fallback for weak executors
	    if debug and debug.getregistry then
		    for _, v in pairs(debug.getregistry()) do
			    if typeof(v) == "table" and rawget(v, "DataManager") then
				    MainGame = v
				    break
			    end
		    end
	    end
    end

    if not MainGame then
        UI.Banner({ Text = "Error: Could not find MainGame. Script may not work." })
        warn("Axiom Hub: MainGame not found.")
        return
    end
    
    -- Notify loaded
    print("Axiom Hub: MainGame found!")
    MainLogic()
end)

-- Settings Table
getgenv().AxiomSettings = {
    AutoHeal = false,
    InfiniteRepel = false,
    SkipDialogue = false,
    FastBattle = false,
    AutoFish = false,
    AutoFishOnlyItems = false,
    WalkSpeed = 16,
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

-- Helper Functions
local function SecureCall(func, ...)
    local set_thread_context = setthreadcontext or function(_) end
    set_thread_context(2)
    return func(...)
end

local function GetCurrentBattle()
    if MainGame and MainGame.Battle then
        return MainGame.Battle.currentBattle
    end
    return nil
end

local function GetActiveLoomian()
    local battle = GetCurrentBattle()
    if battle and battle.yourSide then
        return battle.yourSide.active[1]
    end
    return nil
end

-- Main Logic Wrapper
function MainLogic()
    -- Anti AFK
    LocalPlayer.Idled:Connect(function()
        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)

    --------------------------------------------------------------------------------
    -- HOOKS
    --------------------------------------------------------------------------------
    
    -- 1. Auto Hunt Hook (onStepTaken)
    local OnStepTakenFunc = nil
    if MainGame.WalkEvents and MainGame.WalkEvents.beginLoop and GetUpvalues and GetInfo then
        for _, val in pairs(GetUpvalues(MainGame.WalkEvents.beginLoop)) do
            if typeof(val) == "function" then
                local info = GetInfo(val)
                if info and info.name == "onStepTaken" then
                    OnStepTakenFunc = val
                    break
                end
            end
        end
    end

    -- 2. Battle Hooks (Fast Battle & Misc)
    if MainGame.BattleGui then
        -- Hook Message for Skips
        local oldMessage = MainGame.BattleGui.message
        MainGame.BattleGui.message = function(self, ...)
            local args = {...}
            local msg = args[1]
            if type(msg) == "string" then
                if Settings.Misc.NoNewMoves and msg:find("reassign its moves") then return {}, true end
                if Settings.Misc.NoSwitch and msg:find("Will you switch Loomians") then return {}, true end
                if Settings.Misc.NoNick and msg:find("Give a nickname") then return {}, true end
            end
            if Settings.SkipDialogue then return {}, true end
            return oldMessage(self, ...)
        end

        -- Hook Camera for Fast Battle
        local oldSetCam = MainGame.BattleGui.setCameraIfLookingAway
        MainGame.BattleGui.setCameraIfLookingAway = function(self, battleData)
            if Settings.FastBattle and battleData then 
                battleData.fastForward = true 
            end
            local res = oldSetCam(self, battleData)
            if Settings.FastBattle and battleData then 
                battleData.fastForward = false 
            end
            return res
        end
    end

    if MainGame.RoundedFrame then
        local oldSetFill = MainGame.RoundedFrame.setFillbarRatio
        MainGame.RoundedFrame.setFillbarRatio = function(...)
            local args = {...}
            if Settings.FastBattle and GetCurrentBattle() then
                args[3] = false -- Instant fill
            end
            return oldSetFill(unpack(args))
        end
    end
    
    -- 3. NPC Chat Hook
    if MainGame.NPCChat then
        local oldSay = MainGame.NPCChat.Say
        MainGame.NPCChat.Say = function(self, ...)
            if Settings.SkipDialogue then return end
            return oldSay(self, ...)
        end
    end

    -- 4. Mastery Progress Hook
    if MainGame.Menu and MainGame.Menu.mastery then
        local oldShowProgress = MainGame.Menu.mastery.showProgressUpdate
        MainGame.Menu.mastery.showProgressUpdate = function(...)
            if Settings.Misc.NoProgress then return end
            return oldShowProgress(...)
        end
    end

    -- 5. Auto Fish Hook (FishMiniGame override)
    if MainGame.Fishing then
        MainGame.Fishing.FishMiniGame = function(...)
            if not Settings.AutoFish then 
                -- Returning nothing or false usually means minigame fails naturally
                return false
            end
            
            -- Main logic for Auto Fish
            local currentChunk = MainGame.DataManager.currentChunk
            local fishRegion = currentChunk.regionData.Fishing
            if not fishRegion then return false end
            
            local spotId = fishRegion.id or fishRegion
            
            -- Find water part
            local waterPart = nil
            if currentChunk.map then
                for _, child in pairs(currentChunk.map:GetChildren()) do
                    if child.Name == "Water" then waterPart = child break end
                end
            end

            if waterPart and Settings.AutoFish then
                 local origin = waterPart.Position + Vector3.new(0, waterPart.Size.Y/2, 0)
                 -- Cast Line
                 local res, fsh = MainGame.Network:get("PDS", "fish", origin, spotId)
                 if res then
                      -- If we got a bite
                      local bite = select(2, MainGame.Network:get("PDS", "fish", origin, spotId))
                      if bite and bite.delay then
                            -- Catch it
                            local success = MainGame.Network:get("PDS", "fshchi", bite.id)
                            if success then 
                                 if Settings.AutoFishOnlyItems then
                                      -- Reel in (items)
                                      MainGame.Network:post("PDS", "reelIn")
                                 else
                                      -- Encounter
                                      MainGame.Battle:doWildBattle(fishRegion, { dontExclaim = true, fshPct = 0.95 })
                                 end
                            end
                      end
                 end
                 return true -- Handled
            end
            return false
        end
    end

    --------------------------------------------------------------------------------
    -- LOOPS
    --------------------------------------------------------------------------------
    
    -- Auto Heal Loop
    task.spawn(function()
        while true do
            task.wait(2)
            if Settings.AutoHeal and MainGame.Menu.enabled and not GetCurrentBattle() then
                pcall(function()
                    local fullHealth = MainGame.Network:get("PDS", "areFullHealth")
                    if not fullHealth then
                         local chunk = MainGame.DataManager.currentChunk
                         -- If outdoor healers exist
                         if chunk.data.HasOutsideHealers then
                              MainGame.Network:get("heal", nil, "HealMachine1")
                         end
                    end
                end)
            end
        end
    end)

    -- Auto Hunt Loop
    task.spawn(function()
        while true do
            task.wait(0.1)
            if Settings.AutoHunt then
                if MainGame.MasterControl.WalkEnabled and MainGame.Menu.enabled and not GetCurrentBattle() then
                    if OnStepTakenFunc then
                        pcall(function() OnStepTakenFunc(true) end)
                    end
                end
            end
        end
    end)

    -- Auto Battle & Capture Loop
    task.spawn(function()
        while true do
            task.wait(0.5)
            local battle = GetCurrentBattle()
            if battle and battle.state == "input" then
                local active = GetActiveLoomian()
                local wild = battle.kind == "wild"
                local handled = false

                -- Capture Logic
                if wild and Settings.Capture.Enabled then
                     local shouldCatch = false
                     if Settings.Capture.NotOwned and not active.owned then shouldCatch = true end
                     if Settings.Capture.Gleam and (active.shiny and active.shiny >= 1) then shouldCatch = true end
                     if Settings.Capture.Gamma and (active.shiny and active.shiny == 2) then shouldCatch = true end
                     if Settings.Capture.Spare and (active.hp / active.maxhp < 0.2) then shouldCatch = true end
                     if table.find(Settings.Capture.CustomList, active.name:lower()) then shouldCatch = true end

                     if shouldCatch then
                          local bag = MainGame.Network:get("PDS", "getBagPouch", 3)
                          local discId = nil
                          for _, item in pairs(bag) do
                               if item.name == Settings.Capture.Disc then discId = item.id break end
                          end
                          
                          if discId then
                               MainGame.BattleGui:exitButtonsMain()
                               MainGame.BattleGui.inputEvent:fire("useitem " .. discId)
                               handled = true
                               task.wait(1)
                          else
                               -- Buy disc if auto buy enabled?
                               if Settings.AutoBuyDisc then
                                   -- Handled in separate loop, but we can't do anything right now
                               end
                          end
                     end
                end

                -- Fight Logic
                if not handled and Settings.AutoBattle then
                     -- Do simple fight
                     MainGame.BattleGui:mainButtonClicked(1) -- Fight
                     MainGame.BattleGui:onMoveClicked(1) -- Move 1
                end
            end
        end
    end)

    -- Auto Buy Disc Loop
    task.spawn(function()
        while true do
            task.wait(5)
            if Settings.AutoBuyDisc then
                 pcall(function()
                      local bag = MainGame.Network:get("PDS", "getBagPouch", 3)
                      local count = 0
                      local itemId = nil
                      
                      -- ID placeholders - please verify or use name scanning in Shop
                      local DiscIds = {
                           ["Normal Disc"] = 0,
                           ["Advanced Disc"] = 2, 
                           ["Hyper Disc"] = 3,
                           ["Ace Disc"] = 4
                      }
                      local idToBuy = DiscIds[Settings.SelectedDisc]
                      
                      -- Check current count
                      for _, item in pairs(bag) do
                           if item.name == Settings.SelectedDisc then count = item.count end
                      end
                      
                      if count < 10 and idToBuy then
                           -- Attempt buy 10
                           MainGame.Network:post("Shop", "buyItem", idToBuy, 10)
                      end
                 end)
            end
        end
    end)

    -- Infinite Repel Loop
    task.spawn(function()
        while true do
            task.wait(1)
            if Settings.InfiniteRepel and MainGame.Repel then
                 MainGame.Repel.steps = 100
            end
        end
    end)
    
    -- WalkSpeed Loop
    task.spawn(function()
        while true do
             task.wait()
             if Settings.WalkSpeed ~= 16 and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                  LocalPlayer.Character.Humanoid.WalkSpeed = Settings.WalkSpeed
             end
        end
    end)
end

--------------------------------------------------------------------------------
-- UI CONSTRUCTION
--------------------------------------------------------------------------------

local PageMain = UI.New({ Title = "Main" })

PageMain.Toggle({
    Text = "Auto Heal (Outdoor)",
    Callback = function(v) Settings.AutoHeal = v end,
    Enabled = Settings.AutoHeal
})

PageMain.Toggle({
    Text = "Auto Hunt (Encounter)",
    Callback = function(v) Settings.AutoHunt = v end,
    Enabled = Settings.AutoHunt
})

PageMain.Toggle({
    Text = "Auto Battle (Spam Move 1)",
    Callback = function(v) Settings.AutoBattle = v end,
    Enabled = Settings.AutoBattle
})

PageMain.Slider({
    Text = "Walk Speed",
    Min = 16,
    Max = 200,
    Def = 16,
    Callback = function(v) Settings.WalkSpeed = v end
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
    Callback = function(v) Settings.AutoBuyDisc = v end
})


local PageMisc = UI.New({ Title = "Misc" })

PageMisc.Toggle({ Text = "Infinite Repel", Callback = function(v) Settings.InfiniteRepel = v end })
PageMisc.Toggle({ Text = "Fast Battle", Callback = function(v) Settings.FastBattle = v end })
PageMisc.Toggle({ Text = "Skip Dialogue", Callback = function(v) Settings.SkipDialogue = v end })
PageMisc.Toggle({ Text = "No Trade/Battle/Nick Request", Callback = function(v) 
    Settings.Misc.NoNewMoves = v 
    Settings.Misc.NoSwitch = v
    Settings.Misc.NoNick = v
end })
PageMisc.Toggle({ Text = "Disable Mastery Notification", Callback = function(v) Settings.Misc.NoProgress = v end })

PageMisc.Toggle({
    Text = "Auto Fish (Replaces MiniGame)",
    Callback = function(v) Settings.AutoFish = v end
})
PageMisc.Toggle({
    Text = "Auto Fish (Items Only)",
    Callback = function(v) Settings.AutoFishOnlyItems = v end
})

-- External Scripts
PageMisc.Button({
    Text = "External: Auto Disc Drop",
    Callback = function()
         loadstring(game:HttpGet("https://raw.githubusercontent.com/thedragonslayer2/MrJack-Game-List/main/Functions/Loomian%20Legacy%20-%20306964494/Disc%20Drop.lua"))()
    end
})

PageMisc.Button({
    Text = "Server Hop",
    Callback = function()
         loadstring(game:HttpGet("https://raw.githubusercontent.com/thedragonslayer2/Misc/main/Server%20Hop"))()
    end
})

print("Axiom Hub: Script Initialized")
