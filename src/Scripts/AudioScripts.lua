-- **MINOS AUDIO**
AudioState = {}

OnAnyLoad {
    function(triggerArgs)

        DeferredPlayVoiceLines = {}

        if MusicName ~= nil and MusicId == nil then
            -- Out of sync (presumably from a load)
            -- 加载时音乐状态不一致
            local restoreTrackName = MusicName
            local restoreMusicSection = MusicSection
            MusicName = nil
            MusicSection = nil
            MusicPlayer(restoreTrackName)
            SetMusicSection(restoreMusicSection)
            if MusicId ~= nil then
                if MusicActiveStems ~= nil then
                    SetSoundCueValue({Names = MusicActiveStems, Id = MusicId, Value = 1})
                end
                if MusicMutedStems ~= nil then
                    SetSoundCueValue({Names = MusicMutedStems, Id = MusicId, Value = 0})
                end
            else
                MusicActiveStems = nil
                MusicMutedStems = nil
            end
            if MusicPlayerTrackPaused and MusicPlayerTrackData[MusicName] ~= nil then
                PauseMusic()
            end
        end

        if AmbientTrackName ~= nil and AmbientMusicSource ~= nil and AmbientMusicId == nil then
            -- Out of sync (presumably from a load)
            -- 加载时环境音乐状态不一致
            local restoreTrackName = AmbientTrackName
            AmbientTrackName = nil
            wait(0.02) -- Need to wait for potential stored targets to spawn
            local source = ActiveEnemies[AmbientMusicSource.ObjectId]
            if source ~= nil then
                MusicianMusic(source, {TrackName = restoreTrackName})
                if CurrentDeathAreaRoom ~= nil then
                    if CurrentDeathAreaRoom.AmbientMusicParams ~= nil then
                        for param, value in pairs(CurrentDeathAreaRoom.AmbientMusicParams) do
                            SetSoundCueValue({Id = AmbientMusicId, Name = param, Value = value, Duration = 0.5})
                        end
                    end
                    SetVolume({Id = AmbientMusicId, Value = CurrentDeathAreaRoom.AmbientMusicVolume, Duration = 0.5})
                end
            end
        end
    end
}

-- 延迟执行音频脚本
function DeferredAudioScripts()
    for index, params in ipairs(DeferredPlayVoiceLines) do
        thread(PlayVoiceLinesReal, params[1], params[2], params[3], params[4])
    end
    DeferredPlayVoiceLines = {}
end

-- **Music**

-- 音乐播放事件处理函数
function MusicPlayerEvent(source, args)
    MusicPlayer(args.TrackName, args.MusicInfo, args.DestinationId)
end

-- 音乐播放器函数
function MusicPlayer(trackName, musicInfo, destinationId)
    -- 播放音乐
    if trackName == nil then
        return false
    end

    if MusicName ~= nil and MusicName == trackName then
        -- Don't play an identical track that's already playing
        -- But do still update the source if it is being changed
        -- 如果音乐已经在播放，则不再播放相同的音乐
        SetSoundSource({Id = MusicId, DestinationId = destinationId})
        return false
    end

    if MusicId ~= nil then
        -- Quick cut any music still playing
        -- 停止当前播放的音乐
        StopSound({Id = MusicId, Duration = 0.25})
        MusicId = nil
    end
    if StoppingMusicId ~= nil then
        -- Quick cut any music still fading out
        -- 停止当前淡出的音乐
        StopSound({Id = StoppingMusicId, Duration = 0.25})
        StoppingMusicId = nil
    end

    MusicName = trackName
    MusicId = PlaySound({Name = MusicName, AddCallbacks = true, Id = destinationId})
    SetDefaultMusicParams(MusicName, MusicId)

    if musicInfo ~= nil then
        musicInfo.Id = MusicId
        musicInfo.Name = MusicName
    end

    if SecretMusicId ~= nil then
        -- Secret music has priority and is mutually exclusive so this must wait
        -- 秘密音乐优先级高，互斥，因此必须等待
        SetVolume({Id = MusicId, Value = 0.0, Duration = 0.0})
        PauseSound({Id = MusicId, Duration = 0.0})
    end

    return true

end

-- 秘密音乐播放器函数
function SecretMusicPlayer(trackName, musicInfo)
    -- 播放秘密音乐
    if trackName == nil then
        return false
    end

    if SecretMusicName == trackName then
        -- Don't play an identical track that's already playing
        -- 如果秘密音乐已经在播放，则不再播放相同的音乐
        return
    end

    if MusicId ~= nil then
        -- Quick cut any music still playing
        -- 停止当前播放的音乐
        PauseMusic()
    end
    if SecretMusicId ~= nil then
        -- Quick cut any music still playing
        -- 停止当前播放的秘密音乐
        StopSound({Id = SecretMusicId, Duration = 0.25})
    end

    SecretMusicName = trackName
    SecretMusicId = PlaySound({Name = SecretMusicName, AddCallbacks = true})
    SetDefaultMusicParams(SecretMusicName, SecretMusicId)

    if musicInfo ~= nil then
        musicInfo.Id = SecretMusicId
        musicInfo.Name = SecretMusicName
    end

    return true

end

-- 停止秘密音乐
function StopSecretMusic(smoothStop)
    -- 停止秘密音乐
    if SecretMusicId == nil then
        return
    end

    if smoothStop then
        EndMusic(SecretMusicId, SecretMusicName)
    else
        StopSound({Id = SecretMusicId, Duration = 0.25})
    end
    SecretMusicId = nil
    SecretMusicName = nil

