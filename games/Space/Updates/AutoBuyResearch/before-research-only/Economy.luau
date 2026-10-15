-- Deterministic economy. All actions receive server time; clients never supply rewards.
local Economy = {}
Economy.__index = Economy
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local MonetizationCatalog = require(ReplicatedStorage:WaitForChild("ClickerKit"):WaitForChild("MonetizationCatalog"))
local MonetizationRules = require(ReplicatedStorage.ClickerKit:WaitForChild("MonetizationRules"))
local function number(v, fallback, max)
    if type(v) ~= "number" or v ~= v or v == math.huge or v == -math.huge then
        return fallback or 0
    end
    return math.clamp(v, 0, max or 1e18)
end
local function finite(v)
    return type(v) == "number" and v == v and v ~= math.huge and v ~= -math.huge
end
local function count(v, max)
    return math.floor(number(v, 0, max or 1000000))
end
local function clone(t)
    local r = {}
    for k, v in pairs(t or {}) do
        r[k] = type(v) == "table" and clone(v) or v
    end
    return r
end
local function find(list, id)
    for _, v in ipairs(list) do
        if v.Id == id then
            return v
        end
    end
    return nil
end
local function formatAmount(value)
    local digits = tostring(math.floor(value))
    local groups = {}
    while #digits > 3 do
        table.insert(groups, 1, string.sub(digits, -3))
        digits = string.sub(digits, 1, -4)
    end
    table.insert(groups, 1, digits)
    return table.concat(groups, ",")
end
function Economy.new(config, catalog, progression)
    return setmetatable({ Config = config, Catalog = catalog, P = progression }, Economy)
end
function Economy:New(now)
    return {
        Currency = 0,
        LifetimeCurrency = 0,
        RunEarned = 0,
        TotalClicks = 0,
        LifetimePurchases = 0,
        TotalExpeditions = 0,
        Upgrades = {},
        Research = {},
        Permanent = {},
        ClaimedAchievements = {},
        UnlockedZones = { [self.Config.Zones[1].Id] = true },
        CurrentZone = self.Config.Zones[1].Id,
        Prestiges = 0,
        Stars = 0,
        Expedition = nil,
        LastSeen = now,
        PendingOfflineDoubleProductionBonus = 0,
        PaidBoostEndsAt = 0,
        ProcessedReceipts = {},
        EquippedCosmetic = nil,
        AutoBuyEnabled = false,
        Daily = { Day = math.floor(now / 86400), Baseline = { Clicks = 0, Purchases = 0, Trips = 0 }, Claimed = {} },
        Runtime = {
            Charge = 0,
            BurstEndsAt = 0,
            EventEndsAt = 0,
            EventNextAt = now + self.P.Collectible.FirstDelay,
            EventNonce = 0,
            OwnedPasses = {},
            AutoTapAccumulator = 0,
            AutoBuyAccumulator = 0,
            NoticeSerial = 0,
            Notice = "",
            NoticeKind = "",
            OfflineEarned = 0,
            OfflineSeconds = 0,
            ReceiptLedgerBytes = 2,
        },
    }
