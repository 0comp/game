-- Run in Edit against cloned catalogs so Studio module caching cannot hide changes.
local folder=Instance.new("Folder")
folder.Name="OrbitExpansionChecks"
local kit=game.ReplicatedStorage.ClickerKit:Clone()
kit.Name="OrbitExpansionChecksKit"; kit.Parent=game.ReplicatedStorage
local clones={}
for _,name in ipairs({"UpgradeCatalog","ProgressionCatalog","Art","Interface"}) do
    local m=kit[name]:Clone(); m.Parent=kit; clones[name]=m
end
local theme=kit.Themes.Space:Clone(); theme.Parent=kit.Themes
local effects=game.StarterPlayer.StarterPlayerScripts.Effects:Clone(); effects.Parent=game.StarterPlayer.StarterPlayerScripts
local results={}
local function check(name,run)
    local ok,err=pcall(run); table.insert(results,{Name=name,Passed=ok,Error=not ok and tostring(err) or nil})
end
local C=require(theme)
local P=require(clones.ProgressionCatalog)
local catalog=require(clones.UpgradeCatalog)
local E=require(game.ServerScriptService.ClickerTemplate.Economy).new(C,catalog,P)
local function fresh(worlds)
    local d=E:New(1000)
    for i=1,worlds do d.UnlockedZones[C.Zones[i].Id]=true end
    return d
