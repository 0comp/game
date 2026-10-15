-- Server-authoritative linked star accounts. One lease and receipt ledger per player.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")
local DataStoreService=game:GetService("DataStoreService")
local HttpService=game:GetService("HttpService")
local RunService=game:GetService("RunService")
local Kit=ReplicatedStorage:WaitForChild("ClickerKit")
local Config=require(Kit.ThemeConfig)
local Account=require(script.Parent.AccountProfile)
local Runtime=require(script.Parent.StarAccountRuntime)
local Offers=require(Kit.MonetizationCatalog)
local Rules=require(Kit.MonetizationRules)
local U=require(Kit.StarUtil)
local Remotes=Kit.Remotes
local Profiles,Loading,LastAction,LastSnapshot={},{},{},{}
local SessionId=game.JobId~="" and game.JobId or HttpService:GenerateGUID(false)
local LeaseSeconds=180
local Store
local ready,result=pcall(function()return DataStoreService:GetDataStore(Config.DataStoreName)end)
if ready then Store=result else warn("ORBIT: DataStore unavailable; Studio preview is temporary.")end
local function clock()return workspace:GetServerTimeNow()end
local function checkReconnect(player,r)
    if r.Unresolved and player.Parent then player:Kick("Your saving connection could not be verified. Please rejoin. Saved star systems have not been replaced.")end
end
local function sync(player)
    local r=Profiles[player];if not r or not player.Parent then return end
    local snapshot=r:Snapshot(clock())
    local stats=player:FindFirstChild("leaderstats")
    if stats then stats[Config.Currency.Name].Value=snapshot.Currency;stats.Ascensions.Value=snapshot.Prestiges end
    Remotes.StateUpdate:FireClient(player,snapshot)
end
local function feedback(player,gain)
    local r=Profiles[player];if not r then return end
    local item=Rules.ClickFeedback(gain)
    if item then item.ActiveSystemId=r.Account.ActiveSystemId;item.DiscoveryGeneration=r.Account.DiscoveryGeneration;item.AccountRevision=r.Account.Revision;Remotes.StateUpdate:FireClient(player,item)end
end
local function releaseLeaseOnly(player)
    if not Store then return end
    pcall(function()Store:UpdateAsync("User_"..player.UserId,function(old)
        if type(old)~="table" or type(old._Session)~="table" or old._Session.Id~=SessionId then return nil end
        local copy=U.Clone(old);copy._Session.ExpiresAt=0;return copy
    end)end)
end
local function load(player)
    if not Store then return nil,false end
    local now=os.time()
    local ok,saved=pcall(function()return Store:UpdateAsync("User_"..player.UserId,function(old)
        if old==nil then old={}end
        if type(old)~="table"then return nil end
        local lease=old._Session
        if type(lease)=="table" and lease.Id~=SessionId and U.Finite(lease.ExpiresAt) and lease.ExpiresAt>now then return nil end
        local copy=U.Clone(old);copy._Session={Id=SessionId,ExpiresAt=now+LeaseSeconds};return copy
    end)end)
    if not ok or type(saved)~="table"then warn("ORBIT: could not acquire profile for "..player.Name);return nil,false end
    return saved,true
end
local function refreshOwnership(player,r,attempt)
    local token=r:OwnershipToken()
    local owned,unknown=Rules.ResolvePassOwnership(MarketplaceService,player.UserId,Offers.Passes)
    if Profiles[player]~=r or not player.Parent then return end
    r:ApplyOwnership(owned,token);sync(player)
    if unknown and (attempt or 0)<2 then task.delay(30,function()if Profiles[player]==r then refreshOwnership(player,r,(attempt or 0)+1)end end)end
end
local function save(player,release)
    local r=Profiles[player];if not r then return end
    local started=os.clock()
    while r.Busy and not r.Unresolved and os.clock()-started<20 do task.wait(.1)end
    local status=r:Save(release)
    if not release then
        if status=="Capacity"then Account.Economy(r.Account.ActiveSystemId):Notice(r.Account.Systems[r.Account.ActiveSystemId],"Saving is paused because this profile is near its storage limit.","Error")end
        checkReconnect(player,r)
    end
end
local function joined(player)
    if Profiles[player] or Loading[player]then return end
    Loading[player]=true
    local saved,writable=load(player)
    if not writable and not RunService:IsStudio()then
        Loading[player]=nil
        if player.Parent then player:Kick("Your saved progress could not be loaded. Please rejoin. Existing progress has not been replaced.")end
        return
    end
    local now=clock();local account,err=Account.Normalize(saved,now)
    if not account then
        releaseLeaseOnly(player);Loading[player]=nil;warn("ORBIT: refusing unsupported/corrupt profile: "..tostring(err))
        if player.Parent then player:Kick("Your saved profile needs attention and was not changed. Please contact the game owner.")end
        return
    end
    local owned,unknown=Rules.ResolvePassOwnership(MarketplaceService,player.UserId,Offers.Passes,"DoubleProduction")
    if not player.Parent then releaseLeaseOnly(player);Loading[player]=nil;return end
    local active=account.ActiveSystemId;local run=Account.Project(account,active,now)
    Account.Economy(active):InitializeSession(run,now,owned,writable,unknown)
    account.OwnedPasses=U.Clone(run.Runtime.OwnedPasses)
    local r=Runtime.new(account,{Store=Store,UserId=player.UserId,UserKey="User_"..player.UserId,SessionId=SessionId,
        LeaseSeconds=LeaseSeconds,GameClock=clock,LeaseClock=os.time,Writable=writable,SaveMode=writable and "Cloud" or "Temporary",
        TransitionsEnabled=Config.StarTransitionsEnabled~=false})
    if writable then
        local status=r:Save(false)
        if status=="Capacity"then releaseLeaseOnly(player);r.Writable=false;r.SaveMode="Temporary"end
    end
    if not player.Parent then r:Save(true);Loading[player]=nil;return end
    if r.Unresolved then Loading[player]=nil;checkReconnect(player,r);return end
    if not r.Writable and not RunService:IsStudio()then
        Loading[player]=nil;player:Kick("Your saved profile could not be safely updated. Please contact the game owner. Existing progress has not been replaced.");return
    end
    Profiles[player]=r;Loading[player]=nil
    local old=player:FindFirstChild("leaderstats");if old then old:Destroy()end
    local stats=Instance.new("Folder");stats.Name="leaderstats"
    for _,name in ipairs({Config.Currency.Name,"Ascensions"})do local n=Instance.new("NumberValue");n.Name=name;n.Parent=stats end
    stats.Parent=player
    sync(player);task.spawn(refreshOwnership,player,r,0)
