local vu1 = "Loomian Legacy - 306964494"
warn("\n=>=>=>  " .. vu1 .. " Script Loading...  <=<=<=\n")
local v2 = MrJackTable
if v2 then
    if type(MrJackTable.VenyxLibrary) ~= "function" then
        v2 = false
    else
        v2 = MrJackTable.VenyxLibrary()
    end
end
if not IrisNotificationMrJack then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/thedragonslayer2/hey/main/Misc./iris%20notification%20function"))()
end
if not v2 or v2.MrJack ~= "MrJackIsCool" then
    return loadstring(game:HttpGet("https://thedragonslayer2.github.io"))()
end
if not (getgc or debug.getregistry) then
    if IrisNotificationUserMrJack then
        IrisNotificationUserMrJack.ClearAllNotifications()
    end
    return IrisNotificationMrJack(2, "Executor not Supported! D:", "A Function is Missing!\n\nPlease Download a better Executor!", 10)
end
local vu3 = pcall(function()
    return game:GetService("CoreGui")["keonelibbary/gui"]
end)
local vu4 = {}
local vu5 = nil
local vu6 = nil
local vu7 = nil
local vu8 = nil
local vu9 = nil
local v10 = {}
local vu11 = {}
local vu12 = nil
local v13 = false
if v13 then
    v13 = CreateHookMetaMethod:Index() or CreateHookMetaMethod.Indexes
