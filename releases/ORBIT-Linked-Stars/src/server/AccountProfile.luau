local Shared=game:GetService("ReplicatedStorage"):WaitForChild("ClickerKit")
local Stars=require(Shared.StarSystemCatalog)
local Themes=require(Shared.SystemThemeFactory)
local Upgrades=require(Shared.UpgradeCatalog)
local Progression=require(Shared.ProgressionCatalog)
local Offers=require(Shared.MonetizationCatalog)
local Stellar=require(script.Parent.StellarProgression)
local U=require(Shared.StarUtil)
local Engine=require(script.Parent.Economy)
local Http=game:GetService("HttpService")
local A={}
local engines={}
local localFields={"Currency","LifetimeCurrency","RunEarned","TotalClicks","LifetimePurchases","TotalExpeditions","Prestiges","Stars","CurrentZone","Upgrades","Research","Permanent","ClaimedAchievements","UnlockedZones","Daily","Expedition","LastSeen","PendingOfflineDoubleProductionBonus"}
local retained={"LifetimeCurrency","TotalClicks","LifetimePurchases","TotalExpeditions","ClaimedAchievements","Daily"}
local rootFields={"Version","Revision","LastOperationId","ActiveSystemId","DiscoveryGeneration","UnlockedSystems","StellarLinks","AutoBuyOwnership","OwnedPasses","EquippedCosmetic","PaidBoostEndsAt","ProcessedReceipts","LastTransition"}
local function integer(v,max) return U.Finite(v) and v>=0 and v%1==0 and v<=(max or 9e15) end
function A.Economy(id)
    assert(Stars.Get(id),"Unknown star system")
    if not engines[id]then engines[id]=Engine.new(Themes.Get(id),Upgrades,Progression)end
    return engines[id]
end
function A.New(now)
    return {Version=3,Revision=0,ActiveSystemId="Sun",DiscoveryGeneration=0,
        UnlockedSystems={Sun=true},Systems={Sun=A.Economy("Sun"):New(now)},
        StellarLinks={},AutoBuyOwnership={Sun={Owned=false,PreferredEnabled=false}},
        OwnedPasses={},PaidBoostEndsAt=0,ProcessedReceipts={},Runtime={ReceiptLedgerBytes=2}}
end
function A.CaptureAutoBuy(account,id,explicitPreference)
    local run=account.Systems[id];local ownership=account.AutoBuyOwnership[id]
    if not ownership then ownership={Owned=false,PreferredEnabled=false};account.AutoBuyOwnership[id]=ownership end
    local bought=(run.Research.AutoBuy or 0)>0
    if bought then
        local previouslyOwned=ownership.Owned
        ownership.Owned=true
        if type(explicitPreference)=="boolean" then ownership.PreferredEnabled=explicitPreference
        elseif not previouslyOwned then ownership.PreferredEnabled=run.AutoBuyEnabled==true end
    end
end
function A.Project(account,id,now)
    local d=assert(account.Systems[id],"System has not been discovered")
    local owner=account.AutoBuyOwnership[id] or {Owned=false,PreferredEnabled=false}
    d.Runtime.OwnedPasses=U.Clone(account.OwnedPasses)
    d.PaidBoostEndsAt=account.PaidBoostEndsAt
    d.EquippedCosmetic=account.EquippedCosmetic
    d.Runtime.StellarBonuses=Stellar.Incoming(account,id)
    d.Runtime.ReceiptLedgerBytes=account.Runtime and account.Runtime.ReceiptLedgerBytes or 2
    d.Research.AutoBuy=owner.Owned and 1 or 0
    d.AutoBuyEnabled=owner.Owned and owner.PreferredEnabled and A.Economy(id):AutoBuyUnlocked(d) or false
    return d
