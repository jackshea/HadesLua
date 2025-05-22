-- 杀死主角函数，处理玩家死亡的主要逻辑
function KillHero(victim, triggerArgs)
    local killer = triggerArgs.AttackerTable
    local currentRun = CurrentRun
    local killingUnitWeapon = triggerArgs.SourceWeapon
    local killingUnitId = triggerArgs.AttackerId
    local killingUnitName = triggerArgs.AttackerName
    local enemyData = EnemyData[killingUnitName]

    thread(CheckOnDeathPowers, victim, killer, killingUnitWeapon)

    killTaggedThreads(RoomThreadName)
    if currentRun.CurrentRoom.Encounter ~= nil then
        killTaggedThreads(currentRun.CurrentRoom.Encounter.SpawnThreadName)
    end
    killWaitUntilThreads("RequiredKillEnemyKilledOrSpawned")
    killWaitUntilThreads("AllRequiredKillEnemiesDead")
    killWaitUntilThreads("AllEncounterEnemiesDead")
    killWaitUntilThreads("RequiredEnemyKilled")
    killWaitUntilThreads(UIData.BoonMenuId)

    EndAmbience(0.5)
    EndMusic(MusicId, MusicName, triggerArgs.MusicEndTime or 0.0)

    if killer == nil then
        killer = {}
        killer.Name = killingUnitName
        killer.ObjectId = killingUnitId
    end

    LastKilledByUnitName = killer.Name
    LastKilledByWeaponName = killingUnitWeapon

    if currentRun.DeathFunctionName ~= nil then
        local deathFunction = _G[currentRun.DeathFunctionName]
        deathFunction(currentRun, killer, killingUnitWeapon)
    else
        HandleDeath(currentRun, killer, killingUnitWeapon)
    end
end

-- 表面杀死主角函数，在指定延迟后调用KillHero
function SurfaceKillHero(source, args)
    wait(args.WaitTime or 0)
    KillHero(CurrentRun.Hero, args)
end

-- 处理死亡函数，管理玩家死亡后的游戏状态和转换
function HandleDeath(currentRun, killer, killingUnitWeapon)

    if GetConfigOptionValue({Name = "EditingMode"}) then
        SetAnimation({Name = "ZagreusDeadStartBlood", DestinationId = currentRun.Hero.ObjectId})
        return
    end

    SendSaveFileEmail({ })

    AddTimerBlock(currentRun, "HandleDeath")
    if ScreenAnchors.TraitTrayScreen ~= nil then
        CloseAdvancedTooltipScreen()
    end
    ClearHealthShroud()
    CurrentRun.Hero.HandlingDeath = true
    CurrentRun.Hero.IsDead = true
    CurrentRun.ActiveBiomeTimer = false
    if ConfigOptionCache.EasyMode and not currentRun.Cleared then
        GameState.EasyModeLevel = GameState.EasyModeLevel + 1
    end
    if not CurrentRun.Cleared then
        -- Already recorded if cleared
        RecordRunStats()
    end

    InvalidateCheckpoint()

    ZeroSuperMeter()
    FinishTargetMarker(killer)

    local deathPresentationName = currentRun.DeathPresentationFunctionName or "DeathPresentation"
    local deathPresentationFunction = _G[deathPresentationName]
    deathPresentationFunction(currentRun, killer, killingUnitWeapon)
    AddInputBlock({Name = "MapLoad"})

    currentRun.CurrentRoom.EndingHealth = currentRun.Hero.Health
    currentRun.EndingMoney = currentRun.Money
    table.insert(currentRun.RoomHistory, currentRun.CurrentRoom)
    UpdateRunHistoryCache(currentRun, currentRun.CurrentRoom)

    currentRun.Money = 0
    currentRun.NumRerolls = GetNumMetaUpgrades("RerollMetaUpgrade") + GetNumMetaUpgrades("RerollPanelMetaUpgrade")

    ResetObjectives()
    ActiveScreens = {}

    CurrentRun.Hero.HandlingDeath = false
    CurrentRun.Hero.Health = CurrentRun.Hero.MaxHealth

    local currentRoom = currentRun.CurrentRoom
    local deathMap = "DeathArea"
    GameState.LocationName = "Location_Home"
    RandomSetNextInitSeed()
    SaveCheckpoint({StartNextMap = deathMap, DevSaveName = CreateDevSaveName(currentRun, {StartNextMap = deathMap})})
    ClearUpgrades()

    SetConfigOption({Name = "FlipMapThings", Value = false})

    local runNumber = (GetCompletedRuns() + 1)
    local runDepth = GetRunDepth(currentRun)

    LoadMap({Name = deathMap, ResetBinks = true, ResetWeaponBinks = true})