end
local function action(player,kind,id,quantity)
    local r=Profiles[player];if not r or type(kind)~="string"then return end
    local now=clock()
    if kind~="CheckoutBusy" then
        LastAction[player]=LastAction[player] or {}
        local bucket=kind=="Click" and "Click" or "Other"
        if now-(LastAction[player][bucket] or 0)<(kind=="Click" and Config.ClickCooldown or .12)then return end
        LastAction[player][bucket]=now
    end
    local oldSystem,oldGeneration=r.Account.ActiveSystemId,r.Account.DiscoveryGeneration
    local ok,message=r:Action(kind,id,quantity,now)
    if not ok and message and not r.Unresolved then Account.Economy(r.Account.ActiveSystemId):Notice(r.Account.Systems[r.Account.ActiveSystemId],message,"Error")end
    if ok and kind=="Click"then feedback(player,r.Account.Systems[r.Account.ActiveSystemId].Runtime.LastClickGain)end
    if oldSystem~=r.Account.ActiveSystemId or oldGeneration~=r.Account.DiscoveryGeneration then task.spawn(refreshOwnership,player,r,0)end
    sync(player);checkReconnect(player,r)
end
Remotes.RequestAction.OnServerEvent:Connect(action)
Remotes.RequestClick.OnServerEvent:Connect(function(p)action(p,"Click")end)
Remotes.RequestPurchase.OnServerEvent:Connect(function(p,id)action(p,"Buy",id,1)end)
Remotes.RequestZone.OnServerEvent:Connect(function(p,id)action(p,"Zone",id)end)
Remotes.RequestPrestige.OnServerEvent:Connect(function(p)action(p,"Rebirth")end)
Remotes.RequestSnapshot.OnServerEvent:Connect(function(p)
    local now=clock();if now-(LastSnapshot[p] or 0)<.5 then return end
    LastSnapshot[p]=now;sync(p)
end)
local function processReceipt(info)
    local offer=Offers.ResolveProduct(info.ProductId)
    local player=Players:GetPlayerByUserId(info.PlayerId)
    local r=player and Profiles[player]
    if not offer or not r then return Enum.ProductPurchaseDecision.NotProcessedYet end
    local status=r:ProcessReceipt(offer,info.PurchaseId,clock())
    sync(player);checkReconnect(player,r)
    return (status=="Granted" or status=="Duplicate")and Enum.ProductPurchaseDecision.PurchaseGranted or Enum.ProductPurchaseDecision.NotProcessedYet
end
MarketplaceService.ProcessReceipt=processReceipt
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player,id,purchased)
    local r=Profiles[player];if not r then return end
    r.CheckoutUntil=0
    if purchased then
        for key,offer in pairs(Offers.Passes)do if offer.Id==id then r:ConfirmPassPurchase(key);break end end
        task.spawn(refreshOwnership,player,r,0);task.spawn(save,player,false)
    end
    sync(player)
end)
Players.CharacterAutoLoads=false
for _,p in ipairs(Players:GetPlayers())do if p.Character then p.Character:Destroy()end end
Players.PlayerAdded:Connect(joined)
for _,p in ipairs(Players:GetPlayers())do task.spawn(joined,p)end
Players.PlayerRemoving:Connect(function(p)
    save(p,true);Profiles[p]=nil;Loading[p]=nil;LastAction[p]=nil;LastSnapshot[p]=nil
end)
task.spawn(function()
    local previous=clock();local lastSync=previous
    while task.wait(Rules.AutoTapInterval)do
        local now=clock();local dt=now-previous;previous=now
        for p,r in pairs(Profiles)do if p.Parent then
            for _,gain in ipairs(r:Tick(now,dt))do feedback(p,gain)end
        end end
        if now-lastSync>=1 then lastSync=now;for p in pairs(Profiles)do sync(p)end end
    end
end)
task.spawn(function()while task.wait(Config.AutoSaveSeconds)do for p in pairs(Profiles)do task.spawn(save,p,false)end end end)
game:BindToClose(function()
    local pending=0
    for p in pairs(Profiles)do pending+=1;task.spawn(function()save(p,true);pending-=1 end)end
    local started=os.clock();while pending>0 and os.clock()-started<25 do task.wait(.1)end
end)

