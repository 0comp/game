-- Disposable view controls; persistent input/remote listeners live in ClickerClient.
local Shared=game:GetService("ReplicatedStorage"):WaitForChild("ClickerKit")
local UI=require(Shared.Interface)
local Themes=require(Shared.SystemThemeFactory)
local Stars=require(Shared.StarSystemCatalog)
local Rules=require(Shared.MonetizationRules)
local U=require(Shared.StarUtil)
local Effects=require(script.Parent.Effects)
local TweenService=game:GetService("TweenService")
local C={};C.__index=C
function C.new(parent,hooks)
    local self=setmetatable({Parent=parent,Hooks=hooks,ViewConnections={},Prices={},ToastSerial=0,LastClick=0,AutoTapAccumulator=0,
        Viewport=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,800)},C)
    self:_build("Sun");return self
end
function C:_connect(signal,fn)local c=signal:Connect(fn);table.insert(self.ViewConnections,c);return c end
function C:_send(kind,id,quantity)
    if self.Destroyed or not self.State then return false end
    self.Hooks.SendAction(kind,id,quantity);return true
end
function C:Toast(message)
    if self.Destroyed then return end
    self.ToastSerial+=1;local serial=self.ToastSerial
    self.View.ToastText.Text=message;self.View.Toast.Visible=true
    task.delay(3,function()if not self.Destroyed and self.ToastSerial==serial then self.View.Toast.Visible=false end end)
end
function C:CancelWorldScroll()
    local tween=self.ScrollTween;self.ScrollTween=nil;self.ScrollGoal=nil
    if tween then tween:Cancel()end
end
function C:UpdateWorldScrollButtons()
    if self.Destroyed or not self.View then return end
    local v=self.View;local list=v.WorldList;local vertical=list.ScrollingDirection==Enum.ScrollingDirection.Y
    local p=self.ScrollGoal or list.CanvasPosition
    local offset=vertical and p.Y or p.X
    local maximum=math.max(0,vertical and (list.AbsoluteCanvasSize.Y-list.AbsoluteWindowSize.Y)or(list.AbsoluteCanvasSize.X-list.AbsoluteWindowSize.X))
    v.WorldBack.Active=offset>1;v.WorldNext.Active=offset<maximum-1
    v.WorldBack.TextTransparency=v.WorldBack.Active and 0 or .65;v.WorldNext.TextTransparency=v.WorldNext.Active and 0 or .65
