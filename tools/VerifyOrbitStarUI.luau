local box=game.ServerStorage.OrbitLinkedTests
local Shared,Server=box.Shared,box.Server
local tests={}
local function check(name,fn)local ok,err=pcall(fn);table.insert(tests,{Name=name,Passed=ok,Error=not ok and tostring(err) or nil})end
local function module(name) local m=Shared:FindFirstChild(name);assert(m,"Missing "..name);return require(m)end
local holder=Instance.new("Folder")
check("configuration_factories_keep_sun_api_and_distinct_planets",function()
    local F=module("SystemThemeFactory");local UI=module("Interface");local Art=module("Art")
    assert(type(UI.ForConfig)=="function" and type(Art.ForConfig)=="function")
    local v=UI.ForConfig(F.Get("Proxima")).Build(holder)
    assert(v.Config.SystemId=="Proxima" and v.Zones.Proxima_01 and not v.Zones.Earth)
    v.Gui:Destroy()
end)
check("star_map_shows_current_discover_travel_locked_and_reset_confirmation",function()
    local A=require(Server.AccountProfile);local F=module("SystemThemeFactory");local UI=module("Interface")
    assert(type(UI.ForConfig)=="function")
    local a=A.New(1000);for _,z in ipairs(F.Get("Sun").Zones)do a.Systems.Sun.UnlockedZones[z.Id]=true end
    local v=UI.ForConfig(F.Get("Sun")).Build(holder)
    v:Render(A.Snapshot(a,1000,"Cloud",true))
    assert(v.StarCards.Sun.Button.Text=="CURRENT" and v.StarCards.Proxima.Button.Text=="DISCOVER")
    assert(v.StarCards.AlphaCentauriA.Button.Text=="LOCKED")
    v:OpenDiscovery("Proxima");assert(v.DiscoveryConfirmation.Visible and v.DiscoveryTarget=="Proxima")
    assert(string.find(v.DiscoveryText.Text,"ordinary Ascension",1,true))
    v.Gui:Destroy()
end)
check("stellar_cards_show_direction_cost_effect_and_manual_actions",function()
    local A=require(Server.AccountProfile);local F=module("SystemThemeFactory");local UI=module("Interface")
    assert(type(UI.ForConfig)=="function")
    local a=A.New(1000);for _,z in ipairs(F.Get("Sun").Zones)do a.Systems.Sun.UnlockedZones[z.Id]=true end
    a=assert(A.ProposeDiscovery(a,"Proxima",1000))
    local v=UI.ForConfig(F.Get("Proxima")).Build(holder);v:Render(A.Snapshot(a,1000,"Cloud",true))
    local card=v.StellarCards.Research.Sun.SignalAmplifier
    assert(card and string.find(card.Detail.Text,"Sun",1,true) and card.Item.Cost==100000000)
    assert(string.find(v.Tagline.Text,"PROXIMA",1,true),"Active star missing from header")
    assert(string.find(card.Detail.Text,"Proxima",1,true),"Source star missing")
    assert(string.find(v.StellarLists.Research.Info.Text,"Incoming",1,true),"Incoming benefits missing")
    for _,size in ipairs({Vector2.new(1280,800),Vector2.new(390,844),Vector2.new(375,667),Vector2.new(844,390)})do
        for _,page in ipairs({"Play","StarMap","Research","Ascension"})do v:SetPage(page);v:Layout(size)end
    end
    v.Gui:Destroy()
end)
check("twenty_switches_dispose_old_view_and_preserve_reduced_motion",function()
    local Controller=box.Client:FindFirstChild("StarClientController");assert(Controller,"Missing StarClientController")
    local C=require(Controller);local A=require(Server.AccountProfile);local F=module("SystemThemeFactory")
    local a=A.New(1000);for _,z in ipairs(F.Get("Sun").Zones)do a.Systems.Sun.UnlockedZones[z.Id]=true end
    a=assert(A.ProposeDiscovery(a,"Proxima",1000))
    local live,created,pops,sent=0,0,0,{}
    local c=C.new(holder,{SendAction=function(...)table.insert(sent,{...})end,EffectsFactory=function()
        live+=1;created+=1;local gone=false
        return {Destroy=function()if not gone then live-=1;gone=true end end,Update=function()end,Press=function()end,Pop=function()pops+=1 end}
    end})
    c:ApplySnapshot(A.Snapshot(a,1000,"Cloud",true));c.View.ReducedMotion=true
    for i=1,20 do
        local oldView=c.View;local oldConnections=c.ViewConnections
        a=assert(A.ProposeTravel(a,a.ActiveSystemId=="Sun" and "Proxima" or "Sun",1000+i));a.Revision+=1
        c:ApplySnapshot(A.Snapshot(a,1000+i,"Cloud",true))
        assert(oldView.Gui.Parent==nil and c.View.ReducedMotion and live==1)
        for _,connection in ipairs(oldConnections)do assert(not connection.Connected)end
    end
    c:ApplySnapshot({Kind="ClickFeedback",Gain=1,ActiveSystemId="WrongStar",DiscoveryGeneration=1});assert(pops==0)
    c:ApplySnapshot({Kind="ClickFeedback",Gain=1,ActiveSystemId=a.ActiveSystemId,DiscoveryGeneration=1,AccountRevision=a.Revision});assert(pops==1)
    c:Destroy();assert(live==0 and created>=21)
end)
check("discovery_sends_only_on_confirmation_and_stale_snapshots_are_ignored",function()
    local C=require(box.Client.StarClientController);local A=require(Server.AccountProfile);local F=module("SystemThemeFactory")
    local a=A.New(1000);for _,z in ipairs(F.Get("Sun").Zones)do a.Systems.Sun.UnlockedZones[z.Id]=true end
    local sent={};local c=C.new(holder,{SendAction=function(...)table.insert(sent,{...})end,
        EffectsFactory=function()return {Destroy=function()end,Update=function()end,Press=function()end,Pop=function()error("stale feedback")end}end})
    c:ApplySnapshot(A.Snapshot(a,1000,"Cloud",true));assert(c:Travel("Proxima") and #sent==0 and c.View.DiscoveryConfirmation.Visible)
    assert(c:ConfirmDiscovery() and #sent==1 and sent[1][1]=="DiscoverSystem" and sent[1][2]=="Proxima")
    local old=A.Snapshot(a,1000,"Cloud",true)
    a=assert(A.ProposeDiscovery(a,"Proxima",1001));a.Revision=2
    c:ApplySnapshot(A.Snapshot(a,1001,"Cloud",true));assert(not c:ApplySnapshot(old) and c.State.ActiveSystemId=="Proxima")
    c:ApplySnapshot({Kind="ClickFeedback",Gain=10,ActiveSystemId="Proxima",DiscoveryGeneration=1,AccountRevision=1})
    c:Destroy()
end)
check("all_star_views_build_and_real_effects_cleanup",function()
    local UI=module("Interface");local F=module("SystemThemeFactory");local A=require(Server.AccountProfile)
    local Effects=require(box.Client.Effects);local a=A.New(1000)
    for _,id in ipairs(module("StarSystemCatalog").Order)do
        local config=F.Get(id);local v=UI.ForConfig(config).Build(holder)
        for _,z in ipairs(config.Zones)do assert(v.Zones[z.Id])end
        for _,size in ipairs({Vector2.new(1280,800),Vector2.new(390,844),Vector2.new(375,667),Vector2.new(844,390)})do
            v:Layout(size)
            for _,group in pairs(v.StellarLists)do assert(group.Container.Size.Y.Offset>=30)end
        end
        local fx=Effects.new(v,config);local music=fx.Music;local connection=fx.Connection
        fx:Destroy();assert(not connection.Connected and(not music or music.Parent==nil))
        for _,c in ipairs(fx.ButtonConnections)do assert(not c.Connected)end
        v.Gui:Destroy()
    end
end)
holder:Destroy()
local failed=0;for _,r in ipairs(tests)do if not r.Passed then failed+=1 end end
return game.HttpService:JSONEncode({Total=#tests,Failures=failed,Checks=tests})

