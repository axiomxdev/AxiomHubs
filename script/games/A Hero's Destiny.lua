function scripting()

    -- UI Material ===================================================================================
    local Material                  = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()

    -- Services ======================================================================================
    local Players                   = game:GetService("Players")
    local ReplicatedStorage         = game:GetService("ReplicatedStorage")
    local Workspace                 = game:GetService("Workspace")
    local TweenService              = game:GetService("TweenService")

    -- Variables Services ============================================================================

    --#Players
    local player                    = Players.LocalPlayer

    local character                 = player.Character or player.CharacterAdded:Wait()
    local humanoid                  = character:WaitForChild("Humanoid")
    local humanoidRootPart          = character:WaitForChild("HumanoidRootPart")

    --#Players GUI
    local PlayerGui                 = player:WaitForChild("PlayerGui")
    local GameGui                   = PlayerGui:WaitForChild("GameGui")
    local MenuContainer             = GameGui:WaitForChild("MenuContainer")

    local RebirthMenu               = MenuContainer:WaitForChild("RebirthMenu")
    local RebirthText               = RebirthMenu:WaitForChild("InventoryLabel")

    local HUD                       = MenuContainer:WaitForChild("HUD")
    local LevelBackground           = HUD:WaitForChild("LevelBackground")
    local Level                     = LevelBackground:WaitForChild("TextLabel")

    local AscendMenu                = MenuContainer:GetChildren()[6]
    local AscendText                = AscendMenu:WaitForChild("InventoryLabel")

    local RespawnTimes              = GameGui:WaitForChild("RespawnTimes") 

    --#Workspace
    local Spawns                    = Workspace:WaitForChild("Spawns")

    local WorkspacePlayer           = Workspace[player.Name]
    local Healthbar                 = WorkspacePlayer:WaitForChild(player.Name .. "Healthbar")
    local BG                        = Healthbar:WaitForChild("BG")
    local RankLabel                 = BG:WaitForChild("RankLabel")

    --#ReplicatedStorage
    local Modules                   = ReplicatedStorage:WaitForChild("Modules")
    local Net                       = Modules:WaitForChild("Net")
    local Quest                     = Net:WaitForChild("RE/Quest")
    local CombatEvent               = Net:WaitForChild("RE/CombatEvent")
    local Rebirth                   = Net:WaitForChild("RE/Rebirth")
    local SuperRebirth              = Net:WaitForChild("RE/SuperRebirth")
    local Ascend                    = Net:WaitForChild("RE/Ascend")
    local AscendantRebirth          = Net:WaitForChild("RE/AscendantRebirth")
    local UpgradeAscendantStat      = Net:WaitForChild("RE/UpgradeAscendantStat")

    -- Variables Script ==============================================================================

    getgenv().AutoSuperRebirth      = false
    getgenv().AutoFarmW2            = false
    getgenv().AutoQuest             = false
    getgenv().AutoTrain             = false
    getgenv().AutoRebirthW2         = false

    local QuestToFarm               = 1
    local QuestToFarmW2             = 1
    local QuestLevel                = 1
    local QuestLevelW2              = 1
    local distance_mobs_farm        = 3

    httprequest                     = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

    -- Big Table =====================================================================================

    --#Quest Objectif
    local QuestObjectifW1 = {
        [1]  = {name = "Criminal",             number = 3      },
        [2]  = {name = "Paradiser",            number = 3      },
        [3]  = {name = "Hammerhead",           number = 3      },
        [4]  = {name = "Crablante",            number = 1      },
        [5]  = {name = "Mosquito",             number = 5      },
        [6]  = {name = "Abnormal",             number = 5      },
        [7]  = {name = "Werewolf",             number = 3      },
        [8]  = {name = "Seafolk",              number = 3      },
        [9]  = {name = "SeaKing",              number = 1      },
        [10] = {name = "Sonic",                number = 1      }, 
        [11] = {name = "VaccineMan",           number = 1      },
        [12] = {name = "MosquitoGirl",         number = 1      },
        [13] = {name = "Phoenix",              number = 1      },
        [14] = {name = "Kabuto",               number = 1      },
        [15] = {name = "Gouketsu",             number = 1      },
        [16] = {name = "Boros",                number = 1      },
        [17] = {name = "Charanko",             number = 1      },
        [18] = {name = "Psykos",               number = 1      },
        [19] = {name = "Bahiri",               number = 1      },
        [20] = {name = "Claire",               number = 1      },
        [21] = {name = "Fendstrum",            number = 1      },
        [22] = {name = "Voidlet",              number = 3      },
        [23] = {name = "Void",                 number = 1      },
        [24] = {name = "VoidCrystal",          number = 1      },
        [25] = {name = "HumanMonster",         number = 1      },
        [26] = {name = "GoldenS",              number = 1      },
        [27] = {name = "PlatinumS",            number = 1      },
        [28] = {name = "AwakenedHumanMonster", number = 1      },
        [29] = {name = "Rock",                 number = 1      },
        [30] = {name = "Auroris",              number = 1      },
        [31] = {name = "Kayla",                number = 1      },
        [32] = {name = "CosmicHumanMonster",   number = 1      },
        [33] = {name = "Shinigami",            number = 1      }
    }

    local QuestObjectifW2 = {
        [1]  = {name = "Skyroach",             number = 4      },
        [2]  = {name = "SkyroachKing",         number = 1      },
        [3]  = {name = "WindFairy",            number = 4      },
        [4]  = {name = "SylphQueen",           number = 1      },
        [5]  = {name = "DivineKnight",         number = 4      },
        [6]  = {name = "DivineMagician",       number = 4      },
        [7]  = {name = "DivineBrute",          number = 4      },
        [8]  = {name = "DivineKnightCaptain",  number = 1      },
        [9]  = {name = "ThunderCloud",         number = 4      },
        [10] = {name = "Raijin",               number = 1      },
        [11] = {name = "LunarCultist",         number = 4      },
        [12] = {name = "LunarCore",            number = 1      },
        [13] = {name = "SamuraiDisciple",      number = 4      },
        [14] = {name = "AtomicSamurai",        number = 1      },
        [15] = {name = "CursedStudent",        number = 4      },
        [16] = {name = "CursedKing",           number = 1      },
        [17] = {name = "InfinityMan",          number = 1      },
        [18] = {name = "CatBoy",               number = 4      },
        [19] = {name = "DemonSlime",           number = 1      },
        [20] = {name = "Sdjkfjsdgha",          number = 1      },
        [21] = {name = "EvilCarrot",           number = 1      },
    }

    --#PowerRequierd
    local PowerRequierd = {
        [1]  = {name = "D",                    Value = 0       },
        [2]  = {name = "D+",                   Value = 30      },
        [3]  = {name = "D++",                  Value = 50      },
        [4]  = {name = "C",                    Value = 100     },
        [5]  = {name = "C+",                   Value = 150     },
        [6]  = {name = "C++",                  Value = 200     },
        [7]  = {name = "B",                    Value = 250     },
        [8]  = {name = "B+",                   Value = 300     },
        [9]  = {name = "B++",                  Value = 600     },
        [10] = {name = "A",                    Value = 800     },
        [11] = {name = "A+",                   Value = 1000    },
        [12] = {name = "A++",                  Value = 1400    },
        [13] = {name = "S",                    Value = 1800    },
        [14] = {name = "S+",                   Value = 2200    },
        [15] = {name = "S++",                  Value = 3450    },
        [16] = {name = "X",                    Value = 4250    },
        [17] = {name = "X+",                   Value = 5050    },
        [18] = {name = "X++",                  Value = 7500    },
        [19] = {name = "Champion",             Value = 10000   },
        [20] = {name = "Champion+",            Value = 15000   },
        [21] = {name = "Champion++",           Value = 20000   },
        [22] = {name = "Legend",               Value = 27500   },
        [23] = {name = "Legend+",              Value = 35000   },
        [24] = {name = "Legend++",             Value = 45000   },
        [25] = {name = "Demi-God",             Value = 60000   },
        [26] = {name = "Demi-God+",            Value = 75000   },
        [27] = {name = "Demi-God++",           Value = 100000  },
        [28] = {name = "Deity",                Value = 250000  },
        [29] = {name = "Deity+",               Value = 500000  },
        [30] = {name = "Deity++",              Value = 1000000 },
        [31] = {name = "Divine",               Value = 2000000 },
        [32] = {name = "Divine+",              Value = 3000000 },
        [33] = {name = "Divine++",             Value = 5000000 }
    }

    -- Basic Functions ===============================================================================

    --#Player was killed
    player.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
        humanoid = character:WaitForChild("Humanoid", 5)
        humanoidRootPart = character:WaitForChild("HumanoidRootPart", 5)
    end)

    --#getNil
    local function getNil(name, class)
        for _, v in next, getnilinstances() do
            if v.ClassName == class and v.Name == name then
                return v
            end
        end
        return nil
    end

    --#roundCFrame
    local function roundCFrame(cframe)
        return CFrame.new(math.floor(cframe.X), math.floor(cframe.Y + 0.5), math.floor(cframe.Z))
    end

    --#slideToPosition
    local function slideToPosition(targetCFrame, time)
        local tweenInfo = TweenInfo.new(
            time, -- Durée
            Enum.EasingStyle.Linear, -- Mouvement linéaire
            Enum.EasingDirection.Out,
            0, -- Pas de répétition
            false, -- Pas d'aller-retour
            0 -- Pas de délai
        )
        
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, {
            CFrame = targetCFrame
        })
        
        tween:Play()
        tween.Completed:Wait()
    end

    --#SetWorld
    local function GetWorld(World)
        local PWorld = 1 -- 1 = world 1, 2 = world 2

        if AscendText.Text:find("Descend") then
            PWorld = 2
        end

        if PWorld ~= World then
            getgenv().AutoSuperRebirth = false
            getgenv().AutoQuest = false
            getgenv().AutoTrain = false
            Ascend:FireServer()
            task.wait()
        end
    end

    -- AutoFarm ======================================================================================
    local function handleAutoFarm(QuestLevel, sky)

        -- Récupérer la quête
        local argsQuest = {
            [1] = sky and "GetAscendantQuest" or "GetQuest",
            [2] = QuestLevel
        }

        Quest:FireServer(unpack(argsQuest))

        GetWorld((sky and 2 or 1))

        task.wait(0.3)

        -- Déterminer la table des objectifs en fonction de sky
        local QuestObjectif = sky and QuestObjectifW2 or QuestObjectifW1

        -- Vérifier si la quête existe
        if not QuestObjectif[QuestLevel] then
            warn("Quest level " .. QuestLevel .. " not defined in QuestObjectif!")
            getgenv().AutoQuest = false
            UI.Banner({
                Text = "Quest level " .. QuestLevel .. " not found! AutoFarm stopped."
            })
            return
        end

        -- Parcourir les spawns pour trouver les NPCs
        for _, v in pairs(Spawns:GetChildren()) do
            if v.Name == QuestObjectif[QuestLevel].name and (getgenv().AutoQuest or getgenv().AutoSuperRebirth or getgenv().AutoFarmW2) and v:FindFirstChild(QuestObjectif[QuestLevel].name) then
                local Target = v[QuestObjectif[QuestLevel].name]

                -- Vérifier que le NPC est valide
                if Target:IsA("Model") and Target:FindFirstChild("HumanoidRootPart") then
                    local TargetCFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, 5, distance_mobs_farm)
                    slideToPosition(TargetCFrame, 0.1)

                    -- Attaquer le NPC tant qu'il existe
                    while v.Parent and (getgenv().AutoQuest or getgenv().AutoSuperRebirth or getgenv().AutoFarmW2) do
                        local currentHP = 0

                        -- Extraction des points de vie
                        if Target:FindFirstChild("HumanoidRootPart") and Target.HumanoidRootPart:FindFirstChild("HealthBar") then
                            local HealthBar = Target.HumanoidRootPart.HealthBar
                            if HealthBar:FindFirstChild("BG") and HealthBar.BG:FindFirstChild("TextLabel") then
                                local hpText = HealthBar.BG.TextLabel.Text
                                local extractedHP = hpText:match("HP: ([%d,]+)/")
                                if extractedHP then
                                    currentHP = extractedHP:gsub(",", "") or 0
                                    if tonumber(currentHP) <= 0 then
                                        break 
                                    end
                                else
                                    print("Erreur : Impossible d'extraire les HP.")
                                    break
                                end
                            end
                        end

                        -- Vérifier que le NPC est toujours dans Workspace
                        if not v.Parent or not Target:FindFirstChild("HumanoidRootPart") then
                            print("Le NPC n'est plus valide.")
                            break
                        end

                        -- Mettre à jour la position
                        TargetCFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, 5, distance_mobs_farm)
                        slideToPosition(TargetCFrame, 0)

                        -- Attaquer
                        local argsPunch = {
                            [1] = "PunchHit",
                            [2] = {
                                [1] = Target
                            }
                        }
                        CombatEvent:FireServer(unpack(argsPunch))
                        task.wait()
                    end                    
                end
                task.wait()
            end
        end
        task.wait()
    end

    local function FuncAutoQuest(sky)
        if not Quest or not CombatEvent or not Spawns then
            warn("Required objects not found!")
            return
        end

        while getgenv().AutoQuest do
            handleAutoFarm((sky and QuestLevelW2 or QuestLevel), sky)
            task.wait()
        end
    end

    local function FuncAutoFarmW2()
        while getgenv().AutoFarmW2 do
            task.wait()
            
            -- Recalculer QuestToFarmW2 en fonction du niveau actuel
            local level = tonumber(Level.Text and Level.Text:gsub(',', '') or nil)
            
            if level then
                for i = 1, #PowerRequierd do
                    if PowerRequierd[i].Value <= level then
                        QuestToFarmW2 = i
                    else
                        break
                    end
                end
            end

            if QuestToFarmW2 >= 21 then
                QuestToFarmW2 = 21
            end
            
            local args = {
                [1] = "Authority",
                [2] = 100000
            }
            UpgradeAscendantStat:FireServer(unpack(args))

            for i = QuestToFarmW2, 21 do

                level = tonumber(Level.Text and Level.Text:gsub(',', '') or nil)

                if not getgenv().AutoFarmW2 then
                    break
                end
                
                print(i)
                print(QuestObjectifW2[i].name)

                -- Vérifier si le boss est disponible
                local bossAvailable = true
                if RespawnTimes:FindFirstChild(QuestObjectifW2[i].name) then
                    local text = RespawnTimes[QuestObjectifW2[i].name].TextLabel.Text
                    if (text ~= ' 5:00' and text ~= ' 0:00') then
                        bossAvailable = false
                        print("Boss " .. QuestObjectifW2[i].name .. " not available, trying lower quest")
                    end
                end

                local v = PowerRequierd[i]

                -- Si le boss n'est pas disponible OU le niveau est insuffisant
                if not bossAvailable or not level or v.Value > level then
                    print('Boss unavailable or level too low, searching for available quest')
                    -- Chercher une quête inférieure disponible
                    local foundQuest = false
                    for j = i - 1, 1, -1 do
                        local questAvailable = true
                        if RespawnTimes:FindFirstChild(QuestObjectifW2[j].name) then
                            local questText = RespawnTimes[QuestObjectifW2[j].name].TextLabel.Text
                            if (questText ~= ' 5:00' and questText ~= ' 0:00') then
                                questAvailable = false
                            end
                        end
                        
                        if questAvailable and PowerRequierd[j].Value <= level then
                            QuestToFarmW2 = j
                            print('Found available quest: ' .. j .. ' - ' .. QuestObjectifW2[j].name)
                            handleAutoFarm(j, true)
                            foundQuest = true
                            task.wait()
                            break
                        end
                    end
                    
                    if not foundQuest then
                        print('No available quest found, waiting...')
                        task.wait(5)
                    end
                    break
                else
                    -- Boss disponible et niveau suffisant
                    QuestToFarmW2 = i
                    print('Farming quest: ' .. i)
                    handleAutoFarm(i, true)
                    task.wait()
                end
                task.wait()
            end
            task.wait()
        end
    end

    local function FuncAutoSuperRebirth()
        while getgenv().AutoSuperRebirth do
            local level = tonumber(Level.Text and Level.Text:gsub(',', '') or nil)
            local RankLevel = tonumber(RankLabel.Text:match("%((%d+)%)") or nil) or 0

            -- Fonction pour vérifier et effectuer un rebirth
            local function checkRebirth()
                if RebirthText.Text == "Would you like to Super Rebirth?" then
                    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RE/SuperRebirth"):FireServer()
                    QuestToFarm = 1
                    return true
                elseif RebirthText.Text == "Would you like to Rebirth?" or RebirthText.Text:match("%[%D*%d+%D*%]") then
                    Rebirth:FireServer()
                    QuestToFarm = 1
                    return true
                end
                return false
            end

            -- Si RankLevel < 2, vérifier immédiatement si un rebirth est possible
            if RankLevel < 2 then
                if checkRebirth() then
                    print(RankLevel)
                    task.wait()
                end
            end

            -- Parcourir les quêtes pour farmer
            for i = QuestToFarm, #PowerRequierd do
                if not getgenv().AutoSuperRebirth then
                    break
                end

                print(i)
                print(QuestObjectifW1[i].name)

                local v = PowerRequierd[i]

                -- Si le niveau du joueur est suffisant pour la quête
                if level and v.Value <= level then
                    QuestToFarm = i
                    handleAutoFarm(i, false)
                elseif RankLevel >= 2 and level and v.Value > level then
                    -- Si RankLevel >= 2 et le NPC a un niveau supérieur, tenter un rebirth
                    print(string.format("Required Power: %d | Current Level: %d | Needs More Power: %s", v.Value, level, tostring(v.Value > level)))
                    if checkRebirth() then
                        task.wait(1)
                        break
                    end
                else
                    -- Si le niveau est trop bas, farmer une quête précédente
                    for j = i - 1, 1, -1 do
                        if PowerRequierd[j].Value <= level then
                            QuestToFarm = j
                            handleAutoFarm(j, false)
                            break
                        end
                    end
                    break
                end
                task.wait()
            end
            task.wait()
        end
    end

    local function FuncAutoRebirthW2()
        while getgenv().AutoRebirthW2 do
            AscendantRebirth:FireServer()
            task.wait(0.1)
        end
    end

    -- AutoTrain =====================================================================================
    local function FuncAutoTrain()
        if not CombatEvent then
            warn("CombatEvent not found!")
            return
        end

        while getgenv().AutoTrain do
            local args = {
                [1] = "Train"
            }
            CombatEvent:FireServer(unpack(args))
            task.wait()
        end
    end

    -- UI Material Create ============================================================================
    local UI = Material.Load({
        Title = " Axiom's Hub | " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
        Style = 1,
        SizeX = 500,
        SizeY = 350,
        Theme = "Dark"
    })

    local AutoFarmPageW1 = UI.New({
        Title = "AutoFarm World 1"
    })

    local AutoTrainStart = AutoFarmPageW1.Toggle({
        Text = "Auto Train",
        Callback = function(value)
            getgenv().AutoTrain = value
            if value then
                spawn(function() FuncAutoTrain() end)
            end
        end
    })

    local AutoFarmQuestSelectW1 = AutoFarmPageW1.TextField({
        Text = "Select Quest <Number>",
        Callback = function(Value)
            local number = tonumber(Value)
            if not number or number <= 0 then
                UI.Banner({
                    Text = "Please enter a valid quest number greater than 0 !"
                })
                return
            elseif number > 33 then
                UI.Banner({
                    Text = "The last quest is 33"
                })
                return
            end
            QuestLevel = number
            UI.Banner({
                Text = "Quest number set to " .. number
            })
        end
    })

    local AutoQuestStartNPCW1 = AutoFarmPageW1.Toggle({
        Text = "Auto Quest NPC",
        Callback = function(value)
            if not getgenv().AutoSuperRebirth then
                getgenv().AutoQuest = value
                if value then
                    spawn(function() FuncAutoQuest(false) end)
                end
            elseif value then
                UI.Banner({
                    Text = "Please disable AutoFarm Super Rebirth first"
                })
            end
        end
    })

    local AutoFarmRebirthW1 = AutoFarmPageW1.Toggle({
        Text = "AutoFarm Super Rebirth",
        Callback = function(value)
            if not getgenv().AutoQuest then
                getgenv().AutoSuperRebirth = value
                if value then
                    spawn(function() FuncAutoSuperRebirth() end)
                end
            elseif value then
                UI.Banner({
                    Text = "Please disable Auto Quest NPC first"
                })
            end
        end,
        Menu = {
            Reset = function(self)
                QuestToFarm = 1
                if getgenv().AutoSuperRebirth then
                    getgenv().AutoSuperRebirth = false
                    task.wait(1)
                    getgenv().AutoSuperRebirth = true
                    spawn(function() FuncAutoSuperRebirth() end)
                end
                UI.Banner({
                    Text = "AutoFarm Super Rebirth has been reset"
                })
            end
        }
    })

    local AutoFarmPageW2 = UI.New({
        Title = "AutoFarm World 2"
    })

    local AutoFarmQuestSelectW2 = AutoFarmPageW2.TextField({
        Text = "Select Quest <Number>",
        Callback = function(Value)
            local number = tonumber(Value)
            if not number or number <= 0 then
                UI.Banner({
                    Text = "Please enter a valid quest number greater than 0 !"
                })
                return
            elseif number > 21 then
                UI.Banner({
                    Text = "The last quest is 21"
                })
                return
            end
            QuestLevelW2 = number
            UI.Banner({
                Text = "Quest number set to " .. number
            })
        end
    })

    local AutoQuestStartNPCW2 = AutoFarmPageW2.Toggle({
        Text = "Auto Quest NPC",
        Callback = function(value)
            if not getgenv().AutoFarmW2 then
                getgenv().AutoQuest = value
                if value then
                    spawn(function() FuncAutoQuest(true) end)
                end
            elseif value then
                UI.Banner({
                    Text = "Please disable Auto Rebirth first"
                })
            end
        end
    })

    local AutoFarmRebirthW2 = AutoFarmPageW2.Toggle({
        Text = "AutoFarm Mobs",
        Callback = function(value)
            if not getgenv().AutoQuest then
                getgenv().AutoFarmW2 = value
                if value then
                    spawn(function() FuncAutoFarmW2() end)
                end
            elseif value then
                UI.Banner({
                    Text = "Please disable Auto Quest NPC first"
                })
            end
        end,
        Menu = {
            Reset = function(self)
                QuestToFarmW2 = 1
                if getgenv().AutoFarmW2 then
                    getgenv().AutoFarmW2 = false
                    task.wait(1)
                    getgenv().AutoFarmW2 = true
                    spawn(function() FuncAutoFarmW2() end)
                end
                UI.Banner({
                    Text = "AutoFarm Rebirth has been reset"
                })
            end
        }
    })

    local AutoRebirthW2_ = AutoFarmPageW2.Toggle({
        Text = "AutoRebirth",
        Callback = function(value)
            getgenv().AutoRebirthW2 = value
            if value then
                spawn(function() FuncAutoRebirthW2() end)
            end
        end,
    })

    local AutoFarmSetting = UI.New({
        Title = "AutoFarm Settings"
    })

    local AutoFarmDistance = AutoFarmSetting.Slider({
        Text = "AutoFarm Distance",
        Callback = function(value)
            distance_mobs_farm = value
        end,
        Min = 0,
        Max = 50,
        Def = 3,
    })

    local Misc = UI.New({
        Title = "Misc"
    })

    local ServerHop = Misc.Button({
        Text = " 🔄 Server Hop", -- Icône et texte plus clair
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/thedragonslayer2/Misc/main/Server%20Hop"))()
        end
    })

    local AntiAFK = Misc.Button({
        Text = " 🎮 Anti AFK",
        Callback = function()
            local success, result = pcall(function()
                loadstring(game:HttpGet("https://axiomhub.eu/lua/tools/antiafk.lua"))()
            end)
            if not success then
                UI.Banner({
                    Text = "Failed to load Anti-AFK script ! Try other exploit !"
                })
            else
                UI.Banner({
                    Text = "Anti-AFK script loaded!"
                })
            end
        end
    })

    local Discord = Misc.Button({
        Text = " 🌐 Discord",
        Callback = function()
            local discordLink = "https://discord.gg/wx9gV9Z7Yy"

            local function copyToClipboard()
                local success, result = pcall(function()
                    setclipboard(discordLink)
                end)
                
                if success then
                    UI.Banner({Text = "Discord link copied to clipboard!"})
                else
                    UI.Banner({Text = "Failed to copy Discord link!"})
                end
            end

            if httprequest then
                local success, result = pcall(function()
                    local url = "http://127.0.0.1:6463/rpc?v=1"
                    local headers = {
                        ["Content-Type"] = "application/json",
                        Origin = "https://discord.com"
                    }
                    local body = HttpService:JSONEncode({
                        cmd = "INVITE_BROWSER",
                        nonce = HttpService:GenerateGUID(false),
                        args = {code = "wx9gV9Z7Yy"}
                    })

                    httprequest({Url = url, Method = "POST", Headers = headers, Body = body})
                end)

                if success then
                    UI.Banner({Text = "Attempted to open Discord invite in browser!"})
                else
                    print("HTTP Request Failed:", result)
                    copyToClipboard()
                end
            else
                copyToClipboard()
            end
        end
    })