end
function Economy:Normalize(saved, now)
    local d = self:New(now)
    if type(saved) ~= "table" then
        return d
    end
    for _, k in ipairs({ "Currency", "LifetimeCurrency", "RunEarned", "Stars" }) do
        d[k] = number(saved[k], 0, self.Config.MaximumCurrency)
    end
    for _, k in ipairs({ "TotalClicks", "LifetimePurchases", "TotalExpeditions", "Prestiges" }) do
        d[k] = count(saved[k], 9e15)
    end
    for _, v in ipairs(self.Catalog) do
        d.Upgrades[v.Id] = count(type(saved.Upgrades) == "table" and saved.Upgrades[v.Id], 100000)
    end
    for _, kind in ipairs({ "Research", "Permanent" }) do
        for _, v in ipairs(self.P[kind]) do
            d[kind][v.Id] = count(type(saved[kind]) == "table" and saved[kind][v.Id], v.Max)
        end
    end
    for _, z in ipairs(self.Config.Zones) do
        if type(saved.UnlockedZones) == "table" and saved.UnlockedZones[z.Id] == true then
            d.UnlockedZones[z.Id] = true
        end
    end
    if type(saved.CurrentZone) == "string" and d.UnlockedZones[saved.CurrentZone] then
        d.CurrentZone = saved.CurrentZone
    end
    d.AutoBuyEnabled = saved.AutoBuyEnabled == true and self:AutoBuyUnlocked(d)
    for _, a in ipairs(self.P.Achievements) do
        if type(saved.ClaimedAchievements) == "table" and saved.ClaimedAchievements[a.Id] == true then
            d.ClaimedAchievements[a.Id] = true
        end
    end
    d.LastSeen = number(saved.LastSeen, now, now)
    d.PendingOfflineDoubleProductionBonus =
        number(saved.PendingOfflineDoubleProductionBonus, 0, self.Config.MaximumCurrency)
    if type(saved.OwnedPasses) == "table" then
        for key in pairs(MonetizationCatalog.Passes) do
            if type(saved.OwnedPasses[key]) == "boolean" then
                d.Runtime.OwnedPasses[key] = saved.OwnedPasses[key]
            end
        end
    end
    d.PaidBoostEndsAt = number(saved.PaidBoostEndsAt, 0, 1e18)
    d.EquippedCosmetic = type(saved.EquippedCosmetic) == "string"
            and MonetizationCatalog.Cosmetics[saved.EquippedCosmetic]
            and saved.EquippedCosmetic
        or nil
    if type(saved.ProcessedReceipts) == "table" then
        for purchaseId, receipt in pairs(saved.ProcessedReceipts) do
            local effect = type(receipt) == "table" and receipt.Effect
            local validEffect = type(effect) == "table"
                and (
                    (effect.Type == "Currency" and finite(effect.Amount) and effect.Amount > 0)
                    or (effect.Type == "PaidBoost" and finite(effect.EndsAt) and effect.EndsAt > 0)
                )
            if
                type(purchaseId) == "string"
                and #purchaseId > 0
                and #purchaseId <= 128
                and type(receipt) == "table"
                and receipt.Status == "Granted"
                and receipt.PurchaseId == purchaseId
                and validEffect
            then
                d.ProcessedReceipts[purchaseId] = clone(receipt)
            end
        end
    end
    d.Runtime.ReceiptLedgerBytes = #HttpService:JSONEncode(d.ProcessedReceipts)
    if type(saved.Expedition) == "table" then
        local def = find(self.P.Expeditions, saved.Expedition.Id)
        if def then
            d.Expedition = {
                Id = def.Id,
                EndsAt = number(saved.Expedition.EndsAt, now, now + def.Duration),
                Reward = number(saved.Expedition.Reward, 0, self.Config.MaximumCurrency),
            }
        end
    end
    local daily = saved.Daily
    if type(daily) == "table" and daily.Day == d.Daily.Day then
        if type(daily.Baseline) == "table" then
            for metric, total in pairs({
                Clicks = d.TotalClicks,
                Purchases = d.LifetimePurchases,
                Trips = d.TotalExpeditions,
            }) do
                d.Daily.Baseline[metric] = number(daily.Baseline[metric], total, total)
            end
        end
        for _, a in ipairs(self.P.Daily) do
            if type(daily.Claimed) == "table" and daily.Claimed[a.Id] == true then
                d.Daily.Claimed[a.Id] = true
            end
        end
    else
        self:ResetDaily(d, now)
    end
    return d
end
function Economy:ResetDaily(d, now)
    d.Daily = {
        Day = math.floor(now / 86400),
        Baseline = { Clicks = d.TotalClicks, Purchases = d.LifetimePurchases, Trips = d.TotalExpeditions },
        Claimed = {},
    }
end
function Economy:Serialize(d, now)
    local result = { Version = 2, LastSeen = now }
    for _, k in ipairs({
        "Currency",
        "LifetimeCurrency",
        "RunEarned",
        "TotalClicks",
        "LifetimePurchases",
        "TotalExpeditions",
        "Prestiges",
        "Stars",
        "CurrentZone",
    }) do
        result[k] = d[k]
    end
    for _, k in ipairs({ "Upgrades", "Research", "Permanent", "ClaimedAchievements", "UnlockedZones", "Daily" }) do
        result[k] = clone(d[k])
    end
    result.Expedition = d.Expedition and clone(d.Expedition) or nil
    result.AutoBuyEnabled = d.AutoBuyEnabled == true
    result.PaidBoostEndsAt = d.PaidBoostEndsAt or 0
    result.ProcessedReceipts = clone(d.ProcessedReceipts or {})
    result.EquippedCosmetic = d.EquippedCosmetic
    result.OwnedPasses = clone(d.Runtime.OwnedPasses or {})
    result.PendingOfflineDoubleProductionBonus = d.PendingOfflineDoubleProductionBonus or 0
    return result
end
function Economy:WorldCount(d)
    local n = 0
    for _, z in ipairs(self.Config.Zones) do
        if d.UnlockedZones[z.Id] then
            n += 1
        end
    end
    return n
