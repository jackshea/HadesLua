-- 定义游戏数据
GameData.AchievementData = {
    -- 默认成就
    DefaultAchievement = {
        DebugOnly = true, -- 仅在调试模式下可用
    },

    -- 清除Tartarus的成就
    AchClearTartarus = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredSeenRooms = {"B_Intro", }, -- 需要看到的房间
        },
    },

    -- 清除Asphodel的成就
    AchClearAsphodel = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredSeenRooms = {"C_Intro", }, -- 需要看到的房间
        },
    },

    -- 清除Elysium的成就
    AchClearElysium = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredSeenRooms = {"D_Intro", }, -- 需要看到的房间
        },
    },

    -- 清除ElysiumEM的成就
    AchClearElysiumEM = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredRoom = "C_PostBoss01", -- 需要的房间
            RequireEncounterCompleted = "BossTheseusAndMinotaur", -- 需要完成的遭遇
            RequiredMinActiveMetaUpgradeLevel = {Name = "BossDifficultyShrineUpgrade", Count = 3}, -- 需要的最小活跃元升级等级
        },
    },

    -- 清除HeatGate的成就
    AchClearHeatGate = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
    },

    -- 清除任何运行的成就
    AchClearAnyRun = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiresRunCleared = true, -- 需要清除的运行
        },
    },

    -- 清除Run4thAspect的成就
    AchClearRun4thAspect = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiresRunCleared = true, -- 需要清除的运行
            RequiresInRun = true, -- 需要在运行中
            RequiredOneOfTraits = {"SwordConsecrationTrait", "SpearSpinTravel", "ShieldLoadAmmoTrait", "BowBondTrait", "FistDetonateTrait", "GunLoadedGrenadeTrait"}, -- 需要的特性之一
        },
    },

    -- 打败Charon的成就
    AchBeatCharon = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredTrait = "DiscountTrait", -- 需要的特性
        },
    },

    -- 获得BronzeSkellyTrophy的成就
    AchBronzeSkellyTrophy = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredTextLines = {"TrophyQuest_BronzeUnlocked_01"}, -- 需要的文本行
        },
    },

    -- 获得SilverSkellyTrophy的成就
    AchSilverSkellyTrophy = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredTextLines = {"TrophyQuest_SilverUnlocked_01"}, -- 需要的文本行
        },
    },

    -- 找到Keepsakes的成就
    AchFoundKeepsakes = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredTextLines = {"CerberusGift01", "AchillesGift01", "NyxGift01", "HypnosGift01", "CharonGift01", "MegaeraGift01", "ThanatosGift01", "OrpheusGift01", "DusaGift01", "SkellyGift01",
                                 "SisyphusGift01", "EurydiceGift01", "PatroclusGift01", "PersephoneGift01", "HadesGift02", "AthenaGift01", "ZeusGift01", "PoseidonGift01", "AphroditeGift01", "ArtemisGift01",
                                 "AresGift01", "DionysusGift01", "ChaosGift01"}, -- 需要的文本行
            RequiredAnyTextLines = {"HermesGift01", "HermesGift01B"}, -- 需要的任何文本行
            RequiredAnyOtherTextLines = {"DemeterGift01", "DemeterGift02", "DemeterGift03"}, -- 需要的任何其他文本行
        },
    },

    -- 升级Keepsakes的成就
    AchLeveledKeepsakes = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiresMaxKeepsakes = {
                "MaxHealthKeepsakeTrait", "DirectionalArmorTrait",
                "BackstabAlphaStrikeTrait", "BonusMoneyTrait",
                "ShopDurationTrait", "LowHealthDamageTrait",
                "PerfectClearDamageBonusTrait", "DistanceDamageTrait",
                "LifeOnUrnTrait", "ReincarnationTrait",
                "VanillaTrait", "ShieldBossTrait",
                "ShieldAfterHitTrait", "ChamberStackTrait",
                "HadesShoutKeepsake", "ForceAthenaBoonTrait",
                "ForceZeusBoonTrait", "ForcePoseidonBoonTrait",
                "ForceAphroditeBoonTrait", "ForceArtemisBoonTrait",
                "ForceAresBoonTrait", "ForceDionysusBoonTrait",
                "ForceDemeterBoonTrait", "FastClearDodgeBonusTrait",
                "ChaosBoonTrait"}, -- 需要的最大Keepsakes
        },
    },

    -- 找到Summon的成就
    AchFoundSummon = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredAnyAssistKeepsake = true, -- 需要的任何AssistKeepsake
        },
    },

    -- 找到所有Summons的成就
    AchFoundAllSummons = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredTextLines = {"MegaeraGift07", "ThanatosGift07_A", "DusaGift07", "SkellyGift07", "SisyphusGift07_A", "AchillesGift07_A"}, -- 需要的文本行
        },
    },

    -- 最大化任何Aspect的成就
    AchMaxedAnyAspect = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredMinMaxedWeaponEnchantments = 1, -- 需要的最小化武器魔法
        },
    },

    -- 解锁所有Aspects的成就
    ActUnlockedAllAspects = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredMinUnlockedWeaponEnchantments = 18, -- 需要的最小解锁武器魔法
        },
    },

    -- 选择许多Boons的成就
    AchPickedManyBoons = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredUniqueGodTraitsTaken = 100, -- 需要的独特神特性
        },
    },

    -- 清除LegendBoon的成就
    AchPurgedLegendBoon = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
    },

    -- 选择许多Hammers的成就
    AchPickedManyHammers = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredUniqueWeaponUpgradesTaken = 50, -- 需要的独特武器升级
        },
    },

    -- 解锁所有武器的成就
    AchUnlockedAllWeapons = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredWeaponsUnlocked = {"SwordWeapon", "SpearWeapon", "ShieldWeapon", 'BowWeapon', "FistWeapon", "GunWeapon"}, -- 需要解锁的武器
        },
    },

    -- ForgeBond的成就
    AchForgedBond = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredAnyTextLines = {
                "CerberusGift09", "AchillesGift09_A",
                "NyxGift09", "HypnosGift08",
                "CharonGift07", "MegaeraGift10",
                "ThanatosGift10", "OrpheusGift08",
                "BecameCloseWithDusa01", "SkellyGift09",
                "SisyphusGift09_A", "EurydiceGift08",
                "PatroclusGift08_A", "PersephoneGift09",
                "HadesGift05", "ZeusGift07",
                "PoseidonGift07", "AthenaGift07",
                "AphroditeGift07", "ArtemisGift07",
                "AresGift07", "DionysusGift07",
                "DemeterGift07", "ChaosGift08",
                "HermesGift08", "HermesGift08B"
            }, -- 需要的任何文本行
        },
    },

    -- OlympiansCodex的成就
    AchOlympiansCodex = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredCodexEntries = {
                ZeusUpgrade = 3,
                PoseidonUpgrade = 3,
                AthenaUpgrade = 3,
                AphroditeUpgrade = 3,
                AresUpgrade = 3,
                ArtemisUpgrade = 3,
                DionysusUpgrade = 3,
                DemeterUpgrade = 4,
                HermesUpgrade = 3,
            }, -- 需要的Codex条目
        },
    },

    -- 许多BrokerTrades的成就
    AchManyBrokerTrades = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredMinValues = {MarketSales = 20}, -- 需要的最小值
        },
    },

    -- 许多Cosmetics的成就
    AchManyCosmetics = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredNumCosmeticsMin = 50, -- 需要的最小化妆品数量
        },
    },

    -- 许多Quests的成就
    AchManyQuests = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredMinQuestsComplete = 15, -- 需要的最小完成任务数量
        },
    },

    -- 从每个Biome中捕鱼的成就
    AchFishFromEachBiome = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredAnyCaughtFishTypesOfEach = {
                {"Fish_Tartarus_Common_01", "Fish_Tartarus_Rare_01", "Fish_Tartarus_Legendary_01"},
                {"Fish_Asphodel_Common_01", "Fish_Asphodel_Rare_01", "Fish_Asphodel_Legendary_01"},
                {"Fish_Elysium_Common_01", "Fish_Elysium_Rare_01", "Fish_Elysium_Legendary_01"},
                {"Fish_Styx_Common_01", "Fish_Styx_Rare_01", "Fish_Styx_Legendary_01"},
                {"Fish_Surface_Common_01", "Fish_Surface_Rare_01", "Fish_Surface_Legendary_01"},
            }, -- 需要的任何捕获的鱼类型
        },
    },

    -- OrpheusSingsAgain的成就
    AchOrpheusSingsAgain = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredAnyTextLines = {"OrpheusSingsAgain01", "OrpheusSingsAgain01_B", "OrpheusSingsAgain01_C", "OrpheusSingsAgain01_D", "OrpheusSingsAgain02", "OrpheusSingsAgain03", "OrpheusSingsAgain03_B"}, -- 需要的任何文本行
        },
    },

    -- 解锁所有Mirror的成就
    AchMirrorAllUnlocked = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredAllMetaUpgradesInvestment = 1 -- 需要所有的Meta升级投资
        },
    },

    -- Nyx和Chaos的团聚成就
    AchNyxChaosReunion = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequireQuestsComplete = {"NyxChaosReunion", }, -- 需要完成的任务
        },
    },

    -- 遇见Chthonic神祇的成就
    AchMeetChthonicGods = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequireQuestsComplete = {"MeetChthonicGods", }, -- 需要完成的任务
        },
    },

    -- Ares的杀戮成就
    AchAresKills = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequireQuestsComplete = {"AresEarnKills", }, -- 需要完成的任务
        },
    },

    -- Sisyphus的解放成就
    AchSisyphusLiberation = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequireQuestsComplete = {"SisyphusLiberation", }, -- 需要完成的任务
        },
    },

    -- 歌手的团聚成就
    AchSingersReunion = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequireQuestsComplete = {"OrpheusEurydiceReunion", }, -- 需要完成的任务
        },
    },

    -- Myrmidon的团聚成就
    AchMyrmidonReunion = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequireAnyQuestsComplete = {"AchillesPatroclusReunion_A", "AchillesPatroclusReunion_B", "AchillesPatroclusReunion_C", }, -- 需要完成的任何任务
        },
    },

    -- 镜子升级的成就
    AchMirrorUpgradeClears = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequireQuestsComplete = {"MirrorUpgrades", }, -- 需要完成的任务
        },
    },

    -- Pact升级的成就
    AchPactUpgradesClears = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequireQuestsComplete = {"PactUpgrades", }, -- 需要完成的任务
        },
    },

    -- 武器清除的成就
    AchWeaponClears = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequireQuestsComplete = {"WeaponClears", }, -- 需要完成的任务
        },
    },

    -- 精英属性杀戮的成就
    AchEliteAttributeKills = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequireQuestsComplete = {"EliteAttributeKills", }, -- 需要完成的任务
        },
    },

    -- 访问AdminChamber的成就
    AchAccessAdminChamber = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredRoom = "DeathAreaOffice", -- 需要的房间
            RequiredCosmetics = {"OfficeDoorUnlockItem"}, -- 需要的化妆品
        },
    },

    -- 达到结局的成就
    AchReachedEnding = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredTextLines = {"Ending01"}, -- 需要的文本行
        },
    },

    -- 达到尾声的成就
    AchReachedEpilogue = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredTextLines = {"OlympianReunionQuestComplete"}, -- 需要的文本行
        },
    },

    -- WellShop物品的成就
    AchWellShopItems = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredRunMinValues = {WellPurchases = 9}, -- 需要的最小值
        },
    },

    -- BuffedButterfly的成就
    AchBuffedButterfly = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        GoalValue = 1.296, -- 目标值
    },

    -- BuffedPlume的成就
    AchBuffedPlume = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        GoalValue = 0.2, -- 目标值
    },

    -- CrushedThanatos的成就
    AchCrushedThanatos = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        GoalValue = 15, -- 目标值
    },

    -- GreaterCall的成就
    AchGreaterCall = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
    },

    -- GreaterCallSpurned的成就
    AchGreaterCallSpurned = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
    },

    -- SkellyKills的成就
    AchSkellyKills = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredKills = {TrainingMelee = 15}, -- 需要的杀戮
        },
    },

    -- CerberusPets的成就
    AchCerberusPets = {
        InheritFrom = {"DefaultAchievement"}, -- 继承自默认成就
        CompleteGameStateRequirements = {
            RequiredMinValues = {NumCerberusPettings = 10}, -- 需要的最小值
        },
    },
}