end

-- 开始混沌低音
function ChaosBassStart()
    -- 开始混沌低音
    SetSoundCueValue({Names = {"ChaosBass"}, Id = SecretMusicId, Value = 1, Duration = 0.5})
end

-- 停止混沌低音
function ChaosBassStop()
    -- 停止混沌低音
    SetSoundCueValue({Names = {"ChaosBass"}, Id = SecretMusicId, Value = 0, Duration = 3})
end

-- 歌唱表现
function SingingPresentation(source, ars)
    -- 歌唱表现
    if source.SingingFx ~= nil then
        CreateAnimation({Name = source.SingingFx, DestinationId = source.ObjectId, OffsetX = source.SingingAnimOffsetX or source.AnimOffsetX, OffsetZ = source.AnimOffsetZ, Group = "Combat_UI_World"})
    end
    if source.SingingAnimation ~= nil then
        SetAnimation({Name = source.SingingAnimation, DestinationId = source.ObjectId})
    end
    if source.PartnerSingingAnimation ~= nil and source.PartnerObjectId ~= nil then
        SetAnimation({Name = source.PartnerSingingAnimation, DestinationId = source.PartnerObjectId})
    end
end

-- 音乐家音乐
function MusicianMusic(source, args)
    -- 音乐家音乐
    if CurrentRun.BlockAmbientMusic then
        return
    end

    CurrentRun.EventState[source.ObjectId] = {FunctionName = "SingingPresentation", Args = args}
    SingingPresentation(source, args)

    if args.TrackName == AmbientTrackName then
        -- Don't play an identical track that's already playing
        -- But do still update the source if it is being changed
        -- 如果音乐已经在播放，则不再播放相同的音乐
        SetSoundSource({Id = AmbientMusicId, DestinationId = source.ObjectId})
        AmbientMusicSource = source
        return
    end

    if AmbientMusicId ~= nil then
        -- Quick cut the previously playing id
        -- 停止当前播放的音乐
        StopSound({Id = AmbientMusicId, Duration = 0.25})
        AmbientMusicId = nil
    end

    --Shake({ Id = source.ObjectId, Distance = 1, Speed = 3, Duration = 9999, Angle = 0 })

    AmbientMusicSource = source
    AmbientMusicId = PlaySound({Name = args.TrackName, Id = source.ObjectId})
    SetSoundCueValue({Names = {"Vocals", }, Id = AmbientMusicId, Value = 1})
    AmbientTrackName = args.TrackName
    SetVolume({Id = AmbientMusicId, Value = 1})
    if args.TrackOffsetMin ~= nil then
        SetSoundPosition({Id = AmbientMusicId, Position = RandomFloat(args.TrackOffsetMin, args.TrackOffsetMax)})
    end
    -- Workaround for FMOD bug, after a long play-session VO played in 2D can become inaudible.  Pausing and unpausing the sound fixes it.
    thread(PauseUnpauseSoundWorkaround, AmbientMusicId)

end

-- Workaround for FMOD bug, after a long play-session VO played in 2D can become inaudible.  Pausing and unpausing the sound fixes it.
function PauseUnpauseSoundWorkaround(soundId)
    -- 暂停解除声音故障解决方案
    wait(0.03)
    PauseSound({Id = soundId, Duration = 0})
    ResumeSound({Id = soundId, Duration = 0})
end

-- 停止音乐家音乐
function StopMusicianMusic(source, args)
    -- 停止音乐家音乐
    StopSound({Id = AmbientMusicId, Duration = args.Duration or 0.2})
    AmbientMusicId = nil
    AmbientTrackName = nil
    if source ~= nil and source.ObjectId ~= nil then
        CurrentRun.EventState[source.ObjectId] = nil
    end
end

-- 设置默认音乐参数
function SetDefaultMusicParams(trackName, musicId)
    -- 设置默认音乐参数
    SetSoundCueValue({Names = {"Keys"}, Id = musicId, Value = 1})
    SetSoundCueValue({Names = {"Guitar", "Drums", "Bass"}, Id = musicId, Value = 1})

    SetMusicSection(1, musicId)

end

-- 随机音轨混合器
function RandomStemMixer(currentRoom, musicId)
    -- 随机音轨混合器
    if musicId == nil then
        return
    end
    if currentRoom.IgnoreStemMixer then
        return
    end
    local musicSetup = RandomInt(1, currentRoom.RandomStemMixerOptions or 3)
    if musicSetup == 1 then
        -- guitar, bass, drums
        SetSoundCueValue({Names = {"Guitar"}, Id = musicId, Value = 1, Duration = 2.5})
        SetSoundCueValue({Names = {"Bass"}, Id = musicId, Value = 1, Duration = 2.5})
        SetSoundCueValue({Names = {"Drums"}, Id = musicId, Value = 1, Duration = 0.25})
    elseif musicSetup == 2 then
        -- drums only
        SetSoundCueValue({Names = {"Guitar"}, Id = musicId, Value = 0, Duration = 10})
        SetSoundCueValue({Names = {"Bass"}, Id = musicId, Value = 0, Duration = 10})
        SetSoundCueValue({Names = {"Drums"}, Id = musicId, Value = 1, Duration = 0.25})
    elseif musicSetup == 3 then
        -- bass and drums only
        SetSoundCueValue({Names = {"Guitar"}, Id = musicId, Value = 0, Duration = 10})
        SetSoundCueValue({Names = {"Bass"}, Id = musicId, Value = 1, Duration = 2.5})
        SetSoundCueValue({Names = {"Drums"}, Id = musicId, Value = 1, Duration = 0.25})
    else
        -- guitar and drums only
        SetSoundCueValue({Names = {"Guitar"}, Id = musicId, Value = 1, Duration = 10})
        SetSoundCueValue({Names = {"Bass"}, Id = musicId, Value = 0, Duration = 2.5})
        SetSoundCueValue({Names = {"Drums"}, Id = musicId, Value = 1, Duration = 0.25})
    end