end
function Economy:AutoBuyUnlocked(d)
    return (d.Research[self.P.AutoBuy.ResearchId] or 0) >= 1
        and self:WorldCount(d) >= self.P.AutoBuy.RequiredWorld
end
function Economy:Zone(d)
    return find(self.Config.Zones, d.CurrentZone) or self.Config.Zones[1]
end
function Economy:BurstMultiplier(d, now)
    return d.Runtime.BurstEndsAt > now and self.P.Burst.Multiplier or 1
end
function Economy:PassMultiplier(d)
    local owned = d.Runtime and d.Runtime.OwnedPasses or {}
    return owned.DoubleProduction == true and 2 or 1
end
function Economy:PaidMultiplier(d, now)
    local multiplier = self:PassMultiplier(d)
    if (d.PaidBoostEndsAt or 0) > now then
        multiplier *= 2
    end
    return multiplier
end
function Economy:BurstDuration(d)
    return self.P.Burst.Duration + (d.Research.Capacity or 0) * 0.75 + (d.Permanent.Power or 0)
end
function Economy:Mastery(d)
    return (1 + d.Prestiges * self.Config.Prestige.MultiplierPerPrestige) * (1 + (d.Permanent.Mastery or 0) * 0.1)
end
function Economy:ClickCore(d)
    local base = self.Config.BaseClickPower
    for _, v in ipairs(self.Catalog) do
        base += v.ClickBonus * (d.Upgrades[v.Id] or 0)
    end
    return base
        * self:Zone(d).Multiplier
        * self:Mastery(d)
        * (1 + (d.Research.Focus or 0) * 0.2)
        * (1 + (d.Permanent.Touch or 0) * 0.25)
end
function Economy:ClickPower(d, now)
    return self:ClickCore(d) * self:PaidMultiplier(d, now) * self:BurstMultiplier(d, now)
end
function Economy:PassiveCore(d)
    local rate = 0
    for _, v in ipairs(self.Catalog) do
        rate += v.PassivePerSecond * (d.Upgrades[v.Id] or 0)
    end
    return math.min(
        rate
            * self:Zone(d).Multiplier
            * self:Mastery(d)
            * (1 + (d.Research.Efficiency or 0) * 0.15)
            * (1 + (d.Permanent.Automation or 0) * 0.2),
        self.Config.MaximumCurrency
    )
end
function Economy:Passive(d, now, unboosted)
    return math.min(
        self:PassiveCore(d) * self:PaidMultiplier(d, now) * (unboosted and 1 or self:BurstMultiplier(d, now)),
        self.Config.MaximumCurrency
    )
end
function Economy:GameplayEnergyReward(d, baseEnergy, clickCount, incomeSeconds, now)
    baseEnergy = number(baseEnergy, 0, self.Config.MaximumCurrency)
    clickCount = number(clickCount, 0, 1000000)
    incomeSeconds = number(incomeSeconds, 0, 1000000)
    local reward = baseEnergy + self:ClickPower(d, now) * clickCount + self:Passive(d, now, false) * incomeSeconds
    if reward ~= reward then
        return 0
    end
    return math.clamp(reward, 0, self.Config.MaximumCurrency)
end
function Economy:Cost(def, owned, d, producer)
    local price = (def.BaseCost or def.Cost) * (def.CostMultiplier or def.Growth) ^ math.min(owned, 1000)
    if producer then
        price *= 1 - (d.Research.Discount or 0) * 0.02
    end
    return math.max(1, math.floor(math.min(price, self.Config.MaximumCurrency) + 0.5))
end
function Economy:Add(d, amount)
    amount = number(amount, 0, self.Config.MaximumCurrency)
    local earned = math.min(amount, self.Config.MaximumCurrency - d.Currency)
    d.Currency += earned
    d.LifetimeCurrency = math.min(self.Config.MaximumCurrency, d.LifetimeCurrency + earned)
    d.RunEarned = math.min(self.Config.MaximumCurrency, d.RunEarned + earned)
    return earned
end
function Economy:ProductPurchaseNotice(receiptStatus, offer)
    if
        receiptStatus ~= "Granted"
        or type(offer) ~= "table"
        or type(offer.Name) ~= "string"
        or type(offer.Grant) ~= "table"
    then
        return nil
    end
    local grant = offer.Grant
    if grant.Type == "Currency" then
        local amount = number(grant.Amount, 0, self.Config.MaximumCurrency)
        if amount <= 0 or amount % 1 ~= 0 then
            return nil
        end
        return offer.Name .. " purchased: +" .. formatAmount(amount) .. " Energy."
    elseif grant.Type == "PaidBoost" then
        local duration = number(grant.DurationSeconds, 0, self.Config.MaximumCurrency)
        if duration <= 0 or duration % 60 ~= 0 then
            return nil
        end
        local minutes = duration / 60
        return offer.Name
            .. " active for "
            .. minutes
            .. " minute"
            .. (minutes == 1 and "" or "s")
            .. ". It stacks with natural x3 Overdrive."
    end
    return nil
