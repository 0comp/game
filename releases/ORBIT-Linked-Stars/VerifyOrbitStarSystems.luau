-- Run against the isolated ServerStorage.OrbitLinkedTests container, never player data.
local sandbox=game.ServerStorage:FindFirstChild("OrbitLinkedTests")
assert(sandbox,"Isolated test container missing")
local Shared=sandbox.Shared
local Server=sandbox.Server
local checks={}
local function test(name,fn)
    local ok,err=pcall(fn)
    table.insert(checks,{Name=name,Passed=ok,Error=not ok and tostring(err) or nil})
end
local function module(parent,name)
    local m=parent:FindFirstChild(name)
    assert(m,"Missing module: "..name)
    return require(m)
end
test("catalogs_have_unique_planets_and_matching_balance",function()
    local S=module(Shared,"StarSystemCatalog")
    local F=module(Shared,"SystemThemeFactory")
    assert(#S.Order==4)
    assert(S.Order[1]=="Sun" and S.Order[2]=="Proxima" and S.Order[3]=="AlphaCentauriA" and S.Order[4]=="AlphaCentauriB")
    local sun=F.Get("Sun");local ids={}
    for _,id in ipairs(S.Order) do
        local c=F.Get(id);assert(#c.Zones==13)
        for i,z in ipairs(c.Zones)do
            assert(not ids[z.Id],"Duplicate planet "..z.Id);ids[z.Id]=true
            assert(z.UnlockCost==sun.Zones[i].UnlockCost and z.Multiplier==sun.Zones[i].Multiplier)
            if id~="Sun" then assert(z.Name~=sun.Zones[i].Name) end
        end
    end
    assert(S.Previous("Sun")==nil and S.Next("Sun")=="Proxima")
    assert(S.AreAdjacent("Sun","Proxima") and S.AreAdjacent("Proxima","Sun"))
    assert(not S.AreAdjacent("Sun","AlphaCentauriB"))
end)
test("theme_configs_do_not_share_mutable_tables",function()
    local F=module(Shared,"SystemThemeFactory")
    local a=F.Get("Proxima");local b=F.Get("Proxima");local sun=F.Get("Sun")
    local old=b.Zones[1].Name;a.Zones[1].Name="Changed"
    assert(b.Zones[1].Name==old and sun.Zones[1].Name=="Earth")
end)
test("upgrade_catalog_has_exact_approved_values",function()
    local U=module(Shared,"StellarUpgradeCatalog")
    local a=U.Get("Research","SignalAmplifier")
    assert(a.Cost==100000000 and a.Growth==10 and a.Max==5 and a.Amount==.1)
    local b=U.Get("Ascension","StellarLegacy")
    assert(b.Cost==10 and b.Growth==1.6 and b.Max==10 and b.Amount==.05)
    assert(U.Get("Ascension","VoyagerStorage").Amount==900)
end)
local function bare()
    local a={ActiveSystemId="Sun",UnlockedSystems={Sun=true,Proxima=true,AlphaCentauriA=true,AlphaCentauriB=true},Systems={},StellarLinks={}}
    for _,id in ipairs({"Sun","Proxima","AlphaCentauriA","AlphaCentauriB"})do a.Systems[id]={Currency=1000000000,Stars=1000}end
    return a
end
test("directional_purchase_deducts_only_source_wallet",function()
    local P=module(Server,"StellarProgression");local a=bare()
    local b=assert(P.Purchase(a,"Sun","Proxima","Research","SignalAmplifier"))
    assert(a.Systems.Sun.Currency==1000000000 and b.Systems.Sun.Currency==900000000)
    assert(b.Systems.Proxima.Currency==1000000000)
    assert(b.StellarLinks.Sun.Proxima.Research.SignalAmplifier==1)
    local c=assert(P.Purchase(b,"Sun","Proxima","Ascension","StellarLegacy"))
    assert(c.Systems.Sun.Stars==990 and c.Systems.Proxima.Stars==1000)
end)
test("neighbors_only_and_caps",function()
    local P=module(Server,"StellarProgression");local a=bare()
    assert(not P.Purchase(a,"Sun","AlphaCentauriB","Research","SignalAmplifier"))
    assert(not P.Purchase(a,"Proxima","Sun","Research","SignalAmplifier"))
    a.UnlockedSystems.Proxima=false;assert(not P.Purchase(a,"Sun","Proxima","Research","SignalAmplifier"))
    a.UnlockedSystems.Proxima=true;a.StellarLinks.Sun={Proxima={Research={SignalAmplifier=5},Ascension={}}}
    assert(not P.Purchase(a,"Sun","Proxima","Research","SignalAmplifier"))
    assert(not P.Purchase(a,"Sun","Proxima","Research","Forged"))
    assert(P.Cost("Research","SignalAmplifier",0)==100000000)
end)
test("incoming_bonuses_are_additive_not_recursive",function()
    local P=module(Server,"StellarProgression");local a=bare()
    a.StellarLinks={Sun={Proxima={Research={SignalAmplifier=1,SupplyNetwork=1},Ascension={StellarLegacy=1,VoyagerStorage=1}}}}
    local b=P.Incoming(a,"Proxima")
    assert(b.ClickMultiplier==1.1 and b.PassiveMultiplier==1.1 and b.ProductionMultiplier==1.05 and b.OfflineSeconds==900)
    a.StellarLinks.AlphaCentauriA={Proxima={Research={SignalAmplifier=1},Ascension={StellarLegacy=1}}}
    b=P.Incoming(a,"Proxima");assert(b.ClickMultiplier==1.2 and b.ProductionMultiplier==1.1)
    a.StellarLinks.Proxima={Sun={Research={SignalAmplifier=5},Ascension={StellarLegacy=10}}}
    assert(P.Incoming(a,"Proxima").ClickMultiplier==1.2)
end)
test("economy_applies_incoming_channels_once_and_extends_offline",function()
    local E=module(Server,"Economy").new(module(Shared,"SystemThemeFactory").Get("Sun"),module(Shared,"UpgradeCatalog"),module(Shared,"ProgressionCatalog"))
    local d=E:New(0);d.Upgrades.MiniDrones=1
    d.Runtime.StellarBonuses={ClickMultiplier=1.1,PassiveMultiplier=1.1,ProductionMultiplier=1.05,OfflineSeconds=900}
    assert(math.abs(E:ClickPower(d,1000)-1.155)<1e-9)
    assert(math.abs(E:Passive(d,1000)-1.155)<1e-9)
    E:Offline(d,9000,false);assert(d.Runtime.OfflineSeconds==8100)
end)
test("ordinary_autobuy_never_buys_interstellar",function()
    local F=module(Shared,"SystemThemeFactory");local c=F.Get("Sun")
    local E=module(Server,"Economy").new(c,module(Shared,"UpgradeCatalog"),module(Shared,"ProgressionCatalog"))
    local d=E:New(1000);for i=1,8 do d.UnlockedZones[c.Zones[i].Id]=true end
    d.Currency=1000000000;d.Research.AutoBuy=1;d.AutoBuyEnabled=true
    E:Tick(d,1001,1);assert(d.Research.Focus==1 and d.Currency==999990650)
end)
local function accountModule() return module(Server,"AccountProfile") end
local function ownAll(a,id)
    local F=module(Shared,"SystemThemeFactory");local c=F.Get(id)
    for _,z in ipairs(c.Zones)do a.Systems[id].UnlockedZones[z.Id]=true end
end
test("legacy_load_preserves_eligible_sun_without_discovery",function()
    local A=accountModule();local e=A.Economy("Sun");local d=e:New(1000)
    d.Currency=123456789;d.Stars=7414;d.Prestiges=8;d.Research.AutoBuy=1;d.AutoBuyEnabled=true
    d.Permanent.Mastery=3;d.Upgrades.TapCoil=12;d.ClaimedAchievements.World11=true
    for _,z in ipairs(module(Shared,"SystemThemeFactory").Get("Sun").Zones)do d.UnlockedZones[z.Id]=true end
    d.PaidBoostEndsAt=2000;d.Runtime.OwnedPasses.DoubleProduction=true
    d.ProcessedReceipts.old={Status="Granted",PurchaseId="old",ProductId=3718202097,Effect={Type="Currency",Amount=1200}}
    local a=assert(A.Normalize(e:Serialize(d,1000),1000))
    assert(a.ActiveSystemId=="Sun" and not a.UnlockedSystems.Proxima)
    assert(a.Systems.Sun.Currency==123456789 and a.Systems.Sun.Stars==7414 and a.Systems.Sun.Prestiges==8)
    assert(a.Systems.Sun.Permanent.Mastery==3 and a.Systems.Sun.Upgrades.TapCoil==12)
    assert(a.AutoBuyOwnership.Sun.Owned and a.AutoBuyOwnership.Sun.PreferredEnabled)
    assert(a.PaidBoostEndsAt==2000 and a.OwnedPasses.DoubleProduction)
    assert(a.ProcessedReceipts.old.Effect.SystemId=="Sun" and a.ProcessedReceipts.old.Effect.Generation==0)
    local b=assert(A.Normalize(A.Serialize(a,1000),1000))
    assert(b.Systems.Sun.Currency==a.Systems.Sun.Currency and b.DiscoveryGeneration==0)
    assert(A.Snapshot(b,1000,"Cloud",true).StarSystems[2].Status=="Discover")
    assert(not A.Normalize({Version=4},1000))
    assert(not A.Normalize({Version=3,ActiveSystemId="Sun",Systems={}},1000))
end)
test("each_discovery_resets_all_runs_once",function()
    local A=accountModule();local a=A.New(1000)
    for _,id in ipairs({"Proxima","AlphaCentauriA","AlphaCentauriB"})do
        local previous=module(Shared,"StarSystemCatalog").Previous(id);ownAll(a,previous)
        for known in pairs(a.UnlockedSystems)do
            local d=a.Systems[known];d.Currency=900000000;d.RunEarned=500;d.Stars=50;d.Prestiges=2
            d.Research.Focus=3;d.Permanent.Mastery=4;d.Upgrades.TapCoil=7
            d.TotalClicks=1000;d.ClaimedAchievements.Click10=true;d.Daily.Claimed.DailyClicks=true
            d.Expedition={Id="Scout",EndsAt=2000,Reward=999};d.PendingOfflineDoubleProductionBonus=12
        end
        a.AutoBuyOwnership.Sun={Owned=true,PreferredEnabled=true};a.Systems.Sun.Research.AutoBuy=1
        a.OwnedPasses.DoubleProduction=true;a.PaidBoostEndsAt=3000
        local oldGeneration=a.DiscoveryGeneration
        local b=assert(A.ProposeDiscovery(a,id,1000))
        assert(a.DiscoveryGeneration==oldGeneration and b.DiscoveryGeneration==oldGeneration+1)
        assert(b.ActiveSystemId==id and b.UnlockedSystems[id])
        for known in pairs(b.UnlockedSystems)do
            local d=b.Systems[known]
            assert(d.Currency==0 and d.RunEarned==0 and d.Stars==0 and d.Prestiges==0)
            assert(not d.Expedition and d.PendingOfflineDoubleProductionBonus==0)
            assert(A.Economy(known):WorldCount(d)==1 and (d.Research.Focus or 0)==0 and next(d.Upgrades)==nil and next(d.Permanent)==nil)
            if known~=id then assert(d.TotalClicks==1000 and d.ClaimedAchievements.Click10 and d.Daily.Claimed.DailyClicks)end
        end
        assert(b.AutoBuyOwnership.Sun.Owned and b.AutoBuyOwnership.Sun.PreferredEnabled)
        assert(b.OwnedPasses.DoubleProduction and b.PaidBoostEndsAt==3000)
        assert(b.StellarLinks[previous][id] and b.StellarLinks[id][previous])
        assert(not A.ProposeDiscovery(b,id,1000))
        a=b
    end
end)
test("ordinary_travel_preserves_progress_and_directional_levels",function()
    local A=accountModule();local a=A.New(1000);ownAll(a,"Sun");a=assert(A.ProposeDiscovery(a,"Proxima",1000))
    a.Systems.Proxima.Currency=456;a.Systems.Sun.Currency=789
    a.StellarLinks.Sun.Proxima.Research.SignalAmplifier=2
    local b=assert(A.ProposeTravel(a,"Sun",1100));assert(b.Systems.Sun.Currency==789 and b.Systems.Proxima.Currency==456)
    b=assert(A.Normalize(A.Serialize(b,1100),1100));b=assert(A.ProposeTravel(b,"Proxima",1200))
    assert(b.Systems.Proxima.Currency==456 and b.StellarLinks.Sun.Proxima.Research.SignalAmplifier==2 and b.DiscoveryGeneration==1)
    b.Systems.Proxima.Currency=1e16
    assert(A.Economy("Proxima"):Action(b.Systems.Proxima,"Rebirth",nil,nil,1200))
    assert(b.StellarLinks.Sun.Proxima.Research.SignalAmplifier==2)
    assert(not A.ProposeTravel(b,"AlphaCentauriB",1200))
end)
test("owned_autobuy_is_gated_until_eight_worlds_return",function()
    local A=accountModule();local a=A.New(1000);ownAll(a,"Sun")
    a.AutoBuyOwnership.Sun={Owned=true,PreferredEnabled=true};a.Systems.Sun.Research.AutoBuy=1
    a=assert(A.ProposeDiscovery(a,"Proxima",1000));a=assert(A.ProposeTravel(a,"Sun",1001))
    assert(a.Systems.Sun.Research.AutoBuy==1 and not A.Project(a,"Sun",1001).AutoBuyEnabled)
    local c=module(Shared,"SystemThemeFactory").Get("Sun");for i=1,8 do a.Systems.Sun.UnlockedZones[c.Zones[i].Id]=true end
    assert(A.Project(a,"Sun",1002).AutoBuyEnabled)
    assert(not a.AutoBuyOwnership.Proxima.Owned)
end)
test("inactive_system_never_gets_offline_income_and_expedition_cannot_cross_reset",function()
    local A=accountModule();local a=A.New(1000);ownAll(a,"Sun");a=assert(A.ProposeDiscovery(a,"Proxima",1000))
    a.Systems.Sun.Upgrades.MiniDrones=1;a.Systems.Sun.Expedition={Id="Scout",EndsAt=1030,Reward=150}
    local b=assert(A.ProposeTravel(a,"Sun",2000));assert(b.Systems.Sun.Currency==0 and b.Systems.Sun.LastSeen==2000)
    assert(A.Economy("Sun"):Action(b.Systems.Sun,"ClaimExpedition",nil,nil,2000))
    assert(b.Systems.Sun.Currency==150)
    ownAll(b,"Proxima");b.Systems.Sun.Expedition={Id="Scout",EndsAt=3000,Reward=1e15}
    b=assert(A.ProposeDiscovery(b,"AlphaCentauriA",2000));assert(not b.Systems.Sun.Expedition and b.Systems.Sun.Currency==0)
end)
test("daily_claims_cannot_be_farmed_by_discovery",function()
    local A=accountModule();local a=A.New(1000);local d=a.Systems.Sun
    d.TotalClicks=1000;d.LifetimePurchases=50;d.TotalExpeditions=3
    assert(A.Economy("Sun"):Action(d,"Daily","DailyClicks",nil,1000))
    ownAll(a,"Sun");a=assert(A.ProposeDiscovery(a,"Proxima",1000));a=assert(A.ProposeTravel(a,"Sun",1001))
    assert(not A.Economy("Sun"):Action(a.Systems.Sun,"Daily","DailyClicks",nil,1001))
    a=assert(A.Normalize(A.Serialize(a,1001),86401));assert(not a.Systems.Sun.Daily.Claimed.DailyClicks)
    assert(a.Systems.Sun.Daily.Baseline.Clicks==1000)
end)
test("root_metadata_and_ledger_are_not_duplicated_into_runs",function()
    local A=accountModule();local a=A.New(1000);local encoded=A.Serialize(a,1000)
    assert(encoded.Systems.Sun.OwnedPasses==nil and encoded.Systems.Sun.ProcessedReceipts==nil and encoded.Systems.Sun.PaidBoostEndsAt==nil)
    encoded.Systems.Sun.Currency=math.huge;assert(not A.Normalize(encoded,1000))
end)
local function savedFixture()
    local A=accountModule();local a=A.New(1000);local s=A.Serialize(a,1000)
    s._Session={Id="test-session",ExpiresAt=2000};return s
end
local function fakeStore(initial)
    local clone=module(Shared,"StarUtil").Clone
    local s={Value=clone(initial),Writes=0}
    function s:UpdateAsync(key,fn)
        local nextValue=fn(clone(self.Value))
        if nextValue~=nil then self.Value=clone(nextValue);self.Writes+=1 end
        if self.ThrowAfterWrite then self.ThrowAfterWrite=false;error("Response lost after commit")end
        return clone(nextValue)
    end
    return s
end
test("discovery_commit_is_whole_account_and_duplicate_is_idempotent",function()
    local Store=module(Server,"AccountStore");local A=accountModule();local original=savedFixture();local store=fakeStore(original)
    local a=assert(A.Normalize(original,1000));ownAll(a,"Sun");local proposed=assert(A.ProposeDiscovery(a,"Proxima",1000))
    local status,saved=Store.Commit(store,"User_123","test-session",0,A.Serialize(proposed,1000),"discovery-one",1000,180)
    assert(status=="Committed" and saved.Revision==1 and saved.ActiveSystemId=="Proxima" and saved.Systems.Sun.Currency==0)
    status,saved=Store.Commit(store,"User_123","test-session",0,A.Serialize(proposed,1000),"discovery-one",1000,180)
    assert(status=="Committed" and saved.Revision==1 and saved.DiscoveryGeneration==1)
end)
test("lost_lease_or_revision_cannot_write",function()
    local Store=module(Server,"AccountStore");local original=savedFixture();local store=fakeStore(original)
    assert(Store.Commit(store,"User_123","wrong-session",0,original,"bad",1000,180)=="Conflict")
    assert(Store.Commit(store,"User_123","test-session",5,original,"bad",1000,180)=="Conflict")
    assert(store.Value.Revision==0)
end)
test("write_then_throw_resolves_committed",function()
    local Store=module(Server,"AccountStore");local original=savedFixture();local store=fakeStore(original);store.ThrowAfterWrite=true
    local proposed=module(Shared,"StarUtil").Clone(original);proposed.Systems.Sun.Currency=999
    assert(Store.Commit(store,"User_123","test-session",0,proposed,"response-loss",1000,180)=="Retry")
    local status,saved=Store.Resolve(store,"User_123","test-session",0,"response-loss",original,1000,180)
    assert(status=="Committed" and saved.Systems.Sun.Currency==999 and saved.Revision==1)
end)
test("uncommitted_resolution_invalidates_late_write",function()
    local Store=module(Server,"AccountStore");local original=savedFixture();local store=fakeStore(original)
    local status,saved=Store.Resolve(store,"User_123","test-session",0,"late-request",original,1000,180)
    assert(status=="NotCommitted" and saved.Revision==1)
    local proposed=module(Shared,"StarUtil").Clone(original);proposed.Systems.Sun.Currency=999
    assert(Store.Commit(store,"User_123","test-session",0,proposed,"late-request",1000,180)=="Conflict")
    assert(store.Value.Systems.Sun.Currency==0)
end)
test("store_retries_callback_and_capacity_without_partial_write",function()
    local Store=module(Server,"AccountStore");local original=savedFixture();local store=fakeStore(original)
    local first=store.UpdateAsync
    function store:UpdateAsync(key,fn)fn(module(Shared,"StarUtil").Clone(self.Value));return first(self,key,fn)end
    local status,saved=Store.Commit(store,"User_123","test-session",0,original,"retry-callback",1000,180)
    assert(status=="Committed" and saved.Revision==1)
    local big=module(Shared,"StarUtil").Clone(saved);big.Padding=string.rep("x",3800000)
    assert(Store.Commit(store,"User_123","test-session",1,big,"too-big",1000,180)=="Capacity")
    assert(store.Value.Revision==1)
end)
test("currency_grant_targets_active_star_and_root_ledger",function()
    local M=module(Server,"AccountMonetization");local A=accountModule();local offers=module(Shared,"MonetizationCatalog")
    local a=A.New(1000);ownAll(a,"Sun");a=assert(A.ProposeDiscovery(a,"Proxima",1000))
    local b,r=M.ApplyProduct(a,offers.Products.SmallEnergy,"star-energy",1000,1e18)
    assert(r.Status=="Granted" and b.Systems.Proxima.Currency==1200 and b.Systems.Sun.Currency==0)
    assert(r.Effect.SystemId=="Proxima" and r.Effect.Generation==1 and b.ProcessedReceipts["star-energy"])
    assert(a.Systems.Proxima.Currency==0)
    local duplicate,again=M.ApplyProduct(b,offers.Products.SmallEnergy,"star-energy",1000,1e18)
    assert(again.Status=="Duplicate" and duplicate.Systems.Proxima.Currency==1200)
end)
test("duplicate_after_travel_or_reset_never_regrants",function()
    local M=module(Server,"AccountMonetization");local A=accountModule();local offers=module(Shared,"MonetizationCatalog")
    local a=A.New(1000);local b,r=M.ApplyProduct(a,offers.Products.SmallEnergy,"old-grant",1000,1e18)
    ownAll(b,"Sun");b=assert(A.ProposeDiscovery(b,"Proxima",1000))
    local again=M.ReconcileReceipt(b,r)
    assert(again.Systems.Sun.Currency==0 and again.Systems.Proxima.Currency==0)
    again=M.ApplyProduct(again,offers.Products.SmallEnergy,"old-grant",1000,1e18)
    assert(again.Systems.Sun.Currency==0 and again.Systems.Proxima.Currency==0)
end)
test("legacy_receipt_reconciliation_and_shared_paid_expiry",function()
    local M=module(Server,"AccountMonetization");local A=accountModule();local offers=module(Shared,"MonetizationCatalog")
    local a=A.New(1000);local r={Status="Granted",PurchaseId="legacy-effect",Effect={Type="Currency",Amount=1200}}
    a=M.ReconcileReceipt(a,r);assert(a.Systems.Sun.Currency==1200)
    a=M.ReconcileReceipt(a,r);assert(a.Systems.Sun.Currency==1200)
    ownAll(a,"Sun");a=assert(A.ProposeDiscovery(a,"Proxima",1000))
    a=M.ApplyProduct(a,offers.Products.Boost15Minutes,"boost-global",1000,1e18)
    assert(a.PaidBoostEndsAt==1900)
    a=assert(A.ProposeTravel(a,"Sun",1100));assert(A.Project(a,"Sun",1100).PaidBoostEndsAt==1900)
end)
test("receipt_commit_retains_other_systems_links_and_defers_full_wallet",function()
    local R=module(Server,"MonetizationReceiptService");local M=module(Server,"AccountMonetization");local A=accountModule();local offers=module(Shared,"MonetizationCatalog")
    local a=A.New(1000);ownAll(a,"Sun");a=assert(A.ProposeDiscovery(a,"Proxima",1000));a.Systems.Sun.Currency=777
    a.StellarLinks.Sun.Proxima.Research.SignalAmplifier=2
    local saved=A.Serialize(a,1000);saved._Session={Id="test-session",ExpiresAt=2000};local store=fakeStore(saved)
    local status,r=R.Commit(store,123,"test-session",saved,offers.Products.SmallEnergy,"receipt-global",1000,1000,1e18,180)
    assert(status=="Granted" and store.Value.Systems.Proxima.Currency==1200 and store.Value.Systems.Sun.Currency==777)
    assert(store.Value.StellarLinks.Sun.Proxima.Research.SignalAmplifier==2 and r.Effect.SystemId=="Proxima")
    assert(R.Commit(store,123,"test-session",saved,offers.Products.SmallEnergy,"receipt-global",1000,1000,1e18,180)=="Duplicate")
    a.Systems.Proxima.Currency=1e18
    local full,result=M.ApplyProduct(a,offers.Products.SmallEnergy,"full-wallet",1000,1e18)
    assert(result.Status=="Deferred" and full.Systems.Proxima.Currency==1e18 and not full.ProcessedReceipts["full-wallet"])
end)
local function runtimeFixture(account)
    local A=accountModule();account=account or A.New(1000)
    local encoded=A.Serialize(account,1000);encoded._Session={Id="test-session",ExpiresAt=2000}
    local store=fakeStore(encoded)
    local R=module(Server,"StarAccountRuntime")
    return R.new(account,{Store=store,UserKey="User_123",UserId=123,SessionId="test-session",GameClock=function()return 1000 end,LeaseClock=function()return 1000 end,Writable=true,SaveMode="Cloud",LeaseSeconds=180}),store
end
test("only_active_run_ticks_and_busy_blocks_mutations",function()
    local A=accountModule();local a=A.New(1000);ownAll(a,"Sun");a=assert(A.ProposeDiscovery(a,"Proxima",1000))
    a.Systems.Sun.Upgrades.MiniDrones=1;a.Systems.Proxima.Upgrades.MiniDrones=1
    local r=runtimeFixture(a);r:Tick(1001,1)
    assert(r.Account.Systems.Proxima.Currency==1 and r.Account.Systems.Sun.Currency==0)
    r.Busy=true;local old=r.Account.Systems.Proxima.Currency;r:Tick(1002,1)
    assert(not r:Action("Click",nil,nil,1002) and r.Account.Systems.Proxima.Currency==old)
end)
test("late_ownership_response_cannot_replace_new_run",function()
    local r=runtimeFixture();ownAll(r.Account,"Sun");local old=r:OwnershipToken()
    assert(r:Transition("DiscoverSystem","Proxima","ownership-epoch",1000)=="Committed")
    assert(not r:ApplyOwnership({DoubleProduction=true},old))
    assert(not r.Account.OwnedPasses.DoubleProduction)
    assert(r:ApplyOwnership({DoubleProduction=true},r:OwnershipToken()))
    assert(r.Account.OwnedPasses.DoubleProduction and r.Account.ActiveSystemId=="Proxima")
end)
test("discovery_failure_preserves_source_and_ambiguous_success_resolves",function()
    local r,store=runtimeFixture();ownAll(r.Account,"Sun");r.Account.Systems.Sun.Currency=999
    store.Value._Session.Id="other-session"
    assert(r:Transition("DiscoverSystem","Proxima","conflict-reset",1000)~="Committed")
    assert(r.Account.ActiveSystemId=="Sun" and r.Account.Systems.Sun.Currency==999)
    r,store=runtimeFixture();ownAll(r.Account,"Sun");store.ThrowAfterWrite=true
    assert(r:Transition("DiscoverSystem","Proxima","lost-response-reset",1000)=="Committed")
    assert(r.Account.DiscoveryGeneration==1 and r.Account.ActiveSystemId=="Proxima" and not r.Busy)
end)
test("ordinary_save_preserves_runtime_and_release_releases_lease",function()
    local r,store=runtimeFixture();r.Account.Systems.Sun.Runtime.Charge=12;r.Account.Systems.Sun.Runtime.BurstEndsAt=1010
    assert(r:Save(false)=="Committed")
    assert(r.Account.Systems.Sun.Runtime.Charge==12 and r.Account.Systems.Sun.Runtime.BurstEndsAt==1010)
    assert(r:Save(true)=="Committed" and store.Value._Session.ExpiresAt==0)
end)
test("recovery_mode_preserves_account_and_paid_delivery",function()
    local A=accountModule();local a=A.New(1000)
    for _,id in ipairs({"Proxima","AlphaCentauriA","AlphaCentauriB"})do ownAll(a,a.ActiveSystemId);a=assert(A.ProposeDiscovery(a,id,1000))end
    local r=runtimeFixture(assert(A.Normalize(A.Serialize(a,1000),1000)));r.Context.TransitionsEnabled=false
    assert(r:Transition("TravelSystem","Sun","disabled",1000)~="Committed")
    assert(not r:Action("StellarResearch","AlphaCentauriA","SignalAmplifier",1000))
    local offer=module(Shared,"MonetizationCatalog").Products.SmallEnergy
    assert(r:ProcessReceipt(offer,"recovery-paid",1000)=="Granted")
    assert(r.Account.Systems.AlphaCentauriB.Currency==1200 and r.Account.UnlockedSystems.Sun and r.Account.UnlockedSystems.Proxima and r.Account.UnlockedSystems.AlphaCentauriA)
end)
test("malformed_v3_metadata_fails_closed_without_replacement",function()
    local A=accountModule();local U=module(Shared,"StarUtil");local saved=A.Serialize(A.New(1000),1000)
    for _,change in ipairs({function(s)s.Revision=nil end,function(s)s.Systems.Sun.Daily.Day="bad"end,
        function(s)s.Systems.Sun.Daily.Claimed.Unknown=true end,function(s)s.Systems.Sun.LastSeen="bad"end})do
        local bad=U.Clone(saved);change(bad);assert(A.Normalize(bad,1000)==nil,"Malformed v3 accepted")
    end
end)
local failures=0;for _,r in ipairs(checks)do if not r.Passed then failures+=1 end end
return game.HttpService:JSONEncode({Total=#checks,Failures=failures,Checks=checks})