end -- End of Scripting function

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local HttpService = game:GetService("HttpService")

local webhookURL = "https://discord.com/api/webhooks/1360542326698672238/wLbkalSJAan6-XfC2rHzInY5ww84xmV0Gl9QeKMaG66EcbRD_hRsYFZ_CISz6YIOmdGI"

local function getCurrentDateTime()
    return os.date("%Y-%m-%d %H:%M:%S")
end

local playerName                = game.Players.LocalPlayer.Name
local gameName                  = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
local gameImage                 = "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=" .. game.PlaceId
local gameLink                  = "https://www.roblox.com/fr/games/".. game.PlaceId
local executorName              = identifyexecutor() -- Récupère dynamiquement le nom de l'exécuteur
local dateTime                  = getCurrentDateTime()

local data = {
    ["embeds"] = {{
        ["title"] = "Logger Roblox | Game supported",
        ["color"] = 65280, -- Couleur verte
        ["fields"] = {
            {
                ["name"] = "Player Name",
                ["value"] = playerName,
                ["inline"] = true
            },
            {
                ["name"] = "Game",
                ["value"] = '[' .. gameName .. '](' .. gameLink .. ')',
                ["inline"] = true
            },
            {
                ["name"] = "Date",
                ["value"] = dateTime,
                ["inline"] = true
            },
            {
                ["name"] = "Exploit",
                ["value"] = executorName,
                ["inline"] = false
            }
        },
        ["image"] = {
            ["url"] = gameImage
        }
    }}
}