end
function Economy:Notice(d, text, kind)
    d.Runtime.NoticeSerial += 1
    d.Runtime.Notice = text
    d.Runtime.NoticeKind = kind or "Reward"
end
function Economy:ResolvePendingOfflinePassBonus(d, ownsDoubleProduction)
    local pending = number(d.PendingOfflineDoubleProductionBonus, 0, self.Config.MaximumCurrency)
    local earned = 0
    local remaining = 0
    if ownsDoubleProduction then
        earned = self:Add(d, pending)
        remaining = math.max(0, pending - earned)
        d.Runtime.OfflineEarned = math.min(self.Config.MaximumCurrency, (d.Runtime.OfflineEarned or 0) + earned)
    end
    d.PendingOfflineDoubleProductionBonus = remaining
    return earned
end
function Economy:ApplyPassOwnership(d, ownedPasses, resolvePendingOffline)
    local merged = clone(d.Runtime.OwnedPasses or {})
    for key, value in pairs(ownedPasses or {}) do
        if type(value) == "boolean" then
            merged[key] = value
        end
    end
    d.Runtime.OwnedPasses = merged
    if resolvePendingOffline and type(ownedPasses) == "table" and type(ownedPasses.DoubleProduction) == "boolean" then
        self:ResolvePendingOfflinePassBonus(d, ownedPasses.DoubleProduction)
    end
    return merged
end
function Economy:ConfirmPassPurchase(d, passKey)
    if not MonetizationCatalog.Passes[passKey] then
        return false
    end
    d.Runtime.OwnedPasses[passKey] = true
    if passKey == "DoubleProduction" then
        self:ResolvePendingOfflinePassBonus(d, false)
    end
    return true
end
function Economy:InitializeSession(d, now, ownedPasses, applyOffline, ownershipUnknown)
    self:ApplyPassOwnership(d, ownedPasses, false)
    d.Runtime.AutoTapAccumulator = 0
    if applyOffline then
        self:Offline(d, now, ownershipUnknown == true)
    end
    if type(ownedPasses) == "table" and type(ownedPasses.DoubleProduction) == "boolean" then
        self:ResolvePendingOfflinePassBonus(d, ownedPasses.DoubleProduction)
    end
end
function Economy:Offline(d, now, ownershipUnknown)
    local hours = self.P.Offline.Hours + (d.Research.Storage or 0) * 0.5 + (d.Permanent.Clock or 0)
    local seconds = math.clamp(now - d.LastSeen, 0, math.min(hours, 24) * 3600)
    if seconds >= 60 then
        local startAt = now - seconds
        local boosted = math.clamp((d.PaidBoostEndsAt or 0) - startAt, 0, seconds)
        local baseAmount = self:PassiveCore(d) * (seconds + boosted) * self.P.Offline.Efficiency
        local multiplier = self:PassMultiplier(d)
        local amount = baseAmount * multiplier
        local currencyBefore = d.Currency
        d.Runtime.OfflineEarned = self:Add(d, amount)
        d.Runtime.OfflineSeconds = seconds
        if ownershipUnknown and multiplier == 1 then
            local fullAmount = math.min(baseAmount * 2, math.max(0, self.Config.MaximumCurrency - currencyBefore))
            local pending = math.max(0, fullAmount - d.Runtime.OfflineEarned)
            d.PendingOfflineDoubleProductionBonus =
                math.min(self.Config.MaximumCurrency, (d.PendingOfflineDoubleProductionBonus or 0) + pending)
        end
    end
    d.LastSeen = now
end
function Economy:Metric(d, metric)
    if metric == "Clicks" then
        return d.TotalClicks
    elseif metric == "Earned" then
        return d.LifetimeCurrency
    elseif metric == "Trips" then
        return d.TotalExpeditions
    elseif metric == "Rebirths" then
        return d.Prestiges
    elseif metric == "Purchases" then
        return d.LifetimePurchases
    elseif metric == "Worlds" then
        return self:WorldCount(d)
    elseif metric == "Owned" then
        local n = 0
        for _, v in pairs(d.Upgrades) do
            n += v
        end
        return n
    end
    return 0
