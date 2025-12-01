-- Fonction AUTOFARM inspirée du script (Velocity + TP auto-switch) entre startFarm et endFarm
-- Toggle: getgenv().autofarm = false pour arrêter
-- Appel: startAutoFarm(autoFarmSpeed)  -- speed ~400-600 recommandé (plus haut = plus rapide farm)
-- Assure-toi d'être assis dans VehicleSeat avant !

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local vehicle = workspace.Vehicles:FindFirstChild("AxiomHubs_1")
if not vehicle then
    warn("Voiture AxiomHubs_1 non trouvée !")
    return
end

local vehicleSeat = vehicle:FindFirstChild("VehicleSeat")
if not vehicleSeat then
    warn("VehicleSeat non trouvé !")
    return
end

local vehiclePrimary = vehicle.PrimaryPart or vehicleSeat

local heightY = 39  -- Y fixe +5 (34+5)
local endFarmPos = Vector3.new(-34548, heightY, -32808)
local startFarmPos = Vector3.new(-18223, heightY, -494)
local switchThreshold = 150  -- Dist mini pour switch/TP (studs)
local slightUp = 3  -- Légère montée pour contrer gravité

local function startAutoFarm(speed)
    speed = speed or 500  -- Vitesse défaut (inspiré: 600, mais adapté)
    getgenv().autofarm = true
    print("🚗 AUTOFARM DÉMARRÉ ! Vitesse: " .. speed .. " studs/s | Toggle: getgenv().autofarm = false")

    -- Set network owner ONCE pour control total
    for _, part in pairs(vehicle:GetDescendants()) do
        if part:IsA("BasePart") then
        end
    end

    -- LOOP PRINCIPAL: Velocity constante vers target + auto-switch TP quand arrivé
    spawn(function()
        while getgenv().autofarm do
            local pos = vehiclePrimary.Position
            local distEnd = (pos - endFarmPos).Magnitude
            local distStart = (pos - startFarmPos).Magnitude
            
            local targetPos = (distEnd < distStart) and endFarmPos or startFarmPos
            local otherPos = (distEnd < distStart) and startFarmPos or endFarmPos
            
            -- Direction HORIZONTALE (ignore Y pour height constant)
            local flatTarget = Vector3.new(targetPos.X, pos.Y, targetPos.Z)
            local flatDir = (flatTarget - Vector3.new(pos.X, pos.Y, pos.Z)).Unit
            
            -- Velocity fixe (inspiré du script: constant chaque Heartbeat)
            vehiclePrimary.AssemblyLinearVelocity = flatDir * speed + Vector3.new(0, slightUp, 0)
            vehiclePrimary.AssemblyAngularVelocity = Vector3.new(0, 0, 0)  -- Pas de rotation (droit !)
            
            -- AUTO-SWITCH: Si proche du target → TP près de l'autre point + orient vers lui
            if (targetPos - pos).Magnitude < switchThreshold then
                local tpOffset = Vector3.new(math.random(-40, 40), 0, math.random(-40, 40))
                local tpPos = otherPos + tpOffset  -- TP random près de l'autre
                tpPos = Vector3.new(tpPos.X, heightY, tpPos.Z)  -- Force height fixe
                
                -- Orient vers le nouveau target (l'autre)
                vehiclePrimary.CFrame = CFrame.lookAt(tpPos, otherPos)
                
                print("🔄 Switch TP vers " .. (otherPos == endFarmPos and "endFarm" or "startFarm") .. " !")
                wait(0.2)  -- Petit délai anti-bug
            end
            
            RunService.Heartbeat:Wait()  -- Inspiré: chaque frame (smooth)
        end
        
        -- Cleanup à l'arrêt
        vehiclePrimary.AssemblyLinearVelocity = Vector3.new()
        vehiclePrimary.AssemblyAngularVelocity = Vector3.new()
        print("🛑 AUTOFARM ARRÊTÉ !")
    end)
end

local function stopAutoFarm()
    getgenv().autofarm = false
end

-- Exemples d'utilisation (remplace tes tpAvecVoiture par ça pour farm infini) :
local autoFarmSpeed = 450  -- Augmente pour farm plus rapide (500-600 ok)

-- UNE FOIS pour tester :
startAutoFarm(autoFarmSpeed)

-- OU boucle infinie ? Non besoin, c'est déjà infini ! Toggle off pour stop.
-- getgenv().autofarm = false  -- Pour arrêter n'importe quand