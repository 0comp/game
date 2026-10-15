local Shared=game:GetService("ReplicatedStorage"):WaitForChild("ClickerKit")
local Stars=require(Shared.StarSystemCatalog)
local Catalog=require(Shared.StellarUpgradeCatalog)
local U=require(Shared.StarUtil)
local P={}
local function level(value,max)
    return U.Finite(value) and math.floor(math.clamp(value,0,max)) or 0
end
function P.Cost(section,id,current)
    local def=Catalog.Get(section,id)
    if not def or not U.Finite(current) or current<0 or current%1~=0 or current>=def.Max then return nil end
    return math.max(1,math.floor(math.min(1e18,def.Cost*def.Growth^current)+.5))
end
function P.Incoming(account,target)
    local sums={Clicks=0,Passive=0,Production=0,Offline=0}
    if account.UnlockedSystems[target] then
        for source,targets in pairs(account.StellarLinks or {})do
            local link=type(targets)=="table" and targets[target]
            if account.UnlockedSystems[source] and Stars.AreAdjacent(source,target) and type(link)=="table" then
                for _,section in ipairs({"Research","Ascension"})do
                    for _,def in ipairs(Catalog[section])do
                        local levels=type(link[section])=="table" and link[section][def.Id]
                        sums[def.Effect]+=level(levels,def.Max)*def.Amount
                    end
                end
            end
        end
    end
    return {ClickMultiplier=1+sums.Clicks,PassiveMultiplier=1+sums.Passive,ProductionMultiplier=1+sums.Production,OfflineSeconds=sums.Offline}
end
function P.Purchase(account,source,target,section,id)
    local def=Catalog.Get(section,id)
    if source~=account.ActiveSystemId or not def or not Stars.AreAdjacent(source,target)
        or account.UnlockedSystems[source]~=true or account.UnlockedSystems[target]~=true then
        return nil,"Discover a neighboring star before upgrading it."
    end
    local run=account.Systems[source]
    local targets=(account.StellarLinks or {})[source]
    local link=targets and targets[target]
    local levels=link and link[section]
    local current=level(levels and levels[id],def.Max)
    local cost=P.Cost(section,id,current)
    if not cost then return nil,"This interstellar upgrade is at its maximum level." end
    if not run or not U.Finite(run[def.Wallet]) or run[def.Wallet]<cost then return nil,"Not enough "..(def.Wallet=="Stars" and "Ascend Stars" or "Energy").."." end
    local result=U.Clone(account)
    result.Systems[source][def.Wallet]-=cost
    result.StellarLinks=result.StellarLinks or {}
    result.StellarLinks[source]=result.StellarLinks[source] or {}
    result.StellarLinks[source][target]=result.StellarLinks[source][target] or {Research={},Ascension={}}
    result.StellarLinks[source][target][section]=result.StellarLinks[source][target][section] or {}
    result.StellarLinks[source][target][section][id]=current+1
    return result
end
return P