end

-- 死亡区域加载事件处理函数，在加载DeathArea地图时触发
OnAnyLoad {"DeathArea",
           function(triggerArgs)

               if GameState == nil then
                   StartNewGame()
                   CurrentRun.Hero.IsDead = true
               end

               DeathAreaStartTime = _worldTime
               if CurrentDeathAreaRoom ~= nil and (CurrentDeathAreaRoom.Name == "DeathAreaBedroom" or CurrentDeathAreaRoom.Name == "DeathAreaOffice" or CurrentDeathAreaRoom.Name == "DeathAreaBedroomHades") then
                   if CurrentDeathAreaRoom.Name == "DeathAreaOffice" or CurrentDeathAreaRoom.Name == "DeathAreaBedroomHades" then
                       UnDimTopHallRoomStart()
                   end
                   DeathAreaRoomTransition(nil, {Name = "DeathArea"})
               else
                   StartDeathLoop(CurrentRun)
               end

           end
}

-- 特定死亡区域房间加载事件处理函数
OnAnyLoad {"DeathAreaBedroom DeathAreaBedroomHades DeathAreaOffice RoomPreRun",
           function(triggerArgs)

               if GameState == nil then
                   StartNewGame()
                   CurrentRun.Hero.IsDead = true
               end

               DeathAreaStartTime = _worldTime
               DeathAreaRoomTransition(nil, {Name = triggerArgs.name})

           end
}

-- 开始死亡循环函数，在玩家死亡后初始化死亡区域
function StartDeathLoop(currentRun)

    DisableCombatControls()

    currentRun.BlockDeathAreaTransitions = true
    DeathAreaRoomTransition(nil, {Name = "DeathArea", SkipShowUI = true, })

    if currentRun.ReturnedByBoat then
        StartDeathLoopFromBoatPresentation(currentRun)
    else
        StartDeathLoopPresentation(currentRun)
    end

    local notifyName = "ReattachCameraOnInput"
    NotifyOnPlayerInput({Notify = notifyName})
    waitUntil(notifyName)
    PanCamera({Id = currentRun.Hero.ObjectId, Duration = 2.0, FromCurrentLocation = true, })

    EnableCombatControls()
    ShowCombatUI()
end

-- 设置死亡区域函数，初始化死亡区域的各种元素和触发器
function SetupDeathArea(currentRun)

    StartRoomPreLoadBinks({
        Run = currentRun,
        Room = CurrentDeathAreaRoom
    })
    if CurrentDeathAreaRoom.BinkSet ~= nil then
        SessionState.DeathAreaBinkSet = CurrentDeathAreaRoom.BinkSet
    end

    RunEvents(CurrentDeathAreaRoom)
    AssignObstacles(CurrentDeathAreaRoom)
    CheckInspectPoints(currentRun, CurrentDeathAreaRoom)
    StartTriggers(CurrentDeathAreaRoom, CurrentDeathAreaRoom.DistanceTriggers)

    if CurrentDeathAreaRoom.RemoveDashFireFx then
        SetWeaponProperty({WeaponName = "RushWeapon", DestinationId = CurrentRun.Hero.ObjectId, Property = "UnblockedBlinkFx", Value = "null", ValueChangeType = "Absolute"})
    end

end