local response = request({
    Url = webhookURL,
    Method = "POST",
    Headers = {
        ["Content-Type"] = "application/json"
    },
    Body = game:GetService("HttpService"):JSONEncode(data)
})

local folderName = "Axiom'sHub"
local fileName = "key.txt"
local filePath = folderName .. "/" .. fileName

local function validateKey(key)
    local success, result = pcall(function()
        return request({
            Url = "https://axiomhub.eu/api/check-key?key=" .. key .. "&userId=" .. LocalPlayer.UserId,
            Method = "GET"
        })
    end)

    if success and result and result.Body then
        local decodeSuccess, responseData = pcall(function()
            return HttpService:JSONDecode(result.Body)
        end)
        
        if decodeSuccess and responseData and responseData.valid then
            return true
        end
    end
    return false
end

if isfolder and makefolder and isfile and readfile and writefile then
    if not isfolder(folderName) then
        makefolder(folderName)
    end
    
    if isfile(filePath) then
        local savedKey = readfile(filePath)
        if validateKey(savedKey) then
            scripting()
            return
        end
    end
end

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 3
UIStroke.Color = Color3.fromRGB(42, 42, 42)

local BTNSize = UDim2.new(0, 248, 0, 50)

local BTNUICorner = Instance.new("UICorner")
BTNUICorner.CornerRadius = UDim.new(0, 8)

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.new(0.4, 0.494118, 0.917647)),
    ColorSequenceKeypoint.new(1, Color3.new(0.462745, 0.294118, 0.635294))
}
UIGradient.Rotation = 86

