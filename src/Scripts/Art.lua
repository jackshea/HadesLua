-- 检查是否需要进行阴影处理
local checkShadows = false

-- 处理玩家的阴影效果
function DoPlayerShadows(currentRun)
    -- 获取所有名为"PlayerShadows"的对象的ID
    local shadowIds = GetIds({Name = "PlayerShadows"})
    -- 获取当前英雄的对象ID
    local heroId = currentRun.Hero.ObjectId

    local inShadow = "InShadow"
    local outOfShadow = "OutOfShadow"
    -- 开始检查阴影
    checkShadows = true
    while (checkShadows) do
        -- 当英雄进入阴影区域时，通知"inShadow"
        NotifyOnCollide({Id = heroId, DestinationIds = shadowIds, Notify = inShadow})
        waitUntil(inShadow)
        -- 设置英雄的环境光照强度为0.7
        SetThingProperty({Property = "Ambient", Value = 0.7, DestinationId = currentRun.Hero.ObjectId})

        if checkShadows then
            -- 当英雄离开阴影区域时，通知"outOfShadow"
            NotifyNotColliding({Id = heroId, DestinationIds = shadowIds, Notify = outOfShadow})
            waitUntil(outOfShadow)
            -- 设置英雄的环境光照强度为0.0
            SetThingProperty({Property = "Ambient", Value = 0.0, DestinationId = currentRun.Hero.ObjectId})
        end
    end
end

-- 设置房间的艺术效果
function SetupRoomArt(currentRun, currentRoom)
    -- 获取当前区域的名称
    local currentArea = currentRun.CurrentRoom.RoomSetName

    -- 如果当前区域是"Secrets"或者"Tartarus"，则处理玩家的阴影效果
    if currentArea == "Secrets" then
        thread(DoPlayerShadows, currentRun)
        CreateAnimation({Name = "ReflectionBlob", DestinationId = currentRun.Hero.ObjectId, OffsetY = 100, Scale = 1})
    elseif currentArea == "Tartarus" then
        thread(DoPlayerShadows, currentRun)
    end

    -- 如果当前房间有脚步动画，则替换脚步动画
    if currentRoom.FootstepAnimationL ~= nil then
        SwapAnimation({Name = "FireFootstepL-Spawner", DestinationName = currentRoom.FootstepAnimationL})
    end
    if currentRoom.FootstepAnimationR ~= nil then
        SwapAnimation({Name = "FireFootstepR-Spawner", DestinationName = currentRoom.FootstepAnimationR})
    end

    -- 如果当前房间有动画替换规则，则替换动画
    if currentRoom.SwapAnimations ~= nil then
        for fromAnim, toAnim in pairs(currentRoom.SwapAnimations) do
            SwapAnimation({Name = fromAnim, DestinationName = toAnim})
        end
    end

    -- 如果当前房间有声音替换规则，则替换声音
    if currentRoom.SwapSounds ~= nil then
        for fromSound, toSound in pairs(currentRoom.SwapSounds) do
            SwapSound({Name = fromSound, DestinationName = toSound})
        end
    end
end

-- 清理房间的艺术效果
function TeardownRoomArt(currentRun, currentRoom)
    -- 停止检查阴影
    checkShadows = false
    -- 停止所有等待"InShadow"和"OutOfShadow"的线程
    killWaitUntilThreads("InShadow")
    killWaitUntilThreads("OutOfShadow")

    -- 设置英雄的环境光照强度为0.0
    SetThingProperty({Property = "Ambient", Value = 0.0, DestinationId = currentRun.Hero.ObjectId})
end