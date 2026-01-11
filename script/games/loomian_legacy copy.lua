-- Helper Functions
local client = game:GetService("Players").LocalPlayer

function LooP(func, delay)
    task.spawn(function()
        while task.wait(delay or 0) do
            local success, err = pcall(func)
            if not success then
                warn("LooP Error:", err)
            end
        end
    end)
end

function ForLooP(tbl, func)
    for i, v in pairs(tbl) do
        func(i, v)
    end
end

function GetSavedSettings(path, userId)
    return {}
end

function IrisNotificationMrJack(type, title, message, duration)
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = title,
        Text = message,
        Duration = duration or 5
    })
end

local IrisNotificationUserMrJack = {
    ClearAllNotifications = function()
    end
}

local Material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()

if not Material then
    warn("❌ Material UI Load Failed!")
    return
end

if not (getgc or debug.getregistry) then
    return warn("❌ Executor not Supported! Missing getgc/debug.getregistry")
end

local userSettings = {}
local clientState = nil
local switchingInProgress = nil
local battleGuiOpen = nil
local healingInProgress = nil
local travelLocations = {}
local autoBuyModules = {}
local autoEncounterEnabled = nil
local discDropEnabled = nil
local hasMetaHook = false
if hasMetaHook then
    hasMetaHook = CreateHookMetaMethod:Index() or CreateHookMetaMethod.Indexes
end
local advancedExploitAvailable = false

pcall(function()
    userSettings = GetSavedSettings("MrJack Settings/" .. GAME_NAME .. ".json", tostring(client.UserId))
end)

local function locateClientState()
    pcall(function()
        ForLooP(getgc(true), function(_, candidate)
            if typeof(candidate) == "table" and rawget(candidate, "Utilities") and
                not (clientState and clientState.Battle) then
                clientState = candidate
            end
        end)
    end)
    if not clientState then
        pcall(function()
            ForLooP(debug.getregistry(), function(_, registryValue)
                if typeof(registryValue) == "function" and not (clientState and clientState.Battle) then
                    pcall(function()
                        local iterator = next
                        local upvalueTable, upvalueKey = getupvalues(registryValue)
                        while true do
                            local upvalue
                            upvalueKey, upvalue = iterator(upvalueTable, upvalueKey)
                            if upvalueKey == nil then
                                break
                            end
                            if typeof(upvalue) == "table" and not (clientState and clientState.Battle) then
                                pcall(function()
                                    if upvalue.Utilities then
                                        clientState = upvalue
                                    end
                                end)
                            end
                        end
                    end)
                end
            end)
        end)
    end
end

pcall(function()
    while not clientState do
        locateClientState()
        if clientState then
            break
        end
        task.wait(0.5)
    end
end)

-- Attendre que clientState soit prêt
if not clientState then
    warn("❌ clientState failed to load!")
    return
end

warn("✅ clientState loaded successfully!")
wait(0.5)

local function getCurrentBattle()
    return clientState.Battle.currentBattle
end

local function getActiveMonster()
    return getCurrentBattle().yourSide.active[1]
end

local function isHealedOrAllowed()
    local canAct
    if userSettings["Auto Heal"] then
        if healingInProgress then
            canAct = false
        else
            canAct = clientState.Network:get("PDS", "areFullHealth")
        end
    else
        canAct = true
    end
    return canAct
end

local function getShinyStatus()
    local activeMonster = getActiveMonster()
    local shinyFlag
    if activeMonster.shiny == clientState.Constants.CORRUPT_GLEAM_NUM then
        shinyFlag = false
    else
        shinyFlag = activeMonster.shiny
    end
    return shinyFlag
end

local function isTargetListedLoomian()
    return table.find(userSettings["Auto Hunt"].Loomians, tostring(getActiveMonster().name):lower())
end

local function shouldCatchCurrentEncounter()
    local battle = getCurrentBattle()
    local autoHuntSettings = userSettings["Auto Hunt"]
    if battle and battle.kind == "wild" and not getActiveMonster().corrupt then
        local shinyState = getShinyStatus()
        return shinyState == 1 and autoHuntSettings.Gleam or shinyState == 2 and autoHuntSettings.Gamma or
                   (not getActiveMonster().owned and autoHuntSettings.NotOwned or isTargetListedLoomian())
    end
end

local function chooseMove(moveIndex)
    local battleGui = clientState.BattleGui
    if getCurrentBattle().state == "input" and not switchingInProgress then
        if not battleGui.onMoveClicked then
            battleGui:mainButtonClicked(1)
        end
        local moveDetails = battleGui.moves[moveIndex]
        if moveDetails.energy and
            (battleGui.activeMonster.energy < moveDetails.energy and not battleGui.activeMonster.bypassEnergy) then
            battleGui.fightSelectionGroup:LoseFocus()
            battleGui.inputEvent:fire("rest 0")
            battleGui:exitButtonsMoveChosen()
        elseif not moveDetails.disabled then
            battleGui:onMoveClicked(moveIndex)
        end
    end
end

local function forceBattleEnd()
    local activeBattle = getCurrentBattle()
    if activeBattle and activeBattle.CanRun ~= false and battleGuiOpen then
        clientState.BattleGui.IdleCameraController:quit(activeBattle)
        activeBattle.ended = true
        activeBattle.BattleEnded:Fire()
    end
end

local originalSetupScene = setthreadcontext
if originalSetupScene then
    originalSetupScene = clientState.Battle.setupScene
end

local setThreadContextSafely = setthreadcontext or function(_)
end

if originalSetupScene then
    function clientState.Battle.setupScene(...)
        setThreadContextSafely(2)
        return originalSetupScene(...)
    end
    local originalLoadModule = clientState.DataManager.loadModule
    function clientState.DataManager.loadModule(...)
        setThreadContextSafely(2)
        return originalLoadModule(...)
    end
    local originalLoadChunk = clientState.DataManager.loadChunk
    function clientState.DataManager.loadChunk(...)
        setThreadContextSafely(2)
        return originalLoadChunk(...)
    end
end

LooP(function()
    if not clientState or not clientState.Menu or not clientState.Network then
        return
    end
    local listIterator = next
    local moduleIndex = autoBuyModules
    local moduleKey = nil
    while true do
        local module
        moduleKey, module = listIterator(moduleIndex, moduleKey)
        if moduleKey == nil then
            break
        end
        local shopItems
        if clientState.Menu.shop.shopId then
            shopItems = false
        else
            shopItems = clientState.Network:get("PDS", "getShop", module.ShopId)
        end
        if not shopItems then
            return
        end
        local itemIterator = next
        local itemKey = nil
        while true do
            local item
            itemKey, item = itemIterator(shopItems, itemKey)
            if itemKey == nil then
                break
            end
            module.Func(item)
        end
        if module.CanAutoBuy() then
            for _ = 1, 10 do
                local enabledIterator = next
                local enabledList = module.Enabled
                local enabledKey = nil
                while true do
                    local enabledId
                    enabledKey, enabledId = enabledIterator(enabledList, enabledKey)
                    if enabledKey == nil then
                        break
                    end
                    clientState.Network:get("PDS", "buyItem", enabledKey, 1)
                end
            end
        end
    end
end)