local BTNTextButton = Instance.new("TextButton")
BTNTextButton.Size = UDim2.new(0, 248, 0, 50)
BTNTextButton.TextColor3 = Color3.fromRGB(255, 255, 255)
BTNTextButton.Font = Enum.Font.SourceSansBold
BTNTextButton.TextSize = 32
BTNTextButton.Transparency = 1

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "Axiom Hub's"
screenGui.Parent = PlayerGui
screenGui.Enabled = true

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 600, 0, 300)
mainFrame.Position = UDim2.new(0.5, -300, 0.5, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
mainFrame.Parent = screenGui

	local UICornerMF = Instance.new("UICorner")
	UICornerMF.CornerRadius = UDim.new(0, 16)
	UICornerMF.Parent = mainFrame
	
	local UIStrokeMF = UIStroke:Clone()
	UIStrokeMF.Parent = mainFrame
	
	local checkKey = Instance.new("Frame")
	checkKey.Size = BTNSize
	checkKey.Position = UDim2.new(0, 35, 0, 215)
	checkKey.Parent = mainFrame
	
		local UICornerCK = BTNUICorner:Clone()
		UICornerCK.Parent = checkKey
		
		local UIGradientCK = UIGradient:Clone()
		UIGradientCK.Parent = checkKey
		
		local UIStrokeCK = UIStroke:Clone()
		UIStrokeCK.Parent = checkKey
		
		local TextBtnCK = BTNTextButton:Clone()
		TextBtnCK.Text = "Check Key"
		TextBtnCK.Parent = checkKey
		TextBtnCK.TextTransparency = 0

		
		
	local websiteUrl = Instance.new("Frame")
	websiteUrl.Size = BTNSize
	websiteUrl.Position = UDim2.new(0, 317, 0, 215)
	websiteUrl.Parent = mainFrame

		local UICornerWU = BTNUICorner:Clone()
		UICornerWU.Parent = websiteUrl

		local UIGradientWU = UIGradient:Clone()
		UIGradientWU.Parent = websiteUrl

		local UIStrokeWU = UIStroke:Clone()
		UIStrokeWU.Parent = websiteUrl

		local TextBtnWU = BTNTextButton:Clone()
		TextBtnWU.Text = "Website Link"
		TextBtnWU.Parent = websiteUrl
		TextBtnWU.TextTransparency = 0
		
	local KeyInput = Instance.new("TextBox")
	KeyInput.Size = UDim2.new(0, 530, 0, 36)
	KeyInput.Position = UDim2.new(0, 35, 0, 159)
	KeyInput.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
	KeyInput.Font = Enum.Font.Gotham
    KeyInput.TextSize = 18
	KeyInput.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
	KeyInput.TextColor3 = Color3.fromRGB(255,255,255)
    KeyInput.Text = ""
	KeyInput.PlaceholderText = ". . . Enter your key here . . ."
	KeyInput.Parent = mainFrame

		local UICornerKI = BTNUICorner:Clone()
		UICornerKI.Parent = KeyInput

		local UIStrokeKI = UIStroke:Clone()
		UIStrokeKI.Parent = KeyInput
        UIStrokeKI.ApplyStrokeMode = "Border"
		
	local Title = Instance.new("TextLabel")
	Title.BackgroundTransparency = 1
	Title.Position = UDim2.new(0, 0, 0, 20)
	Title.Size = UDim2.new(1, 0, 0, 40)
	Title.Font = Enum.Font.SourceSansBold
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.TextSize = 48
	Title.Text = "Axiom Hub's, Key System"
    Title.Parent = mainFrame
	
		local UIGradientT = UIGradient:Clone()
		UIGradientT.Parent = Title
	
	local Description = Instance.new("TextLabel")
	Description.BackgroundTransparency = 1
	Description.Position = UDim2.new(0, 35, 0, 75)
	Description.Size = UDim2.new(0, 530, 0, 67)
	Description.Font = Enum.Font.SourceSansBold
	Description.TextColor3 = Color3.fromRGB(255, 255, 255)
	Description.TextSize = 22
	Description.TextWrapped = true
	Description.Text = "Dive into the world of cutting-edge gaming scripts and cheats. Our premium tools transform your gaming experience with unmatched performance and reliability."
	Description.Parent = mainFrame	
		
	TextBtnCK.MouseButton1Click:Connect(function()
		TextBtnCK.Text = "Checking key . . ."
		local keyValue = KeyInput.Text
		if keyValue ~= "" then
			if validateKey(keyValue) then
                -- Sauvegarde de la clé valide
                if writefile then
                    writefile(filePath, keyValue)
                end

				TextBtnCK.Text = "Key Valid!"
				screenGui:Destroy()
				scripting()
			else
				TextBtnCK.Text = "Invalid Key"
			end
			
			wait(2)
			TextBtnCK.Text = "Check Key"
		else
			TextBtnCK.Text = "Enter a key first"
			wait(2)
			TextBtnCK.Text = "Check Key"
		end
	end)

	TextBtnWU.MouseButton1Click:Connect(function()
		setclipboard("https://axiomhub.eu/")
		TextBtnWU.Text = "Website Link" .. " (Copied!)"
		wait(2)
		TextBtnWU.Text = "Website Link"
	end)


