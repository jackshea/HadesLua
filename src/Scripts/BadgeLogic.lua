-- 使用徽章商人功能，处理玩家与徽章商人的交互
function UseBadgeSeller(usee, args)

    -- 如果徽章商人信息不存在，则退出函数
    if not TextLinesRecord.BadgeSellerInfo01 then
        return
    end

    -- 获取下一个徽章等级和数据
    local nextRank = (GameState.BadgeRank or 0) + 1
    local nextBadgeData = GameData.BadgeData[GameData.BadgeOrderData[nextRank]]
    if nextBadgeData == nil then
        -- 如果已经达到最高等级，则退出函数
        return
    end

    -- 检查是否有足够的资源购买下一个徽章
    if nextBadgeData.ResourceCost ~= nil then
        local hasAllResources = true
        for k, resourceCost in pairs(nextBadgeData.ResourceCost) do
            if not HasResource(resourceCost.Name, resourceCost.Amount) then
                hasAllResources = false
                break
            end
        end

        -- 如果没有足够的资源，则显示无法购买提示并退出函数
        if not hasAllResources then
            BadgeCannotAffordPresentation(usee, nextBadgeData)
            return
        end

        -- 购买徽章并处理资源消耗
        AddInputBlock({Name = "BadgeResourceSpend"})
        for k, resourceCost in pairs(nextBadgeData.ResourceCost) do
            SpendResource(resourceCost.Name, resourceCost.Amount)
            BadgeResourceSpendPresentation(usee, resourceCost)
        end
        RemoveInputBlock({Name = "BadgeResourceSpend"})
    end

    -- 更新徽章等级和购买状态
    GameState.BadgeRank = nextRank
    CurrentRun.BadgePurchased = true

    -- 显示徽章购买提示
    BadgePurchasePresentation(usee, nextBadgeData)
    UseableOff({Id = usee.ObjectId})

end
