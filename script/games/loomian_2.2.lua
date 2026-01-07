local GAME_NAME = "Loomian Legacy - 306964494"
warn("\n=>=>=>  " .. GAME_NAME .. " Script Loading...  <=<=<=\n")

local venyxLibraryWrapper = MrJackTable
if venyxLibraryWrapper then
    if type(MrJackTable.VenyxLibrary) ~= "function" then
        venyxLibraryWrapper = false
    else
        venyxLibraryWrapper = MrJackTable.VenyxLibrary()
    end
end

if not IrisNotificationMrJack then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/thedragonslayer2/hey/main/Misc./iris%20notification%20function"))()
end

if not venyxLibraryWrapper or venyxLibraryWrapper.MrJack ~= "MrJackIsCool" then
    return loadstring(game:HttpGet("https://thedragonslayer2.github.io"))()
end

if not (getgc or debug.getregistry) then
    if IrisNotificationUserMrJack then
        IrisNotificationUserMrJack.ClearAllNotifications()
    end
    return IrisNotificationMrJack(2, "Executor not Supported! D:", "A Function is Missing!\n\nPlease Download a better Executor!", 10)
end

local coreGuiCheck = pcall(function()
    return game:GetService("CoreGui")["keonelibbary/gui"]
end)

local userSettings = {}
local clientState = nil
local loadingNotification = nil
local switchingInProgress = nil
local battleGuiOpen = nil
local healingInProgress = nil
local travelLocations = {}
local autoBuyModules = {}
local autoEncounterEnabled = nil
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
            if typeof(candidate) == "table" and rawget(candidate, "Utilities") and not (clientState and clientState.Battle) then
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
        if clientState and not coreGuiCheck then
            return
        end
        if not loadingNotification then
            loadingNotification = AbstractPooNotif():notify({
                Title = "Notification",
                Description = "Waiting for Game to Load...",
                Length = 9000000000
            })
        end
        if coreGuiCheck then
            while task.wait() do
            end
        end
        task.wait(7.5)
    end
end)

if loadingNotification then
    loadingNotification()
end

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
        return shinyState == 1 and autoHuntSettings.Gleam
            or shinyState == 2 and autoHuntSettings.Gamma
            or (not getActiveMonster().owned and autoHuntSettings.NotOwned or isTargetListedLoomian())
    end
end

local function chooseMove(moveIndex)
    local battleGui = clientState.BattleGui
    if getCurrentBattle().state == "input" and not switchingInProgress then
        if not battleGui.onMoveClicked then
            battleGui:mainButtonClicked(1)
        end
        local moveDetails = battleGui.moves[moveIndex]
        if moveDetails.energy and (battleGui.activeMonster.energy < moveDetails.energy and not battleGui.activeMonster.bypassEnergy) then
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
    if typeof(badgeValue) == "number" and badgeName:sub(1, 5) == "Medal" and badgeName:sub(7, 7) == "" and badgeValue ~= 0 then
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
            if task.wait() and miningPoint.Part and not (miningPoint.Part:GetAttribute("OnlyOnce") or miningPoint.Part:SetAttribute("OnlyOnce", true)) then
                miningPoint.Part.Parent = miningModel
            end
        end
    end
end)

function clientState.Menu.options.resetLastUnstuckTick()
end

LooP(function()
    if clientState.MasterControl.WalkEnabled and not getCurrentBattle() then
        workspace.Camera.FieldOfView = 70
    end
end)

local originalSwitchMonster = clientState.BattleGui.switchMonster
function clientState.BattleGui.switchMonster(...)
    setThreadContextSafely(2)
    local forceSwitch = ({
        ...
    })[3] == false
    if forceSwitch then
        switchingInProgress = true
    end
    local results = {
        originalSwitchMonster(...)
    }
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

local venyxWindow = venyxLibraryWrapper.new(GAME_NAME:split(" - ")[1])
venyxWindow:toggle()
local venyxAddPage = venyxWindow.addPage
function venyxWindow.addPage(...)
    task.wait(0.5)
    return venyxAddPage(...)