end
check("13 worlds, 19 producers, 9 expeditions, 30 achievements and 6 dailies",function()
    assert(#C.Zones==13,"Expected 13 worlds")
    assert(#catalog==19,"Expected 19 producers")
    assert(#P.Expeditions==9,"Expected 9 expeditions")
    assert(#P.Achievements==30,"Expected 30 achievements")
    assert(#P.Daily==6,"Expected 6 daily goals")
end)
check("IDs are unique and all content fits currency and world limits",function()
    for _,list in ipairs({C.Zones,catalog,P.Expeditions,P.Achievements,P.Daily}) do
        local ids={}
        for _,def in ipairs(list) do
            assert(not ids[def.Id],"Duplicate "..def.Id); ids[def.Id]=true
            assert((def.UnlockCost or def.BaseCost or def.Cost or 0)<=C.MaximumCurrency)
            assert((def.RequiredWorld or def.World or 1)<=#C.Zones)
        end
    end
    for _,def in ipairs(catalog) do assert(C.UpgradePresentation[def.Id],def.Id.." lacks presentation") end
end)
check("New worlds enforce exact price and allow returning without another charge",function()
    for _,index in ipairs({12,13}) do
        local zone=C.Zones[index]; assert(zone,"Missing new world")
        local d=fresh(index-1); d.Currency=zone.UnlockCost-128
        assert(not E:Action(d,"Zone",zone.Id,nil,1000),"Underpriced unlock")
        d.Currency=zone.UnlockCost
        assert(E:Action(d,"Zone",zone.Id,nil,1000))
        assert(d.Currency==0 and d.CurrentZone==zone.Id and d.UnlockedZones[zone.Id])
        assert(E:Action(d,"Zone",zone.Id,nil,1000) and d.Currency==0)
    end
end)
check("Each new producer respects its unlock and improves production",function()
    for _,id in ipairs({"SunPrism","CausalityTap","PulsarArray","OblivionEngine"}) do
        local def
        for _,item in ipairs(catalog) do if item.Id==id then def=item end end
        assert(def,"Missing "..id)
        local d=fresh(def.RequiredWorld-1); d.Currency=C.MaximumCurrency
        assert(not E:Action(d,"Buy",id,1,1000))
        d=fresh(def.RequiredWorld); d.Currency=def.BaseCost
        local power=E:ClickPower(d,1000)+E:Passive(d,1000)
        assert(E:Action(d,"Buy",id,1,1000))
        assert(d.Currency==0 and d.Upgrades[id]==1)
        assert(E:ClickPower(d,1000)+E:Passive(d,1000)>power)
    end
end)
check("New expeditions enforce locks, timing and single reward",function()
    assert(#P.Expeditions==9,"Missing expeditions")
    for i=4,9 do
        local def=P.Expeditions[i]; local d=fresh(def.World-1); d.Currency=C.MaximumCurrency
        assert(not E:Action(d,"Expedition",def.Id,nil,1000))
        d=fresh(def.World); d.Currency=def.Cost
        assert(E:Action(d,"Expedition",def.Id,nil,1000))
        assert(not E:Action(d,"ClaimExpedition",nil,nil,1000+def.Duration-1))
        local reward=d.Expedition.Reward
        assert(E:Action(d,"ClaimExpedition",nil,nil,1000+def.Duration))
        assert(d.Currency==reward and d.TotalExpeditions==1)
        assert(not E:Action(d,"ClaimExpedition",nil,nil,1000+def.Duration))
    end
end)
check("New achievements and dailies claim exactly once",function()
    assert(#P.Achievements==30 and #P.Daily==6,"Missing goals")
    for _,kind in ipairs({"Achievement","Daily"}) do
        local list=kind=="Achievement" and P.Achievements or P.Daily
        local start=kind=="Achievement" and 19 or 4
        for i=start,#list do
            local def=list[i]; local d=fresh(13)
            d.TotalClicks=1000000; d.LifetimeCurrency=C.MaximumCurrency; d.TotalExpeditions=100
            d.Prestiges=15; d.LifetimePurchases=100; d.Upgrades.TapCoil=1000
            assert(E:Action(d,kind,def.Id,nil,1000),def.Id)
            assert(not E:Action(d,kind,def.Id,nil,1000),"Duplicate "..def.Id)
        end
    end
end)
check("Expansion progression survives serialization and Ascend",function()
    local d=fresh(13); d.CurrentZone="Oblivion"; d.Upgrades.OblivionEngine=2
    d.ClaimedAchievements.World13=true; d.Research.AutoBuy=1; d.AutoBuyEnabled=true
    local restored=E:Normalize(game.HttpService:JSONDecode(game.HttpService:JSONEncode(E:Serialize(d,1000))),1000)
    assert(restored.CurrentZone=="Oblivion" and restored.Upgrades.OblivionEngine==2)
    assert(restored.ClaimedAchievements.World13 and E:WorldCount(restored)==13)
    restored.Currency=C.MaximumCurrency
    assert(E:Action(restored,"Rebirth",nil,nil,1000))
    assert(E:WorldCount(restored)==13 and restored.ClaimedAchievements.World13 and restored.Research.AutoBuy==1)
end)
check("Both worlds render distinct animated art with reduced-motion support",function()
    local A=require(clones.Art); local F=require(effects); local UI=require(clones.Interface)
    for _,index in ipairs({12,13}) do
        local zone=C.Zones[index]; assert(zone,"Missing world")
        local v=UI.Build(folder); v.Art:Destroy(); v.Art=A.Planet(v.Target,zone)
        v.State=nil
        local rig=v.Art:FindFirstChild(index==12 and "PulseBeams" or "AccretionRing")
        assert(rig,"Missing distinct world art")
        local effect={View=v,Time=0,Velocity=0,Spring=1,Tilt=0,Collectors={},Clouds={}}
        F.Step(effect,0.1); local first=rig.Rotation; F.Step(effect,0.1)
        assert(rig.Rotation~=first,"World effect does not animate")
        v.ReducedMotion=true; F.Step(effect,0.1); first=rig.Rotation; F.Step(effect,0.1)
        assert(rig.Rotation==first,"Reduced motion still animates")
        v.Gui:Destroy()
    end
end)
check("Expanded UI renders all cards and both worlds at desktop and phone sizes",function()
    local UI=require(clones.Interface); local v=UI.Build(folder)
    local function count(t) local n=0; for _ in pairs(t) do n+=1 end; return n end
    assert(count(v.Rows)==19 and count(v.Cards.Expeditions)==9 and count(v.Cards.Journal)==36)
    local d=fresh(13)
    for _,id in ipairs({"Pulsar","Oblivion"}) do
        d.CurrentZone=id; v:Render(E:Snapshot(d,1000,"Cloud",true))
        assert(v.Art:FindFirstChild(id=="Pulsar" and "PulseBeams" or "AccretionRing"))
        for _,size in ipairs({Vector2.new(1280,800),Vector2.new(390,844),Vector2.new(844,390)}) do
            for _,page in ipairs({"Play","Expeditions","Journal"}) do v.Page=page;v:Layout(size) end
        end
    end
    v.Gui:Destroy()
end)
folder:Destroy(); theme:Destroy(); effects:Destroy()
for _,m in pairs(clones) do m:Destroy() end
kit:Destroy()
local failures=0; for _,r in ipairs(results) do if not r.Passed then failures+=1 end end
return game.HttpService:JSONEncode({Total=#results,Failures=failures,Checks=results})