end

-- 音乐混合器
function MusicMixer(mixArgs)
    -- 音乐混合器
    if mixArgs == nil then
        return
    end

    if mixArgs.MusicMixerRequirements ~= nil and not IsGameStateEligible(CurrentRun, mixArgs, mixArgs.MusicMixerRequirements) then
        return
    end

    wait(mixArgs.MusicStartDelay)

    if mixArgs.PlayBiomeMusic then
        local biomeName = CurrentRun.CurrentRoom.RoomSetName
        local biomeMusicTracks = MusicTrackData[biomeName]
        if biomeMusicTracks ~= nil then
            if BiomeMusicPlayCounts[biomeName] == nil then
                BiomeMusicPlayCounts[biomeName] = 0
            end
            local trackIndex = (BiomeMusicPlayCounts[biomeName] % #biomeMusicTracks) + 1
            local trackData = biomeMusicTracks[trackIndex]
            MusicPlayer(trackData.Name, trackData)
            BiomeMusicPlayCounts[biomeName] = BiomeMusicPlayCounts[biomeName] + 1
        end
    end

    if MusicId == nil then
        return
    end
    if mixArgs.MusicActiveStems ~= nil then
        MusicActiveStems = mixArgs.MusicActiveStems
        SetSoundCueValue({Names = mixArgs.MusicActiveStems, Id = MusicId, Value = 1, Duration = 0.75})
    end
    if mixArgs.MusicMutedStems ~= nil then
        MusicMutedStems = mixArgs.MusicMutedStems
        SetSoundCueValue({Names = mixArgs.MusicMutedStems, Id = MusicId, Value = 0, Duration = mixArgs.MusicMutedStemsDuration or 0.75})
    end
    if mixArgs.MusicSection ~= nil then
        SetMusicSection(mixArgs.MusicSection)
    end
    if mixArgs.UseRoomMusicSection ~= nil and CurrentRun.CurrentRoom.MusicSection ~= nil then
        SetMusicSection(CurrentRun.CurrentRoom.MusicSection)
    end

end

-- 检查音乐事件
function CheckMusicEvents(currentRun, musicEvents)
    -- 检查音乐事件
    if musicEvents == nil then
        return
    end

    for k, musicEvent in ipairs(musicEvents) do

        if IsGameStateEligible(currentRun, musicEvent, musicEvent.GameStateRequirements) then

            if musicEvent.EndMusic then
                EndMusic()
            end

            thread(MusicMixer, musicEvent)

        end

    end

end

-- 开始Boss房间音乐
function StartBossRoomMusic()
    -- 开始Boss房间音乐
    SetMusicSection(2)
    local activeStemTable = {"Guitar", "Bass", "Drums"}
    SetSoundCueValue({Names = activeStemTable, Id = MusicId, Value = 1, Duration = 0.75})
end

-- 结束音乐
function EndMusic(musicId, musicName, hardStopTime)
    -- 结束音乐
    if musicId == nil then
        musicId = MusicId
    end
    if musicName == nil then
        musicName = MusicName
    end
    if hardStopTime == nil then
        hardStopTime = 20
    end

    if musicId == nil then
        return
    end

    SetMusicSection(10, musicId)

    if hardStopTime ~= nil then
        StopSound({Id = musicId, Value = 0.0, Duration = hardStopTime})
        StoppingMusicId = musicId
    end

    if musicId == MusicId then
        MusicId = nil
        MusicName = nil
        MusicSection = nil
    end

end

-- 暂停音乐
function PauseMusic()
    -- 暂停音乐
    PauseSound({Id = MusicId, Duration = 0.2})
end

-- 恢复音乐
function ResumeMusic(duration, delay)
    -- 恢复音乐
    if MusicId == nil then
        return
    end
    wait(delay)
    ResumeSound({Id = MusicId, Duration = duration or 0.2})
end

-- 暂停环境音乐
function PauseAmbientMusic()
    -- 暂停环境音乐
    PauseSound({Id = AmbientMusicId, Duration = 0.2})
    PauseSound({Id = SecretMusicId, Duration = 0.2})
end

-- 恢复环境音乐
function ResumeAmbientMusic()
    -- 恢复环境音乐
    ResumeSound({Id = AmbientMusicId, Duration = 0.2})
    SetVolume({Id = AmbientMusicId, Value = 1.0})
    ResumeSound({Id = SecretMusicId, Duration = 0.2})
end

-- 设置音乐段落
function SetMusicSection(section, musicId)
    -- 设置音乐段落
    if section == nil then
        return
    end
    if musicId == nil then
        musicId = MusicId
    end
    SetSoundCueValue({Names = {"Section", }, Id = musicId, Value = section})
    if musicId == MusicId then
        MusicSection = section
        MusicSectionStartDepth = CurrentRun.RunDepthCache
    end
end

-- 设置高级工具提示混合
function SetAdvancedTooltipMixing(value)
    -- 设置高级工具提示混合
    value = value or 0
    SetSoundCueValue({Id = GetMixingId({}), Names = {"Wagon"}, Value = value})
end

-- 检查音乐是否正在播放
function IsMusicPlaying()
    -- 检查音乐是否正在播放
    if MusicId ~= nil and MusicId > 0 then
        return true
    end
    return false
end

-- Music Marker logic
OnMusicMarker {"Marker End",
               function(triggerArgs)
                   -- 音乐标记逻辑
                   local markerName = triggerArgs.name
                   if markerName == "Marker End" then
                       notifyExistingWaiters("MusicTrackEnded")
                   end
               end
}

OnMusicMarker {"Shout",
               function(triggerArgs)
                   -- 音乐标记逻辑
                   if not AllowShout then
                       return
                   end

                   if MusicName ~= "/Music/MusicExploration4_MC" and MusicName ~= "/Music/MusicHadesReset_MC" then
                       return
                   end

                   if CurrentRun.Hero.LastKillTime == nil or _worldTime > CurrentRun.Hero.LastKillTime + 20 then
                       return
                   end

                   if IsEmpty(RequiredKillEnemies) then
                       return
                   end

                   PlaySound({Name = "/SFX/Shout1"})
                   AllowShout = false

               end
}

-- **AMBIENCE**
-- 开始房间环境音效
function StartRoomAmbience(currentRun, currentRoom)
    -- 开始房间环境音效
    local newTrackName = nil
    if currentRoom.Encounter then
        newTrackName = currentRoom.Encounter.Ambience
    end

    newTrackName = newTrackName or currentRoom.Ambience

    if newTrackName == "None" then
        -- Silence requested
        -- 请求静音
        StopSound({Id = AmbienceId, Duration = 0.5})
        AmbienceId = nil
        AmbienceName = nil
    elseif newTrackName ~= nil then
        -- Specific track requested
        -- 请求特定音轨
        if newTrackName ~= AmbienceName then
            StopSound({Id = AmbienceId, Duration = 0.5})
            AmbienceId = PlaySound({Name = newTrackName, Duration = 0.5})
            AmbienceName = newTrackName
        end
    else
        -- Nothing requested, use default biome track
        -- 没有请求，使用默认生物音轨
        local ambienceTrackName = nil
        local biomeAmbienceTracks = AmbienceTracks[currentRoom.RoomSetName]
        if biomeAmbienceTracks ~= nil then
            local trackIndex = (GetCompletedRuns() % #biomeAmbienceTracks) + 1
            local trackData = biomeAmbienceTracks[trackIndex]
            if trackData.Name ~= nil and trackData.Name ~= AmbienceName then
                StopSound({Id = AmbienceId, Duration = 0.5})
                AmbienceId = PlaySound({Name = trackData.Name, Duration = 0.5})
                AmbienceName = trackData.Name
            end
            if trackData.ReverbValue ~= nil then
                SetAudioEffectState({Name = "Reverb", Value = trackData.ReverbValue})
            end
        end
    end

    if currentRoom.ReverbValue ~= nil then
        SetAudioEffectState({Name = "Reverb", Value = currentRoom.ReverbValue})
    end

end

-- 结束环境音效
function EndAmbience(duration)
    -- 结束环境音效
    StopSound({Id = AmbienceId, Duration = duration or 0.2})
    AmbienceId = nil
    StopSound({Id = AmbientMusicId, Duration = duration or 0.2})
    AmbientMusicId = nil
    AmbientTrackName = nil
end

-- **VO**
-- Minos Voice Debug
OnKeyPressed {"Alt V", Name = "ToggleVoice",
              function(triggerArgs)
                  -- Minos语音调试
                  if CurrentRun.CurrentRoom.IntroVO ~= nil then
                      PlayRemainingSpeech(CurrentRun.CurrentRoom.IntroVO)
                  end
              end
}

-- 音频初始化
function AudioInit()
    -- 音频初始化
    PlayedRandomLines = PlayedRandomLines or {}
    AllowShout = true
    BiomeMusicPlayCounts = BiomeMusicPlayCounts or {}

end

-- 播放随机符合条件的语音行
function PlayRandomEligibleVoiceLines(voiceLineSets)
    -- 播放随机符合条件的语音行
    while not IsEmpty(voiceLineSets) do
        local voiceLines = RemoveRandomValue(voiceLineSets)
        local playedSomething = PlayVoiceLines(voiceLines, true)
        if playedSomething then
            return
        end
    end

end

-- 播放第一个符合条件的语音行
function PlayFirstEligibleVoiceLines(voiceLineSets)
    -- 播放第一个符合条件的语音行
    local highestIndex = GetHighestIndex(voiceLineSets)
    for index = 1, highestIndex do
        local voiceLines = voiceLineSets[index]
        if voiceLines ~= nil then
            local playedSomething = PlayVoiceLines(voiceLines, true)
            if playedSomething then
                return
            end
        end
    end

end

-- 播放语音行
function PlayVoiceLines(voiceLines, neverQueue, source, args)
    -- 播放语音行
    if args ~= nil and args.Defer then
        for k, v in pairs(DeferredPlayVoiceLines) do
            if v[1] == voiceLines then
                --DebugPrint({ Text = "voice lines play request de-duped"})
                return
            end
        end
        table.insert(DeferredPlayVoiceLines, {voiceLines, neverQueue, source, args})
        return
    end

    return PlayVoiceLinesReal(voiceLines, neverQueue, source, args)
end

-- 实际播放语音行
function PlayVoiceLinesReal(voiceLines, neverQueue, source, args)
    -- 实际播放语音行
    if voiceLines == nil then
        return
    end

    args = args or {}

    source = GetLineSource(voiceLines, source, args)
    if source == nil then
        -- Never play a line if the source doesn't exist
        -- 如果源对象不存在，则不播放语音行
        return
    end

    if not IsVoiceLineEligible(CurrentRun, voiceLines, nil, nil, source, args) then
        -- First check requirements of the whole set
        -- 首先检查整个集合的要求
        if voiceLines.PlayedNothingFunctionName ~= nil then
            local playedNothingFunction = _G[voiceLines.PlayedNothingFunctionName]
            if playedNothingFunction ~= nil then
                playedNothingFunction(source, voiceLines.PlayedNothingFunctionArgs)
            end
        end
        return
    end

    if source.PlayingVoiceLines then
        if voiceLines.Queue == "Interrupt" then
            -- Play as normal
            -- 正常播放
        else
            if neverQueue then
                --DebugPrint({ Text = "Skipped voiceLines on "..GetTableString( source.Name, source ) })
                return
            end
            if source.QueuedVoiceLines == nil then
                source.QueuedVoiceLines = {}
            end
            table.insert(source.QueuedVoiceLines, voiceLines)
            --DebugPrint({ Text = "Queued voiceLines on "..GetTableString( source.Name, source ) })
            return
        end
    end

    local playedSomething = false
    local parentLine = voiceLines

    source.PlayingVoiceLines = true
    if PlayVoiceLine(voiceLines, nil, nil, source, args) then
        playedSomething = true
    else
        if voiceLines.PlayedNothingFunctionName ~= nil then
            local playedNothingFunction = _G[voiceLines.PlayedNothingFunctionName]
            if playedNothingFunction ~= nil then
                playedNothingFunction(source, voiceLines.PlayedNothingFunctionArgs)
            end
        end
    end
    source.PlayingVoiceLines = false

    if not IsEmpty(source.QueuedVoiceLines) then
        local nextVoiceLines = RemoveFirstValue(source.QueuedVoiceLines)
        if PlayVoiceLines(nextVoiceLines, false, source, args) then
            playedSomething = true
        end
    end

    return playedSomething

end

-- 获取语音行源
function GetLineSource(line, source, args)
    -- 获取语音行源
    if line.ObjectType ~= nil then
        local typeIds = GetIdsByType({Name = line.ObjectType})
        if IsEmpty(typeIds) then
            return nil
        end
        local objectId = typeIds[1]
        source = ActiveEnemies[objectId]
        if source == nil then
            return nil
        else
            if line.RequiredSourceValue ~= nil and not source[line.RequiredSourceValue] then
                return nil
            end
            if line.RequiredSourceValueFalse ~= nil and source[line.RequiredSourceValueFalse] then
                return nil
            end
            return source
        end
    end

    if line.UsePlayerSource then
        return CurrentRun.Hero
    end

    if line.Source ~= nil then
        return line.Source
    end

    if source ~= nil then
        return source
    end

    return CurrentRun.Hero

end

-- 播放单个语音行
function PlayVoiceLine(line, prevLine, parentLine, source, args)
    -- 播放单个语音行
    local playedSomething = false

    if parentLine == nil then
        parentLine = line
    end

    args = args or {}
    args.ThreadName = line.ThreadName or args.ThreadName
    args.Queue = line.Queue or args.Queue
    args.BreakIfPlayed = line.BreakIfPlayed or args.BreakIfPlayed
    args.PlayOnceContext = line.PlayOnceContext or args.PlayOnceContext
    args.SubtitleMinDistance = line.SubtitleMinDistance or args.SubtitleMinDistance
    args.Actor = line.Actor or args.Actor
    args.AllowTalkOverTextLines = line.AllowTalkOverTextLines or args.AllowTalkOverTextLines
    -- By default, the player object is the ListenerId, though could be something else
    args.ListenerId = line.ListenerId or args.ListenerId or CurrentRun.Hero.ObjectId

    source = GetLineSource(line, source, args)
    if source == nil then
        -- Never play a line if the source doesn't exist
        -- 如果源对象不存在，则不播放语音行
        return
    end

    if line.SetFlagTrue ~= nil then
        GameState.Flags[line.SetFlagTrue] = true
    end
    if line.SetFlagFalse ~= nil then
        GameState.Flags[line.SetFlagFalse] = false
    end

    if line.TriggerCooldowns ~= nil then
        for k, cooldownName in pairs(line.TriggerCooldowns) do
            TriggerCooldown(cooldownName)
        end
    end

    -- Play this line
    if line.Cue ~= nil then

        if args.OnPlayedSomethingFunctionName ~= nil and not args.PlayedSomething then
            local onPlayedSomethingFunction = _G[args.OnPlayedSomethingFunctionName]
            if onPlayedSomethingFunction ~= nil then
                thread(onPlayedSomethingFunction, source, args.OnPlayedSomethingFunctionArgs)
            end
        end

        if line.PreLineThreadedFunctionName ~= nil then
            local preLineThreadedFunction = _G[line.PreLineThreadedFunctionName]
            thread(preLineThreadedFunction, source, line.PreLineThreadedFunctionArgs)
        end
        wait(line.PreLineWait or parentLine.PreLineWait, args.ThreadName)
        local preLineAnim = line.PreLineAnim or parentLine.PreLineAnim
        if preLineAnim ~= nil then
            SetAnimation({Name = preLineAnim, DestinationId = source.ObjectId})
        end

        local playedSpeechId = 0
        local useSubtitles = false
        if not source.Mute then
            if args.SubtitleMinDistance then
                local dist = GetDistance({Id = args.ListenerId, DestinationId = source.ObjectId})
                if dist > args.SubtitleMinDistance then
                    useSubtitles = false
                else
                    useSubtitles = true
                end
            else
                useSubtitles = true
            end
            if line.NoTarget or parentLine.NoTarget then
                playedSpeechId = PlaySpeech({Name = line.Cue, Queue = args.Queue, SubtitleColor = source.SubtitleColor, UseSubtitles = useSubtitles, Actor = args.Actor})
            elseif line.SkipAnim or parentLine.SkipAnim then
                playedSpeechId = PlaySpeechCueFromSource(line.Cue, source, false, args.Queue, useSubtitles, source.SubtitleColor, args)
            else
                playedSpeechId = PlaySpeechCueFromSource(line.Cue, source, true, args.Queue, useSubtitles, source.SubtitleColor, args)
            end
        end
        if line.UseOcclusion then
            SetSoundCueValue({Id = playedSpeechId, Names = {"VoiceOcclusion"}, Value = 1.0, Duration = 0.01})
        end
        if playedSpeechId > 0 then
            prevLine = line
            LastLinePlayed = line.Cue
            table.insert(CurrentRun.CurrentRoom.VoiceLinesPlayed, line.Cue)
            playedSomething = true
            args.PlayedSomething = true
            -- @refactor The SpeechRecord recording is pretty scattered / redundant
            SpeechRecord[line.Cue] = true
            CurrentRun.SpeechRecord[line.Cue] = true
            if args.PlayOnceContext ~= nil then
                GameState.SpeechRecordContexts[args.PlayOnceContext] = GameState.SpeechRecordContexts[args.PlayOnceContext] or {}
                GameState.SpeechRecordContexts[args.PlayOnceContext][line.Cue] = true
            end
            -- Intentionally leaving this on raw data for now to be wiped out on load
            line.LastPlayTime = _worldTime
            parentLine.LastPlayTime = _worldTime
            waitUntil(line.Cue)
            wait(line.PostLineWait or parentLine.PostLineWait, args.ThreadName)
            if line.PostLineFunctionName ~= nil then
                local postLineFunction = _G[line.PostLineFunctionName]
                postLineFunction(source, line.PostLineFunctionArgs)
            end
            if args.BreakIfPlayed then
                return playedSomething
            end
        else
            --DebugAssert({ Condition = playedSpeechId > 0, Text = "Speech failed to play: "..line.Cue })
        end
    end

    -- Play sublines
    if line.RandomRemaining then
        local eligibleUnplayedLines = {}
        local allEligibleLines = {}
        for k, subLine in ipairs(line) do
            if IsVoiceLineEligible(CurrentRun, subLine, prevLine, line, source, args) then
                table.insert(allEligibleLines, subLine)
                if not PlayedRandomLines[subLine.Cue] then
                    table.insert(eligibleUnplayedLines, subLine)
                end
            end
        end
        if not IsEmpty(allEligibleLines) then
            local randomLine = nil
            if IsEmpty(eligibleUnplayedLines) then
                -- All lines played, start the record over
                for k, subLine in ipairs(line) do
                    PlayedRandomLines[subLine.Cue] = nil
                end
                randomLine = GetRandomValue(allEligibleLines)
            else
                randomLine = GetRandomValue(eligibleUnplayedLines)
            end
            PlayedRandomLines[randomLine.Cue] = true
            -- Effectively pass down by value rather than reference
            local subLineArgs = ShallowCopyTable(args)
            if PlayVoiceLine(randomLine, prevLine, line, source, subLineArgs) then
                prevLine = randomLine
                playedSomething = true
                args.PlayedSomething = true
                if args.BreakIfPlayed or randomLine.BreakIfPlayed or subLineArgs.BreakIfPlayed then
                    return playedSomething
                end
            end
        end
    else
        for k, subLine in ipairs(line) do
            if IsVoiceLineEligible(CurrentRun, subLine, prevLine, line, source, args) then
                -- Effectively pass down by value rather than reference
                local subLineArgs = ShallowCopyTable(args)
                if PlayVoiceLine(subLine, prevLine, line, source, subLineArgs) then
                    prevLine = subLine
                    playedSomething = true
                    args.PlayedSomething = true
                    if args.BreakIfPlayed or subLine.BreakIfPlayed or subLineArgs.BreakIfPlayed then
                        return playedSomething
                    end
                end
            end
        end
    end

    return playedSomething

end

-- 清理当前语音ID
function CleanUpCurrentSpeechId(cue, speechId, source, animation)
    -- 清理当前语音ID
    if speechId == nil then
        return
    end
    waitUntil(cue)
    if animation ~= nil then
        if StopStatusAnimation(source, animation) and not source.BlockStatusAnimations and ConfigOptionCache.ShowUIAnimations and ConfigOptionCache.ShowSpeechBubble then
            local endAnimation = animation .. "_End"
            CreateAnimation({Name = endAnimation, DestinationId = source.ObjectId, OffsetX = source.AnimOffsetX, OffsetZ = source.AnimOffsetZ})
        end
    end
    -- 清理当前语音ID
    if CurrentSpeechId == speechId then
        CurrentSpeechId = nil
    end
end

-- 播放语音提示
function PlaySpeechCue(cue, source, animation, queue, useSubtitles, subtitleColor, args)
    -- 播放语音提示
    if cue == nil or cue == "" then
        return 0
    end

    -- 获取参数
    args = args or {}

    -- 获取源对象ID
    local sourceId = nil
    if source ~= nil then
        sourceId = source.ObjectId
    end

    -- 播放语音
    local speechId = PlaySpeech({Name = cue, Id = sourceId, Queue = queue, UseSubtitles = useSubtitles, SubtitleColor = subtitleColor, Actor = args.Actor})
    -- 如果语音播放成功，则播放动画
    if speechId > 0 then
        if source ~= nil and animation ~= nil and ConfigOptionCache.ShowUIAnimations and ConfigOptionCache.ShowSpeechBubble then
            PlayStatusAnimation(source, {Animation = animation})
        end
        -- 记录当前语音ID
        CurrentSpeechId = speechId
        -- @refactor The SpeechRecord recording is pretty scattered / redundant
        -- 记录语音播放记录
        SpeechRecord[cue] = true
        CurrentRun.SpeechRecord[cue] = true
        -- 清理当前语音ID
        thread(CleanUpCurrentSpeechId, cue, speechId, source, animation)
    end
    -- 返回语音ID
    return speechId

end

-- 从源播放语音提示
function PlaySpeechCueFromSource(cue, source, useDefaultAnim, queue, useSubtitles, subtitleColor, args)
    -- 从源播放语音提示
    if PlayingTextLines and not args.AllowTalkOverTextLines then
        return 0

    end

    -- 如果源对象为空，则使用英雄对象
    if source == nil then
        source = CurrentRun.Hero
    end
    -- 如果使用默认动画，则设置动画
    if useDefaultAnim == nil then
        useDefaultAnim = true
    end
    -- 获取动画名称
    local anim = nil
    if useDefaultAnim then
        anim = StatusAnimations.Speaking
    end
    -- 播放语音提示
    return PlaySpeechCue(cue, source, anim, queue, useSubtitles, subtitleColor, args)
end

-- 检查语音是否符合播放条件
function IsVoiceLineEligible(currentRun, line, prevLine, parentLine, source, args)
    -- 检查语音是否符合播放条件
    if line == nil then
        return false
    end

    -- 获取参数
    args = args or {}

    -- 如果源对象不为空，则检查源对象条件
    if source ~= nil then
        -- 如果源对象被魅惑，则返回false
        if line.RequiresFalseCharmed ~= nil and source.Charmed then
            return false
        end
        -- 如果源对象未被魅惑，则返回false
        if line.RequiresCharmed ~= nil and not source.Charmed then
            return false
        end
        -- 如果源对象不满足条件，则返回false
        if line.RequiredSourceValue ~= nil and not source[line.RequiredSourceValue] then
            return false
        end
        -- 如果源对象满足条件，则返回false
        if line.RequiredSourceValueFalse ~= nil and source[line.RequiredSourceValueFalse] then
            return false
        end
    end

    -- 如果参数不为空，则检查参数条件
    if args ~= nil and args.ElapsedTime ~= nil then
        -- 如果参数时间小于最小时间，则返回false
        if line.RequiredMinElapsedTime ~= nil and args.ElapsedTime < line.RequiredMinElapsedTime then
            return false
        end
        -- 如果参数时间大于最大时间，则返回false
        if line.RequiredMaxElapsedTime ~= nil and args.ElapsedTime > line.RequiredMaxElapsedTime then
            return false
        end
    end

    -- 如果语音行有显式条件，则检查条件
    if line.ExplicitRequirements or (parentLine ~= nil and parentLine.ExplicitRequirements) then
        -- 如果语音行不满足条件，则返回false
        if line.GameStateRequirements ~= nil and not IsGameStateEligible(currentRun, line, line.GameStateRequirements) then
            return false
        end
    else
        -- 如果语音行不满足条件，则返回false
        if not IsGameStateEligible(currentRun, line, line.GameStateRequirements) then
            return false
        end
    end

    -- 如果语音行有播放次数限制，则检查限制
    if line.PlayOnceFromTableThisRun then
        -- 如果语音行已经播放，则返回false
        for k, subLine in ipairs(line) do
            if subLine.Cue ~= nil and currentRun.SpeechRecord[subLine.Cue] then
                return false
            end
        end
    end

    -- 如果语音行有连续播放概率，则检查概率
    if line.SuccessiveChanceToPlay ~= nil then
        -- 如果语音行已经播放，则返回false
        local anyLinePlayed = false
        for k, subLine in ipairs(line) do
            if subLine.Cue ~= nil and SpeechRecord[subLine.Cue] then
                anyLinePlayed = true
                break
            end
        end
        -- 如果语音行未播放，则返回false
        if anyLinePlayed and not RandomChance(line.SuccessiveChanceToPlay) then
            return false
        end
    end

    -- 如果语音行有连续播放概率，则检查概率
    if line.SuccessiveChanceToPlayAll ~= nil then
        -- 如果语音行已经播放，则返回false
        local allLinesPlayed = true
        for k, subLine in ipairs(line) do
            if subLine.Cue ~= nil and not SpeechRecord[subLine.Cue] then
                allLinesPlayed = false
                break
            end
        end
        -- 如果语音行未播放，则返回false
        if allLinesPlayed and not RandomChance(line.SuccessiveChanceToPlayAll) then
            return false
        end
    end

    -- 如果语音行有源对象条件，则检查条件
    if line.Cue ~= nil then

        -- 如果语音行有播放次数限制，则检查限制
        if line.PlayOnce or (parentLine ~= nil and parentLine.PlayOnce) then
            -- 如果语音行已经播放，则返回false
            if args.PlayOnceContext ~= nil then
                DebugPrint({Text = "checking context = " .. tostring(args.PlayOnceContext)})
                GameState.SpeechRecordContexts[args.PlayOnceContext] = GameState.SpeechRecordContexts[args.PlayOnceContext] or {}
                if GameState.SpeechRecordContexts[args.PlayOnceContext][line.Cue] then
                    return false
                end
            elseif SpeechRecord[line.Cue] then
                return false
            end
        end

        -- 如果语音行有播放次数限制，则检查限制
        if line.PlayOnceThisRun or (parentLine ~= nil and parentLine.PlayOnceThisRun) then
            -- 如果语音行已经播放，则返回false
            if currentRun.SpeechRecord[line.Cue] then
                return false
            end
        end

        -- 如果语音行有连续播放概率，则检查概率
        local chanceToPlayAgain = line.ChanceToPlayAgain or (parentLine ~= nil and parentLine.ChanceToPlayAgain)
        -- 如果语音行已经播放，则返回false
        if chanceToPlayAgain and SpeechRecord[line.Cue] and not RandomChance(chanceToPlayAgain) then
            return false
        end

        -- 如果语音行有冷却时间，则检查冷却时间
        if line.CooldownTime ~= nil then
            -- 如果语音行未冷却，则返回false
            if not CheckCooldown(line.CooldownName or line.Cue, line.CooldownTime) then
                --DebugPrint({ Text = "VO blocked from cooldown: "..tostring(line.CooldownName or line.Cue) })
                return false
            end
        end
        -- 如果语音行有冷却时间，则检查冷却时间
        if line.Cooldowns ~= nil then
            -- 如果语音行未冷却，则返回false
            for k, cooldown in pairs(line.Cooldowns) do
                local cooldownTime = cooldown.Time or line.CooldownTime
                if cooldownTime == nil and source ~= nil then
                    cooldownTime = source.SpeechCooldownTime
                end
                if not CheckCooldown(cooldown.Name, cooldownTime) then
                    --DebugPrint({ Text = "VO blocked from cooldown: "..tostring(cooldown.Name) })
                    return false
                end
            end
        end

    else

        -- 如果语音行有冷却时间，则检查冷却时间
        if line.CooldownTime ~= nil then
            -- 如果语音行未冷却，则返回false
            local cooldownName = line.CooldownName
            if cooldownName == nil and line[1] ~= nil then
                cooldownName = line[1].CooldownName or line[1].Cue
            end
            if cooldownName ~= nil and not CheckCooldown(cooldownName, line.CooldownTime) then
                --DebugPrint({ Text = "VO blocked from cooldown: "..tostring(cooldownName) })
                return false
            end
        end
        -- 如果语音行有冷却时间，则检查冷却时间
        if line.Cooldowns ~= nil then
            -- 如果语音行未冷却，则返回false
            for k, cooldown in pairs(line.Cooldowns) do
                local cooldownTime = cooldown.Time or line.CooldownTime
                if cooldownTime == nil and source ~= nil then
                    cooldownTime = source.SpeechCooldownTime
                end
                if not CheckCooldown(cooldown.Name, cooldownTime) then
                    --DebugPrint({ Text = "VO blocked from cooldown: "..tostring(cooldown.Name) })
                    return false
                end
            end
        end

    end

    -- 如果语音行需要源对象活着，则检查源对象
    if line.RequiresSourceAlive then
        -- 如果源对象为空，则返回false
        if line.ObjectType ~= nil then
            local typeIds = GetIdsByType({Name = line.ObjectType})
            local objectId = typeIds[1]
            source = ActiveEnemies[objectId]
        end
        -- 如果源对象为空或死亡，则返回false
        if source == nil or source.IsDead then
            return false
        end
    end

    -- 如果语音行满足所有条件，则返回true
    return true

end

-- 有时播放战斗结束语音
function SometimesPlayCombatResolvedVoiceLines()
    -- 有时播放战斗结束语音
    if not RandomChance(0.25) then
        return
    end
    local currentHealthFraction = CurrentRun.Hero.Health / CurrentRun.Hero.MaxHealth
    if currentHealthFraction >= 0.95 then
        thread(PlayVoiceLines, GlobalVoiceLines.CombatResolvedHighHealthLines, true)
    elseif currentHealthFraction >= 0.3 and currentHealthFraction < 0.95 then
        thread(PlayVoiceLines, GlobalVoiceLines.CombatResolvedMediumHealthLines, true)
    elseif currentHealthFraction < 0.3 then
        thread(PlayVoiceLines, GlobalVoiceLines.CombatResolvedLowHealthLines, true)
    end
end

-- 环境聊天
function AmbientChatting(source, args)

    -- play a random line from ChattingRepeatable or similar table, from the character source position, with speech bubble; when player gets sufficiently close, play an 'interrupt' line, interrupting the ambient line if it's still playing
    -- 环境聊天
    if args.StartDistance ~= nil then
        local notifyName = "StartDistance" .. source.Name
        NotifyWithinDistanceAny({Ids = {CurrentRun.Hero.ObjectId}, DestinationIds = {source.ObjectId}, Distance = args.StartDistance, Notify = notifyName})
        waitUntil(notifyName)
    end

    thread(CheckDistanceTrigger, args.DistanceTrigger, source)
    PlayVoiceLines(args.VoiceLines, nil, source)
    -- source.BlockStatusAnimations = true
    wait(1.5)
    -- source.BlockStatusAnimations = false

end