end
local vu14 = false
pcall(function()
    vu4 = GetSavedSettings("MrJack Settings/" .. vu1 .. ".json", tostring(client.UserId))
end)
local function vu21()
    pcall(function()
        ForLooP(getgc(true), function(_, p15)
            if typeof(p15) == "table" and (rawget(p15, "Utilities") and not (vu5 and vu5.Battle)) then
                vu5 = p15
            end
        end)
    end)
    if not vu5 then
        pcall(function()
            ForLooP(debug.getregistry(), function(_, pu16)
                if typeof(pu16) == "function" and not (vu5 and vu5.Battle) then
                    pcall(function()
                        local v17 = next
                        local v18, v19 = getupvalues(pu16)
                        while true do
                            local vu20
                            v19, vu20 = v17(v18, v19)
                            if v19 == nil then
                                break
                            end
                            if typeof(vu20) == "table" and not (vu5 and vu5.Battle) then
                                pcall(function()
                                    if vu20.Utilities then
                                        vu5 = vu20
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
    while not vu5 do
        vu21()
        if vu5 and not vu3 then
            return
        end
        if not vu6 then
            vu6 = AbstractPooNotif():notify({
                Title = "Notification",
                Description = "Waiting for Game to Load...",
                Length = 9000000000
            })
        end
        if vu3 then
            while task.wait() do
            end
        end
        task.wait(7.5)
    end
end)
if vu6 then
    vu6()
end
wait(0.5)
local function vu22()
    return vu5.Battle.currentBattle
end
local function vu23()
    return vu22().yourSide.active[1]
end
local function vu25()
    local v24
    if vu4["Auto Heal"] then
        if vu9 then
            v24 = false
        else
            v24 = vu5.Network:get("PDS", "areFullHealth")
        end
    else
        v24 = true
    end
    return v24
end
local function vu28()
    local v26 = vu23()
    local v27
    if v26.shiny == vu5.Constants.CORRUPT_GLEAM_NUM then
        v27 = false
    else
        v27 = v26.shiny
    end
    return v27
end
local function vu29()
    return table.find(vu4["Auto Hunt"].Loomians, tostring(vu23().name):lower())
end
local function vu33()
    local v30 = vu22()
    local v31 = vu4["Auto Hunt"]
    if v30 and (v30.kind == "wild" and not vu23().corrupt) then
        local v32 = vu28()
        return v32 == 1 and v31.Gleam or (v32 == 2 and v31.Gamma or (not vu23().owned and v31.NotOwned or vu29()))
    end
end
local function vu37(p34)
    local v35 = vu5.BattleGui
    if vu22().state == "input" and not vu7 then
        if not v35.onMoveClicked then
            v35:mainButtonClicked(1)
        end
        local v36 = v35.moves[p34]
        if v36.energy and (v35.activeMonster.energy < v36.energy and not v35.activeMonster.bypassEnergy) then
            v35.fightSelectionGroup:LoseFocus()
            v35.inputEvent:fire("rest 0")
            v35:exitButtonsMoveChosen()
        elseif not v36.disabled then
            v35:onMoveClicked(p34)
        end
    end
end
local function v39()
    local v38 = vu22()
    if v38 and (v38.CanRun ~= false and vu8) then
        vu5.BattleGui.IdleCameraController:quit(v38)
        v38.ended = true
        v38.BattleEnded:Fire()
    end
end
local vu40 = setthreadcontext
if vu40 then
    vu40 = vu5.Battle.setupScene
end
local vu41 = setthreadcontext or function(_)
end
if vu40 then
    function vu5.Battle.setupScene(...)
        vu41(2)
        return vu40(...)
    end
    local vu42 = vu5.DataManager.loadModule
    function vu5.DataManager.loadModule(...)
        vu41(2)
        return vu42(...)
    end
    local vu43 = vu5.DataManager.loadChunk
    function vu5.DataManager.loadChunk(...)
        vu41(2)
        return vu43(...)
    end
end
LooP(function()
    local v44 = next
    local v45 = vu11
    local v46 = nil
    while true do
        local v47
        v46, v47 = v44(v45, v46)
        if v46 == nil then
            break
        end
        local v48
        if vu5.Menu.shop.shopId then
            v48 = false
        else
            v48 = vu5.Network:get("PDS", "getShop", v47.ShopId)
        end
        if not v48 then
            return
        end
        local v49 = next
        local v50 = nil
        while true do
            local v51
            v50, v51 = v49(v48, v50)
            if v50 == nil then
                break
            end
            v47.Func(v51)
        end
        if v47.CanAutoBuy() then
            for _ = 1, 10 do
                local v52 = next
                local v53 = v47.Enabled
                local v54 = nil
                while true do
                    local v55
                    v54, v55 = v52(v53, v54)
                    if v54 == nil then
                        break
                    end
                    vu5.Network:get("PDS", "buyItem", v54, 1)
                end
            end
        end
    end
end)
LooP(function()
    if vu22() and client.PlayerGui.MainGui:FindFirstChild("BattleGui", true) then
        task.wait(3)
        vu8 = true
        repeat
            wait()
        until not vu22()
    else
        vu8 = false
    end
end)
local vu56 = vu5.Menu.mastery.showProgressUpdate
function vu5.Menu.mastery.showProgressUpdate(...)
    if not vu4.MiscSettings.NoProgress then
        return vu56(...)
    end
end
local v57 = next
local v58 = vu5.Assets.badgeId
local v59 = nil
while true do
    local vu60, v61 = v57(v58, v59)
    if vu60 == nil then
        break
    end
    v59 = vu60
    if typeof(v61) == "number" and (vu60:sub(1, 5) == "Medal" and (vu60:sub(7, 7) == "" and v61 ~= 0)) then
        task.spawn(function()
            while task.wait() do
                local v62 = vu5.DataManager:getModule("BattleTheatre" .. vu60:sub(6, 6))
                if v62 then
                    function v62.EnablePuzzleControls()
                        return true
                    end
                    function v62.enablePuzzleControls()
                        return true
                    end
                end
            end
        end)
    end
end
task.spawn(function()
    local v63 = nil
    while task.wait() and not v63 do
        v63 = vu5.DataManager:getModule("Mining")
    end
    function v63.DecrementBattery()
    end
    function v63.SetBattery()
    end
    local v64 = Instance.new("Model", workspace)
    Instance.new("Highlight", v64)
    while task.wait() do
        local v65 = next
        local v66 = v63.MinePoints
        local v67 = nil
        while true do
            local v68
            v67, v68 = v65(v66, v67)
            if v67 == nil then
                break
            end
            if task.wait() and v68.Part and not (v68.Part:GetAttribute("OnlyOnce") or v68.Part:SetAttribute("OnlyOnce", true)) then
                v68.Part.Parent = v64
            end
        end
    end
end)
function vu5.Menu.options.resetLastUnstuckTick()
end
LooP(function()
    if vu5.MasterControl.WalkEnabled and not vu22() then
        workspace.Camera.FieldOfView = 70
    end
end)
local vu69 = vu5.BattleGui.switchMonster
function vu5.BattleGui.switchMonster(...)
    vu41(2)
    local v70 = ({
        ...
    })[3] == false
    if v70 then
        vu7 = true
    end
    local v71 = {
        vu69(...)
    }
    if v70 then
        vu7 = nil
    end
    return unpack(v71)
end
local v72 = next
local v73, v74 = vu5.Menu.map.getAvailableTravelLocationInfo()
while true do
    local v75
    v74, v75 = v72(v73, v74)
    if v74 == nil then
        break
    end
    table.insert(v10, v75.name)
end
local vu76 = vu5.Battle.doTrainerBattle
function vu5.Battle.doTrainerBattle(...)
    while not vu25() do
        task.wait()
    end
    vu41(2)
    return vu76(...)
end
local vu77 = v2.new(vu1:split(" - ")[1])
vu77:toggle()
local vu78 = vu77.addPage
function vu77.addPage(...)
    task.wait(0.5)
    return vu78(...)
end
local v79 = vu77:addPage("Main")
local v80 = v79:addSection("Main")
v80:addToggle("Auto Heal[Outdoor Only]", vu4["Auto Heal"], function(p81)
    vu4["Auto Heal"] = p81
end)
LooP(function()
    xpcall(function()
        local v82 = vu5.DataManager.currentChunk
        if vu4["Auto Heal"] and (vu5.MasterControl.WalkEnabled and (vu5.Menu.enabled and not (v82.indoors or (vu22() or vu5.ObjectiveManager.disabledBy.LoomianCare)))) and not vu5.Network:get("PDS", "areFullHealth") then
            if v82.data.HasOutsideHealers then
                vu5.Network:get("heal", nil, "HealMachine1")
            else
                local v83 = v82.regionData and v82.regionData.BlackOutTo or v82.data.blackOutTo
                local v84 = v82.id
                local v85 = client.character.PrimaryPart.CFrame
                if v83 then
                    local v86 = vu5.MasterControl
                    vu9 = true
                    v86.WalkEnabled = false
                    vu5.Menu:disable()
                    vu5.Menu:fastClose(3)
                    vu5.Utilities.FadeOut(1)
                    task.spawn(function()
                        vu5.NPCChat:Say("[ma][MrJack]Auto healing...")
                    end)
                    vu5.Utilities.TeleportToSpawnBox()
                    v82:unbindIndoorCam()
                    v82:destroy()
                    vu41(2)
                    v82 = vu5.DataManager:loadChunk(v83)
                end
                local v87 = v82:getRoom("HealthCenter", v82:getDoor("HealthCenter"), 1)
                local v88 = vu5.Network
                local v89 = v88.get
                local v90 = task.wait()
                local v91 = v89(v88, "getHealer", v90 and "HealthCenter" or v90)
                if v91 then
                    vu5.Network:get("heal", "HealthCenter", v91)
                end
                v87:Destroy()
                if v83 then
                    v82:destroy()
                    vu5.DataManager:loadChunk(v84)
                    vu5.Utilities.Teleport(v85)
                    vu5.Menu:enable()
                    vu5.NPCChat:manualAdvance()
                    vu5.Utilities.FadeIn(1)
                    local v92 = vu5.MasterControl
                    vu9 = nil
                    v92.WalkEnabled = true
                end
            end
        end
    end, function(...)
        warn("Main | Auto Heal -", ...)
    end)
end, 0.1)
v80:addToggle("Active Repellent", vu4["Infinite Repel"], function(p93)
    vu4["Infinite Repel"] = p93
end)
LooP(function()
    if vu5.Repel.steps < 10 or (not vu4["Infinite Repel"] or vu12) then
        vu5.Repel.steps = not vu12 and (vu4["Infinite Repel"] and 100) or 0
    end
end)
if vu14 then
    local vu94 = {}
    v80:addToggle("Ignore NPC Battle", vu4["Ignore NPC Battle"], function(p95)
        vu4["Ignore NPC Battle"] = p95
    end)
    local vu96 = vu5.BitBuffer.GetBit
    function vu5.BitBuffer.GetBit(...)
        local v97 = {
            ...
        }
        if not (table.find(vu94, vu5.DataManager.currentChunk.map) or table.clear(vu94)) then
            table.insert(vu94, vu5.DataManager.currentChunk.map)
        end
        if v97[1] == vu5.PlayerData.defeatedTrainers and v97[2] then
            if vu4["Ignore NPC Battle"] and table.find(vu94, v97[2]) then
                return true
            end
            if not table.find(vu94, v97[2]) then
                table.insert(vu94, v97[2])
            end
        end
        vu41(2)
        return vu96(...)
    end
end
if getthreadcontext then
    getthreadcontext()
end
v80:addToggle("Skip Dialogue", vu4["Skip Dialogue"], function(p98)
    vu4["Skip Dialogue"] = p98
end)
local function vu106(_, ...)
    local v99 = {
        ...
    }
    local v100 = {}
    local v101 = nil
    if typeof(v99[2]) == "string" then
        if v99[2]:sub(1, 8) == "[NoSkip]" then
            return {
                v99[1],
                v99[2]:sub(9)
            }, true
        end
        if v99[2]:sub(1, 5):lower() == "[y/n]" then
            if vu4.MiscSettings.NoSwitch and v99[2]:find("Will you switch Loomians") then
                v99[2] = "Auto Deny Swicth Question Enabled!"
            elseif vu4.MiscSettings.NoNick and v99[2]:find("Give a nickname to the") then
                v99[2] = "Auto Deny Nickname Enabled!"
            elseif vu4.MiscSettings.NoNewMoves then
                if v99[2]:find("reassign its moves") then
                    v99[2] = "Auto Deny Reassign Move Enabled!"
                elseif v99[2]:find(" to give up on learning ") then
                    return "Y/N", true
                end
            end
        end
    end
    if vu4["Skip Dialogue"] then
        local v102 = next
        local v103 = nil
        while true do
            local v104
            v103, v104 = v102(v99, v103)
            if v103 == nil then
                break
            end
            if typeof(v104) ~= "string" then
                v100[# v100 + 1] = v104
            else
                local v105
                if v104:sub(1, 5):lower() ~= "[y/n]" then
                    if v104:sub(1, 9):lower() ~= "[gamepad]" then
                        v105 = v104
                    else
                        v105 = v104:sub(10)
                    end
                else
                    v100[# v100 + 1] = v104
                    v105 = v104:sub(6)
                    v101 = true
                end
                if v105:sub(1, 4):lower() == "[ma]" or v105:sub(1, 5) == "[pma]" then
                    v100[# v100 + 1] = v104
                    v101 = true
                end
            end
        end
    else
        v100 = v99
        v101 = true
    end
    return v100, v101
end
local function v112(p107, pu108)
    local vu109 = p107[pu108]
    p107[pu108] = function(...)
        local v110, v111 = vu106(pu108, ...)
        if v110 == "Y/N" then
            return v111
        end
        if v111 then
            vu41(2)
            local _ = unpack
        end
    end
end
v112(vu5.BattleGui, "message")
v112(vu5.NPCChat, "Say")
v112(vu5.NPCChat, "say")
v80:addToggle("Fast Battle", vu4["Fast Battle"], function(p113)
    vu4["Fast Battle"] = p113
end)
local v114 = next
local v115 = {
    [vu5.BattleClientSprite] = {
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
    [vu5.BattleClientSide] = {
        switchOut = 1,
        faint = 1,
        swapTo = 1,
        dragIn = 1
    }
}
local v116 = nil
local function v123(p117, p118, pu119)
    local vu120 = p118[p117]
    if vu120 then
        p118[p117] = function(...)
            vu41(2)
            local v121 = {
                ...
            }
            v121[pu119].battle.fastForward = vu4["Fast Battle"]
            local v122 = {
                vu120(unpack(v121))
            }
            v121[pu119].battle.fastForward = false
            return unpack(v122)
        end
    end
end
while true do
    local v124
    v116, v124 = v114(v115, v116)
    if v116 == nil then
        break
    end
    local v125 = next
    local v126 = v116
    local v127 = nil
    while true do
        local v128
        v127, v128 = v125(v124, v127)
        if v127 == nil then
            break
        end
        v123(v127, v126, v128)
    end
end
local v129 = next
local v130 = {
    [vu5.BattleGui] = {
        "animWeather",
        "animStatus",
        "animAbility",
        "animBoost",
        "animHit",
        "animMove"
    }
}
local v131 = nil
local function v135(p132, p133)
    local vu134 = p133[p132]
    if vu134 then
        p133[p132] = function(...)
            vu41(2)
            local _ = vu4["Fast Battle"]
        end
    end
end
while true do
    local v136
    v131, v136 = v129(v130, v131)
    if v131 == nil then
        break
    end
    local v137 = next
    local v138 = v131
    local v139 = nil
    while true do
        local v140
        v139, v140 = v137(v136, v139)
        if v139 == nil then
            break
        end
        v135(v140, v138)
    end
end
local vu141 = vu5.BattleGui.setCameraIfLookingAway
function vu5.BattleGui.setCameraIfLookingAway(p142, p143)
    p143.fastForward = vu4["Fast Battle"]
    local v144 = {
        vu141(p142, p143)
    }
    p143.fastForward = false
    return unpack(v144)
end
local vu145 = vu5.RoundedFrame.setFillbarRatio
function vu5.RoundedFrame.setFillbarRatio(...)
    local v146 = {
        ...
    }
    if vu4["Fast Battle"] and vu22() then
        v146[3] = false
    end
    return vu145(unpack(v146))
end
if vu14 then
    v80:addButton("End Battle", v39)
end
if v13 then
    v13.WalkSpeed = v13.WalkSpeed or {}
    table.insert(v13.WalkSpeed, function(_, p147)
        local v148 = p147[1]
        local v149 = client.Character
        if v149 then
            v149 = client.Character:FindFirstChild("Humanoid")
        end
        if v148 == v149 then
            return true, 16
        end
    end)
    v80:addSlider("WalkSpeed", vu4.WalkSpeed or 16, 0, 250, 0.1, function(p150)
        vu4.WalkSpeed = p150
    end)
    LooP(function()
        if vu4.WalkSpeed and vu4.WalkSpeed ~= 0 then
            client.Character.Humanoid.WalkSpeed = vu4.WalkSpeed or 16
        elseif vu4.WalkSpeed == 0 then
            local v151 = client.Character.Humanoid
            vu4.WalkSpeed = nil
            v151.WalkSpeed = 16
        end
    end)
end
local v152 = v79:addSection("GUIs")
v152:addButton("Open Rally Team", function()
    vu5.Menu:disable()
    vu5.Menu.rally:openRallyTeamMenu()
    vu5.Menu:enable()
end)
v152:addButton("Open Rallied", function()
    pcall(function()
        if vu5.Network:get("PDS", "ranchStatus").rallied > 0 then
            vu5.Menu:disable()
            vu5.Menu.rally:openRalliedMonstersMenu()
            vu5.Menu:enable()
        end
    end)
end)
v152:addButton("Open PC", function()
    vu5.Menu.pc:bootUp()
end)
v152:addButton("Open Shop", function()
    vu5.Menu:disable()
    vu5.Menu.shop:open()
    vu5.Menu:enable()
end)
v152:addButton("Junk 4 Junk", function()
    vu5.Menu:disable()
    vu5.Menu.shop:open("fishtrash")
    vu5.Menu:enable()
end)
local v153 = vu77:addPage("Misc")
if not vu4.MiscSettings then
    vu4.MiscSettings = {}
end
local vu154 = v153:addSection("Misc Settings")
local vu155 = vu4.MiscSettings
local function v159(p156, pu157)
    vu154:addToggle(p156, vu155[pu157], function(p158)
        vu155[pu157] = p158
    end)
end
v159("Deny Reassign Move", "NoNewMoves")
v159("Deny Switch Request", "NoSwitch")
v159("Deny Nickname Request", "NoNick")
v159("Disable Show Progress", "NoProgress")
local v160 = v153:addSection("Auto Fish")
v160:addToggle(vu40 and "Enabled" or "Enabled(will only get items)", vu4.AutoFish, function(p161)
    vu4.AutoFish = p161
end)
if vu40 then
    v160:addToggle("Items Only", vu4.AutoFish, function(p162)
        vu4.AutoFishOnlyItems = p162
    end)
end
local vu163 = vu5.Fishing.OnWaterClicked
local vu164 = nil
LooP(function()
    pcall(function()
        if vu164 and not vu164:IsDescendantOf(workspace) then
            vu164 = nil
        end
        ForLooP(vu5.DataManager.currentChunk.map:GetChildren(), function(_, p165)
            if p165.Name ~= "Water" or not p165 then
                p165 = p165:FindFirstChild("Water")
            end
            if task.wait() and (p165 and p165:FindFirstChild("Mesh")) then
                vu164 = p165
            end
        end)
    end)
end)
function vu5.Fishing.FishMiniGame(p166, _, _, p167, p168)
    local v169 = vu5.DataManager.currentChunk.regionData.Fishing
    local v170 = next
    local v171 = vu5.DataManager.currentChunk.regionData
    local v172 = nil
    while true do
        local v173
        v172, v173 = v170(v171, v172)
        if v172 == nil then
            break
        end
        if not v169 and (typeof(v173) == "table" and v172 == "Fishing") then
            if v173.id then
                v169 = v173
            end
        end
    end
    local v174 = next
    local v175 = vu5.DataManager.currentChunk.data.regions
    local v176 = nil
    while true do
        local v177
        v176, v177 = v174(v175, v176)
        if v176 == nil then
            break
        end
        local v178 = next
        local v179 = nil
        while true do
            local v180
            v179, v180 = v178(v177, v179)
            if v179 == nil then
                break
            end
            if not v169 and (typeof(v180) == "table" and v179 == "Fishing") then
                if v180.id then
                    v169 = v180
                end
            end
        end
    end
    local v181
    if v169 then
        v181 = v169.id
    else
        v181 = v169
    end
    if vu164 and v181 then
        local v182 = vu5.Fishing.rod
        local v183
        if p166 == "MrJack" then
            local v184 = vu164.Position + Vector3.new(0, vu164.Size.Y - 5, 0)
            local v185 = nil
            local v186 = RaycastParams.new()
            v186.FilterDescendantsInstances = {
                workspace.Terrain
            }
            v186.IgnoreWater = false
            v186.FilterType = Enum.RaycastFilterType.Whitelist
            local v187 = workspace:Raycast(v184 + Vector3.new(0, 3, 0), Vector3.new(0.001, - 10, 0.001), v186)
            if v187 and v187.Material == Enum.Material.Water then
                v184 = v187.Position
            end
            if v182 then
                v182.postPoseUpdates = true
            else
                local v188
                v188, v185 = vu5.Network:get("PDS", "fish", v184, v181)
                v182 = v188 and {
                    model = v188,
                    bobberMain = v188.Bobber.Main,
                    string = v188.Bobber.Main.String
                } or v182
                vu5.Fishing.rod = v182
            end
            v183 = not v185 and select(2, vu5.Network:get("PDS", "fish", v184, v181))
            if v183 then
                vu5.Fishing.rod.postPoseUpdates = v183.rep
            end
            if v182 and v182.model then
                v182.model.Parent = nil
            end
        else
            v183 = {
                id = p168,
                delay = true
            }
        end
        if v183 and v183.delay then
            return 0.9, vu5.Network:get("PDS", "fshchi", p167 or v183.id), v169
        else
            return false
        end
    else
        return false
    end
end
function vu5.Fishing.OnWaterClicked(...)
    if vu5.MasterControl.WalkEnabled then
        if vu4.AutoFish then
            return IrisNotificationMrJack(1, "Notification", "Please Turn Off Auto Fish.", 2)
        end
        vu41(2)
        return vu163(...)
    end
end
LooP(function()
    pcall(function()
        if vu4.AutoFish and vu5.PlayerData.completedEvents.mabelRt8 then
            local v189, v190, v191 = vu5.Fishing.FishMiniGame("MrJack")
            if v189 and vu4.AutoFish then
                if v190 == true and (vu40 and not vu4.AutoFishOnlyItems) then
                    vu5.Battle:doWildBattle(v191, {
                        dontExclaim = true,
                        fshPct = v189
                    })
                else
                    vu5.Network:post("PDS", "reelIn")
                end
                task.wait(0.5)
            end
            vu5.Fishing:DisableRodModel(v190 ~= true and true or nil)
        end
    end)
end)
local v192, vu193 = v153:addSection("Auto Disc Drop")
v192:addToggle("Enabled", nil, function(p194)
    vu193 = p194
end)
v192:addToggle("Fast Mode", vu4.FastDiscDrop, function(p195)
    vu4.FastDiscDrop = p195
end)
task.spawn(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/thedragonslayer2/MrJack-Game-List/main/Functions/Loomian%20Legacy%20-%20306964494/Disc%20Drop.lua"))()
    local vu196, vu197 = getgenv().LoomianLegacyAutoDisDrop(vu4, vu5)
    LooP(function()
        pcall(function()
            if vu193 and (vu5.ArcadeController.playing and vu197()) and vu197().gui.GridFrame:IsDescendantOf(client.PlayerGui) then
                if vu197().gameEnded then
                    vu197():CleanUp()
                    vu197():new()
                else
                    vu196()
                end
            end
        end)
    end)
end)
if not vu4["Auto Hunt"] then
    vu4["Auto Hunt"] = {}
end
local v198 = vu77:addPage("Auto Hunt")
local vu199 = vu4["Auto Hunt"]
local vu200 = v198:addSection("Auto Hunt")
local v201 = debug.getinfo or getgenv().getinfo
local v202, v203, v204 = pairs(getupvalues(vu5.WalkEvents.beginLoop))
local vu205 = nil
local vu206 = {}
local vu207 = {}
local vu208 = nil
local vu209 = {}
local vu210 = nil
while true do
    local v211
    v204, v211 = v202(v203, v204)
    if v204 == nil then
        break
    end
    if typeof(v211) == "function" and (v201 and v201(v211).name == "onStepTaken") then
        vu205 = v211
    end
end
vu200:addToggle("Auto Encounter", nil, function(p212)
    vu12 = p212
end)
LooP(function()
    pcall(function()
        if vu5.MasterControl.WalkEnabled and (vu12 and (vu5.Menu.enabled and (not vu22() and (vu5.PlayerData.completedEvents.ChooseBeginner and vu25())))) then
            vu205(true)
        end
    end)
end)
local v213
if vu14 then
    v213 = nil
else
    v213 = vu199.Disc or nil
end
vu199.Disc = v213
local vu214
if vu14 then
    vu214 = vu200:addDropdown(vu199.Disc or "Select Disc", vu206, function(p215)
        vu199.Disc = p215
    end)
else
    vu214 = vu14
end
LooP(function()
    pcall(function()
        local v216 = vu5.Network:get("PDS", "getBagPouch", 3)
        local v217 = next
        local v218 = nil
        local v219 = {}
        local v220 = nil
        local v221 = nil
        while true do
            local v222
            v218, v222 = v217(v216, v218)
            if v218 == nil then
                break
            end
            if not table.find(vu206, v222.name) then
                table.insert(vu206, v222.name)
                vu209[v222.name] = v222.id
                v220 = true
            end
            v221 = vu199.Disc and v222.name == vu199.Disc and true or v221
            if not vu207[v222.name] then
                local v223 = vu210
                vu207[v222.name] = v223:addButton("")
            end
            vu210:updateButton(vu207[v222.name], v222.name .. ": " .. v222.qty)
            table.insert(v219, v222.name)
        end
        local v224 = next
        local v225 = vu206
        local v226 = nil
        while true do
            local v227
            v226, v227 = v224(v225, v226)
            if v226 == nil then
                break
            end
            if not table.find(v219, v227) then
                vu210:updateButton(vu207[v227], v227 .. ": 0")
                return table.remove(vu206, v226)
            end
        end
        if v220 or not v221 then
            if not v221 then
                vu199.Disc = nil
            end
            if vu14 then
                vu200:updateDropdown(vu214, vu199.Disc or "Select Disc", vu206, function(p228)
                    vu199.Disc = p228
                end, true)
            end
        end
    end)
end)
if vu14 then
    task.wait(0.1)
    local function v232(p229, pu230)
        vu200:addToggle(p229, vu199[pu230], function(p231)
            vu199[pu230] = p231
        end)
    end
    v232("Use Spare", "Spare")
    v232("Catch Not Owned", "NotOwned")
    v232("Catch Normal Gleam", "Gleam")
    v232("Catch Gamma Gleam", "Gamma")
    if not vu199.Loomians then
        vu199.Loomians = {}
    end
    local vu233 = v198:addSection("Catch Listed Loomians")
    local vu234 = vu199.Loomians
    local vu235 = nil
    local function vu237(p236)
        table.remove(vu234, table.find(vu234, p236))
        task.delay(0.25, function()
            vu233:updateDropdown(vu235, "List", vu234, vu237, true)
        end)
    end
    local v238 = vu233
    vu235 = vu233.addDropdown(v238, "List", vu234, vu237)
    local v239 = vu233
    vu233.addTextbox(v239, "Add Loomian", "Name", function(p240, p241)
        if p241 then
            if not table.find(vu234, p240:lower()) then
                table.insert(vu234, p240:lower())
            end
            vu233:updateDropdown(vu235, "List", vu234, vu237, true)
        end
    end)
    task.wait(0.1)
    local v242 = v198:addSection("Defeat Corrupt")
    local v243 = {
        "Disabled"
    }
    for v244 = 1, 4 do
        table.insert(v243, "Move " .. v244)
    end
    if not vu199.CorruptMove then
        vu199.CorruptMove = "Disabled"
    end
    v242:addDropdown(vu199.CorruptMove, v243, function(p245)
        vu199.CorruptMove = p245
    end)
    local v246 = v198:addSection("Mode")
    local v247 = {
        "Disabled",
        "Run"
    }
    for v248 = 1, 4 do
        table.insert(v247, "Move " .. v248)
    end
    v246:addDropdown("Disabled", v247, function(p249)
        vu208 = p249
    end)
end
local vu250 = v198:addSection("Auto Buy Disc")
local vu251 = {}
local vu253 = {
    CanAutoBuy = function()
        return true
    end,
    Enabled = {},
    Func = function(p252)
        if p252.name and p252.id and (p252.id:sub(# p252.id - 3, # p252.id) == "disc" and (typeof(p252.price) == "number" and not vu251[p252.name])) then
            vu251[p252.name] = p252
        end
    end
}
LooP(function()
    local v254 = next
    local v255 = vu251
    local v256 = nil
    while true do
        local vu257
        v256, vu257 = v254(v255, v256)
        if v256 == nil then
            break
        end
        if typeof(vu257) ~= "Instance" then
            local v258 = vu250
            vu251[vu257.name] = v258:addToggle(vu257.name, nil, function(p259)
                vu253.Enabled[vu257.id] = p259 or nil
            end)
        end
    end
end)
table.insert(vu11, vu253)
LooP(function()
    pcall(function()
        if vu22().state == "input" and (vu12 and vu14) then
            local v260 = vu23()
            if vu33() then
                local v261 = next
                local v262 = vu5.BattleGui.moves
                local v263 = nil
                while true do
                    local v264
                    v263, v264 = v261(v262, v263)
                    if v263 == nil then
                        break
                    end
                    if v264.move == "Spare" and (vu199.Spare and v260.hp / v260.maxhp > 0.2) then
                        return vu37(v263)
                    end
                end
                if vu7 or not vu209[vu199.Disc] then
                    return
                end
                vu5.BattleGui:exitButtonsMain()
                vu5.BattleGui.inputEvent:fire("useitem " .. vu209[vu199.Disc])
            elseif v260.corrupt and vu199.Corrupt ~= "Disabled" then
                vu37(tonumber(vu199.CorruptMove:split(" ")[2]))
            elseif vu208 and vu208 ~= "Disabled" then
                if vu208 ~= "Run" then
                    local v265 = vu208
                    vu37(tonumber(v265:split(" ")[2]))
                elseif vu22() and (vu22().CanRun ~= false and vu8) then
                    vu5.BattleGui:mainButtonClicked(4)
                end
            end
        end
    end)
end)
local _ = v198:addSection("Discs Counter")
if vu14 then
    if not vu4.AutoRally then
        vu4.AutoRally = {}
    end
    local v266 = vu77:addPage("Auto Rally"):addSection("Auto Rally")
    v266:addToggle("Enabled", vu4.AutoRally.Enabled, function(p267)
        vu4.AutoRally.Enabled = p267
    end)
    v266:addToggle("Keep All", vu4.AutoRally.All, function(p268)
        vu4.AutoRally.All = p268
    end)
    v266:addToggle("Keep Gleaming", vu4.AutoRally.Gleaming, function(p269)
        vu4.AutoRally.Gleaming = p269
    end)
    v266:addToggle("Keep Hidden Ability", vu4.AutoRally["Hidden Ability"], function(p270)
        vu4.AutoRally["Hidden Ability"] = p270
    end)
    v266:addDropdown(vu4.AutoRally.x40Tab or "x40 keep Disabled", {
        "x40 keep Disabled",
        "3x40 and Higher",
        "4x40 and Higher",
        "5x40 and Higher",
        "6x40 and Higher",
        "7x40 Only"
    }, function(p271)
        vu4.AutoRally.x40Tab = p271
        local v272 = p271 == "x40 keep Disabled" and 8 or p271:sub(1, 1)
        vu4.AutoRally.x40 = tonumber(v272)
    end)
    LooP(function()
        pcall(function()
            if vu4.AutoRally.Enabled then
                local vu273 = vu5.Network:get("PDS", "getRallied")
                local vu274 = {}
                local vu275 = {}
                local v276 = vu273.monsters
                if v276 and v276[1] then
                    local v277 = next
                    local v278 = nil
                    while true do
                        local v279, v280 = v277(v276, v278)
                        if v279 == nil then
                            break
                        end
                        local v281 = next
                        local v282 = v280.summ.ivr
                        v278 = v279
                        local v283 = nil
                        local v284 = 0
                        while true do
                            local v285
                            v283, v285 = v281(v282, v283)
                            if v283 == nil then
                                break
                            end
                            if v285 == 6 then
                                v284 = v284 + 1
                            end
                        end
                        if vu4.AutoRally.All or v280.gl and vu4.AutoRally.Gleaming then
                            vu275[v279] = 2
                        elseif v280.sa and vu4.AutoRally["Hidden Ability"] then
                            vu275[v279] = 2
                        elseif vu4.AutoRally.x40 and vu4.AutoRally.x40 <= v284 then
                            vu275[v279] = 2
                        else
                            vu275[v279] = 1
                        end
                    end
                    local v287 = {
                        function()
                            vu5.DataManager:setLoading(vu274, true)
                            local v286 = vu5.Network:get("PDS", "handleRallied", vu275)
                            vu5.DataManager:setLoading(vu274, false)
                            if v286 then
                                vu5.Menu.rally.ralliedCount = v286
                                if vu5.Menu.rally.updateNPCBubble then
                                    vu5.Menu.rally.updateNPCBubble(v286)
                                end
                            end
                        end,
                        function()
                            if vu273.mastery then
                                vu5.Menu.mastery:showProgressUpdate(vu273.mastery, false)
                            end
                        end
                    }
                    vu5.Utilities.Sync(v287)
                end
            end
        end)
    end)
end
local v288 = vu77:addPage("Auto Battle")
if not vu4.AutoBattle then
    vu4.AutoBattle = {}
end
local v289 = v288:addSection("Auto Move")
vu4.Move = "Disabled"
local v290 = {
    "Disabled"
}
for v291 = 1, 4 do
    table.insert(v290, "Move " .. v291)
end
v289:addDropdown("Disabled", v290, function(p292)
    vu4.Move = p292
end)
LooP(function()
    pcall(function()
        if client.PlayerGui.MainGui:FindFirstChild("BattleGui", true) and (string.find(vu4.Move, "Move") and vu22().kind ~= "wild") then
            vu37(tonumber(vu4.Move:split(" ")[2]))
        end
    end)
end)
local vu293 = v288:addSection("Auto Battle")
local vu294 = "Disabled"
local vu295 = {
    "Disabled"
}
local vu296 = {}
local vu297 = {}
local vu298 = {}
local function vu312(_, pu299)
    pcall(function()
        local v300 = vu5.DataManager.currentChunk.battles
        local v301 = pu299.model:FindFirstChild("#Battle") and pu299.model["#Battle"].Value or "Mrjack"
        local v302
        if v300 then
            v302 = v300[tostring(v301)] or v300[v301]
        else
            v302 = v300
        end
        if task.wait() and (v302 and v302.RematchQuestion) then
            local v303 = next
            local v304 = nil
            local v305 = {}
            while true do
                local v306
                v304, v306 = v303(v300, v304)
                if v304 == nil then
                    break
                end
                table.insert(v305, v306.Name)
            end
            local v307 = next
            local v308 = vu295
            local v309 = nil
            while true do
                local v310
                v309, v310 = v307(v308, v309)
                if v309 == nil then
                    break
                end
                if v310 ~= "Disabled" and not table.find(v305, v310) then
                    table.remove(vu295, v309)
                end
            end
            vu298[v302.Name] = tostring(v301)
            local v311 = {
                opponentBaseNPC = pu299,
                trainer = v302
            }
            vu296[v302.Name] = v311
            if not table.find(vu295, v302.Name) and (vu40 or not vu5.DataManager.currentChunk.regionData.BattleScene) then
                table.insert(vu295, v302.Name)
            end
        end
    end)
end
local v313 = vu293
local vu315 = vu293.addDropdown(v313, vu297[1], vu297, function(p314)
    vu294 = p314
end)
LooP(function()
    ForLooP(vu5.CollectionManager:GetNPCs(), vu312)
end)
LooP(function()
    pcall(function()
        local v316 = # vu295 ~= # vu297
        local v317 = next
        local v318 = vu297
        local v319 = nil
        local v320 = true
        while true do
            local v321
            v319, v321 = v317(v318, v319)
            if v319 == nil then
                break
            end
            if not table.find(vu295, v321) then
                v316 = true
            end
        end
        local v322 = next
        local v323 = vu5.DataManager.currentChunk.battles
        local v324 = nil
        while true do
            local v325
            v324, v325 = v322(v323, v324)
            if v324 == nil then
                break
            end
            v320 = false
        end
        if v320 and (# vu295 ~= 1 or not table.find(vu295, "Disabled")) and not table.clear(vu295) then
            table.insert(vu295, "Disabled")
        elseif v316 and not table.clear(vu297) then
            local v326 = next
            local v327 = vu295
            local v328 = nil
            while true do
                local v329
                v328, v329 = v326(v327, v328)
                if v328 == nil then
                    break
                end
                table.insert(vu297, v329)
            end
            vu293:updateDropdown(vu315)
            vu293:updateDropdown(vu315, "Disabled", vu295, function(p330)
                vu294 = p330
            end, true)
        elseif vu294 ~= "Disabled" then
            local v331 = vu296[vu294]
            local v332 = vu298[vu294]
            if v331 and v331.opponentBaseNPC.model and (v331.opponentBaseNPC.model:IsDescendantOf(workspace) and vu5.DataManager.currentChunk.battles[v332]) then
                if vu5.MasterControl.WalkEnabled and (not vu22() and (table.find(vu295, vu294) and (vu5.PlayerData.completedEvents.ChooseBeginner and vu25()))) then
                    if v331.trainer.Name == "Tamyra" and vu5.DataManager.currentChunk.id == "chunk20" then
                        v331.fshPct = 0.9
                    end
                    vu5.Battle:doTrainerBattle(v331)
                end
            else
                table.remove(vu295, vu294)
            end
        end
    end, 0.1)
end)
if table.find(v10, "Uhnne Fair") then
    vu4.Event = vu4.Event or {}
    vu4.Event["Uhnne Fair"] = vu4.Event["Uhnne Fair"] or {}
    local v333 = vu77:addPage("Event")
    local vu334 = vu4.Event["Uhnne Fair"]
    local vu335 = {}
    local vu336 = nil
    local v337 = v333:addSection("Main")
    v337:addToggle("Disable Traps", vu334.DisableTraps, function(p338)
        vu334.DisableTraps = p338
    end)
    v337:addButton("Fix Camera", function()
        client.CameraMode = "Classic"
    end)
    v337:addSlider("Brightness", 0, 0, 50, 0.1, function(p339)
        game.Lighting.Brightness = p339
    end)
    local v340 = v333:addSection("ESP")
    v340:addToggle("Nevermare", vu334.NevermareESP, function(p341)
        vu334.NevermareESP = p341
    end)
    v340:addToggle("Key", vu334.KeyESP, function(p342)
        vu334.KeyESP = p342
    end)
    v340:addToggle("Potion", vu334.PotionESP, function(p343)
        vu334.PotionESP = p343
    end)
    v340:addToggle("Candy", vu334.CandyESP, function(p344)
        vu334.CandyESP = p344
    end)
    v340:addToggle("Safe House", vu334.SafeHouseESP, function(p345)
        vu334.SafeHouseESP = p345
    end)
    if game.PlaceId == tonumber("8284266336") then
        local vu346 = {}
        local vu347 = {}
        local vu348 = {}
        local vu349 = vu5.CMazeGameClient.SetupTraps
        function vu5.CMazeGameClient.SetupTraps(p350, p351)
            vu347 = p351
            vu41(2)
            return vu349(p350, p351)
        end
        local vu352 = vu5.CMazeGameClient.SetupLasers
        function vu5.CMazeGameClient.SetupLasers(p353, p354, p355)
            vu335 = p355
            vu348 = p354
            task.spawn(function()
                repeat
                    task.wait()
                until vu5.CMazeGameClient.removeMazeFolder
                task.wait(0.5)
                vu346 = {}
                local v356 = next
                local v357 = vu335
                local v358 = nil
                while true do
                    local v359
                    v358, v359 = v356(v357, v358)
                    if v358 == nil then
                        break
                    end
                    if v359:FindFirstChild("SafeHouse") then
                        table.insert(vu346, v359.SafeHouse)
                    end
                end
            end)
            vu41(2)
            return vu352(p353, p354, p355)
        end
        LooP(function()
            vu336 = vu5.CMazeGameClient.mazeFolder
            pcall(function()
                local v360 = next
                local v361 = vu348
                local v362 = nil
                while true do
                    local v363
                    v362, v363 = v360(v361, v362)
                    if v362 == nil then
                        break
                    end
                    v363.Model.CanTouch = not vu334.DisableTraps
                end
            end)
            pcall(function()
                local v364 = next
                local v365 = vu347
                local v366 = nil
                while true do
                    local v367
                    v366, v367 = v364(v365, v366)
                    if v366 == nil then
                        break
                    end
                    v367.Trigger.CanTouch = not vu334.DisableTraps
                end
            end)
        end)
        local vu368 = Instance.new("Folder", workspace)
        local vu369 = Instance.new("Model", vu368)
        local vu370 = Instance.new("Model", vu368)
        local vu371 = Instance.new("Model", vu368)
        local function vu380(p372, p373, p374)
            local v375 = p372:FindFirstChild("BillboardGui") or Instance.new("BillboardGui", p372)
            local v376 = UDim2.new(1, 200, 1, 30)
            v375.Adornee = p372
            v375.AlwaysOnTop = true
            v375.Size = v376
            local v377 = v375:FindFirstChild("TextLabel") or Instance.new("TextLabel", v375)
            local v378 = Vector2.new(0.5, 0.5)
            local v379 = UDim2.new(0.5, 0, 0.5, 0)
            v377.Visible = p374
            v377.Position = v379
            v377.AnchorPoint = v378
            v377.Size = UDim2.new(1, 0, 1.5, 0)
            v377.Font = "SourceSansBold"
            v377.TextScaled = true
            v377.TextYAlignment = "Top"
            v377.TextStrokeTransparency = 1
            v377.TextTransparency = 0
            v377.TextSize = 100
            v377.Text = "."
            v377.BackgroundTransparency = 1
            v377.TextColor3 = p373
        end
        LooP(function()
            local v381 = next
            local v382 = vu5.CMazeGameClient.cleanupInstances or {}
            local v383 = nil
            while true do
                local v384
                v383, v384 = v381(v382, v383)
                if v383 == nil then
                    break
                end
                local vu385 = v384.model
                if vu385 and task.wait() then
                    pcall(function()
                        if vu385:IsDescendantOf(client.Character) then
                            if vu385.Main:FindFirstChild("BillboardGui") then
                                vu385.Main.BillboardGui:Destroy()
                            end
                        else
                            local v386 = vu371
                            local v387 = Color3.fromRGB(100, 0, 250)
                            local v388 = vu334.PotionESP
                            if vu385.Name ~= "Key" then
                                if vu385.Name == "Candy" then
                                    v386 = vu370
                                    v387 = Color3.fromRGB(250, 140, 5)
                                    v388 = vu334.CandyESP
                                end
                            else
                                v386 = vu369
                                v387 = Color3.fromRGB(102, 255, 255)
                                v388 = vu334.KeyESP
                            end
                            vu380(vu385.Main, v387, v388)
                            vu385.Parent = v386
                        end
                    end)
                end
            end
            pcall(function()
                local v389 = next
                local v390 = vu346
                local v391 = nil
                while true do
                    local v392
                    v391, v392 = v389(v390, v391)
                    if v391 == nil then
                        break
                    end
                    local v393 = v392:FindFirstChild("EnterSafeHouseTrigger")
                    if v393 then
                        v392.Parent = vu368
                        local v394 = vu380
                        local v395 = Color3.fromRGB(80, 255, 0)
                        local v396 = vu336
                        if v396 then
                            v396 = vu334.SafeHouseESP
                        end
                        v394(v393, v395, v396)
                    end
                end
            end)
            pcall(function()
                local v397 = workspace:FindFirstChild("Nevermare")
                if v397 then
                    local v398 = v397:FindFirstChild("RootPart")
                    if v397:FindFirstChild("BB") then
                        v397.Name = "Nevrmare"
                    elseif v398 then
                        vu380(v398, Color3.fromRGB(255, 0, 0), vu334.NevermareESP)
                    end
                end
            end)
        end)
    end
end
local v399 = Color3.fromHSV(tick() % math.random(5) / math.random(5), 1, 1)
local vu400 = vu77:addPage("GUI Theme"):addSection("Colors")
local v401 = vu4.Theme or {}
local v402 = {
    Background = Color3.fromRGB(24, 24, 24),
    Glow = v399,
    Accent = Color3.fromRGB(10, 10, 10),
    LightContrast = Color3.fromRGB(20, 20, 20),
    DarkContrast = Color3.fromRGB(14, 14, 14),
    TextColor = v399
}
vu4.Theme = v401
local v403 = next
local vu404 = v402
local v405 = nil
local vu406 = {}
local function v408(p407)
    return math.clamp(math.ceil(p407.R * 255), 0, 255), math.clamp(math.ceil(p407.G * 255), 0, 255), math.clamp(math.ceil(p407.B * 255), 0, 255)
end
while true do
    local vu409, v410 = v403(v402, v405)
    if vu409 == nil then
        break
    end
    v405 = vu409
    local v411 = vu4.Theme[vu409]
    if v411 then
        v411 = Color3.fromRGB(v408(Color3.new(unpack(vu4.Theme[vu409]:split(", ")))))
    end
    vu406[vu409] = vu400:addColorPicker(vu409, v411 or v410, function(p412)
        vu77:setTheme(vu409, p412)
        vu4.Theme[vu409] = tostring(p412)
    end)
end
vu400:addButton("Reset Theme", function()
    local v413 = next
    local v414 = vu404
    local v415 = nil
    while true do
        local v416
        v415, v416 = v413(v414, v415)
        if v415 == nil then
            break
        end
        vu77:setTheme(v415, v416)
        vu400:updateColorPicker(vu406[v415], v415, v416)
    end
    vu4.Theme = {}
end)
local v417 = vu77:addPage("Other")
local v418 = v417:addSection("Built In Features")
v418:addButton("Skip Battle Theater Puzzles")
v418:addButton("No Unstuck CoolDown")
v418:addButton("Skip Fish MiniGame")
v418:addButton("Infinite UMV Energy")
local v419 = v417:addSection("Teleport")
v419:addButton("Rejoin", function()
    game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId)
end)
v419:addButton("Switch Server", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/thedragonslayer2/Misc/main/Server%20Hop"))()
end)
v419:addButton("Find Most Empty Server", function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/thedragonslayer2/hey/main/Misc./Find%20the%20most%20empty%20server%20script"))()
end)
local v420 = v417:addSection("Other")
v420:addButton("Copy Discord Invite", function()
    setclipboard(DiscordInvite)
    IrisNotificationMrJack(1, "Notification", "Discord Link Copied!", 3)
end)
if IrisNotificationUserMrJack then
    IrisNotificationUserMrJack.ClearAllNotifications()
end
if not passlolbruh then
    return IrisNotificationMrJack(2, "Ui Library Variable Did Not Load!", "Something went wrong,\nPlease Execute again!", 7)
end
v420:addKeybind("Hide/Show Gui", Enum.KeyCode.RightAlt, function()
    vu77:toggle()
end)
local v421 = next
local v422 = nil
while true do
    local v423, v424 = v421(vu404, v422)
    if v423 == nil then
        break
    end
    v422 = v423
    local v425 = vu4.Theme[v423]
    if v425 then
        v425 = Color3.fromRGB(v408(Color3.new(unpack(vu4.Theme[v423]:split(", ")))))
    end
    vu77:setTheme(v423, v425 or v424)
end
vu77:toggle()
vu77:SelectPage(vu77.pages[1], true)