end
local function validateReceipts(account)
    assert(type(account.ProcessedReceipts)=="table","Receipt ledger missing")
    for id,r in pairs(account.ProcessedReceipts)do
        assert(type(id)=="string" and #id>0 and #id<=128 and type(r)=="table" and r.Status=="Granted" and r.PurchaseId==id,"Invalid receipt ledger")
        assert(r.ProductId==nil or (integer(r.ProductId) and r.ProductId>0),"Invalid receipt product")
        local e=r.Effect;assert(type(e)=="table","Invalid receipt effect")
        if e.Type=="Currency" then
            assert(U.Finite(e.Amount) and e.Amount>0 and e.Amount<=1e18,"Invalid currency receipt")
            assert(account.UnlockedSystems[e.SystemId]==true and integer(e.Generation,account.DiscoveryGeneration),"Invalid receipt destination")
        else assert(e.Type=="PaidBoost" and U.Finite(e.EndsAt) and e.EndsAt>0,"Invalid boost receipt")end
    end
end
local function validateLocal(saved,id)
    assert(type(saved)=="table","Missing system run")
    for _,key in ipairs({"Currency","LifetimeCurrency","RunEarned","Stars"})do
        assert(U.Finite(saved[key]) and saved[key]>=0 and saved[key]<=1e18,"Invalid local balance: "..key)
    end
    for _,key in ipairs({"TotalClicks","LifetimePurchases","TotalExpeditions","Prestiges"})do assert(integer(saved[key]),"Invalid local counter")end
    local zones={};for _,z in ipairs(Themes.Get(id).Zones)do zones[z.Id]=true end
    assert(type(saved.UnlockedZones)=="table" and type(saved.CurrentZone)=="string" and zones[saved.CurrentZone] and saved.UnlockedZones[saved.CurrentZone]==true,"Invalid local world")
    for key,value in pairs(saved.UnlockedZones)do assert(zones[key] and value==true,"Unknown local world")end
    assert(saved.UnlockedZones[Themes.Get(id).Zones[1].Id],"First world missing")
    local lists={Upgrades=Upgrades,Research=Progression.Research,Permanent=Progression.Permanent,ClaimedAchievements=Progression.Achievements}
    for key,list in pairs(lists)do
        assert(type(saved[key])=="table","Local progression table missing")
        local ids={};for _,def in ipairs(list)do ids[def.Id]=def end
        for name,value in pairs(saved[key])do
            assert(ids[name],"Unknown progression key")
            if key=="ClaimedAchievements" then assert(value==true,"Invalid achievement claim")
            else assert(integer(value,ids[name].Max or 100000),"Invalid upgrade level")end
        end
    end
    assert(type(saved.Daily)=="table" and type(saved.Daily.Claimed)=="table" and type(saved.Daily.Baseline)=="table","Invalid daily state")
    assert(integer(saved.Daily.Day),"Invalid daily day")
    local dailyIds={};for _,def in ipairs(Progression.Daily)do dailyIds[def.Id]=true end
    for key,value in pairs(saved.Daily.Claimed)do assert(dailyIds[key] and value==true,"Invalid daily claim")end
    local totals={Clicks=saved.TotalClicks,Purchases=saved.LifetimePurchases,Trips=saved.TotalExpeditions}
    for key,value in pairs(saved.Daily.Baseline)do assert(totals[key] and integer(value,totals[key]),"Invalid daily baseline")end
    for key in pairs(totals)do assert(saved.Daily.Baseline[key]~=nil,"Missing daily baseline")end
    assert(U.Finite(saved.LastSeen) and saved.LastSeen>=0 and saved.LastSeen<=1e18,"Invalid last-seen time")
    assert(U.Finite(saved.PendingOfflineDoubleProductionBonus) and saved.PendingOfflineDoubleProductionBonus>=0 and saved.PendingOfflineDoubleProductionBonus<=1e18,"Invalid pending offline Energy")
    if saved.Expedition then
        local found;for _,def in ipairs(Progression.Expeditions)do if saved.Expedition.Id==def.Id then found=def end end
        assert(found and U.Finite(saved.Expedition.EndsAt) and U.Finite(saved.Expedition.Reward) and saved.Expedition.Reward>=0 and saved.Expedition.Reward<=1e18,"Invalid expedition")
    end
end
function A.Normalize(saved,now)
    local ok,result=pcall(function()
        if saved==nil then return A.New(now)end
        assert(type(saved)=="table","Invalid saved profile")
        if saved.Version~=3 then
            assert(saved.Version==nil or saved.Version==1 or saved.Version==2,"Unsupported save version")
            local empty=true;for key in pairs(saved)do if key~="_Session" then empty=false end end
            if empty then return A.New(now)end
            assert(saved.Version==1 or saved.Version==2 or saved.Currency~=nil or saved.Upgrades~=nil,"Unrecognized legacy profile")
            local a=A.New(now);local d=A.Economy("Sun"):Normalize(saved,now)
            a.Systems.Sun=d;a.OwnedPasses=U.Clone(d.Runtime.OwnedPasses)
            a.PaidBoostEndsAt=d.PaidBoostEndsAt;a.EquippedCosmetic=d.EquippedCosmetic
            a.ProcessedReceipts=U.Clone(d.ProcessedReceipts)
            for _,receipt in pairs(a.ProcessedReceipts)do if receipt.Effect.Type=="Currency" then receipt.Effect.SystemId="Sun";receipt.Effect.Generation=0 end end
            A.CaptureAutoBuy(a,"Sun")
            a.Runtime.ReceiptLedgerBytes=#Http:JSONEncode(a.ProcessedReceipts)
            A.Project(a,"Sun",now);return a
        end
        assert(integer(saved.Revision) and integer(saved.DiscoveryGeneration,3),"Invalid account revision")
        assert(type(saved.Systems)=="table" and type(saved.UnlockedSystems)=="table" and saved.UnlockedSystems.Sun==true,"Account systems missing")
        assert(type(saved.AutoBuyOwnership)=="table" and type(saved.StellarLinks)=="table" and type(saved.OwnedPasses)=="table","Account metadata missing")
        assert(Stars.Get(saved.ActiveSystemId) and saved.UnlockedSystems[saved.ActiveSystemId]==true,"Invalid active system")
        local a=U.Clone(saved);a.Systems={};local count=0;local gap=false
        for _,id in ipairs(Stars.Order)do
            if saved.UnlockedSystems[id]==true then
                assert(not gap,"Nonsequential discovery")
                validateLocal(saved.Systems[id],id);a.Systems[id]=A.Economy(id):Normalize(saved.Systems[id],now);count+=1
                local owner=saved.AutoBuyOwnership[id]
                assert(type(owner)=="table" and type(owner.Owned)=="boolean" and type(owner.PreferredEnabled)=="boolean","Auto Buy ownership missing")
            else gap=true end
        end
        assert(count==a.DiscoveryGeneration+1,"Discovery generation mismatch")
        for id,value in pairs(saved.UnlockedSystems)do assert(Stars.Get(id) and value==true,"Unknown discovered system")end
        for id in pairs(saved.Systems)do assert(saved.UnlockedSystems[id]==true,"Undiscovered system save")end
        for id in pairs(saved.AutoBuyOwnership)do assert(saved.UnlockedSystems[id]==true,"Unknown Auto Buy ownership")end
        for source,targets in pairs(a.StellarLinks)do
            assert(a.UnlockedSystems[source] and type(targets)=="table","Invalid stellar source")
            for target,link in pairs(targets)do
                assert(a.UnlockedSystems[target] and Stars.AreAdjacent(source,target) and type(link)=="table","Invalid stellar target")
                for section,levels in pairs(link)do
                    local catalog=Shared.StellarUpgradeCatalog
                    local defs=require(catalog)
                    assert((section=="Research" or section=="Ascension") and type(levels)=="table","Invalid stellar section")
                    for name,value in pairs(levels)do local def=defs.Get(section,name);assert(def and integer(value,def.Max),"Invalid stellar level")end
                end
            end
        end
        for key,value in pairs(a.OwnedPasses)do assert(Offers.Passes[key] and type(value)=="boolean","Invalid ownership cache")end
        assert(U.Finite(a.PaidBoostEndsAt) and a.PaidBoostEndsAt>=0 and a.PaidBoostEndsAt<=1e18,"Invalid paid boost")
        assert(a.EquippedCosmetic==nil or Offers.Cosmetics[a.EquippedCosmetic],"Invalid cosmetic")
        validateReceipts(a)
        a.Runtime={ReceiptLedgerBytes=#Http:JSONEncode(a.ProcessedReceipts)}
        for id in pairs(a.UnlockedSystems)do A.Project(a,id,now)end
        return a
    end)
    if not ok then return nil,tostring(result)end
    return result
end
function A.Serialize(account,now)
    local result={};for _,key in ipairs(rootFields)do result[key]=U.Clone(account[key])end
    result.Systems={}
    for id,run in pairs(account.Systems)do
        local encoded=A.Economy(id):Serialize(run,now);local localRun={}
        for _,key in ipairs(localFields)do localRun[key]=U.Clone(encoded[key])end
        if id~=account.ActiveSystemId then localRun.LastSeen=run.LastSeen end
        result.Systems[id]=localRun
    end
    return result
end
function A.Eligible(account,target)
    local previous=Stars.Previous(target)
    return previous~=nil and account.UnlockedSystems[target]~=true and account.UnlockedSystems[previous]==true
        and A.Economy(previous):WorldCount(account.Systems[previous])==13
end
function A.ProposeTravel(account,target,now)
    if not Stars.Get(target) or account.UnlockedSystems[target]~=true or target==account.ActiveSystemId then return nil,"Choose another discovered star."end
    local a=U.Clone(account);local source=a.ActiveSystemId
    a.Systems[source].LastSeen=now;a.Systems[source].Runtime=A.Economy(source):New(now).Runtime
    a.ActiveSystemId=target;a.Systems[target].LastSeen=now;a.Systems[target].Runtime=A.Economy(target):New(now).Runtime
    if a.Systems[target].Daily.Day~=math.floor(now/86400)then A.Economy(target):ResetDaily(a.Systems[target],now)end
    A.Project(a,target,now);return a
end
function A.ProposeDiscovery(account,target,now)
    if not A.Eligible(account,target)then return nil,"Own all 13 planets around the preceding star first."end
    local a=U.Clone(account)
    for id,run in pairs(a.Systems)do
        A.CaptureAutoBuy(a,id)
        local fresh=A.Economy(id):New(now)
        for _,key in ipairs(retained)do fresh[key]=U.Clone(run[key])end
        if fresh.Daily.Day~=math.floor(now/86400)then A.Economy(id):ResetDaily(fresh,now)end
        a.Systems[id]=fresh
    end
    a.UnlockedSystems[target]=true;a.Systems[target]=A.Economy(target):New(now)
    a.AutoBuyOwnership[target]={Owned=false,PreferredEnabled=false}
    a.ActiveSystemId=target;a.DiscoveryGeneration+=1
    local previous=Stars.Previous(target)
    for _,edge in ipairs({{previous,target},{target,previous}})do
        a.StellarLinks[edge[1]]=a.StellarLinks[edge[1]] or {}
        a.StellarLinks[edge[1]][edge[2]]=a.StellarLinks[edge[1]][edge[2]] or {Research={},Ascension={}}
    end
    for id in pairs(a.UnlockedSystems)do A.Project(a,id,now)end
    return a
end
function A.Snapshot(account,now,saveMode,writable)
    local id=account.ActiveSystemId;local run=A.Project(account,id,now)
    local s=A.Economy(id):Snapshot(run,now,saveMode,writable)
    s.ActiveSystemId=id;s.SystemName=Stars.Get(id).Name;s.DiscoveryGeneration=account.DiscoveryGeneration
    s.AccountRevision=account.Revision;s.StarSystems={};s.StellarUpgrades={Research={},Ascension={}}
    s.IncomingStellar=U.Clone(run.Runtime.StellarBonuses)
    for _,target in ipairs(Stars.Order)do
        local known=account.UnlockedSystems[target]==true
        table.insert(s.StarSystems,{Id=target,Name=Stars.Get(target).Name,Worlds=known and A.Economy(target):WorldCount(account.Systems[target]) or 0,
            Status=target==id and "Current" or known and "Travel" or A.Eligible(account,target) and "Discover" or "Locked",Previous=Stars.Previous(target)})
    end
    local definitions=require(Shared.StellarUpgradeCatalog)
    for _,target in ipairs(Stars.Order)do if Stars.AreAdjacent(id,target)then
        local link=account.StellarLinks[id] and account.StellarLinks[id][target]
        for _,section in ipairs({"Research","Ascension"})do for _,def in ipairs(definitions[section])do
            local current=link and link[section] and link[section][def.Id] or 0
            local cost=Stellar.Cost(section,def.Id,current)
            table.insert(s.StellarUpgrades[section],{TargetId=target,TargetName=Stars.Get(target).Name,Id=def.Id,Name=def.Name,Level=current,Max=def.Max,
                Amount=def.Amount,Effect=def.Effect,Cost=cost or 0,Wallet=def.Wallet,Locked=account.UnlockedSystems[target]~=true,
                CanBuy=writable==true and saveMode=="Cloud" and account.UnlockedSystems[target]==true and cost~=nil and run[def.Wallet]>=cost})
        end end
    end end
    s.AutoBuyOwned=account.AutoBuyOwnership[id].Owned
    s.AutoBuyPreferredEnabled=account.AutoBuyOwnership[id].PreferredEnabled
    return s
end
return A
