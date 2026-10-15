local Shared=game:GetService("ReplicatedStorage"):WaitForChild("ClickerKit")
local A=require(script.Parent.AccountProfile)
local Store=require(script.Parent.AccountStore)
local Stellar=require(script.Parent.StellarProgression)
local Receipts=require(script.Parent.MonetizationReceiptService)
local Rules=require(Shared.MonetizationRules)
local U=require(Shared.StarUtil)
local Http=game:GetService("HttpService")
local R={};R.__index=R
function R.new(account,context)
    local self=setmetatable({Account=account,Context=context,Busy=false,Unresolved=false,Closing=false,CheckoutUntil=0,
        SaveMode=context.SaveMode or "Temporary",Writable=context.Writable==true,Identity=Http:GenerateGUID(false)},R)
    A.Project(account,account.ActiveSystemId,context.GameClock())
    return self
end
function R:OwnershipToken()return {Identity=self.Identity,Generation=self.Account.DiscoveryGeneration}end
function R:ApplyOwnership(owned,token)
    if not token or token.Identity~=self.Identity or token.Generation~=self.Account.DiscoveryGeneration or self.Closing then return false end
    if self.Busy then self.PendingOwnership={Owned=U.Clone(owned),Token=token};return false end
    local id=self.Account.ActiveSystemId;local d=A.Project(self.Account,id,self.Context.GameClock())
    A.Economy(id):ApplyPassOwnership(d,owned,true)
    self.Account.OwnedPasses=U.Clone(d.Runtime.OwnedPasses)
    return true
end
function R:ConfirmPassPurchase(key)
    local id=self.Account.ActiveSystemId;local d=A.Project(self.Account,id,self.Context.GameClock())
    if self.Busy then return self:ApplyOwnership({[key]=true},self:OwnershipToken())end
    if not A.Economy(id):ConfirmPassPurchase(d,key)then return false end
    self.Account.OwnedPasses=U.Clone(d.Runtime.OwnedPasses);return true
end
function R:_finish()
    if self.Unresolved then return end
    self.Busy=false
    local pending=self.PendingOwnership;self.PendingOwnership=nil
    if pending then self:ApplyOwnership(pending.Owned,pending.Token)end
end
function R:_adopt(saved,now,preserveRuntime)
    local a,err=A.Normalize(saved,now)
    if not a then self.Unresolved=true;self.Writable=false;self.SaveMode="Temporary";self.Error=err;return false end
    if preserveRuntime and a.DiscoveryGeneration==self.Account.DiscoveryGeneration then
        for id,run in pairs(a.Systems)do
            if self.Account.Systems[id]then run.Runtime=U.Clone(self.Account.Systems[id].Runtime)end
        end
    end
    self.Account=a;A.Project(a,a.ActiveSystemId,now);return true
end
function R:_canTransact()
    return self.Writable and self.SaveMode=="Cloud" and not self.Busy and not self.Unresolved and not self.Closing
end
function R:_commit(proposed,kind,operationId,now,release)
    if not self:_canTransact()then return "Unavailable"end
    self.Busy=true
    local rollback=A.Serialize(self.Account,now);local encoded=A.Serialize(proposed,now)
    if release then rollback._ReleaseSession=true;encoded._ReleaseSession=true end
    local c=self.Context;local base=self.Account.Revision
    local status,saved=Store.Commit(c.Store,c.UserKey,c.SessionId,base,encoded,operationId,c.LeaseClock(),c.LeaseSeconds or 180)
    if status=="Retry"then status,saved=Store.Resolve(c.Store,c.UserKey,c.SessionId,base,operationId,rollback,c.LeaseClock(),c.LeaseSeconds or 180)end
    if status=="Committed" or status=="NotCommitted" then
        local preserve=status=="NotCommitted" or (kind~="DiscoverSystem" and kind~="TravelSystem")
        if not self:_adopt(saved,now,preserve)then return "Conflict"end
        self.SaveMode="Cloud";self:_finish()
    elseif status=="Capacity"then self:_finish()
    else self.Unresolved=true;self.Writable=false;self.SaveMode="Temporary";self.Error="Saving ownership or transaction outcome could not be verified."end
    return status
end
function R:Tick(now,dt)
    if self.Busy or self.Unresolved or self.Closing then return {}end
    local id=self.Account.ActiveSystemId;local d=A.Project(self.Account,id,now);local e=A.Economy(id)
    e:Tick(d,now,dt)
    local clicks,remainder=Rules.AdvanceAutoTap(d.Runtime.OwnedPasses,d.Runtime.AutoTapAccumulator or 0,dt)
    d.Runtime.AutoTapAccumulator=remainder
    local gains={}
    for _=1,clicks do
        if e:Action(d,"Click",nil,nil,now) and (d.Runtime.LastClickGain or 0)>0 then table.insert(gains,d.Runtime.LastClickGain)end
    end
    return gains