LooP(function()
    if not clientState or not client or not client.PlayerGui then
        return
    end
    if getCurrentBattle() and client.PlayerGui.MainGui:FindFirstChild("BattleGui", true) then
        task.wait(3)
        battleGuiOpen = true
        repeat
            wait()
        until not getCurrentBattle()
    else
        battleGuiOpen = false
    end
end)

local originalShowProgressUpdate = clientState.Menu.mastery.showProgressUpdate
function clientState.Menu.mastery.showProgressUpdate(...)
    if not userSettings.MiscSettings.NoProgress then
        return originalShowProgressUpdate(...)
    end
end

local badgeIterator = next
local badgeLookup = clientState.Assets.badgeId
local badgeKey = nil
while true do
    local badgeName, badgeValue = badgeIterator(badgeLookup, badgeKey)
    if badgeName == nil then
        break
    end
    badgeKey = badgeName
    if typeof(badgeValue) == "number" and badgeName:sub(1, 5) == "Medal" and badgeName:sub(7, 7) == "" and badgeValue ~=
        0 then
        task.spawn(function()
            while task.wait() do
                local theatreModule = clientState.DataManager:getModule("BattleTheatre" .. badgeName:sub(6, 6))
                if theatreModule then
                    function theatreModule.EnablePuzzleControls()
                        return true
                    end
                    function theatreModule.enablePuzzleControls()
                        return true
                    end
                end
            end
        end)
    end
end

task.spawn(function()
    local miningModule = nil
    while task.wait() and not miningModule do
        miningModule = clientState.DataManager:getModule("Mining")
    end
    function miningModule.DecrementBattery()
    end
    function miningModule.SetBattery()
    end
    local miningModel = Instance.new("Model", workspace)
    Instance.new("Highlight", miningModel)
    while task.wait() do
        local pointIterator = next
        local miningPoints = miningModule.MinePoints
        local miningKey = nil
        while true do
            local miningPoint
            miningKey, miningPoint = pointIterator(miningPoints, miningKey)
            if miningKey == nil then
                break
            end
            if task.wait() and miningPoint.Part and
                not (miningPoint.Part:GetAttribute("OnlyOnce") or miningPoint.Part:SetAttribute("OnlyOnce", true)) then
                miningPoint.Part.Parent = miningModel
            end
        end
    end
end)

function clientState.Menu.options.resetLastUnstuckTick()
end

LooP(function()
    if not clientState or not clientState.MasterControl then
        return
    end
    if clientState.MasterControl.WalkEnabled and not getCurrentBattle() then
        workspace.Camera.FieldOfView = 70
    end
end)

local originalSwitchMonster = clientState.BattleGui.switchMonster
function clientState.BattleGui.switchMonster(...)
    setThreadContextSafely(2)
    local forceSwitch = ({...})[3] == false
    if forceSwitch then
        switchingInProgress = true
    end
    local results = {originalSwitchMonster(...)}
    if forceSwitch then
        switchingInProgress = nil
    end
    return unpack(results)
end

local travelIterator = next
local travelInfoTable, travelKey = clientState.Menu.map.getAvailableTravelLocationInfo()
while true do
    local travelInfo
    travelKey, travelInfo = travelIterator(travelInfoTable, travelKey)
    if travelKey == nil then
        break
    end
    table.insert(travelLocations, travelInfo.name)
end

local originalDoTrainerBattle = clientState.Battle.doTrainerBattle
function clientState.Battle.doTrainerBattle(...)
    while not isHealedOrAllowed() do
        task.wait()
    end
    setThreadContextSafely(2)
    return originalDoTrainerBattle(...)
end

getgenv().AxiomHubUiConstante = Material.Load({
    Title = "Axiom Hub | Loomian Legacy",
    Style = 1,
    SizeX = 550,
    SizeY = 400,
    Theme = "Dark"
})

local mainPage = getgenv().AxiomHubUiConstante.New({
    Title = "Main"
})

mainPage.Toggle({
    Text = "Auto Heal [Outdoor Only]",
    Enabled = userSettings["Auto Heal"],
    Callback = function(enabled)
        userSettings["Auto Heal"] = enabled
    end
})

LooP(function()
    xpcall(function()
        if not clientState or not clientState.DataManager or not clientState.MasterControl then
            return
        end
        local currentChunk = clientState.DataManager.currentChunk
        if userSettings["Auto Heal"] and clientState.MasterControl.WalkEnabled and clientState.Menu.enabled and
            not currentChunk.indoors and not getCurrentBattle() and
            not clientState.ObjectiveManager.disabledBy.LoomianCare and
            not clientState.Network:get("PDS", "areFullHealth") then
            if currentChunk.data.HasOutsideHealers then
                clientState.Network:get("heal", nil, "HealMachine1")
            else
                local returnChunkId = currentChunk.regionData and currentChunk.regionData.BlackOutTo or
                                          currentChunk.data.blackOutTo
                local currentChunkId = currentChunk.id
                local currentCFrame = client.character.PrimaryPart.CFrame
                if returnChunkId then
                    local masterControl = clientState.MasterControl
                    healingInProgress = true
                    masterControl.WalkEnabled = false
                    clientState.Menu:disable()
                    clientState.Menu:fastClose(3)
                    clientState.Utilities.FadeOut(1)
                    task.spawn(function()
                        clientState.NPCChat:Say("[ma][MrJack]Auto healing...")
                    end)
                    clientState.Utilities.TeleportToSpawnBox()
                    currentChunk:unbindIndoorCam()
                    currentChunk:destroy()
                    setThreadContextSafely(2)
                    currentChunk = clientState.DataManager:loadChunk(returnChunkId)
                end
                local healthCenter = currentChunk:getRoom("HealthCenter", currentChunk:getDoor("HealthCenter"), 1)
                local network = clientState.Network
                local healer = network:get("getHealer", task.wait() and "HealthCenter" or nil)
                if healer then
                    clientState.Network:get("heal", "HealthCenter", healer)
                end
                healthCenter:Destroy()
                if returnChunkId then
                    currentChunk:destroy()
                    clientState.DataManager:loadChunk(currentChunkId)
                    clientState.Utilities.Teleport(currentCFrame)
                    clientState.Menu:enable()
                    clientState.NPCChat:manualAdvance()
                    clientState.Utilities.FadeIn(1)
                    local masterControlBack = clientState.MasterControl
                    healingInProgress = nil
                    masterControlBack.WalkEnabled = true
                end
            end
        end
    end, function(...)
        warn("Main | Auto Heal -", ...)
    end)
end, 0.1)

mainPage.Toggle({
    Text = "Active Repellent",
    Enabled = userSettings["Infinite Repel"],
    Callback = function(enabled)
        userSettings["Infinite Repel"] = enabled
    end
})

LooP(function()
    if not clientState or not clientState.Repel then
        return
    end
    if clientState.Repel.steps < 10 or not userSettings["Infinite Repel"] or autoEncounterEnabled then
        clientState.Repel.steps = not autoEncounterEnabled and (userSettings["Infinite Repel"] and 100) or 0
    end
end)

