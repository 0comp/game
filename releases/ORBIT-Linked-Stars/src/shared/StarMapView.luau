-- Star travel and directional upgrades extend the existing six-page interface.
local Stars=require(script.Parent.StarSystemCatalog)
local Upgrades=require(script.Parent.StellarUpgradeCatalog)
local Number=require(script.Parent.Art).Number
local M={}
local function make(class,parent,name,props)
    local o=Instance.new(class);o.Name=name
    for key,value in pairs(props or {})do o[key]=value end;o.Parent=parent;return o
end
local function frame(parent,name,color)
    local o=make("Frame",parent,name,{BackgroundColor3=color,BorderSizePixel=0})
    make("UICorner",o,"Corner",{CornerRadius=UDim.new(0,14)});return o
end
local function label(parent,name,text,size,color)
    return make("TextLabel",parent,name,{BackgroundTransparency=1,Text=text,TextSize=size,TextColor3=color,Font=Enum.Font.Gotham,
        TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
end
local function button(parent,name,text,t)
    local o=make("TextButton",parent,name,{BackgroundColor3=t.Accent,BorderSizePixel=0,Text=text,TextSize=12,Font=Enum.Font.GothamBold,TextColor3=t.Background,AutoButtonColor=false})
    make("UICorner",o,"Corner",{CornerRadius=UDim.new(0,9)});return o
end
local function scroll(parent,name)
    return make("ScrollingFrame",parent,name,{BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=5,
        CanvasSize=UDim2.fromOffset(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollingDirection=Enum.ScrollingDirection.Y})
end
local function pos(o,x,y,w,h)o.Position=UDim2.fromOffset(x,y);o.Size=UDim2.fromOffset(w,h)end
function M.Attach(v,config)
    local t=config.Theme;v.Config=config;v.StellarMode={Research=false,Ascension=false}
    local art=require(script.Parent.Art).ForConfig(config)
    v.StarCards={};v.StellarCards={Research={},Ascension={}};v.StellarTabs={};v.StellarLists={}
    v.StarMapButton=button(v.Worlds,"StarMapButton","STAR MAP >",t)
    local panel=frame(v.Canvas,"StarMap",t.Panel);v.StarMapPanel=panel
    local title=label(panel,"Title","STAR MAP",24,t.Text)
    local sub=label(panel,"Subtitle","Develop 13 planets to discover the next star. Travel preserves progress; discovery resets ordinary runs.",13,t.MutedText)
    v.StarMapBack=button(panel,"Back","< PLANETS",t)
    local list=scroll(panel,"List")
    make("UIListLayout",list,"Layout",{Padding=UDim.new(0,12),SortOrder=Enum.SortOrder.LayoutOrder})
    for i,id in ipairs(Stars.Order)do
        local star=Stars.Get(id);local row=frame(list,id,t.PanelRaised);row.LayoutOrder=i
        local orb=frame(row,"Star",star.Accent);make("UICorner",orb,"Round",{CornerRadius=UDim.new(1,0)})
        local name=label(row,"Name",star.Name,18,t.Text);name.Font=Enum.Font.GothamBold
        local detail=label(row,"Detail","Undiscovered star system",12,t.MutedText)
        local state=label(row,"Status","LOCKED",12,t.AccentAlt)
        local buy=button(row,"Action","LOCKED",t);buy.Active=false
        v.StarCards[id]={Frame=row,Orb=orb,Name=name,Detail=detail,Status=state,Button=buy,Id=id}
    end
    for _,section in ipairs({"Research","Ascension"})do
        local parent=v.Panels[section]
        local normal=button(parent,"StandardTab","STANDARD",t)
        local stellar=button(parent,"InterstellarTab","INTERSTELLAR",t)
        v.StellarTabs[section]={Standard=normal,Interstellar=stellar}
        local container=make("Frame",parent,"InterstellarSection",{BackgroundTransparency=1})
        local info=label(container,"Info","Permanent upgrades for neighboring stars. Kept through Ascend and new-star discovery.",12,t.MutedText)
        local cards=scroll(container,"List")
        local grid=make("UIGridLayout",cards,"Grid",{CellPadding=UDim2.fromOffset(12,12),SortOrder=Enum.SortOrder.LayoutOrder})
        v.StellarLists[section]={Container=container,List=cards,Info=info,Grid=grid}
        for _,target in ipairs(Stars.Order)do if Stars.AreAdjacent(config.SystemId or "Sun",target)then
            v.StellarCards[section][target]={}
            for i,def in ipairs(Upgrades[section])do
                local row=frame(cards,target..def.Id,t.PanelRaised);row.LayoutOrder=(table.find(Stars.Order,target) or 0)*10+i
                local presentation=(config.StellarPresentation or {})[def.Id]
                local name=label(row,"Name",presentation and presentation.Name or def.Name,16,t.Text);name.Font=Enum.Font.GothamBold
                local iconTile
                if presentation then
                    iconTile=frame(row,"UpgradeIcon",presentation.Color:Lerp(t.Panel,.85))
                    local icon=art.Icon(iconTile,presentation.Icon,presentation.Color)
                    make("UIScale",icon,"IconScale",{Scale=.67})
                end
                local detail=label(row,"Detail","Boost "..Stars.Get(target).Name,12,t.MutedText)
                local status=label(row,"Status","DISCOVER NEIGHBOR",11,t.AccentAlt)
                local price=label(row,"Price","",11,t.MutedText)
                local buy=button(row,"Action","LOCKED",t)
                v.StellarCards[section][target][def.Id]={Frame=row,Name=name,IconTile=iconTile,Detail=detail,Status=status,Reward=price,Button=buy,TargetId=target,Id=def.Id,Section=section}
            end
        end end
    end
    local overlay=make("Frame",v.Gui,"DiscoveryConfirmation",{BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.2,
        BorderSizePixel=0,Size=UDim2.fromScale(1,1),Visible=false,ZIndex=60,Active=true})
    v.DiscoveryConfirmation=overlay
    local body=frame(overlay,"Body",t.PanelRaised);body.AnchorPoint=Vector2.new(.5,.5);body.Position=UDim2.fromScale(.5,.5);body.ZIndex=61
    local heading=label(body,"Title","DISCOVER A NEW STAR",20,t.Text);heading.Font=Enum.Font.GothamBold;heading.ZIndex=62
    v.DiscoveryText=label(body,"Text","",14,t.Text);v.DiscoveryText.ZIndex=62
    v.DiscoveryCancel=button(body,"Cancel","KEEP PLAYING",t);v.DiscoveryCancel.ZIndex=62
    v.DiscoveryConfirm=button(body,"Confirm","DISCOVER & RESET",t);v.DiscoveryConfirm.ZIndex=62
    local oldLayout,oldRender=v.Layout,v.Render
    function v:OpenDiscovery(id)
        local card=self.StarCards[id]
        if not card or not card.Item or card.Item.Status~="Discover" or (self.State and self.State.CanTravel==false)then return end
        self.DiscoveryTarget=id
        heading.Text="DISCOVER "..string.upper(Stars.Get(id).Name)
        self.DiscoveryText.Text="Discovering this star resets ordinary progress in EVERY discovered system: Energy, producers, planets, Research, ordinary Ascension upgrades, earned Stars, expeditions, pending offline Energy and temporary burst/charge.\n\nYou keep interstellar upgrades, Auto Buy ownership, achievements, daily progress and all Robux benefits.\n\nLater travel preserves progress."
        self.DiscoveryConfirmation.Visible=true
    end
    function v:SetStellarMode(section,enabled)
        if self.StellarMode[section]==nil then return end
        self.StellarMode[section]=enabled==true;self:Layout(self.Viewport)
    end
    function v:Render(s)
        oldRender(self,s)
        self.Tagline.Text=string.upper(s.SystemName or config.SystemName or "Sun").." SYSTEM"
        self.SceneTag.Text=(s.SystemName or config.SystemName or "Sun").." · "..self.SceneTag.Text
        local incoming=s.IncomingStellar or {}
        local function percent(key)return math.floor(((incoming[key] or 1)-1)*100+.5)end
        for _,section in ipairs({"Research","Ascension"})do
            self.StellarLists[section].Info.Text="Incoming: +"..percent("ClickMultiplier").."% clicks · +"..percent("PassiveMultiplier")
                .."% passive · +"..percent("ProductionMultiplier").."% production · +"..math.floor((incoming.OfflineSeconds or 0)/60).." min offline. Upgrades stay through discovery."
        end
        for _,item in ipairs(s.StarSystems or {})do
            local row=self.StarCards[item.Id];if row then
                row.Item=item;row.Button.Text=string.upper(item.Status=="Travel" and "TRAVEL" or item.Status)
                row.Button.Active=(item.Status=="Travel" or item.Status=="Discover") and s.CanTravel~=false and not s.TransactionBusy
                row.Button.BackgroundColor3=row.Button.Active and t.Accent or t.Panel
                row.Button.TextColor3=row.Button.Active and t.Background or t.MutedText
                row.Status.Text=item.Worlds.." / 13 PLANETS"
                row.Detail.Text=item.Status=="Locked" and ("Complete 13 planets around "..(Stars.Get(item.Previous) or {Name="the previous star"}).Name..".")
                    or item.Status=="Discover" and "Ready for discovery. All ordinary runs will reset."
                    or "Your local progress is saved when you travel."
            end
        end
        for _,section in ipairs({"Research","Ascension"})do
            for _,item in ipairs(s.StellarUpgrades and s.StellarUpgrades[section] or {})do
                local row=self.StellarCards[section][item.TargetId] and self.StellarCards[section][item.TargetId][item.Id]
                if row then
                    row.Item=item
                    local effect=item.Effect=="Offline" and ("+"..item.Amount/60 .." min offline / level")
                        or ("+"..math.floor(item.Amount*100+.5).."% "..(item.Effect=="Clicks" and "clicks" or item.Effect=="Passive" and "passive" or "all production").." / level")
                    row.Detail.Text=(s.SystemName or config.SystemName or "Sun").." > "..item.TargetName.." · "..effect
                    row.Status.Text=item.Locked and "DISCOVER THIS NEIGHBOR" or "LEVEL "..item.Level.." / "..item.Max
                    row.Reward.Text=item.Level>=item.Max and "PERMANENT · MAXED" or Number(item.Cost)..(item.Wallet=="Stars" and " ASCEND STARS" or " ENERGY")
                    row.Button.Text=item.Locked and "LOCKED" or item.Level>=item.Max and "MAXED" or item.CanBuy and "UPGRADE" or "NEED "..(item.Wallet=="Stars" and "STARS" or "ENERGY")
                    row.Button.Active=item.CanBuy and not s.TransactionBusy
                    row.Button.BackgroundColor3=row.Button.Active and t.Accent or t.Panel
                    row.Button.TextColor3=row.Button.Active and t.Background or t.MutedText
                end
            end
        end
        self.ShopSubtitle.Text="Energy packs apply to your active star when delivered. Passes and paid boosts work across all stars."
        if s.AutoBuyOwned and not s.AutoBuyUnlocked then self.AutoBuy.Text="AUTO OWNED: NEED 8 WORLDS"end
    end
    function v:Layout(viewport)
        oldLayout(self,viewport)
        local w,h=self.Canvas.Size.X.Offset,self.Canvas.Size.Y.Offset
        local y=self.Scene.Position.Y.Offset;local bodyH=h-y
        self.WorldTitle.Visible=false
        self.StarMapButton.Position=self.WorldTitle.Position
        self.StarMapButton.Size=UDim2.fromOffset(math.min(144,self.WorldTitle.Size.X.Offset),24)
        pos(panel,0,y,w,bodyH);panel.Visible=self.Page=="StarMap"
        pos(title,24,16,w-190,34);pos(sub,24,54,w-48,40);sub.Visible=not self.Landscape
        pos(self.StarMapBack,w-155,16,130,34)
        local top=self.Landscape and 60 or 105
        pos(list,22,top,w-44,math.max(30,bodyH-top-20))
        for _,r in pairs(self.StarCards)do
            r.Frame.Size=UDim2.new(1,-6,0,126)
            pos(r.Orb,16,20,40,40);pos(r.Name,72,14,w-210,28)
            pos(r.Detail,72,47,w-125,34);pos(r.Status,72,88,w-220,22)
            pos(r.Button,w-178,86,106,30)
        end
        for _,section in ipairs({"Research","Ascension"})do
            local normalList=self[section.."List"]
            local baseTop=normalList.Position.Y.Offset
            local tabY=section=="Ascension" and (self.Landscape and 52 or 96) or baseTop
            local tabs=self.StellarTabs[section];local width=(w-56)/2
            pos(tabs.Standard,22,tabY,width,32);pos(tabs.Interstellar,34+width,tabY,width,32)
            local mode=self.StellarMode[section]
            tabs.Standard.BackgroundColor3=not mode and t.Accent or t.PanelRaised
            tabs.Interstellar.BackgroundColor3=mode and t.Accent or t.PanelRaised
            tabs.Standard.TextColor3=not mode and t.Background or t.MutedText
            tabs.Interstellar.TextColor3=mode and t.Background or t.MutedText
            normalList.Visible=not mode
            normalList.Position+=UDim2.fromOffset(0,42)
            normalList.Size=UDim2.fromOffset(normalList.Size.X.Offset,math.max(30,normalList.Size.Y.Offset-42))
            if section=="Ascension"then self.AscendBanner.Position+=UDim2.fromOffset(0,42);self.AscendBanner.Visible=not mode end
            local group=self.StellarLists[section];local listY=tabY+42
            pos(group.Container,22,listY,w-44,math.max(30,bodyH-listY-18));group.Container.Visible=mode
            pos(group.Info,0,0,w-60,34)
            group.List.Position=UDim2.fromOffset(0,42);group.List.Size=UDim2.new(1,0,1,-42)
            local columns=self.Compact and not self.Landscape and 1 or 2
            local cw=(w-50-12*(columns-1))/columns
            local rh=self.Landscape and 114 or 148
            group.Grid.CellSize=UDim2.fromOffset(cw,rh)
            for _,rows in pairs(self.StellarCards[section])do for _,r in pairs(rows)do
                pos(r.Name,14,10,cw-28,24);pos(r.Detail,14,38,cw-28,self.Landscape and 27 or 40)
                if r.IconTile then pos(r.IconTile,12,6,32,32);pos(r.Name,54,10,cw-68,24)end
                pos(r.Status,14,self.Landscape and 67 or 84,cw-28,19)
                pos(r.Reward,14,rh-31,cw-133,22);pos(r.Button,cw-115,rh-38,101,30)
            end end
        end
        local mw=math.min(540,viewport.X-32);local mh=math.min(380,viewport.Y-24)
        body.Size=UDim2.fromOffset(mw,mh)
        pos(heading,20,14,mw-40,54);pos(self.DiscoveryText,20,74,mw-40,mh-145)
        pos(self.DiscoveryCancel,20,mh-55,(mw-52)/2,36);pos(self.DiscoveryConfirm,32+(mw-52)/2,mh-55,(mw-52)/2,36)
    end
    v:Layout(v.Viewport or Vector2.new(1280,800))
end
return M