end
function Economy:RebirthCost(d)
    return math.min(
        self.Config.MaximumCurrency,
        self.Config.Prestige.BaseRequirement * self.Config.Prestige.RequirementMultiplier ^ math.min(d.Prestiges, 15)
    )
end
function Economy:RebirthGain(d)
    local maximum =
        math.max(1, math.floor(math.sqrt(self.Config.MaximumCurrency / self.Config.Prestige.BaseRequirement)))
    return math.clamp(math.floor(math.sqrt(d.RunEarned / self.Config.Prestige.BaseRequirement)), 1, maximum)
end
-- Shared purchase path keeps manual and automatic spending under identical gates.
function Economy:BuyProducer(d, def, limit)
    if self:WorldCount(d) < (def.RequiredWorld or 1) then
        return 0
    end
    local bought = 0
    for _ = 1, limit do
        local owned = d.Upgrades[def.Id] or 0
        if owned >= 100000 then
            break
        end
        local cost = self:Cost(def, owned, d, true)
        if d.Currency < cost then
            break
        end
        d.Currency -= cost
        d.Upgrades[def.Id] = owned + 1
        bought += 1
        d.LifetimePurchases += 1
    end
    return bought
end
function Economy:Tick(d, now, dt)
    if d.Daily.Day ~= math.floor(now / 86400) then
        self:ResetDaily(d, now)
    end
    local elapsed = math.clamp(dt, 0, 5)
    local startAt = now - elapsed
    local boundaries = { startAt, now }
    for _, endsAt in ipairs({ d.Runtime.BurstEndsAt or 0, d.PaidBoostEndsAt or 0 }) do
        if endsAt > startAt and endsAt < now then
            table.insert(boundaries, endsAt)
        end
    end
    table.sort(boundaries)
    local amount = 0
    local base = self:PassiveCore(d)
    for i = 1, #boundaries - 1 do
        local fromAt, toAt = boundaries[i], boundaries[i + 1]
        local mid = (fromAt + toAt) * 0.5
        amount += base * self:PaidMultiplier(d, mid) * self:BurstMultiplier(d, mid) * (toAt - fromAt)
    end
    self:Add(d, amount)
    if d.Runtime.OwnedPasses.DoubleProduction == true and (d.PendingOfflineDoubleProductionBonus or 0) > 0 then
        self:ResolvePendingOfflinePassBonus(d, true)
    end
    if d.Runtime.EventEndsAt > 0 and now >= d.Runtime.EventEndsAt then
        d.Runtime.EventEndsAt = 0
    end
    if now >= d.Runtime.EventNextAt then
        d.Runtime.EventEndsAt = now + self.P.Collectible.Lifetime
        d.Runtime.EventNextAt = now + self.P.Collectible.Interval
        d.Runtime.EventNonce += 1
    end
    if d.AutoBuyEnabled and self:AutoBuyUnlocked(d) then
        d.Runtime.AutoBuyAccumulator = (d.Runtime.AutoBuyAccumulator or 0) + elapsed
        if d.Runtime.AutoBuyAccumulator >= self.P.AutoBuy.Interval then
            d.Runtime.AutoBuyAccumulator %= self.P.AutoBuy.Interval
            -- One bounded pass per tick; never spend offline income before joining.
            for i = #self.Catalog, 1, -1 do
                self:BuyProducer(d, self.Catalog[i], self.P.AutoBuy.PurchasesPerTier)
            end
        end
    else
        d.Runtime.AutoBuyAccumulator = 0
    end