if advancedExploitAvailable then
    local defeatedTrainerCache = {}
    mainPage.Toggle({
        Text = "Ignore NPC Battle",
        Enabled = userSettings["Ignore NPC Battle"],
        Callback = function(enabled)
            userSettings["Ignore NPC Battle"] = enabled
        end
    })
    local originalGetBit = clientState.BitBuffer.GetBit
    function clientState.BitBuffer.GetBit(...)
        local args = {...}
        if not (table.find(defeatedTrainerCache, clientState.DataManager.currentChunk.map) or
            table.clear(defeatedTrainerCache)) then
            table.insert(defeatedTrainerCache, clientState.DataManager.currentChunk.map)
        end
        if args[1] == clientState.PlayerData.defeatedTrainers and args[2] then
            if userSettings["Ignore NPC Battle"] and table.find(defeatedTrainerCache, args[2]) then
                return true
            end
            if not table.find(defeatedTrainerCache, args[2]) then
                table.insert(defeatedTrainerCache, args[2])
            end
        end
        setThreadContextSafely(2)
        return originalGetBit(...)
    end
end

if getthreadcontext then
    getthreadcontext()
end

mainPage.Toggle({
    Text = "Skip Dialogue",
    Enabled = userSettings["Skip Dialogue"],
    Callback = function(enabled)
        userSettings["Skip Dialogue"] = enabled
    end
})