end

local mainPage = venyxWindow:addPage("Main")
local mainSection = mainPage:addSection("Main")

mainSection:addToggle("Auto Heal[Outdoor Only]", userSettings["Auto Heal"], function(enabled)
    userSettings["Auto Heal"] = enabled
end)

LooP(function()
    xpcall(function()
        local currentChunk = clientState.DataManager.currentChunk
        if userSettings["Auto Heal"]
            and clientState.MasterControl.WalkEnabled
            and clientState.Menu.enabled
            and not currentChunk.indoors
            and not getCurrentBattle()
            and not clientState.ObjectiveManager.disabledBy.LoomianCare
            and not clientState.Network:get("PDS", "areFullHealth") then
            if currentChunk.data.HasOutsideHealers then
                clientState.Network:get("heal", nil, "HealMachine1")
            else
                local returnChunkId = currentChunk.regionData and currentChunk.regionData.BlackOutTo or currentChunk.data.blackOutTo
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

mainSection:addToggle("Active Repellent", userSettings["Infinite Repel"], function(enabled)
    userSettings["Infinite Repel"] = enabled
end)

LooP(function()
    if clientState.Repel.steps < 10 or not userSettings["Infinite Repel"] or autoEncounterEnabled then
        clientState.Repel.steps = not autoEncounterEnabled and (userSettings["Infinite Repel"] and 100) or 0
    end
end)

if advancedExploitAvailable then
    local defeatedTrainerCache = {}
    mainSection:addToggle("Ignore NPC Battle", userSettings["Ignore NPC Battle"], function(enabled)
        userSettings["Ignore NPC Battle"] = enabled
    end)
    local originalGetBit = clientState.BitBuffer.GetBit
    function clientState.BitBuffer.GetBit(...)
        local args = {
            ...
        }
        if not (table.find(defeatedTrainerCache, clientState.DataManager.currentChunk.map) or table.clear(defeatedTrainerCache)) then
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

mainSection:addToggle("Skip Dialogue", userSettings["Skip Dialogue"], function(enabled)
    userSettings["Skip Dialogue"] = enabled
end)

local function filterDialogue(_, ...)
    local dialogueArgs = {
        ...
    }
    local filteredDialogue = {}
    local shouldShow = nil
    if typeof(dialogueArgs[2]) == "string" then
        if dialogueArgs[2]:sub(1, 8) == "[NoSkip]" then
            return {
                dialogueArgs[1],
                dialogueArgs[2]:sub(9)
            }, true
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

mainSection:addToggle("Fast Battle", userSettings["Fast Battle"], function(enabled)
    userSettings["Fast Battle"] = enabled
end)

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
            local callArgs = {
                ...
            }
            callArgs[targetIndex].battle.fastForward = userSettings["Fast Battle"]
            local results = {
                originalMethod(unpack(callArgs))
            }
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
    [clientState.BattleGui] = {
        "animWeather",
        "animStatus",
        "animAbility",
        "animBoost",
        "animHit",
        "animMove"
    }
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
    local results = {
        originalSetCamera(self, cameraData)
    }
    cameraData.fastForward = false
    return unpack(results)
end

local originalFillbarRatio = clientState.RoundedFrame.setFillbarRatio
function clientState.RoundedFrame.setFillbarRatio(...)
    local args = {
        ...
    }
    if userSettings["Fast Battle"] and getCurrentBattle() then
        args[3] = false
    end
    return originalFillbarRatio(unpack(args))
end

if advancedExploitAvailable then
    mainSection:addButton("End Battle", forceBattleEnd)
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
    mainSection:addSlider("WalkSpeed", userSettings.WalkSpeed or 16, 0, 250, 0.1, function(value)
        userSettings.WalkSpeed = value
    end)
    LooP(function()
        if userSettings.WalkSpeed and userSettings.WalkSpeed ~= 0 then
            client.Character.Humanoid.WalkSpeed = userSettings.WalkSpeed or 16
        elseif userSettings.WalkSpeed == 0 then
            local humanoid = client.Character.Humanoid
            userSettings.WalkSpeed = nil
            humanoid.WalkSpeed = 16
        end
    end)
end

local guiSection = mainPage:addSection("GUIs")

guiSection:addButton("Open Rally Team", function()
    clientState.Menu:disable()
    clientState.Menu.rally:openRallyTeamMenu()
    clientState.Menu:enable()
end)

guiSection:addButton("Open Rallied", function()
    pcall(function()
        if clientState.Network:get("PDS", "ranchStatus").rallied > 0 then
            clientState.Menu:disable()
            clientState.Menu.rally:openRalliedMonstersMenu()
            clientState.Menu:enable()
        end
    end)
end)

guiSection:addButton("Open PC", function()
    clientState.Menu.pc:bootUp()
end)

guiSection:addButton("Open Shop", function()
    clientState.Menu:disable()
    clientState.Menu.shop:open()
    clientState.Menu:enable()
end)

guiSection:addButton("Junk 4 Junk", function()
    clientState.Menu:disable()
    clientState.Menu.shop:open("fishtrash")
    clientState.Menu:enable()
end)

local miscPage = venyxWindow:addPage("Misc")
if not userSettings.MiscSettings then
    userSettings.MiscSettings = {}
end
local miscSettingsSection = miscPage:addSection("Misc Settings")
local miscSettings = userSettings.MiscSettings

local function addMiscToggle(label, key)
    miscSettingsSection:addToggle(label, miscSettings[key], function(enabled)
        miscSettings[key] = enabled
    end)
end

addMiscToggle("Deny Reassign Move", "NoNewMoves")
addMiscToggle("Deny Switch Request", "NoSwitch")
addMiscToggle("Deny Nickname Request", "NoNick")
addMiscToggle("Disable Show Progress", "NoProgress")

local autoFishSection = miscPage:addSection("Auto Fish")
autoFishSection:addToggle(originalSetupScene and "Enabled" or "Enabled(will only get items)", userSettings.AutoFish, function(enabled)
    userSettings.AutoFish = enabled
end)
if originalSetupScene then
    autoFishSection:addToggle("Items Only", userSettings.AutoFish, function(enabled)
        userSettings.AutoFishOnlyItems = enabled
    end)
end

local originalOnWaterClicked = clientState.Fishing.OnWaterClicked
local currentWaterPart = nil

LooP(function()
    pcall(function()
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
            raycastParams.FilterDescendantsInstances = {
                workspace.Terrain
            }
            raycastParams.IgnoreWater = false
            raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
            local rayResult = workspace:Raycast(castPosition + Vector3.new(0, 3, 0), Vector3.new(0.001, -10, 0.001), raycastParams)
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

local discDropSection, discDropEnabled = miscPage:addSection("Auto Disc Drop")
discDropSection:addToggle("Enabled", nil, function(enabled)
    discDropEnabled = enabled
end)
discDropSection:addToggle("Fast Mode", userSettings.FastDiscDrop, function(enabled)
    userSettings.FastDiscDrop = enabled
end)

task.spawn(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/thedragonslayer2/MrJack-Game-List/main/Functions/Loomian%20Legacy%20-%20306964494/Disc%20Drop.lua"))()
    local runDiscDrop, getDiscDropState = getgenv().LoomianLegacyAutoDisDrop(userSettings, clientState)
    LooP(function()
        pcall(function()
            if discDropEnabled and clientState.ArcadeController.playing and getDiscDropState() and getDiscDropState().gui.GridFrame:IsDescendantOf(client.PlayerGui) then
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

local autoHuntPage = venyxWindow:addPage("Auto Hunt")
local autoHuntSettings = userSettings["Auto Hunt"]
local autoHuntSection = autoHuntPage:addSection("Auto Hunt")
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

autoHuntSection:addToggle("Auto Encounter", nil, function(enabled)
    autoEncounterEnabled = enabled
end)

LooP(function()
    pcall(function()
        if clientState.MasterControl.WalkEnabled
            and autoEncounterEnabled
            and clientState.Menu.enabled
            and not getCurrentBattle()
            and clientState.PlayerData.completedEvents.ChooseBeginner
            and isHealedOrAllowed() then
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
    discDropdown = autoHuntSection:addDropdown(autoHuntSettings.Disc or "Select Disc", availableDiscs, function(choice)
        autoHuntSettings.Disc = choice
    end)
else
    discDropdown = advancedExploitAvailable
end

LooP(function()
    pcall(function()
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
                local sectionRef = discCounterSection
                discButtons[item.name] = sectionRef:addButton("")
            end
            discCounterSection:updateButton(discButtons[item.name], item.name .. ": " .. item.qty)
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
                discCounterSection:updateButton(discButtons[discName], discName .. ": 0")
                return table.remove(availableDiscs, availableKey)
            end
        end
        if updateDropdown or not selectedFound then
            if not selectedFound then
                autoHuntSettings.Disc = nil
            end
            if advancedExploitAvailable then
                autoHuntSection:updateDropdown(discDropdown, autoHuntSettings.Disc or "Select Disc", availableDiscs, function(choice)
                    autoHuntSettings.Disc = choice
                end, true)
            end
        end
    end)
end)

if advancedExploitAvailable then
    task.wait(0.1)
    local function addAutoHuntToggle(label, key)
        autoHuntSection:addToggle(label, autoHuntSettings[key], function(enabled)
            autoHuntSettings[key] = enabled
        end)
    end
    addAutoHuntToggle("Use Spare", "Spare")
    addAutoHuntToggle("Catch Not Owned", "NotOwned")
    addAutoHuntToggle("Catch Normal Gleam", "Gleam")
    addAutoHuntToggle("Catch Gamma Gleam", "Gamma")

    if not autoHuntSettings.Loomians then
        autoHuntSettings.Loomians = {}
    end
    local catchListSection = autoHuntPage:addSection("Catch Listed Loomians")
    local catchList = autoHuntSettings.Loomians
    local catchDropdown = nil
    local function removeLoomian(name)
        table.remove(catchList, table.find(catchList, name))
        task.delay(0.25, function()
            catchListSection:updateDropdown(catchDropdown, "List", catchList, removeLoomian, true)
        end)
    end
    catchDropdown = catchListSection:addDropdown("List", catchList, removeLoomian)
    catchListSection:addTextbox("Add Loomian", "Name", function(text, enterPressed)
        if enterPressed then
            if not table.find(catchList, text:lower()) then
                table.insert(catchList, text:lower())
            end
            catchListSection:updateDropdown(catchDropdown, "List", catchList, removeLoomian, true)
        end
    end)

    task.wait(0.1)
    local corruptSection = autoHuntPage:addSection("Defeat Corrupt")
    local corruptMoves = {
        "Disabled"
    }
    for moveIndex = 1, 4 do
        table.insert(corruptMoves, "Move " .. moveIndex)
    end
    if not autoHuntSettings.CorruptMove then
        autoHuntSettings.CorruptMove = "Disabled"
    end
    corruptSection:addDropdown(autoHuntSettings.CorruptMove, corruptMoves, function(choice)
        autoHuntSettings.CorruptMove = choice
    end)

    local modeSection = autoHuntPage:addSection("Mode")
    local modeOptions = {
        "Disabled",
        "Run"
    }
    for moveIndex = 1, 4 do
        table.insert(modeOptions, "Move " .. moveIndex)
    end
    modeSection:addDropdown("Disabled", modeOptions, function(choice)
        runModeSelection = choice
    end)
end

local autoBuyDiscSection = autoHuntPage:addSection("Auto Buy Disc")
local availableShopDiscs = {}
local autoBuyDiscModule = {
    CanAutoBuy = function()
        return true
    end,
    Enabled = {},
    Func = function(item)
        if item.name and item.id and item.id:sub(#item.id - 3, #item.id) == "disc" and typeof(item.price) == "number" and not availableShopDiscs[item.name] then
            availableShopDiscs[item.name] = item
        end
    end
}

LooP(function()
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
            availableShopDiscs[disc.name] = autoBuyDiscSection:addToggle(disc.name, nil, function(enabled)
                autoBuyDiscModule.Enabled[disc.id] = enabled or nil
            end)
        end
    end
end)

table.insert(autoBuyModules, autoBuyDiscModule)

LooP(function()
    pcall(function()
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
                clientState.BattleGui.inputEvent:fire("useitem " .. discIdLookup[autoHuntSettings.Disc])
            elseif activeLoomian.corrupt and autoHuntSettings.Corrupt ~= "Disabled" then
                chooseMove(tonumber(autoHuntSettings.CorruptMove:split(" ")[2]))
            elseif runModeSelection and runModeSelection ~= "Disabled" then
                if runModeSelection ~= "Run" then
                    local selectedMove = runModeSelection
                    chooseMove(tonumber(selectedMove:split(" ")[2]))
                elseif getCurrentBattle() and getCurrentBattle().CanRun ~= false and battleGuiOpen then
                    clientState.BattleGui:mainButtonClicked(4)
                end
            end
        end
    end)
end)

local _ = autoHuntPage:addSection("Discs Counter")

if advancedExploitAvailable then
    if not userSettings.AutoRally then
        userSettings.AutoRally = {}
    end
    local autoRallySection = venyxWindow:addPage("Auto Rally"):addSection("Auto Rally")
    autoRallySection:addToggle("Enabled", userSettings.AutoRally.Enabled, function(enabled)
        userSettings.AutoRally.Enabled = enabled
    end)
    autoRallySection:addToggle("Keep All", userSettings.AutoRally.All, function(enabled)
        userSettings.AutoRally.All = enabled
    end)
    autoRallySection:addToggle("Keep Gleaming", userSettings.AutoRally.Gleaming, function(enabled)
        userSettings.AutoRally.Gleaming = enabled
    end)
    autoRallySection:addToggle("Keep Hidden Ability", userSettings.AutoRally["Hidden Ability"], function(enabled)
        userSettings.AutoRally["Hidden Ability"] = enabled
    end)
    autoRallySection:addDropdown(userSettings.AutoRally.x40Tab or "x40 keep Disabled", {
        "x40 keep Disabled",
        "3x40 and Higher",
        "4x40 and Higher",
        "5x40 and Higher",
        "6x40 and Higher",
        "7x40 Only"
    }, function(choice)
        userSettings.AutoRally.x40Tab = choice
        local keepCount = choice == "x40 keep Disabled" and 8 or choice:sub(1, 1)
        userSettings.AutoRally.x40 = tonumber(keepCount)
    end)

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
                    local actions = {
                        function()
                            clientState.DataManager:setLoading(loadingFlag, true)
                            local handledCount = clientState.Network:get("PDS", "handleRallied", toHandle)
                            clientState.DataManager:setLoading(loadingFlag, false)
                            if handledCount then
                                clientState.Menu.rally.ralliedCount = handledCount
                                if clientState.Menu.rally.updateNPCBubble then
                                    clientState.Menu.rally.updateNPCBubble(handledCount)
                                end
                            end
                        end,
                        function()
                            if rallied.mastery then
                                clientState.Menu.mastery:showProgressUpdate(rallied.mastery, false)
                            end
                        end
                    }
                    clientState.Utilities.Sync(actions)
                end
            end
        end)
    end)
end

local autoBattlePage = venyxWindow:addPage("Auto Battle")
if not userSettings.AutoBattle then
    userSettings.AutoBattle = {}
end

local autoMoveSection = autoBattlePage:addSection("Auto Move")
userSettings.Move = "Disabled"
local moveOptions = {
    "Disabled"
}
for moveIndex = 1, 4 do
    table.insert(moveOptions, "Move " .. moveIndex)
end
autoMoveSection:addDropdown("Disabled", moveOptions, function(choice)
    userSettings.Move = choice
end)

LooP(function()
    pcall(function()
        if client.PlayerGui.MainGui:FindFirstChild("BattleGui", true) and string.find(userSettings.Move, "Move") and getCurrentBattle().kind ~= "wild" then
            chooseMove(tonumber(userSettings.Move:split(" ")[2]))
        end
    end)
end)

local autoBattleSection = autoBattlePage:addSection("Auto Battle")
local selectedTrainer = "Disabled"
local trainerOptions = {
    "Disabled"
}
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
            if not table.find(trainerOptions, trainerBattle.Name) and (originalSetupScene or not clientState.DataManager.currentChunk.regionData.BattleScene) then
                table.insert(trainerOptions, trainerBattle.Name)
            end
        end
    end)
end

local trainerDropdown = autoBattleSection:addDropdown(trainerNames[1], trainerNames, function(choice)
    selectedTrainer = choice
end)

LooP(function()
    ForLooP(clientState.CollectionManager:GetNPCs(), cacheTrainerData)
end)

LooP(function()
    pcall(function()
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
        if allInOptions and (#trainerOptions ~= 1 or not table.find(trainerOptions, "Disabled")) and not table.clear(trainerOptions) then
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
            autoBattleSection:updateDropdown(trainerDropdown)
            autoBattleSection:updateDropdown(trainerDropdown, "Disabled", trainerOptions, function(choice)
                selectedTrainer = choice
            end, true)
        elseif selectedTrainer ~= "Disabled" then
            local trainerContext = trainerData[selectedTrainer]
            local trainerBattleId = battleNameLookup[selectedTrainer]
            if trainerContext and trainerContext.opponentBaseNPC.model and trainerContext.opponentBaseNPC.model:IsDescendantOf(workspace) and clientState.DataManager.currentChunk.battles[trainerBattleId] then
                if clientState.MasterControl.WalkEnabled and not getCurrentBattle() and table.find(trainerOptions, selectedTrainer) and clientState.PlayerData.completedEvents.ChooseBeginner and isHealedOrAllowed() then
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
    local eventPage = venyxWindow:addPage("Event")
    local fairSettings = userSettings.Event["Uhnne Fair"]
    local mazeLasers = {}
    local mazeFolder = nil
    local mainSectionEvent = eventPage:addSection("Main")
    mainSectionEvent:addToggle("Disable Traps", fairSettings.DisableTraps, function(enabled)
        fairSettings.DisableTraps = enabled
    end)
    mainSectionEvent:addButton("Fix Camera", function()
        client.CameraMode = "Classic"
    end)
    mainSectionEvent:addSlider("Brightness", 0, 0, 50, 0.1, function(value)
        game.Lighting.Brightness = value
    end)

    local espSection = eventPage:addSection("ESP")
    espSection:addToggle("Nevermare", fairSettings.NevermareESP, function(enabled)
        fairSettings.NevermareESP = enabled
    end)
    espSection:addToggle("Key", fairSettings.KeyESP, function(enabled)
        fairSettings.KeyESP = enabled
    end)
    espSection:addToggle("Potion", fairSettings.PotionESP, function(enabled)
        fairSettings.PotionESP = enabled
    end)
    espSection:addToggle("Candy", fairSettings.CandyESP, function(enabled)
        fairSettings.CandyESP = enabled
    end)
    espSection:addToggle("Safe House", fairSettings.SafeHouseESP, function(enabled)
        fairSettings.SafeHouseESP = enabled
    end)

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
                cleanupKey, cleanupEntry = cleanupIterator(clientState.CMazeGameClient.cleanupInstances or {}, cleanupKey)
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

local randomColor = Color3.fromHSV(tick() % math.random(5) / math.random(5), 1, 1)
local themeSection = venyxWindow:addPage("GUI Theme"):addSection("Colors")
local themeSettings = userSettings.Theme or {}
local defaultTheme = {
    Background = Color3.fromRGB(24, 24, 24),
    Glow = randomColor,
    Accent = Color3.fromRGB(10, 10, 10),
    LightContrast = Color3.fromRGB(20, 20, 20),
    DarkContrast = Color3.fromRGB(14, 14, 14),
    TextColor = randomColor
}
userSettings.Theme = themeSettings
local themeIterator = next
local themeDefaults = defaultTheme
local themeKey = nil
local themePickers = {}
local function toRGB(color)
    return math.clamp(math.ceil(color.R * 255), 0, 255), math.clamp(math.ceil(color.G * 255), 0, 255), math.clamp(math.ceil(color.B * 255), 0, 255)
end
while true do
    local themeName, themeValue = themeIterator(defaultTheme, themeKey)
    if themeName == nil then
        break
    end
    themeKey = themeName
    local savedTheme = userSettings.Theme[themeName]
    if savedTheme then
        savedTheme = Color3.fromRGB(toRGB(Color3.new(unpack(userSettings.Theme[themeName]:split(", ")))))
    end
    themePickers[themeName] = themeSection:addColorPicker(themeName, savedTheme or themeValue, function(color)
        venyxWindow:setTheme(themeName, color)
        userSettings.Theme[themeName] = tostring(color)
    end)
end

themeSection:addButton("Reset Theme", function()
    local iterator = next
    local key = nil
    while true do
        local name, value = iterator(themeDefaults, key)
        if name == nil then
            break
        end
        key = name
        venyxWindow:setTheme(name, value)
        themeSection:updateColorPicker(themePickers[name], name, value)
    end
    userSettings.Theme = {}
end)

local otherPage = venyxWindow:addPage("Other")
local builtInSection = otherPage:addSection("Built In Features")
builtInSection:addButton("Skip Battle Theater Puzzles")
builtInSection:addButton("No Unstuck CoolDown")
builtInSection:addButton("Skip Fish MiniGame")
builtInSection:addButton("Infinite UMV Energy")

local teleportSection = otherPage:addSection("Teleport")
teleportSection:addButton("Rejoin", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
end)
teleportSection:addButton("Switch Server", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/thedragonslayer2/Misc/main/Server%20Hop"))()
end)
teleportSection:addButton("Find Most Empty Server", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/thedragonslayer2/hey/main/Misc./Find%20the%20most%20empty%20server%20script"))()
end)

local otherSection = otherPage:addSection("Other")
otherSection:addButton("Copy Discord Invite", function()
    setclipboard(DiscordInvite)
    IrisNotificationMrJack(1, "Notification", "Discord Link Copied!", 3)
end)

if IrisNotificationUserMrJack then
    IrisNotificationUserMrJack.ClearAllNotifications()
end

if not passlolbruh then
    return IrisNotificationMrJack(2, "Ui Library Variable Did Not Load!", "Something went wrong,\nPlease Execute again!", 7)
end

otherSection:addKeybind("Hide/Show Gui", Enum.KeyCode.RightAlt, function()
    venyxWindow:toggle()
end)

local themeApplyIterator = next
local themeApplyKey = nil
while true do
    local themeName, themeValue = themeApplyIterator(themeDefaults, themeApplyKey)
    if themeName == nil then
        break
    end
    themeApplyKey = themeName
    local savedTheme = userSettings.Theme[themeName]
    if savedTheme then
        savedTheme = Color3.fromRGB(toRGB(Color3.new(unpack(userSettings.Theme[themeName]:split(", ")))))
    end
    venyxWindow:setTheme(themeName, savedTheme or themeValue)
end

venyxWindow:toggle()
venyxWindow:SelectPage(venyxWindow.pages[1], true)