end
function Economy:Action(d, action, id, quantity, now)
    if type(action) ~= "string" then
        return false, "Unknown action."
    end
    if d.Daily.Day ~= math.floor(now / 86400) then
        self:ResetDaily(d, now)
    end
    if action == "EquipCosmetic" then
        if not MonetizationRules.CanEquipCosmetic(id, MonetizationCatalog.Cosmetics, d.Runtime.OwnedPasses or {}) then
            return false, "That cosmetic is not unlocked."
        end
        d.EquippedCosmetic = id
        self:Notice(d, "Cosmetic equipped: " .. MonetizationCatalog.Cosmetics[id].Name, "Cosmetic")
        return true
    elseif action == "Click" then
        if d.Runtime.BurstEndsAt <= now then
            d.Runtime.Charge += 1
            if d.Runtime.Charge >= self.P.Burst.Clicks then
                d.Runtime.Charge = 0
                d.Runtime.BurstEndsAt = now + self:BurstDuration(d)
                self:Notice(
                    d,
                    "Overdrive active: natural x"
                        .. self.P.Burst.Multiplier
                        .. " production. It stacks with your paid x2 boost.",
                    "Burst"
                )
            end
        end
        local gained = self:Add(d, self:ClickPower(d, now))
        d.TotalClicks += 1
        d.Runtime.LastClickGain = gained
        return true
    elseif action == "AutoBuy" then
        if type(id) ~= "boolean" then
            return false, "Invalid Auto Buy setting."
        end
        if id and not self:AutoBuyUnlocked(d) then
            return false, "Auto Buy requires 8 worlds and the 500M Energy Research upgrade."
        end
        d.AutoBuyEnabled = id
        d.Runtime.AutoBuyAccumulator = 0
        self:Notice(
            d,
            id and "Auto Buy enabled. Producers buy every second, highest tier first."
                or "Auto Buy paused. Save Energy for your next goal.",
            "Confirm"
        )
        return true
    elseif action == "Buy" then
        local def = find(self.Catalog, id)
        if not def then
            return false, "Unknown producer."
        end
        if self:WorldCount(d) < (def.RequiredWorld or 1) then
            return false, "Unlock more worlds first."
        end
        local limit = quantity == "Max" and 100 or quantity == 10 and 10 or 1
        local bought = self:BuyProducer(d, def, limit)
        if bought == 0 then
            return false, "Not enough " .. string.lower(self.Config.Currency.Name) .. "."
        end
        self:Notice(
            d,
            "Purchased " .. bought .. " " .. ((self.Config.UpgradePresentation[id] or {}).Name or id),
            "Purchase"
        )
        return true
    elseif action == "Zone" then
        local z = find(self.Config.Zones, id)
        if not z then
            return false, "Unknown world."
        end
        if not d.UnlockedZones[id] then
            if d.Currency < z.UnlockCost then
                return false, "Not enough to unlock " .. z.Name .. "."
            end
            d.Currency -= z.UnlockCost
            d.UnlockedZones[id] = true
            self:Notice(d, z.Name .. " unlocked! x" .. z.Multiplier .. " production", "World")
        end
        d.CurrentZone = id
        return true
    elseif action == "Research" or action == "Permanent" then
        local defs = self.P[action]
        local def = find(defs, id)
        if not def then
            return false, "Unknown upgrade."
        end
        local level = d[action][id] or 0
        if level >= def.Max then
            return false, "Already at maximum level."
        end
        if action == "Research" and id == self.P.AutoBuy.ResearchId
            and self:WorldCount(d) < self.P.AutoBuy.RequiredWorld then
            return false, "Own " .. self.P.AutoBuy.RequiredWorld .. " worlds before buying Auto Buy."
        end
        local cost = self:Cost(def, level, d)
        local wallet = action == "Permanent" and "Stars" or "Currency"
        if d[wallet] < cost then
            return false,
                "Not enough " .. (wallet == "Stars" and "stars" or string.lower(self.Config.Currency.Name)) .. "."
        end
        d[wallet] -= cost
        d[action][id] = level + 1
        if action == "Research" and id == self.P.AutoBuy.ResearchId then
            d.AutoBuyEnabled = true
            d.Runtime.AutoBuyAccumulator = 0
            self:Notice(d, "Auto Buy unlocked and enabled! Pause it in Production to save Energy.", "Research")
        else
            self:Notice(d, def.Name .. " upgraded to level " .. (level + 1), "Research")
        end
        return true
    elseif action == "Expedition" then
        if d.Expedition then
            return false, "Finish your current expedition first."
        end
        local def = find(self.P.Expeditions, id)
        if not def then
            return false, "Unknown expedition."
        end
        if self:WorldCount(d) < def.World then
            return false, "Unlock more worlds first."
        end
        if d.Currency < def.Cost then
            return false, "Not enough to launch this expedition."
        end
        local multiplier = (1 + (d.Research.Logistics or 0) * 0.15) * (1 + (d.Permanent.Cargo or 0) * 0.25)
        local baseReward = self:GameplayEnergyReward(d, def.Reward, def.ClickCount or 0, def.IncomeSeconds or 0, now)
        local reward = math.min(self.Config.MaximumCurrency, baseReward * multiplier)
        d.Currency -= def.Cost
        d.Expedition = { Id = id, EndsAt = now + def.Duration, Reward = reward }
        self:Notice(d, def.Name .. " is on its way.", "Expedition")
        return true
    elseif action == "ClaimExpedition" then
        if not d.Expedition or now < d.Expedition.EndsAt then
            return false, "Your expedition is still traveling."
        end
        local reward = d.Expedition.Reward
        d.Expedition = nil
        self:Add(d, reward)
        d.TotalExpeditions += 1
        self:Notice(d, "Expedition complete! Cargo collected.", "Reward")
        return true
    elseif action == "Achievement" or action == "Daily" then
        local def = find(action == "Daily" and self.P.Daily or self.P.Achievements, id)
        if not def then
            return false, "Unknown reward."
        end
        local claimed = action == "Daily" and d.Daily.Claimed or d.ClaimedAchievements
        local metric = self:Metric(d, def.Metric) - (action == "Daily" and (d.Daily.Baseline[def.Metric] or 0) or 0)
        if claimed[id] then
            return false, "Reward already collected."
        end
        if metric < def.Goal then
            return false, "Objective is not complete yet."
        end
        claimed[id] = true
        self:Add(d, self:GameplayEnergyReward(d, def.Energy or 0, def.ClickCount or 0, def.IncomeSeconds or 0, now))
        d.Stars = math.min(self.Config.MaximumCurrency, d.Stars + (def.Stars or 0))
        self:Notice(d, def.Name .. " reward collected!", "Achievement")
        return true
    elseif action == "Collect" then
        if d.Runtime.EventEndsAt <= now or id ~= d.Runtime.EventNonce then
            return false, "That bonus has passed."
        end
        d.Runtime.EventEndsAt = 0
        self:Add(d, self:GameplayEnergyReward(d, 25, 10, 15, now))
        self:Notice(d, "Bonus collected!", "Collect")
        return true
    elseif action == "Rebirth" then
        if not self.Config.Prestige.Enabled or d.Currency < self:RebirthCost(d) then
            return false, "You need more Energy for Ascension."
        end
        local stars = self:RebirthGain(d)
        d.Stars = math.min(self.Config.MaximumCurrency, d.Stars + stars)
        d.Prestiges += 1
        d.Currency = 0
        d.RunEarned = 0
        d.Upgrades = {}
        d.Research = {}
        d.AutoBuyEnabled = false
        d.Runtime.AutoBuyAccumulator = 0
        d.Runtime.Charge = 0
        d.Runtime.BurstEndsAt = 0
        self:Notice(d, "Ascension complete! +" .. stars .. " stars. Permanent upgrades are waiting.", "Rebirth")
        return true
    end
    return false, "Unknown action."