local function filterDialogue(_, ...)
    local dialogueArgs = {...}
    local filteredDialogue = {}
    local shouldShow = nil
    if typeof(dialogueArgs[2]) == "string" then
        if dialogueArgs[2]:sub(1, 8) == "[NoSkip]" then
            return {dialogueArgs[1], dialogueArgs[2]:sub(9)}, true
        end
        if dialogueArgs[2]:sub(1, 5):lower() == "[y/n]" then
            if userSettings.MiscSettings.NoSwitch and dialogueArgs[2]:find("Will you switch Loomians") then
                dialogueArgs[2] = "Auto Deny Swicth Question Enabled!"
            elseif userSettings.MiscSettings.NoNick and dialogueArgs[2]:find("Give a nickname to the") then
                dialogueArgs[2] = "Auto Deny Nickname Enabled!"
            elseif userSettings.MiscSettings.NoNewMoves then
                if dialogueArgs[2]:find("reassign its moves") then
                    dialogueArgs[2] = "Auto Deny Reassign Move Enabled!"
                elseif dialogueArgs[2]:find(" to give up on learning ") then
                    return "Y/N", true
                end
            end
        end
    end
    if userSettings["Skip Dialogue"] then
        local iterator = next
        local key = nil
        while true do
            local value
            key, value = iterator(dialogueArgs, key)
            if key == nil then
                break
            end
            if typeof(value) ~= "string" then
                filteredDialogue[#filteredDialogue + 1] = value
            else
                local dialogText
                if value:sub(1, 5):lower() ~= "[y/n]" then
                    if value:sub(1, 9):lower() ~= "[gamepad]" then
                        dialogText = value
                    else
                        dialogText = value:sub(10)
                    end
                else
                    filteredDialogue[#filteredDialogue + 1] = value
                    dialogText = value:sub(6)
                    shouldShow = true
                end
                if dialogText:sub(1, 4):lower() == "[ma]" or dialogText:sub(1, 5) == "[pma]" then
                    filteredDialogue[#filteredDialogue + 1] = value
                    shouldShow = true
                end
            end
        end
    else
        filteredDialogue = dialogueArgs
        shouldShow = true
    end
    return filteredDialogue, shouldShow
end

local function overrideDialogue(targetTable, methodName)
    local originalMethod = targetTable[methodName]
    targetTable[methodName] = function(...)
        local newDialogue, shouldReturn = filterDialogue(methodName, ...)
        if newDialogue == "Y/N" then
            return shouldReturn
        end
        if shouldReturn then
            setThreadContextSafely(2)
            local _ = unpack
        end
    end
end

overrideDialogue(clientState.BattleGui, "message")
overrideDialogue(clientState.NPCChat, "Say")
overrideDialogue(clientState.NPCChat, "say")

mainPage.Toggle({
    Text = "Fast Battle",
    Enabled = userSettings["Fast Battle"],
    Callback = function(enabled)
        userSettings["Fast Battle"] = enabled
    end
})

local speedPatchIterator = next
local speedPatchTargets = {
    [clientState.BattleClientSprite] = {
        animFaint = 1,
        animSummon = 1,
        animUnsummon = 1,
        monsterIn = 1,
        monsterOut = 1,
        animEmulate = 1,
        animScapegoat = 1,
        animScapegoatFade = 1,
        animRecolor = 1
    },
    [clientState.BattleClientSide] = {
        switchOut = 1,
        faint = 1,
        swapTo = 1,
        dragIn = 1
    }
}
local speedPatchKey = nil
local function wrapBattleAnimation(methodName, targetTable, targetIndex)
    local originalMethod = targetTable[methodName]
    if originalMethod then
        targetTable[methodName] = function(...)
            setThreadContextSafely(2)
            local callArgs = {...}
            callArgs[targetIndex].battle.fastForward = userSettings["Fast Battle"]
            local results = {originalMethod(unpack(callArgs))}
            callArgs[targetIndex].battle.fastForward = false
            return unpack(results)
        end
    end
end

while true do
    local targetTable
    speedPatchKey, targetTable = speedPatchIterator(speedPatchTargets, speedPatchKey)
    if speedPatchKey == nil then
        break
    end
    local methodIterator = next
    local targetIndex = speedPatchKey
    local methodKey = nil
    while true do
        local methodName
        methodKey, methodName = methodIterator(targetTable, methodKey)
        if methodKey == nil then
            break
        end
        wrapBattleAnimation(methodName, targetIndex, methodName)
    end
end

local animPatchIterator = next
local animPatchTargets = {
    [clientState.BattleGui] = {"animWeather", "animStatus", "animAbility", "animBoost", "animHit", "animMove"}
}
local animPatchKey = nil
local function disableAnimations(methodName, targetTable)
    local originalMethod = targetTable[methodName]
    if originalMethod then
        targetTable[methodName] = function(...)
            setThreadContextSafely(2)
            local _ = userSettings["Fast Battle"]
        end
    end
end

while true do
    local targetTable
    animPatchKey, targetTable = animPatchIterator(animPatchTargets, animPatchKey)
    if animPatchKey == nil then
        break
    end
    local methodIterator = next
    local targetIndex = animPatchKey
    local methodKey = nil
    while true do
        local methodName
        methodKey, methodName = methodIterator(targetTable, methodKey)
        if methodKey == nil then
            break
        end
        disableAnimations(methodName, targetIndex)
    end
end

local originalSetCamera = clientState.BattleGui.setCameraIfLookingAway
function clientState.BattleGui.setCameraIfLookingAway(self, cameraData)
    cameraData.fastForward = userSettings["Fast Battle"]
    local results = {originalSetCamera(self, cameraData)}
    cameraData.fastForward = false
    return unpack(results)
end

local originalFillbarRatio = clientState.RoundedFrame.setFillbarRatio
function clientState.RoundedFrame.setFillbarRatio(...)
    local args = {...}
    if userSettings["Fast Battle"] and getCurrentBattle() then
        args[3] = false
    end
    return originalFillbarRatio(unpack(args))
end

if advancedExploitAvailable then
    mainPage.Button({
        Text = "End Battle",
        Callback = forceBattleEnd
    })
end

if hasMetaHook then
    hasMetaHook.WalkSpeed = hasMetaHook.WalkSpeed or {}
    table.insert(hasMetaHook.WalkSpeed, function(_, humanoidArgs)
        local targetHumanoid = humanoidArgs[1]
        local playerCharacter = client.Character
        if playerCharacter then
            playerCharacter = client.Character:FindFirstChild("Humanoid")
        end
        if targetHumanoid == playerCharacter then
            return true, 16
        end
    end)
    mainPage.Slider({
        Text = "WalkSpeed",
        Min = 0,
        Max = 250,
        Def = userSettings.WalkSpeed or 16,
        Callback = function(value)
            userSettings.WalkSpeed = value
        end
    })
    LooP(function()
        if not client or not client.Character or not client.Character:FindFirstChild("Humanoid") then
            return
        end
        if userSettings.WalkSpeed and userSettings.WalkSpeed ~= 0 then
            client.Character.Humanoid.WalkSpeed = userSettings.WalkSpeed or 16
        elseif userSettings.WalkSpeed == 0 then
            local humanoid = client.Character.Humanoid
            userSettings.WalkSpeed = nil
            humanoid.WalkSpeed = 16
        end
    end)
end

mainPage.Button({
    Text = "Open Rally Team",
    Callback = function()
        clientState.Menu:disable()
        clientState.Menu.rally:openRallyTeamMenu()
        clientState.Menu:enable()
    end
})

mainPage.Button({
    Text = "Open Rallied",
    Callback = function()
        pcall(function()
            if clientState.Network:get("PDS", "ranchStatus").rallied > 0 then
                clientState.Menu:disable()
                clientState.Menu.rally:openRalliedMonstersMenu()
                clientState.Menu:enable()
            end
        end)
    end
})

mainPage.Button({
    Text = "Open PC",
    Callback = function()
        clientState.Menu.pc:bootUp()
    end
})

mainPage.Button({
    Text = "Open Shop",
    Callback = function()
        clientState.Menu:disable()
        clientState.Menu.shop:open()
        clientState.Menu:enable()
    end
})

mainPage.Button({
    Text = "Junk 4 Junk",
    Callback = function()
        clientState.Menu:disable()
        clientState.Menu.shop:open("fishtrash")
        clientState.Menu:enable()
    end
})

--[[
local miscPage = getgenv().AxiomHubUiConstante.New({
    Title = "Misc"
})

if not userSettings.MiscSettings then
    userSettings.MiscSettings = {}
end

miscPage.Toggle({
    Text = "Deny Reassign Move",
    Enabled = userSettings.MiscSettings.NoNewMoves,
    Callback = function(enabled)
        userSettings.MiscSettings.NoNewMoves = enabled
    end
})

miscPage.Toggle({
    Text = "Deny Switch Request",
    Enabled = userSettings.MiscSettings.NoSwitch,
    Callback = function(enabled)
        userSettings.MiscSettings.NoSwitch = enabled
    end
})

miscPage.Toggle({
    Text = "Deny Nickname Request",
    Enabled = userSettings.MiscSettings.NoNick,
    Callback = function(enabled)
        userSettings.MiscSettings.NoNick = enabled
    end
})

miscPage.Toggle({
    Text = "Disable Show Progress",
    Enabled = userSettings.MiscSettings.NoProgress,
    Callback = function(enabled)
        userSettings.MiscSettings.NoProgress = enabled
    end
})

miscPage.Toggle({
    Text = originalSetupScene and "Auto Fish" or "Auto Fish (Items Only)",
    Enabled = userSettings.AutoFish,
    Callback = function(enabled)
        userSettings.AutoFish = enabled
    end
})

if originalSetupScene then
    miscPage.Toggle({
        Text = "Items Only",
        Enabled = userSettings.AutoFishOnlyItems,
        Callback = function(enabled)
            userSettings.AutoFishOnlyItems = enabled
        end
    })
end

local originalOnWaterClicked = clientState.Fishing.OnWaterClicked
local currentWaterPart = nil

LooP(function()
    pcall(function()
        if not clientState or not clientState.DataManager or not clientState.DataManager.currentChunk then
            return
        end
        if currentWaterPart and not currentWaterPart:IsDescendantOf(workspace) then
            currentWaterPart = nil
        end
        ForLooP(clientState.DataManager.currentChunk.map:GetChildren(), function(_, child)
            if child.Name ~= "Water" or not child then
                child = child:FindFirstChild("Water")
            end
            if task.wait() and child and child:FindFirstChild("Mesh") then
                currentWaterPart = child
            end
        end)
    end)
end)

function clientState.Fishing.FishMiniGame(mode, _, _, rodId, itemId)
    local regionFishing = clientState.DataManager.currentChunk.regionData.Fishing
    local regionIterator = next
    local regionData = clientState.DataManager.currentChunk.regionData
    local regionKey = nil
    while true do
        local regionValue
        regionKey, regionValue = regionIterator(regionData, regionKey)
        if regionKey == nil then
            break
        end
        if not regionFishing and typeof(regionValue) == "table" and regionKey == "Fishing" then
            if regionValue.id then
                regionFishing = regionValue
            end
        end
    end
    local chunkIterator = next
    local chunkRegions = clientState.DataManager.currentChunk.data.regions
    local chunkKey = nil
    while true do
        local chunkValue
        chunkKey, chunkValue = chunkIterator(chunkRegions, chunkKey)
        if chunkKey == nil then
            break
        end
        local chunkRegionIterator = next
        local chunkRegionKey = nil
        while true do
            local chunkRegionValue
            chunkRegionKey, chunkRegionValue = chunkRegionIterator(chunkValue, chunkRegionKey)
            if chunkRegionKey == nil then
                break
            end
            if not regionFishing and typeof(chunkRegionValue) == "table" and chunkRegionKey == "Fishing" then
                if chunkRegionValue.id then
                    regionFishing = chunkRegionValue
                end
            end
        end
    end
    local fishingId
    if regionFishing then
        fishingId = regionFishing.id
    else
        fishingId = regionFishing
    end
    if currentWaterPart and fishingId then
        local fishingRod = clientState.Fishing.rod
        local fishingResult
        if mode == "MrJack" then
            local castPosition = currentWaterPart.Position + Vector3.new(0, currentWaterPart.Size.Y - 5, 0)
            local reelId = nil
            local raycastParams = RaycastParams.new()
            raycastParams.FilterDescendantsInstances = {workspace.Terrain}
            raycastParams.IgnoreWater = false
            raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
            local rayResult = workspace:Raycast(castPosition + Vector3.new(0, 3, 0), Vector3.new(0.001, -10, 0.001),
                raycastParams)
            if rayResult and rayResult.Material == Enum.Material.Water then
                castPosition = rayResult.Position
            end
            if fishingRod then
                fishingRod.postPoseUpdates = true
            else
                local rodModel
                rodModel, reelId = clientState.Network:get("PDS", "fish", castPosition, fishingId)
                fishingRod = rodModel and {
                    model = rodModel,
                    bobberMain = rodModel.Bobber.Main,
                    string = rodModel.Bobber.Main.String
                } or fishingRod
                clientState.Fishing.rod = fishingRod
            end
            fishingResult = not reelId and select(2, clientState.Network:get("PDS", "fish", castPosition, fishingId))
            if fishingResult then
                clientState.Fishing.rod.postPoseUpdates = fishingResult.rep
            end
            if fishingRod and fishingRod.model then
                fishingRod.model.Parent = nil
            end
        else
            fishingResult = {
                id = itemId,
                delay = true
            }
        end
        if fishingResult and fishingResult.delay then
            return 0.9, clientState.Network:get("PDS", "fshchi", rodId or fishingResult.id), regionFishing
        else
            return false
        end
    else
        return false
    end
end

function clientState.Fishing.OnWaterClicked(...)
    if clientState.MasterControl.WalkEnabled then
        if userSettings.AutoFish then
            return IrisNotificationMrJack(1, "Notification", "Please Turn Off Auto Fish.", 2)
        end
        setThreadContextSafely(2)
        return originalOnWaterClicked(...)
    end
end

LooP(function()
    pcall(function()
        if not clientState or not clientState.PlayerData or not clientState.Fishing then
            return
        end
        if userSettings.AutoFish and clientState.PlayerData.completedEvents.mabelRt8 then
            local delayValue, shouldBattle, regionFishing = clientState.Fishing.FishMiniGame("MrJack")
            if delayValue and userSettings.AutoFish then
                if shouldBattle == true and originalSetupScene and not userSettings.AutoFishOnlyItems then
                    clientState.Battle:doWildBattle(regionFishing, {
                        dontExclaim = true,
                        fshPct = delayValue
                    })
                else
                    clientState.Network:post("PDS", "reelIn")
                end
                task.wait(0.5)
            end
            clientState.Fishing:DisableRodModel(shouldBattle ~= true and true or nil)
        end
    end)
end)

miscPage.Toggle({
    Text = "Disc Drop - Enabled",
    Enabled = nil,
    Callback = function(enabled)
        discDropEnabled = enabled
    end
})

miscPage.Toggle({
    Text = "Disc Drop - Fast Mode",
    Enabled = userSettings.FastDiscDrop,
    Callback = function(enabled)
        userSettings.FastDiscDrop = enabled
    end
})
]]

task.spawn(function()
    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/thedragonslayer2/MrJack-Game-List/main/Functions/Loomian%20Legacy%20-%20306964494/Disc%20Drop.lua"))()
    local runDiscDrop, getDiscDropState = getgenv().LoomianLegacyAutoDisDrop(userSettings, clientState)
    LooP(function()
        pcall(function()
            if discDropEnabled and clientState.ArcadeController.playing and getDiscDropState() and
                getDiscDropState().gui.GridFrame:IsDescendantOf(client.PlayerGui) then
                if getDiscDropState().gameEnded then
                    getDiscDropState():CleanUp()
                    getDiscDropState():new()
                else
                    runDiscDrop()
                end
            end
        end)
    end)
end)

if not userSettings["Auto Hunt"] then
    userSettings["Auto Hunt"] = {}
end

local autoHuntPage = getgenv().AxiomHubUiConstante.New({
    Title = "Auto Hunt"
})
local autoHuntSettings = userSettings["Auto Hunt"]
local debugInfo = debug.getinfo or getgenv().getinfo
local walkEventIterator, walkEventTable, walkEventKey = pairs(getupvalues(clientState.WalkEvents.beginLoop))
local onStepTaken = nil
local availableDiscs = {}
local discButtons = {}
local runModeSelection = nil
local discIdLookup = {}
local discCounterSection = nil
while true do
    local walkEvent
    walkEventKey, walkEvent = walkEventIterator(walkEventTable, walkEventKey)
    if walkEventKey == nil then
        break
    end
    if typeof(walkEvent) == "function" and debugInfo and debugInfo(walkEvent).name == "onStepTaken" then
        onStepTaken = walkEvent
    end
end

autoHuntPage.Toggle({
    Text = "Auto Encounter",
    Enabled = nil,
    Callback = function(enabled)
        autoEncounterEnabled = enabled
    end
})

LooP(function()
    pcall(function()
        if not clientState or not clientState.MasterControl or not clientState.Menu or not clientState.PlayerData then
            return
        end
        if clientState.MasterControl.WalkEnabled and autoEncounterEnabled and clientState.Menu.enabled and
            not getCurrentBattle() and clientState.PlayerData.completedEvents.ChooseBeginner and isHealedOrAllowed() then
            onStepTaken(true)
        end
    end)
end)

local selectedDisc
if advancedExploitAvailable then
    selectedDisc = nil
else
    selectedDisc = autoHuntSettings.Disc or nil
end
autoHuntSettings.Disc = selectedDisc

local discDropdown
if advancedExploitAvailable then
    discDropdown = autoHuntPage.Dropdown({
        Text = autoHuntSettings.Disc or "Select Disc",
        Options = availableDiscs,
        Callback = function(choice)
            autoHuntSettings.Disc = choice
        end
    })
else
    discDropdown = advancedExploitAvailable
end

LooP(function()
    pcall(function()
        if not clientState or not clientState.Network then
            return
        end
        local pouchItems = clientState.Network:get("PDS", "getBagPouch", 3)
        local pouchIterator = next
        local pouchKey = nil
        local bagNames = {}
        local updateDropdown = nil
        local selectedFound = nil
        while true do
            local item
            pouchKey, item = pouchIterator(pouchItems, pouchKey)
            if pouchKey == nil then
                break
            end
            if not table.find(availableDiscs, item.name) then
                table.insert(availableDiscs, item.name)
                discIdLookup[item.name] = item.id
                updateDropdown = true
            end
            selectedFound = autoHuntSettings.Disc and item.name == autoHuntSettings.Disc or selectedFound
            if not discButtons[item.name] then
                discButtons[item.name] = true
            end
            table.insert(bagNames, item.name)
        end
        local availableIterator = next
        local availableKey = nil
        while true do
            local discName
            availableKey, discName = availableIterator(availableDiscs, availableKey)
            if availableKey == nil then
                break
            end
            if not table.find(bagNames, discName) then
                return table.remove(availableDiscs, availableKey)
            end
        end
        if updateDropdown or not selectedFound then
            if not selectedFound then
                autoHuntSettings.Disc = nil
            end
        end
    end)
end)

if advancedExploitAvailable then
    task.wait(0.1)

    autoHuntPage.Toggle({
        Text = "Use Spare",
        Enabled = autoHuntSettings.Spare,
        Callback = function(enabled)
            autoHuntSettings.Spare = enabled
        end
    })

    autoHuntPage.Toggle({
        Text = "Catch Not Owned",
        Enabled = autoHuntSettings.NotOwned,
        Callback = function(enabled)
            autoHuntSettings.NotOwned = enabled
        end
    })

    autoHuntPage.Toggle({
        Text = "Catch Normal Gleam",
        Enabled = autoHuntSettings.Gleam,
        Callback = function(enabled)
            autoHuntSettings.Gleam = enabled
        end
    })

    autoHuntPage.Toggle({
        Text = "Catch Gamma Gleam",
        Enabled = autoHuntSettings.Gamma,
        Callback = function(enabled)
            autoHuntSettings.Gamma = enabled
        end
    })

    if not autoHuntSettings.Loomians then
        autoHuntSettings.Loomians = {}
    end

    local catchList = autoHuntSettings.Loomians
    local catchDropdown = nil
    local function removeLoomian(name)
        table.remove(catchList, table.find(catchList, name))
        task.delay(0.25, function()
        end)
    end

    catchDropdown = autoHuntPage.Dropdown({
        Text = "Remove Loomian",
        Options = catchList,
        Callback = removeLoomian
    })

    autoHuntPage.Textbox({
        Text = "Add Loomian",
        Placeholder = "Name",
        Callback = function(text, enterPressed)
            if enterPressed then
                if not table.find(catchList, text:lower()) then
                    table.insert(catchList, text:lower())
                end
            end
        end
    })

    task.wait(0.1)

    local corruptMoves = {"Disabled"}
    for moveIndex = 1, 4 do
        table.insert(corruptMoves, "Move " .. moveIndex)
    end

    if not autoHuntSettings.CorruptMove then
        autoHuntSettings.CorruptMove = "Disabled"
    end

    autoHuntPage.Dropdown({
        Text = autoHuntSettings.CorruptMove,
        Options = corruptMoves,
        Callback = function(choice)
            autoHuntSettings.CorruptMove = choice
        end
    })

    local modeOptions = {"Disabled", "Run"}
    for moveIndex = 1, 4 do
        table.insert(modeOptions, "Move " .. moveIndex)
    end

    autoHuntPage.Dropdown({
        Text = "Mode",
        Options = modeOptions,
        Callback = function(choice)
            runModeSelection = choice
        end
    })
end

local availableShopDiscs = {}
local autoBuyDiscModule = {
    CanAutoBuy = function()
        return true
    end,
    Enabled = {},
    Func = function(item)
        if item.name and item.id and item.id:sub(#item.id - 3, #item.id) == "disc" and typeof(item.price) == "number" and
            not availableShopDiscs[item.name] then
            availableShopDiscs[item.name] = item
        end
    end
}

LooP(function()
    if not autoHuntPage then
        return
    end
    local iterator = next
    local discTable = availableShopDiscs
    local key = nil
    while true do
        local disc
        key, disc = iterator(discTable, key)
        if key == nil then
            break
        end
        if typeof(disc) ~= "Instance" then
            if disc and disc.name and disc.id then
                availableShopDiscs[disc.name] = autoHuntPage.Toggle({
                    Text = "Buy " .. tostring(disc.name),
                    Enabled = nil,
                    Callback = function(enabled)
                        autoBuyDiscModule.Enabled[disc.id] = enabled or nil
                    end
                })
            end
        end
    end
end)

table.insert(autoBuyModules, autoBuyDiscModule)

LooP(function()
    pcall(function()
        if not clientState or not getCurrentBattle() then
            return
        end
        if getCurrentBattle().state == "input" and autoEncounterEnabled and advancedExploitAvailable then
            local activeLoomian = getActiveMonster()
            if shouldCatchCurrentEncounter() then
                local moveIterator = next
                local battleMoves = clientState.BattleGui.moves
                local moveKey = nil
                while true do
                    local move
                    moveKey, move = moveIterator(battleMoves, moveKey)
                    if moveKey == nil then
                        break
                    end
                    if move.move == "Spare" and autoHuntSettings.Spare and activeLoomian.hp / activeLoomian.maxhp > 0.2 then
                        return chooseMove(moveKey)
                    end
                end
                if switchingInProgress or not discIdLookup[autoHuntSettings.Disc] then
                    return
                end
                clientState.BattleGui:exitButtonsMain()
                local discItemId = discIdLookup[autoHuntSettings.Disc]
                if discItemId then
                    clientState.BattleGui.inputEvent:fire("useitem " .. tostring(discItemId))
                end
            elseif activeLoomian.corrupt and autoHuntSettings.Corrupt ~= "Disabled" then
                if autoHuntSettings.CorruptMove and autoHuntSettings.CorruptMove ~= "Disabled" then
                    local moveNum = autoHuntSettings.CorruptMove:split(" ")[2]
                    if moveNum then
                        chooseMove(tonumber(moveNum))
                    end
                end
            elseif runModeSelection and runModeSelection ~= "Disabled" then
                if runModeSelection ~= "Run" then
                    local selectedMove = runModeSelection
                    local moveNum = selectedMove:split(" ")[2]
                    if moveNum then
                        chooseMove(tonumber(moveNum))
                    end
                elseif getCurrentBattle() and getCurrentBattle().CanRun ~= false and battleGuiOpen then
                    clientState.BattleGui:mainButtonClicked(4)
                end
            end
        end
    end)
end)

local _ = nil

if advancedExploitAvailable then
    if not userSettings.AutoRally then
        userSettings.AutoRally = {}
    end

    local autoRallyPage = getgenv().AxiomHubUiConstante.New({
        Title = "Auto Rally"
    })

    autoRallyPage.Toggle({
        Text = "Enabled",
        Enabled = userSettings.AutoRally.Enabled,
        Callback = function(enabled)
            userSettings.AutoRally.Enabled = enabled
        end
    })

    autoRallyPage.Toggle({
        Text = "Keep All",
        Enabled = userSettings.AutoRally.All,
        Callback = function(enabled)
            userSettings.AutoRally.All = enabled
        end
    })

    autoRallyPage.Toggle({
        Text = "Keep Gleaming",
        Enabled = userSettings.AutoRally.Gleaming,
        Callback = function(enabled)
            userSettings.AutoRally.Gleaming = enabled
        end
    })

    autoRallyPage.Toggle({
        Text = "Keep Hidden Ability",
        Enabled = userSettings.AutoRally["Hidden Ability"],
        Callback = function(enabled)
            userSettings.AutoRally["Hidden Ability"] = enabled
        end
    })

    autoRallyPage.Dropdown({
        Text = userSettings.AutoRally.x40Tab or "x40 keep Disabled",
        Options = {"x40 keep Disabled", "3x40 and Higher", "4x40 and Higher", "5x40 and Higher", "6x40 and Higher",
                   "7x40 Only"},
        Callback = function(choice)
            userSettings.AutoRally.x40Tab = choice
            local keepCount = choice == "x40 keep Disabled" and 8 or choice:sub(1, 1)
            userSettings.AutoRally.x40 = tonumber(keepCount)
        end
    })

    LooP(function()
        pcall(function()
            if userSettings.AutoRally.Enabled then
                local rallied = clientState.Network:get("PDS", "getRallied")
                local loadingFlag = {}
                local toHandle = {}
                local monsters = rallied.monsters
                if monsters and monsters[1] then
                    local monsterIterator = next
                    local monsterKey = nil
                    while true do
                        local monsterIndex, monsterData = monsterIterator(monsters, monsterKey)
                        if monsterIndex == nil then
                            break
                        end
                        local ivIterator = next
                        local ivTable = monsterData.summ.ivr
                        monsterKey = monsterIndex
                        local ivKey = nil
                        local maxIVCount = 0
                        while true do
                            local _, ivValue = ivIterator(ivTable, ivKey)
                            ivKey = _
                            if _ == nil then
                                break
                            end
                            if ivValue == 6 then
                                maxIVCount = maxIVCount + 1
                            end
                        end
                        if userSettings.AutoRally.All or monsterData.gl and userSettings.AutoRally.Gleaming then
                            toHandle[monsterIndex] = 2
                        elseif monsterData.sa and userSettings.AutoRally["Hidden Ability"] then
                            toHandle[monsterIndex] = 2
                        elseif userSettings.AutoRally.x40 and userSettings.AutoRally.x40 <= maxIVCount then
                            toHandle[monsterIndex] = 2
                        else
                            toHandle[monsterIndex] = 1
                        end
                    end
                    local actions = {function()
                        clientState.DataManager:setLoading(loadingFlag, true)
                        local handledCount = clientState.Network:get("PDS", "handleRallied", toHandle)
                        clientState.DataManager:setLoading(loadingFlag, false)
                        if handledCount then
                            clientState.Menu.rally.ralliedCount = handledCount
                            if clientState.Menu.rally.updateNPCBubble then
                                clientState.Menu.rally.updateNPCBubble(handledCount)
                            end
                        end
                    end, function()
                        if rallied.mastery then
                            clientState.Menu.mastery:showProgressUpdate(rallied.mastery, false)
                        end
                    end}
                    clientState.Utilities.Sync(actions)
                end
            end
        end)
    end)
end

local autoBattlePage = getgenv().AxiomHubUiConstante.New({
    Title = "Auto Battle"
})
if not userSettings.AutoBattle then
    userSettings.AutoBattle = {}
end

userSettings.Move = "Disabled"
local moveOptions = {"Disabled"}
for moveIndex = 1, 4 do
    table.insert(moveOptions, "Move " .. moveIndex)
end

autoBattlePage.Dropdown({
    Text = "Auto Move",
    Options = moveOptions,
    Callback = function(choice)
        userSettings.Move = choice
    end
})

LooP(function()
    pcall(function()
        chooseMove(tonumber(userSettings.Move:split(" ")[2]))
    end)
end)

local selectedTrainer = "Disabled"
local trainerOptions = {"Disabled"}
local trainerData = {}
local trainerNames = {}
local battleNameLookup = {}

local function cacheTrainerData(_, npc)
    pcall(function()
        local battles = clientState.DataManager.currentChunk.battles
        local battleId = npc.model:FindFirstChild("#Battle") and npc.model["#Battle"].Value or "Mrjack"
        local trainerBattle
        if battles then
            trainerBattle = battles[tostring(battleId)] or battles[battleId]
        else
            trainerBattle = battles
        end
        if task.wait() and trainerBattle and trainerBattle.RematchQuestion then
            local battleIterator = next
            local battleKey = nil
            local battleNames = {}
            while true do
                local battleEntry
                battleKey, battleEntry = battleIterator(battles, battleKey)
                if battleKey == nil then
                    break
                end
                table.insert(battleNames, battleEntry.Name)
            end
            local optionIterator = next
            local optionKey = nil
            while true do
                local option
                optionKey, option = optionIterator(trainerOptions, optionKey)
                if optionKey == nil then
                    break
                end
                if option ~= "Disabled" and not table.find(battleNames, option) then
                    table.remove(trainerOptions, optionKey)
                end
            end
            battleNameLookup[trainerBattle.Name] = tostring(battleId)
            local battleContext = {
                opponentBaseNPC = npc,
                trainer = trainerBattle
            }
            trainerData[trainerBattle.Name] = battleContext
            if not table.find(trainerOptions, trainerBattle.Name) and
                (originalSetupScene or not clientState.DataManager.currentChunk.regionData.BattleScene) then
                table.insert(trainerOptions, trainerBattle.Name)
            end
        end
    end)
end

local trainerDropdown = autoBattlePage.Dropdown({
    Text = "Select Trainer",
    Options = trainerNames,
    Callback = function(choice)
        selectedTrainer = choice
    end
})

LooP(function()
    if not clientState or not clientState.CollectionManager then
        return
    end
    ForLooP(clientState.CollectionManager:GetNPCs(), cacheTrainerData)
end)

LooP(function()
    pcall(function()
        if not clientState or not clientState.DataManager or not clientState.DataManager.currentChunk then
            return
        end
        local needsUpdate = #trainerOptions ~= #trainerNames
        local nameIterator = next
        local nameKey = nil
        local allInOptions = true
        while true do
            local name
            nameKey, name = nameIterator(trainerNames, nameKey)
            if nameKey == nil then
                break
            end
            if not table.find(trainerOptions, name) then
                needsUpdate = true
            end
        end
        local battleIterator = next
        local battles = clientState.DataManager.currentChunk.battles
        local battleKey = nil
        while true do
            local battleEntry
            battleKey, battleEntry = battleIterator(battles, battleKey)
            if battleKey == nil then
                break
            end
            allInOptions = false
        end
        if allInOptions and (#trainerOptions ~= 1 or not table.find(trainerOptions, "Disabled")) and
            not table.clear(trainerOptions) then
            table.insert(trainerOptions, "Disabled")
        elseif needsUpdate and not table.clear(trainerNames) then
            local optionIterator = next
            local optionKey = nil
            while true do
                local option
                optionKey, option = optionIterator(trainerOptions, optionKey)
                if optionKey == nil then
                    break
                end
                table.insert(trainerNames, option)
            end
            trainerDropdown = autoBattlePage.Dropdown({
                Text = "Select Trainer",
                Options = trainerNames,
                Callback = function(choice)
                    selectedTrainer = choice
                end
            })
        elseif selectedTrainer ~= "Disabled" then
            local trainerContext = trainerData[selectedTrainer]
            local trainerBattleId = battleNameLookup[selectedTrainer]
            if trainerContext and trainerContext.opponentBaseNPC.model and
                trainerContext.opponentBaseNPC.model:IsDescendantOf(workspace) and
                clientState.DataManager.currentChunk.battles[trainerBattleId] then
                if clientState.MasterControl.WalkEnabled and not getCurrentBattle() and
                    table.find(trainerOptions, selectedTrainer) and
                    clientState.PlayerData.completedEvents.ChooseBeginner and isHealedOrAllowed() then
                    if trainerContext.trainer.Name == "Tamyra" and clientState.DataManager.currentChunk.id == "chunk20" then
                        trainerContext.fshPct = 0.9
                    end
                    clientState.Battle:doTrainerBattle(trainerContext)
                end
            else
                table.remove(trainerOptions, selectedTrainer)
            end
        end
    end, 0.1)
end)

if table.find(travelLocations, "Uhnne Fair") then
    userSettings.Event = userSettings.Event or {}
    userSettings.Event["Uhnne Fair"] = userSettings.Event["Uhnne Fair"] or {}

    local eventPage = getgenv().AxiomHubUiConstante.New({
        Title = "Event"
    })
    local fairSettings = userSettings.Event["Uhnne Fair"]
    local mazeLasers = {}
    local mazeFolder = nil

    eventPage.Toggle({
        Text = "Disable Traps",
        Enabled = fairSettings.DisableTraps,
        Callback = function(enabled)
            fairSettings.DisableTraps = enabled
        end
    })

    eventPage.Button({
        Text = "Fix Camera",
        Callback = function()
            client.CameraMode = "Classic"
        end
    })

    eventPage.Slider({
        Text = "Brightness",
        Min = 0,
        Max = 50,
        Def = 0,
        Callback = function(value)
            game.Lighting.Brightness = value
        end
    })

    eventPage.Toggle({
        Text = "Nevermare ESP",
        Enabled = fairSettings.NevermareESP,
        Callback = function(enabled)
            fairSettings.NevermareESP = enabled
        end
    })

    eventPage.Toggle({
        Text = "Key ESP",
        Enabled = fairSettings.KeyESP,
        Callback = function(enabled)
            fairSettings.KeyESP = enabled
        end
    })

    eventPage.Toggle({
        Text = "Potion ESP",
        Enabled = fairSettings.PotionESP,
        Callback = function(enabled)
            fairSettings.PotionESP = enabled
        end
    })

    eventPage.Toggle({
        Text = "Candy ESP",
        Enabled = fairSettings.CandyESP,
        Callback = function(enabled)
            fairSettings.CandyESP = enabled
        end
    })

    eventPage.Toggle({
        Text = "Safe House ESP",
        Enabled = fairSettings.SafeHouseESP,
        Callback = function(enabled)
            fairSettings.SafeHouseESP = enabled
        end
    })

    if game.PlaceId == tonumber("8284266336") then
        local trapTriggers = {}
        local laserParts = {}
        local safeRooms = {}
        local originalSetupTraps = clientState.CMazeGameClient.SetupTraps
        function clientState.CMazeGameClient.SetupTraps(client, traps)
            trapTriggers = traps
            setThreadContextSafely(2)
            return originalSetupTraps(client, traps)
        end
        local originalSetupLasers = clientState.CMazeGameClient.SetupLasers
        function clientState.CMazeGameClient.SetupLasers(client, lasers, mazeData)
            mazeLasers = mazeData
            safeRooms = lasers
            task.spawn(function()
                repeat
                    task.wait()
                until clientState.CMazeGameClient.removeMazeFolder
                task.wait(0.5)
                trapTriggers = {}
                local safeIterator = next
                local safeKey = nil
                while true do
                    local safeRoom
                    safeKey, safeRoom = safeIterator(mazeLasers, safeKey)
                    if safeKey == nil then
                        break
                    end
                    if safeRoom:FindFirstChild("SafeHouse") then
                        table.insert(trapTriggers, safeRoom.SafeHouse)
                    end
                end
            end)
            setThreadContextSafely(2)
            return originalSetupLasers(client, lasers, mazeData)
        end

        LooP(function()
            mazeFolder = clientState.CMazeGameClient.mazeFolder
            pcall(function()
                local laserIterator = next
                local laserKey = nil
                while true do
                    local laser
                    laserKey, laser = laserIterator(safeRooms, laserKey)
                    if laserKey == nil then
                        break
                    end
                    laser.Model.CanTouch = not fairSettings.DisableTraps
                end
            end)
            pcall(function()
                local trapIterator = next
                local trapKey = nil
                while true do
                    local trap
                    trapKey, trap = trapIterator(trapTriggers, trapKey)
                    if trapKey == nil then
                        break
                    end
                    trap.Trigger.CanTouch = not fairSettings.DisableTraps
                end
            end)
        end)

        local espFolder = Instance.new("Folder", workspace)
        local keyModel = Instance.new("Model", espFolder)
        local candyModel = Instance.new("Model", espFolder)
        local potionModel = Instance.new("Model", espFolder)

        local function tagESP(target, color, isVisible)
            local billboard = target:FindFirstChild("BillboardGui") or Instance.new("BillboardGui", target)
            local billboardSize = UDim2.new(1, 200, 1, 30)
            billboard.Adornee = target
            billboard.AlwaysOnTop = true
            billboard.Size = billboardSize
            local label = billboard:FindFirstChild("TextLabel") or Instance.new("TextLabel", billboard)
            local anchorPoint = Vector2.new(0.5, 0.5)
            local position = UDim2.new(0.5, 0, 0.5, 0)
            label.Visible = isVisible
            label.Position = position
            label.AnchorPoint = anchorPoint
            label.Size = UDim2.new(1, 0, 1.5, 0)
            label.Font = "SourceSansBold"
            label.TextScaled = true
            label.TextYAlignment = "Top"
            label.TextStrokeTransparency = 1
            label.TextTransparency = 0
            label.TextSize = 100
            label.Text = "."
            label.BackgroundTransparency = 1
            label.TextColor3 = color
        end

        LooP(function()
            local cleanupIterator = next
            local cleanupKey = nil
            while true do
                local cleanupEntry
                cleanupKey, cleanupEntry = cleanupIterator(clientState.CMazeGameClient.cleanupInstances or {},
                    cleanupKey)
                if cleanupKey == nil then
                    break
                end
                local model = cleanupEntry.model
                if model and task.wait() then
                    pcall(function()
                        if model:IsDescendantOf(client.Character) then
                            if model.Main:FindFirstChild("BillboardGui") then
                                model.Main.BillboardGui:Destroy()
                            end
                        else
                            local targetFolder = potionModel
                            local color = Color3.fromRGB(100, 0, 250)
                            local enabledFlag = fairSettings.PotionESP
                            if model.Name ~= "Key" then
                                if model.Name == "Candy" then
                                    targetFolder = candyModel
                                    color = Color3.fromRGB(250, 140, 5)
                                    enabledFlag = fairSettings.CandyESP
                                end
                            else
                                targetFolder = keyModel
                                color = Color3.fromRGB(102, 255, 255)
                                enabledFlag = fairSettings.KeyESP
                            end
                            tagESP(model.Main, color, enabledFlag)
                            model.Parent = targetFolder
                        end
                    end)
                end
            end
            pcall(function()
                local safeIterator = next
                local safeKey = nil
                while true do
                    local safeRoom
                    safeKey, safeRoom = safeIterator(trapTriggers, safeKey)
                    if safeKey == nil then
                        break
                    end
                    local safeTrigger = safeRoom:FindFirstChild("EnterSafeHouseTrigger")
                    if safeTrigger then
                        safeRoom.Parent = espFolder
                        tagESP(safeTrigger, Color3.fromRGB(80, 255, 0), mazeFolder and fairSettings.SafeHouseESP)
                    end
                end
            end)
            pcall(function()
                local nevermare = workspace:FindFirstChild("Nevermare")
                if nevermare then
                    local root = nevermare:FindFirstChild("RootPart")
                    if nevermare:FindFirstChild("BB") then
                        nevermare.Name = "Nevrmare"
                    elseif root then
                        tagESP(root, Color3.fromRGB(255, 0, 0), fairSettings.NevermareESP)
                    end
                end
            end)
        end)
    end
end

loadstring(game:HttpGet("https://axiomhub.eu/lua/tools/othergui.lua"))()