-- 死亡区域切换房间函数，处理在死亡区域内不同房间之间的切换
function DeathAreaSwitchRoom(source, args)
    ClearEffect({Id = CurrentRun.Hero.ObjectId, All = true, BlockAll = true, })
    NextHeroStartPoint = args.HeroStartPoint
    NextHeroEndPoint = args.HeroEndPoint
    LeaveDeathAreaRoomPresentation(CurrentRun, source)

    for obstacleId, obstacle in pairs(MapState.ActiveObstacles) do
        if obstacle.AIThreadName ~= nil then
            killTaggedThreads(obstacle.AIThreadName)
        end
        if obstacle.AINotifyName ~= nil then
            killWaitUntilThreads(obstacle.AINotifyName)
        end
    end
    killTaggedThreads(RoomThreadName)

    if not GameState.Flags.InFlashback then
        SaveCheckpoint({StartNextMap = args.Name, DevSaveName = CreateDevSaveName(CurrentRun, {StartNextMap = args.Name})})
    end
    SetSoundSource({Id = AmbientMusicId}) -- Remove until new source is created in the next room

    local nextRoomData = DeathLoopData[args.Name]

    local resetBinks = false
    if args.CheckBinkSetChange and SessionState.DeathAreaBinkSet ~= nextRoomData.BinkSet then
        resetBinks = true
        SessionState.NeedWeaponPickupBinkLoad = false
    end
    LoadMap({Name = args.Name, ResetBinks = resetBinks})
end

-- 死亡区域房间转换函数，处理进入新的死亡区域房间的逻辑
function DeathAreaRoomTransition(source, args)

    AddInputBlock({Name = "DeathAreaTransition"})
    PreviousDeathAreaRoom = CurrentDeathAreaRoom
    CurrentDeathAreaRoom = DeathLoopData[args.Name]

    if GameState ~= nil then
        GameState.SpentShrinePointsCache = GetTotalSpentShrinePoints()
        UpdateActiveShrinePoints()
    end

    local currentRun = CurrentRun
    SetupHeroObject(currentRun)

    if CurrentDeathAreaRoom.RichPresence ~= nil then
        SetRichPresence({Key = "status", Value = CurrentDeathAreaRoom.RichPresence})
        SetRichPresence({Key = "steam_display", Value = CurrentDeathAreaRoom.RichPresence})
    end

    FadeOut({Color = Color.Black, Duration = 0})
    SetupCamera(CurrentDeathAreaRoom)
    SwitchActiveUnit({Id = currentRun.Hero.ObjectId})

    if CurrentDeathAreaRoom.AmbientMusicParams ~= nil then
        for param, value in pairs(CurrentDeathAreaRoom.AmbientMusicParams) do
            SetSoundCueValue({Id = AmbientMusicId, Name = param, Value = value, Duration = 0.5})
        end
    end
    SetVolume({Id = AmbientMusicId, Value = CurrentDeathAreaRoom.AmbientMusicVolume, Duration = 0.5})

    ResetObjectives()
    RunUnthreadedEvents(CurrentDeathAreaRoom.StartUnthreadedEvents, CurrentDeathAreaRoom)

    local musicTargetIds = GetIdsByType({Name = "NPC_Orpheus_01"})
    if IsEmpty(musicTargetIds) then
        musicTargetIds = GetIdsByType({Name = "HeroStart"})
    end
    SetSoundSource({Id = AmbientMusicId, DestinationIds = musicTargetIds})
    if AmbientMusicSource ~= nil and not IsEmpty(musicTargetIds) then
        AmbientMusicSource.ObjectId = musicTargetIds[1]
    end

    SetupDeathArea(currentRun)

    if currentRun.BlockDeathAreaTransitions then
        currentRun.BlockDeathAreaTransitions = false
    else
        StartRoomPresentation(currentRun, CurrentDeathAreaRoom)
        thread(PlayVoiceLines, CurrentDeathAreaRoom.EnteredVoiceLines)
        FadeIn({Duration = 0.5})
    end

    RemoveInputBlock({Name = "DeathAreaTransition"})

    if CurrentDeathAreaRoom.CheckObjectives ~= nil then
        for k, objectiveName in pairs(CurrentDeathAreaRoom.CheckObjectives) do
            CheckObjectiveSet(objectiveName)
        end
    end

    if not args.SkipShowUI then
        ShowCombatUI()
    end

    CheckAutoObjectiveSets(currentRun, "RoomStart")
