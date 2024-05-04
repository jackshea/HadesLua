-- 创建一个空的表来存储解锁的成就
SessionAchivementUnlocks = {}

-- 定义一个函数来检查成就的进度
function CheckProgressAchievements(args)

    -- 如果游戏状态为空，则返回
    if GameState == nil then
        return
    end

    args = args or {}

    local threadName = "CheckAchievementStatus"
    if not args.Silent then
        if SetThreadWait(threadName, 0.3) then
            return
        end
        wait(0.3, threadName)
    end

    -- 遍历所有的成就数据
    for achievementName, achievementData in pairs(GameData.AchievementData) do
        -- 如果成就不是仅供调试使用，并且在本次会话中还未解锁
        if not achievementData.DebugOnly and not SessionAchivementUnlocks[achievementName] then
            -- 如果成就的完成条件满足
            if achievementData.CompleteGameStateRequirements ~= nil and IsGameStateEligible(CurrentRun, achievementData, achievementData.CompleteGameStateRequirements) then
                -- 解锁成就
                UnlockAchievement({Name = achievementName})
                -- 将成就标记为已解锁
                SessionAchivementUnlocks[achievementName] = true
                wait(0.5, threadName)
            else
                wait(0.02, threadName) -- 分布工作负载在帧上
            end
        end
    end
end

-- 定义一个函数来检查单个成就
function CheckAchievement(args)
    local achievementData = GameData.AchievementData[args.Name]
    if achievementData == nil then
        return
    end
    if SessionAchivementUnlocks[args.Name] then
        return
    end

    -- 如果当前值和目标值都存在
    if args.CurrentValue ~= nil and achievementData.GoalValue ~= nil then
        -- 如果当前值大于等于目标值
        if args.CurrentValue >= achievementData.GoalValue then
            -- 解锁成就
            UnlockAchievement({Name = args.Name})
            -- 将成就标记为已解锁
            SessionAchivementUnlocks[args.Name] = true
        end
        return
    end

    local achievementData = GameData.AchievementData[args.Name]
    -- 如果成就的完成条件满足
    if achievementData.CompleteGameStateRequirements == nil or IsGameStateEligible(CurrentRun, achievementData, achievementData.CompleteGameStateRequirements) then
        -- 解锁成就
        UnlockAchievement({Name = args.Name})
        -- 将成就标记为已解锁
        SessionAchivementUnlocks[args.Name] = true
    end
end