end
function C:ScrollWorlds(direction)
    local v=self.View;local list=v.WorldList;local vertical=list.ScrollingDirection==Enum.ScrollingDirection.Y
    local current=self.ScrollGoal or list.CanvasPosition;local zones=v.Config.Zones
    local first=v.Zones[zones[1].Id].Button;local second=v.Zones[zones[2].Id].Button
    local stride=math.abs(vertical and (second.AbsolutePosition.Y-first.AbsolutePosition.Y)or(second.AbsolutePosition.X-first.AbsolutePosition.X))
    if stride<1 then stride=vertical and 80 or 230 end
    local target=UI.WorldScrollOffset(vertical and current.Y or current.X,vertical and list.AbsoluteWindowSize.Y or list.AbsoluteWindowSize.X,
        vertical and list.AbsoluteCanvasSize.Y or list.AbsoluteCanvasSize.X,stride,direction)
    local goal=vertical and Vector2.new(0,target)or Vector2.new(target,0)
    self:CancelWorldScroll()
    if v.ReducedMotion then list.CanvasPosition=goal;self:UpdateWorldScrollButtons();return end
    self.ScrollGoal=goal
    local tween=TweenService:Create(list,TweenInfo.new(.22,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{CanvasPosition=goal})
    self.ScrollTween=tween
    tween.Completed:Once(function()if self.ScrollTween==tween then self.ScrollTween=nil;self.ScrollGoal=nil;self:UpdateWorldScrollButtons()end end)
    tween:Play();self:UpdateWorldScrollButtons()
end
function C:OverWorldList(input)
    local v=self.View
    if v.Page~="Play" or not v.Worlds.Visible or v.Modal.Visible or v.DiscoveryConfirmation.Visible then return false end
    local p,s=v.WorldList.AbsolutePosition,v.WorldList.AbsoluteSize
    return input.Position.X>=p.X and input.Position.X<=p.X+s.X and input.Position.Y>=p.Y and input.Position.Y<=p.Y+s.Y
end
function C:Click()
    local v=self.View
    if not self.State or self.PendingTransition or self.Checkout or self.State.TransactionBusy or v.Modal.Visible or v.DiscoveryConfirmation.Visible
        or v.Page~="Play" or(v.Compact and v.PlayPage~="Collect")then return end
    local now=os.clock();if now-self.LastClick<v.Config.ClickCooldown then return end
    self.LastClick=now;self.Effects:Press();self:_send("Click")
end
function C:Travel(id)
    if not self.State or self.PendingTransition or self.Checkout or self.State.CanTravel==false or self.State.TransactionBusy then return false end
    local row=self.View.StarCards[id];local item=row and row.Item
    if not item then return false end
    if item.Status=="Discover"then self.View:OpenDiscovery(id);return true end
    if item.Status~="Travel"then return false end
    self.PendingTransition=true;return self:_send("TravelSystem",id)
end
function C:ConfirmDiscovery()
    local id=self.View.DiscoveryTarget;local row=id and self.View.StarCards[id]
    if not row or not row.Item or row.Item.Status~="Discover" or self.PendingTransition or self.Checkout or self.State.CanTravel==false then return false end
    self.View.DiscoveryConfirmation.Visible=false;self.PendingTransition=true
    return self:_send("DiscoverSystem",id)
end
function C:_build(id)
    local reduced=self.View and self.View.ReducedMotion or false
    self.ToastSerial+=1;self:CancelWorldScroll()
    for _,c in ipairs(self.ViewConnections)do c:Disconnect()end
    self.ViewConnections={}
    if self.Effects then self.Effects:Destroy()end
    if self.View then self.View.Gui:Destroy()end
    local config=Themes.Get(id)
    self.View=UI.ForConfig(config).Build(self.Parent)
    local v=self.View;v.ReducedMotion=reduced;v.Motion.Text=reduced and "Motion: OFF" or "Motion: ON"
    v.ShopPrices=self.Prices
    self.Effects=(self.Hooks.EffectsFactory or Effects.new)(v,config)
    self.AutoTapAccumulator=0;self.LastClick=0
    self:_connect(v.Target.Activated,function()self:Click()end)
    for page,b in pairs(v.Nav)do self:_connect(b.Activated,function()v:SetPage(page)end)end
    for page,b in pairs(v.MobileTabs)do self:_connect(b.Activated,function()v:SetPlayPage(page)end)end
    for q,b in pairs(v.QuantityButtons)do self:_connect(b.Activated,function()v.Quantity=q;if self.State then v:Render(self.State)end end)end
    for key,row in pairs(v.ShopOffers)do self:_connect(row.Button.Activated,function()if self.Hooks.PromptOffer then self.Hooks.PromptOffer(key,self)end end)end
    for key,row in pairs(v.CosmeticRows)do self:_connect(row.Button.Activated,function()
        if self.State and self.State.OwnedPasses[row.Cosmetic.PassKey]then self:_send("EquipCosmetic",key)else self:Toast("Unlock this cosmetic in the Shop first.")end
    end)end
    self:_connect(v.AutoBuy.Activated,function()if self.State and self.State.AutoBuyUnlocked then self:_send("AutoBuy",not self.State.AutoBuyEnabled)end end)
    for id,row in pairs(v.Rows)do self:_connect(row.Buy.Activated,function()self:_send("Buy",id,v.Quantity)end)end
    for id,row in pairs(v.Zones)do self:_connect(row.Button.Activated,function()self:_send("Zone",id)end)end
    self:_connect(v.WorldBack.Activated,function()self:ScrollWorlds(-1)end)
    self:_connect(v.WorldNext.Activated,function()self:ScrollWorlds(1)end)
    self:_connect(v.WorldList:GetPropertyChangedSignal("CanvasPosition"),function()self:UpdateWorldScrollButtons()end)
    for _,property in ipairs({"AbsoluteCanvasSize","AbsoluteWindowSize","ScrollingDirection"})do
        self:_connect(v.WorldList:GetPropertyChangedSignal(property),function()self:CancelWorldScroll();self:UpdateWorldScrollButtons()end)
    end
    for name,b in pairs(v.JournalButtons)do self:_connect(b.Activated,function()v:SetFilter(name)end)end
    for _,cards in pairs(v.Cards)do for _,row in pairs(cards)do self:_connect(row.Button.Activated,function()
        local s=self.State;if not s then return end
        if row.Kind=="Expedition"then
            if not row.Button.Active then return end
            if s.Expedition then self:_send("ClaimExpedition")else self:_send("Expedition",row.Id)end
        elseif row.Kind=="Achievement" or row.Kind=="Daily"then
            if row.Item and row.Item.Ready then self:_send(row.Kind,row.Id)else self:Toast("Complete this goal before collecting its reward.")end
        else self:_send(row.Kind,row.Id)end
    end)end end
    local function ascend()
        if self.State and self.State.CanPrestige then v.Modal.Visible=true else self:Toast("Earn more Energy to Ascend.")end
    end
    self:_connect(v.Rebirth.Activated,ascend);self:_connect(v.AscendButton.Activated,ascend)
    self:_connect(v.Cancel.Activated,function()v.Modal.Visible=false end)
    self:_connect(v.Confirm.Activated,function()if self.State and self.State.CanPrestige then self:_send("Rebirth")end;v.Modal.Visible=false end)
    self:_connect(v.Motion.Activated,function()v.ReducedMotion=not v.ReducedMotion;v.Motion.Text=v.ReducedMotion and "Motion: OFF"or"Motion: ON"end)
    self:_connect(v.Comet.Activated,function()if self.State then self:_send("Collect",self.State.EventNonce)end end)
    self:_connect(v.StarMapButton.Activated,function()v:SetPage("StarMap")end)
    self:_connect(v.StarMapBack.Activated,function()v:SetPage("Play");v:SetPlayPage("Worlds")end)
    for id,row in pairs(v.StarCards)do self:_connect(row.Button.Activated,function()self:Travel(id)end)end
    self:_connect(v.DiscoveryCancel.Activated,function()v.DiscoveryConfirmation.Visible=false;v.DiscoveryTarget=nil end)
    self:_connect(v.DiscoveryConfirm.Activated,function()self:ConfirmDiscovery()end)
    for section,tabs in pairs(v.StellarTabs)do
        self:_connect(tabs.Standard.Activated,function()v:SetStellarMode(section,false)end)
        self:_connect(tabs.Interstellar.Activated,function()v:SetStellarMode(section,true)end)
        for target,rows in pairs(v.StellarCards[section])do for track,row in pairs(rows)do self:_connect(row.Button.Activated,function()
            if row.Item and row.Item.CanBuy then self:_send(section=="Research"and"StellarResearch"or"StellarAscension",target,track)end
        end)end end
    end
    v:Layout(self.Viewport);self:UpdateWorldScrollButtons()
end
function C:ApplySnapshot(snapshot)
    if self.Destroyed or type(snapshot)~="table"then return false end
    if snapshot.Kind=="ClickFeedback"then
        local s=self.State
        if s and snapshot.ActiveSystemId==s.ActiveSystemId and snapshot.DiscoveryGeneration==s.DiscoveryGeneration
            and (snapshot.AccountRevision==nil or snapshot.AccountRevision>=(s.AccountRevision or 0)) and U.Finite(snapshot.Gain) and snapshot.Gain>0 then
            self.Effects:Pop("+"..UI.Number(snapshot.Gain),nil,self.View.Target.Position.X.Offset,self.View.Target.Position.Y.Offset-45,true)
        end
        return true
    end
    if not Stars.Get(snapshot.ActiveSystemId) or not U.Finite(snapshot.DiscoveryGeneration)then return false end
    local previous=self.State
    if previous then
        if snapshot.DiscoveryGeneration<previous.DiscoveryGeneration or(snapshot.AccountRevision or 0)<(previous.AccountRevision or 0)then return false end
        if snapshot.AccountRevision==previous.AccountRevision and (snapshot.ServerTime or 0)<(previous.ServerTime or 0)then return false end
    end
    local changed=not previous or snapshot.ActiveSystemId~=previous.ActiveSystemId or snapshot.DiscoveryGeneration~=previous.DiscoveryGeneration
    self.State=snapshot
    if changed then self:_build(snapshot.ActiveSystemId);previous=nil end
    if not snapshot.TransactionBusy then self.PendingTransition=false end
    self.View:Render(snapshot);self.Effects:Update(previous,snapshot)
    if previous and snapshot.NoticeSerial~=previous.NoticeSerial and snapshot.Notice and snapshot.Notice~=""then self:Toast(snapshot.Notice)end
    if not previous and(snapshot.OfflineEarned or 0)>0 then self:Toast("Welcome back! +"..UI.Number(snapshot.OfflineEarned).." offline Energy.")end
    return true
end
function C:SetViewport(size)self.Viewport=size;if not self.Destroyed then self.View:Layout(size);self:UpdateWorldScrollButtons()end end
function C:SetPrice(key,price)self.Prices[key]=price;if self.State then self.View:Render(self.State)end end
function C:SetCheckout(enabled)self.Checkout=enabled==true;self:_send("CheckoutBusy",self.Checkout)end
function C:AutoTapStep(dt)
    if self.Destroyed then return end
    local s,v=self.State,self.View
    local clicks,left=Rules.AdvanceAutoTap(s and s.OwnedPasses,self.AutoTapAccumulator,dt);self.AutoTapAccumulator=left
    if s and not v.Modal.Visible and not v.DiscoveryConfirmation.Visible and v.Page=="Play"and(not v.Compact or v.PlayPage=="Collect")then
        for _=1,clicks do self.Effects:Press()end
    end
end
function C:Destroy()
    if self.Destroyed then return end
    self.Destroyed=true;self.ToastSerial+=1;self:CancelWorldScroll()
    for _,c in ipairs(self.ViewConnections)do c:Disconnect()end
    self.ViewConnections={};if self.Effects then self.Effects:Destroy()end
    if self.View then self.View.Gui:Destroy()end
end
return C
