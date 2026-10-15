-- Isolated release checks: no player profiles, DataStore writes or Robux prompts.
local kit = game.ReplicatedStorage.ClickerKit
local E = require(game.ServerScriptService.ClickerTemplate.Economy)
local P = require(kit.ProgressionCatalog)
local C = require(kit.ThemeConfig)
local e = E.new(C, require(kit.UpgradeCatalog), P)
local rules = require(kit.MonetizationRules)
local offers = require(kit.MonetizationCatalog)
local ui = require(kit.Interface)
local receipts = require(game.ServerScriptService.ClickerTemplate.MonetizationReceiptService)
local h = game:GetService("HttpService")
local results = {}
local function test(name, run)
    local ok, err = pcall(run)
    table.insert(results, {Name=name, Passed=ok, Error=not ok and tostring(err) or nil})
end
local function profile(worlds, currency)
    local d=e:New(1000)
    for i=1,worlds do d.UnlockedZones[C.Zones[i].Id]=true end
    d.Currency=currency
    return d
end
test("Seven worlds rejects Auto Buy without spending", function()
    local d=profile(7,500000000)
    assert(not e:Action(d,"Research","AutoBuy",nil,1000))
    assert(d.Currency==500000000 and not e:AutoBuyUnlocked(d))
end)
test("Eight worlds still requires 500M", function()
    local d=profile(8,499999999)
    assert(not e:Action(d,"Research","AutoBuy",nil,1000))
    assert(d.Currency==499999999)
end)
test("Exact price unlocks permanently; repeat does not charge", function()
    local d=profile(8,500000000)
    assert(e:Action(d,"Research","AutoBuy",nil,1000))
    assert(d.Currency==0 and d.AutoBuyEnabled and e:AutoBuyUnlocked(d))
    d.Currency=500000000
    assert(not e:Action(d,"Research","AutoBuy",nil,1000))
    assert(d.Currency==500000000)
end)
test("Auto Buy purchases one level of each research only", function()
    local d=profile(8,501000000)
    assert(e:Action(d,"Research","AutoBuy",nil,1000))
    e:Tick(d,1001,1)
    assert(d.Currency==990650, tostring(d.Currency))
    for _,def in ipairs(P.Research) do assert(d.Research[def.Id]==1,def.Id) end
    assert(next(d.Upgrades)==nil and next(d.Permanent)==nil and d.Stars==0)
end)
test("Auto Buy obeys maximum and affordability", function()
    local d=profile(8,99); d.Research.AutoBuy=1; d.AutoBuyEnabled=true
    e:Tick(d,1001,1); assert(d.Currency==99 and not d.Research.Focus)
    for _,def in ipairs(P.Research) do d.Research[def.Id]=def.Max end
    d.Currency=1000000; e:Tick(d,1002,1); assert(d.Currency==1000000)
end)
test("Paused Auto Buy does not spend", function()
    local d=profile(8,1000000); d.Research.AutoBuy=1; d.AutoBuyEnabled=true
    assert(e:Action(d,"AutoBuy",false,nil,1000))
    e:Tick(d,1001,1); assert(d.Currency==1000000 and not d.Research.Focus)
end)
test("Ascend keeps Auto Buy and both toggle choices", function()
    for _,enabled in ipairs({true,false}) do
        local d=profile(8,1e16); d.Research={AutoBuy=1,Focus=5}; d.AutoBuyEnabled=enabled
        d.Upgrades.TapCoil=5; d.Permanent.Mastery=2
        assert(e:Action(d,"Rebirth",nil,nil,1000))
        assert(d.Research.AutoBuy==1 and not d.Research.Focus and d.AutoBuyEnabled==enabled)
        assert(next(d.Upgrades)==nil and d.Permanent.Mastery==2 and e:WorldCount(d)==8)
        local restored=e:Normalize(h:JSONDecode(h:JSONEncode(e:Serialize(d,1000))),1000)
        assert(restored.Research.AutoBuy==1 and restored.AutoBuyEnabled==enabled)
    end
end)
test("Paid badges reflect pass, timed boost, stacking and expiry", function()
    assert(ui.PaidProductionText({OwnedPasses={DoubleProduction=true}},1000)=="DOUBLE PRODUCTION PASS: x2")
    assert(string.find(ui.PaidProductionText({PaidBoostEndsAt=1060},1000),"PAID x2",1,true))
    assert(string.find(ui.PaidProductionText({OwnedPasses={DoubleProduction=true},PaidBoostEndsAt=1060},1000),"PAID PRODUCTION x4",1,true))
    assert(ui.PaidProductionText({OwnedPasses={DoubleProduction=true},PaidBoostEndsAt=999},1000)=="DOUBLE PRODUCTION PASS: x2")
    assert(ui.PaidProductionText({PaidBoostEndsAt=999},1000)==nil)
end)
test("Paid production applies 2x and stacked 4x", function()
    local d=profile(1,0); local base=e:ClickPower(d,1000)
    d.Runtime.OwnedPasses.DoubleProduction=true
    assert(e:ClickPower(d,1000)==base*2)
    d.PaidBoostEndsAt=1100; assert(e:ClickPower(d,1000)==base*4)
    d.Runtime.BurstEndsAt=1100; assert(e:ClickPower(d,1000)==base*12)
end)
test("Auto Tap produces ten clicks per second", function()
    local n,remainder=rules.AdvanceAutoTap({AutoTap=true},0,1)
    assert(n==10 and remainder==0)
    assert(rules.AdvanceAutoTap({},0,1)==0)
end)
test("Receipt commit grants once and duplicate does not grant", function()
    local d=profile(1,100); local saved=e:Serialize(d,1000)
    saved._Session={Id="release-test",ExpiresAt=2000}
    local store={Value=saved}
    function store:UpdateAsync(key, callback)
        assert(key=="User_123")
        local nextValue=callback(self.Value)
        if nextValue~=nil then self.Value=nextValue end
        return nextValue
    end
    local status,receipt=receipts.Commit(store,123,"release-test",saved,offers.Products.SmallEnergy,"release-receipt",1000,1000,C.MaximumCurrency,180)
    assert(status=="Granted" and store.Value.Currency==1300)
    local duplicate=receipts.Commit(store,123,"release-test",saved,offers.Products.SmallEnergy,"release-receipt",1000,1000,C.MaximumCurrency,180)
    assert(duplicate=="Duplicate" and store.Value.Currency==1300)
    local live=rules.ReconcileReceipt(saved,receipt)
    assert(live.Currency==1300 and rules.ReconcileReceipt(live,receipt).Currency==1300)
end)
test("Timed boost purchases stack duration once per receipt", function()
    local d=profile(1,0)
    local a,ra=rules.ApplyProduct(d,offers.Products.Boost15Minutes,"boost-a",1000,C.MaximumCurrency)
    assert(ra.Status=="Granted" and a.PaidBoostEndsAt==1900)
    local b,rb=rules.ApplyProduct(a,offers.Products.Boost30Minutes,"boost-b",1000,C.MaximumCurrency)
    assert(rb.Status=="Granted" and b.PaidBoostEndsAt==3700)
    local c=rules.ApplyProduct(b,offers.Products.Boost30Minutes,"boost-b",1000,C.MaximumCurrency)
    assert(c.PaidBoostEndsAt==3700)
end)
local failures=0
for _,r in ipairs(results) do if not r.Passed then failures+=1 end end
return h:JSONEncode({Checks=results,Failures=failures,Total=#results})