end
function Economy:Snapshot(d, now, saveMode, profileWritable)
    local canSellDeveloperProducts, productsUnavailableReason =
        MonetizationRules.DeveloperProductAvailability(profileWritable, d.Runtime.ReceiptLedgerBytes or 2)
    local s = {
        Currency = d.Currency,
        LifetimeCurrency = d.LifetimeCurrency,
        RunEarned = d.RunEarned,
        TotalClicks = d.TotalClicks,
        ClickPower = self:ClickPower(d, now),
        PassiveRate = self:Passive(d, now),
        BasePassiveRate = self:Passive(d, now, true),
        PaidBoostEndsAt = d.PaidBoostEndsAt or 0,
        OwnedPasses = clone(d.Runtime.OwnedPasses or {}),
        EquippedCosmetic = d.EquippedCosmetic,
        CanSellDeveloperProducts = canSellDeveloperProducts,
        DeveloperProductsUnavailableReason = productsUnavailableReason,
        CurrentZone = d.CurrentZone,
        ZoneMultiplier = self:Zone(d).Multiplier,
        Prestiges = d.Prestiges,
        Stars = d.Stars,
        PrestigeEnabled = self.Config.Prestige.Enabled,
        PrestigeCost = self:RebirthCost(d),
        RebirthGain = self:RebirthGain(d),
        CanPrestige = self.Config.Prestige.Enabled and d.Currency >= self:RebirthCost(d),
        PrestigeMultiplier = self:Mastery(d),
        BurstCharge = d.Runtime.Charge,
        BurstEndsAt = d.Runtime.BurstEndsAt,
        BurstDuration = self:BurstDuration(d),
        BurstNeeded = self.P.Burst.Clicks,
        BurstMultiplier = self.P.Burst.Multiplier,
        EventEndsAt = d.Runtime.EventEndsAt,
        EventNonce = d.Runtime.EventNonce,
        ServerTime = now,
        SaveMode = saveMode,
        NoticeSerial = d.Runtime.NoticeSerial,
        Notice = d.Runtime.Notice,
        NoticeKind = d.Runtime.NoticeKind,
        LastClickGain = d.Runtime.LastClickGain or 0,
        OfflineEarned = d.Runtime.OfflineEarned,
        OfflineSeconds = d.Runtime.OfflineSeconds,
        Expedition = d.Expedition and clone(d.Expedition) or nil,
        Upgrades = {},
        Zones = {},
        Research = {},
        Permanent = {},
        Expeditions = {},
        Achievements = {},
        Daily = {},
        Claimable = 0,
    }
    local worlds = self:WorldCount(d)
    s.AutoBuyWorldsMet = worlds >= self.P.AutoBuy.RequiredWorld
    s.AutoBuyRequiredWorld = self.P.AutoBuy.RequiredWorld
    s.AutoBuyUnlocked = self:AutoBuyUnlocked(d)
    s.AutoBuyEnabled = s.AutoBuyUnlocked and d.AutoBuyEnabled == true
    for _, v in ipairs(self.Catalog) do
        s.Upgrades[v.Id] = {
            Owned = d.Upgrades[v.Id] or 0,
            Cost = self:Cost(v, d.Upgrades[v.Id] or 0, d, true),
            Locked = worlds < (v.RequiredWorld or 1),
            RequiredWorld = v.RequiredWorld or 1,
        }
    end
    for i, z in ipairs(self.Config.Zones) do
        s.Zones[i] = {
            Id = z.Id,
            Name = z.Name,
            UnlockCost = z.UnlockCost,
            Multiplier = z.Multiplier,
            Unlocked = d.UnlockedZones[z.Id] == true,
            Current = d.CurrentZone == z.Id,
        }
    end
    for _, kind in ipairs({ "Research", "Permanent" }) do
        for i, v in ipairs(self.P[kind]) do
            local level = d[kind][v.Id] or 0
            s[kind][i] = {
                Id = v.Id,
                Name = v.Name,
                Description = v.Description,
                Level = level,
                Max = v.Max,
                Cost = self:Cost(v, level, d),
                Locked = kind == "Research" and v.Id == self.P.AutoBuy.ResearchId
                    and worlds < self.P.AutoBuy.RequiredWorld,
                RequiredWorld = kind == "Research" and v.Id == self.P.AutoBuy.ResearchId
                    and self.P.AutoBuy.RequiredWorld or nil,
            }
        end
    end
    for i, v in ipairs(self.P.Expeditions) do
        local multiplier = (1 + (d.Research.Logistics or 0) * 0.15) * (1 + (d.Permanent.Cargo or 0) * 0.25)
        local baseReward = self:GameplayEnergyReward(d, v.Reward, v.ClickCount or 0, v.IncomeSeconds or 0, now)
        s.Expeditions[i] = {
            Id = v.Id,
            Name = v.Name,
            Description = v.Description,
            Duration = v.Duration,
            Cost = v.Cost,
            Locked = worlds < v.World,
            RequiredWorld = v.World,
            Reward = math.min(self.Config.MaximumCurrency, baseReward * multiplier),
        }
    end
    for _, kind in ipairs({ "Achievements", "Daily" }) do
        for i, v in ipairs(self.P[kind]) do
            local progress =
                math.max(0, self:Metric(d, v.Metric) - (kind == "Daily" and (d.Daily.Baseline[v.Metric] or 0) or 0))
            local claimed = kind == "Daily" and d.Daily.Claimed[v.Id] == true
                or kind == "Achievements" and d.ClaimedAchievements[v.Id] == true
            local ready = not claimed and progress >= v.Goal
            if ready then
                s.Claimable += 1
            end
            local energy = self:GameplayEnergyReward(d, v.Energy or 0, v.ClickCount or 0, v.IncomeSeconds or 0, now)
            s[kind][i] = {
                Id = v.Id,
                Name = v.Name,
                Progress = math.min(progress, v.Goal),
                Goal = v.Goal,
                Claimed = claimed,
                Ready = ready,
                Energy = energy,
                Stars = v.Stars or 0,
            }
        end
    end
    local first = self.Catalog[1]
    local second = self.Catalog[2]
    if (d.Upgrades[first.Id] or 0) == 0 then
        s.Objective = "First goal: buy " .. ((self.Config.UpgradePresentation[first.Id] or {}).Name or first.Id)
    elseif second and (d.Upgrades[second.Id] or 0) == 0 then
        s.Objective = "Next: automate with " .. ((self.Config.UpgradePresentation[second.Id] or {}).Name or second.Id)
    elseif s.Claimable > 0 then
        s.Objective = "Journal: " .. s.Claimable .. " rewards ready to collect"
    elseif not d.Expedition then
        s.Objective = "Send an expedition for extra income"
    else
        s.Objective = "Keep growing. A new world is within reach."
    end
    return s
end
return Economy