end
function R:Transition(kind,target,operationId,now)
    if self.Context.TransitionsEnabled==false or self.CheckoutUntil>now or not self:_canTransact()then return "Unavailable"end
    local proposed,err
    if kind=="DiscoverSystem"then proposed,err=A.ProposeDiscovery(self.Account,target,now)
    elseif kind=="TravelSystem"then proposed,err=A.ProposeTravel(self.Account,target,now)
    else return "Unavailable"end
    if not proposed then return "Unavailable",err end
    proposed.LastTransition={Id=operationId,Kind=kind,FromSystemId=self.Account.ActiveSystemId,ToSystemId=target,Generation=proposed.DiscoveryGeneration}
    local status=self:_commit(proposed,kind,operationId,now,false)
    if status=="Committed"then
        local id=self.Account.ActiveSystemId
        A.Economy(id):Notice(self.Account.Systems[id],kind=="DiscoverSystem" and "New star discovered! Your interstellar upgrades remain." or "Travel complete. Your progress is restored.","World")
    end
    return status
end
function R:Action(kind,id,quantity,now)
    if self.Busy or self.Unresolved or self.Closing then return false,"Please wait for saving to finish."end
    if kind=="CheckoutBusy"then
        if type(id)~="boolean"then return false end
        self.CheckoutUntil=id and now+120 or 0;return true
    end
    if kind=="DiscoverSystem" or kind=="TravelSystem"then
        local status,err=self:Transition(kind,id,Http:GenerateGUID(false),now)
        return status=="Committed",err or (status~="Committed" and "Travel could not be saved. Your current progress is unchanged." or nil)
    end
    if kind=="StellarResearch" or kind=="StellarAscension"then
        if self.Context.TransitionsEnabled==false or not self:_canTransact()then return false,"Interstellar upgrades require cloud saving."end
        if type(id)~="string" or type(quantity)~="string"then return false,"Invalid upgrade."end
        local section=kind=="StellarResearch" and "Research" or "Ascension"
        local proposed,err=Stellar.Purchase(self.Account,self.Account.ActiveSystemId,id,section,quantity)
        if not proposed then return false,err end
        local status=self:_commit(proposed,kind,Http:GenerateGUID(false),now,false)
        if status=="Committed"then A.Economy(self.Account.ActiveSystemId):Notice(self.Account.Systems[self.Account.ActiveSystemId],"Interstellar upgrade purchased for a neighboring star.","Research")end
        return status=="Committed",status~="Committed" and "This upgrade could not be saved." or nil
    end
    local active=self.Account.ActiveSystemId;local d=A.Project(self.Account,active,now)
    local ok,err=A.Economy(active):Action(d,kind,id,quantity,now)
    if ok then
        if kind=="AutoBuy" then A.CaptureAutoBuy(self.Account,active,id)
        elseif kind=="Research" and id=="AutoBuy"then A.CaptureAutoBuy(self.Account,active,true)
        elseif kind=="EquipCosmetic"then self.Account.EquippedCosmetic=d.EquippedCosmetic end
    end
    return ok,err
end
function R:Save(release)
    if self.Closing then return "Unavailable"end
    local now=self.Context.GameClock()
    local status=self:_commit(self.Account,"Save",Http:GenerateGUID(false),now,release)
    if release and (status=="Committed" or status=="NotCommitted")then self.Closing=true;self.Writable=false end
    return status
end
function R:ProcessReceipt(offer,purchaseId,now)
    if type(purchaseId)~="string" or #purchaseId==0 or #purchaseId>128 then return "Retry"end
    local existing=self.Account.ProcessedReceipts[purchaseId]
    if existing then return (existing.ProductId==nil or existing.ProductId==offer.Id) and "Duplicate" or "Retry",existing end
    if not self:_canTransact()then return "Retry"end
    self.Busy=true
    local c=self.Context;local rollback=A.Serialize(self.Account,now);local base=self.Account.Revision
    local status,receipt,saved=Receipts.Commit(c.Store,c.UserId,c.SessionId,rollback,offer,purchaseId,now,c.LeaseClock(),1e18,c.LeaseSeconds or 180)
    if status=="Retry"then
        local resolved,record=Store.Resolve(c.Store,c.UserKey,c.SessionId,base,"receipt:"..purchaseId,rollback,c.LeaseClock(),c.LeaseSeconds or 180)
        if resolved=="Committed"then status="Granted";saved=record;receipt=record.ProcessedReceipts[purchaseId]
        elseif resolved=="NotCommitted"then saved=record end
        if resolved~="Committed" and resolved~="NotCommitted"then self.Unresolved=true;self.Writable=false;self.SaveMode="Temporary"end
    end
    if saved then
        if not self:_adopt(saved,now,true)then return "Retry"end
    end
    self:_finish()
    if status=="Granted" or status=="Duplicate"then
        self.CheckoutUntil=0
        local active=self.Account.ActiveSystemId;local e=A.Economy(active)
        local message=e:ProductPurchaseNotice(status,offer)
        if message then e:Notice(self.Account.Systems[active],message,"Purchase")end
    end
    return status,receipt
end
function R:Snapshot(now)
    local s=A.Snapshot(self.Account,now,self.SaveMode,self.Writable)
    s.TransactionBusy=self.Busy or self.CheckoutUntil>now
    s.CanTravel=self:_canTransact() and self.Context.TransitionsEnabled~=false and self.CheckoutUntil<=now
    s.ReconnectRequired=self.Unresolved
    s.CanSellDeveloperProducts=s.CanSellDeveloperProducts and not self.Busy
    return s
end
return R