end

-- 设置摄像机函数，调整游戏摄像机的位置和缩放
function SetupCamera(source, args)
    args = args or {}
    if source.CameraZoomWeights ~= nil then
        for id, weight in pairs(source.CameraZoomWeights) do
            SetCameraZoomWeight({Id = id, Weight = weight, ZoomSpeed = 1.0})
        end
    end
    AdjustZoom({Fraction = source.ZoomFraction or 1.0, LerpTime = args.LerpTime})
    LockCamera({Ids = {CurrentRun.Hero.ObjectId}, Duration = args.Duration})
end

-- 解锁死亡区域交互物体函数，根据游戏进度解锁特定交互物体
function UnlockDeathAreaInteractbles()

    local shopIds = {50056}
    local fateIds = {50057}

    if GetCompletedRuns() >= 2 then
        Activate({Ids = shopIds})
    end

    if GetCompletedRuns() >= 4 then
        Activate({Ids = fateIds})
    end

end

-- 使用逃脱门函数，处理玩家使用逃脱门开始新的逃脱尝试
function UseEscapeDoor(usee, args)

    if GetNumRunsCleared() > 0 or GameState.Flags.HardMode then
        UseShrineObject(usee, args)
    else
        ClearShrineLoadout()
        StartOver()
    end
end

-- 重新开始函数，初始化新的游戏运行
function StartOver()

    AddInputBlock({Name = "StartOver"})

    local currentRun = CurrentRun
    EndRun(currentRun)
    CurrentDeathAreaRoom = nil
    PreviousDeathAreaRoom = nil
    currentRun = StartNewRun(currentRun)
    StopSound({Id = AmbientMusicId, Duration = 1.0})
    AmbientMusicId = nil
    AmbientTrackName = nil
    ResetObjectives()
    killTaggedThreads(RoomThreadName)

    SetConfigOption({Name = "FlipMapThings", Value = false})

    AddTimerBlock(currentRun, "StartOver")
    SetPersephoneAwayAtRunStart()
    StartNewRunPresentation(currentRun)
    RemoveInputBlock({Name = "StartOver"})
    RemoveTimerBlock(currentRun, "StartOver")
    killTaggedThreads(RoomThreadName)

    AddInputBlock({Name = "MapLoad"})

    LoadMap({Name = currentRun.CurrentRoom.Name, ResetBinks = true, ResetWeaponBinks = true})

end

-- 闪回离开卧室函数，处理闪回场景中离开卧室的逻辑
function FlashbackLeftBedroom(source)
    AdvanceFlashback()
    source.IgnoreClamps = true
    SetCameraClamp({Ids = {391571, 391553, }})
    CreateCameraWalls({ })
end

-- 检查礼物目标函数，提示玩家关于礼物系统的信息
function CheckGiftObjective()
    wait(1.5)
    if HasResource("GiftPoints", 0) then
        CheckObjectiveSet("GiftPrompt")
    end
end

-- 生成骷髅函数，在训练区域生成骷髅训练伙伴
function SpawnSkelly(waitTime)

    GameState.Flags.SkellyUnlocked = true
    if MapState.SkellySpawned then
        return
    end
    MapState.SkellySpawned = true
    wait(waitTime or 3.0, RoomThreadName)
    ActivatePrePlaced(nil, {LegalTypes = {"TrainingMelee"}})
    CurrentRun.SkellySpawned = true
    wait(4.2, RoomThreadName)
    CheckConversations()

end

-- 检查花园开放函数，处理花园区域的开放条件和相关设置
function CheckGardenOpen(eventSource, args)
    if args.DeleteGroups then
        for k, groupName in pairs(args.DeleteGroups) do
            Destroy({Ids = GetIds({Name = groupName})})
        end
    end
    if args.SetClamps ~= nil then
        CurrentDeathAreaRoom.CameraClamps = args.SetClamps
    end
end