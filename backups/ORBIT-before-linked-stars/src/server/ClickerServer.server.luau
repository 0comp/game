-- Server-authoritative progression and session-owned persistence.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local MarketplaceService=game:GetService("MarketplaceService")
local DataStoreService=game:GetService("DataStoreService")
local HttpService=game:GetService("HttpService")
local RunService=game:GetService("RunService")
local Kit=ReplicatedStorage:WaitForChild("ClickerKit")
local Config=require(Kit:WaitForChild("ThemeConfig"))
local Catalog=require(Kit:WaitForChild("UpgradeCatalog"))
local Progression=require(Kit:WaitForChild("ProgressionCatalog"))
local MonetizationCatalog=require(Kit:WaitForChild("MonetizationCatalog"))
local MonetizationRules=require(Kit:WaitForChild("MonetizationRules"))
local ReceiptService=require(script.Parent:WaitForChild("MonetizationReceiptService"))
local Economy=require(script.Parent:WaitForChild("Economy")).new(Config,Catalog,Progression)
local Remotes=Kit:WaitForChild("Remotes")
local ActionRemote=Remotes:FindFirstChild("RequestAction") or Instance.new("RemoteEvent")
ActionRemote.Name="RequestAction"; ActionRemote.Parent=Remotes
local StateUpdate=Remotes:WaitForChild("StateUpdate")
local Profiles,SaveModes,Writable,Saving,Loading,LastAction,LastSnapshot,ReceiptBusy={},{},{},{},{},{},{},{}
local Closing={}
local SessionId=game.JobId~="" and game.JobId or HttpService:GenerateGUID(false)
local LeaseSeconds=180
local Store
local ready,result=pcall(function() return DataStoreService:GetDataStore(Config.DataStoreName) end)
if ready then Store=result else warn("Clicker: temporary session progress until a published place has DataStore access.") end
Players.CharacterAutoLoads=false
for _,p in ipairs(Players:GetPlayers()) do if p.Character then p.Character:Destroy() end end

local function clock() return workspace:GetServerTimeNow() end
local function sync(player)
 local d=Profiles[player]; if not d or not player.Parent then return end
 local stats=player:FindFirstChild("leaderstats")
 if stats then stats[Config.Currency.Name].Value=d.Currency; stats.Ascensions.Value=d.Prestiges end
 StateUpdate:FireClient(player,Economy:Snapshot(d,clock(),SaveModes[player] or "Temporary",Writable[player]==true))
end
local function sendClickFeedback(player,d)
 local feedback=MonetizationRules.ClickFeedback(d.Runtime.LastClickGain)
 if feedback then StateUpdate:FireClient(player,feedback) end
end
local function queryOwnership(player,onlyKey,skipKey)
 return MonetizationRules.ResolvePassOwnership(
  MarketplaceService,
  player.UserId,
  MonetizationCatalog.Passes,
  onlyKey,
  skipKey
 )
end
local function refreshOwnership(player,d,attempt,skipDoubleProduction,resolvePendingOffline)
 local owned,unknown=queryOwnership(player,nil,skipDoubleProduction and "DoubleProduction" or nil)
 if Profiles[player]~=d or not player.Parent then return end
 Economy:ApplyPassOwnership(d,owned,resolvePendingOffline)
 d.Runtime.AutoTapAccumulator=0
 sync(player)
 if unknown and (attempt or 0)<2 then
  task.delay(30,function() if Profiles[player]==d then refreshOwnership(player,d,(attempt or 0)+1,skipDoubleProduction,resolvePendingOffline) end end)
 end
end
local function load(player)
 if not Store then return nil,false end
 local now=os.time()
 local ok,saved=pcall(function()
  return Store:UpdateAsync("User_"..player.UserId,function(old)
   if type(old)~="table" then old={} end
   local lease=old._Session
   if type(lease)=="table" and lease.Id~=SessionId and type(lease.ExpiresAt)=="number" and lease.ExpiresAt>now then return nil end
   old._Session={Id=SessionId,ExpiresAt=now+LeaseSeconds}
   return old
  end)
 end)
 if not ok or type(saved)~="table" then warn("Clicker: could not obtain saved progress for "..player.Name.."; this session cannot overwrite it."); return nil,false end
 return saved,true
end
local function save(player,release)
 local d=Profiles[player]; if not Store or not d or not Writable[player] then return end
 if Closing[player] and not release then return end
 if release then Closing[player]=true end
 local started=os.clock()
 while Saving[player] or ReceiptBusy[player] do task.wait(.1); if Profiles[player]~=d or os.clock()-started>20 then return end end
 if not Writable[player] or Profiles[player]~=d then return end
 if Closing[player] and not release then return end
 Saving[player]=true
 local payload=Economy:Serialize(d,clock())
 payload._Session={Id=SessionId,ExpiresAt=release and 0 or os.time()+LeaseSeconds}
 local ok,saved=pcall(function()
  return Store:UpdateAsync("User_"..player.UserId,function(old)
   if type(old)~="table" or type(old._Session)~="table" or old._Session.Id~=SessionId then return nil end
   return payload
  end)
 end)
 Saving[player]=nil
 if not ok then
  if SaveModes[player]~="Retrying" then Economy:Notice(d,"Saving interrupted. Retrying automatically; keep this session open.","Error") end
  SaveModes[player]="Retrying"; warn("Clicker: save will be retried for "..player.Name)
 elseif saved==nil then Writable[player]=false; SaveModes[player]="Temporary"; Economy:Notice(d,"Saving connection lost. Rejoin before a long session.","Error")
 else
  if SaveModes[player]=="Retrying" then Economy:Notice(d,"Saving restored. Your progress has been saved.","Reward") end
  SaveModes[player]="Cloud"
 end
end
local function processReceipt(receiptInfo)
 local offer=MonetizationCatalog.ResolveProduct(receiptInfo.ProductId)
 if not offer then
  warn("Clicker: unresolved Developer Product ID "..tostring(receiptInfo.ProductId))
  return Enum.ProductPurchaseDecision.NotProcessedYet
 end
 local player=Players:GetPlayerByUserId(receiptInfo.PlayerId)
 if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
 local d=Profiles[player]
 if not d or Loading[player] or not Writable[player] or not Store or Closing[player] then
  return Enum.ProductPurchaseDecision.NotProcessedYet
 end
 local started=os.clock()
 while Saving[player] or ReceiptBusy[player] do
  task.wait(.1)
  if Profiles[player]~=d or not player.Parent or Closing[player] or os.clock()-started>20 then
   return Enum.ProductPurchaseDecision.NotProcessedYet
  end
 end
 if Profiles[player]~=d or not Writable[player] or not player.Parent or Closing[player] then
  return Enum.ProductPurchaseDecision.NotProcessedYet
 end

 ReceiptBusy[player]=true
 local ok,status,receipt=pcall(function()
  local now=clock()
  local snapshot=Economy:Serialize(d,now)
  return ReceiptService.Commit(Store,player.UserId,SessionId,snapshot,offer,receiptInfo.PurchaseId,now,os.time(),Config.MaximumCurrency,LeaseSeconds)
 end)
 if ok and (status=="Granted" or status=="Duplicate") then
  Profiles[player]=MonetizationRules.ReconcileReceipt(d,receipt)
  local sizeOk,ledgerJson=pcall(function() return HttpService:JSONEncode(Profiles[player].ProcessedReceipts or {}) end)
  Profiles[player].Runtime.ReceiptLedgerBytes=sizeOk and #ledgerJson or 4_000_000
  SaveModes[player]="Cloud"
  local notice=Economy:ProductPurchaseNotice(status,offer)
  if notice then Economy:Notice(Profiles[player],notice,"Purchase") end
  ReceiptBusy[player]=nil
  sync(player)
  return Enum.ProductPurchaseDecision.PurchaseGranted
 end
 ReceiptBusy[player]=nil
 if not ok then
  warn("Clicker: Developer Product receipt will be retried for "..player.Name)
 elseif status=="Deferred" then
  warn("Clicker: Developer Product receipt deferred until the wallet has room for "..player.Name)
 elseif status=="Capacity" then
  warn("Clicker: Developer Product receipt deferred because the profile is near Roblox's per-key storage limit for "..player.Name)
 end
 return Enum.ProductPurchaseDecision.NotProcessedYet
end
MarketplaceService.ProcessReceipt=processReceipt

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player,passId,purchased)
 if not purchased then return end
 local d=Profiles[player]
 if d then
  for key,offer in pairs(MonetizationCatalog.Passes) do
   if offer.Id>0 and offer.Id==passId then
    Economy:ConfirmPassPurchase(d,key)
    sync(player)
    task.spawn(save,player,false)
    break
   end
  end
  task.spawn(refreshOwnership,player,d)
 end
end)

local function joined(player)
 if Profiles[player] or Loading[player] then return end
 Loading[player]=true
 local saved,canSave=load(player)
 -- Studio can preview without cloud access. Published servers require a loaded profile.
 if not canSave and not RunService:IsStudio() then
  Loading[player]=nil
  if player.Parent then player:Kick("Your saved progress could not be loaded. Please rejoin in a moment. Existing progress has not been replaced.") end
  return
 end
 if not player.Parent then
  if canSave then Profiles[player]=Economy:Normalize(saved,clock()); Writable[player]=true; save(player,true); Profiles[player]=nil; Writable[player]=nil end
  Loading[player]=nil; return
 end
 local now=clock(); local d=Economy:Normalize(saved,now)
 local owned,ownershipUnknown=queryOwnership(player,"DoubleProduction")
 if not player.Parent then
  if canSave then Profiles[player]=d; Writable[player]=true; SaveModes[player]="Cloud"; save(player,true); Profiles[player]=nil; Writable[player]=nil; SaveModes[player]=nil end
  Loading[player]=nil; return
 end
 Economy:InitializeSession(d,now,owned,canSave,ownershipUnknown)
 Profiles[player]=d; Writable[player]=canSave; SaveModes[player]=canSave and "Cloud" or "Temporary"; Loading[player]=nil
 local old=player:FindFirstChild("leaderstats"); if old then old:Destroy() end
 local stats=Instance.new("Folder"); stats.Name="leaderstats"
 local currency=Instance.new("NumberValue"); currency.Name=Config.Currency.Name; currency.Parent=stats
 local ascensions=Instance.new("IntValue"); ascensions.Name="Ascensions"; ascensions.Parent=stats
 stats.Parent=player; sync(player)
 task.spawn(refreshOwnership,player,d,0,true)
 if ownershipUnknown then task.delay(30,function() if Profiles[player]==d then refreshOwnership(player,d,1,false,true) end end) end
end
local function action(player,kind,id,quantity)
 local d=Profiles[player]; if not d or type(kind)~="string" or ReceiptBusy[player] then return end
 local now=clock()
 LastAction[player]=LastAction[player] or {}
 local bucket=kind=="Click" and "Click" or "Other"
 if now-(LastAction[player][bucket] or 0)<(kind=="Click" and Config.ClickCooldown or .12) then return end
 LastAction[player][bucket]=now
 local ok,message=Economy:Action(d,kind,id,quantity,now)
 if not ok and message then Economy:Notice(d,message,"Error") end
 if ok and kind=="Click" then sendClickFeedback(player,d) end
 sync(player)
end
ActionRemote.OnServerEvent:Connect(action)
-- Preserve the original public remotes for older integrations.
Remotes.RequestClick.OnServerEvent:Connect(function(p) action(p,"Click") end)
Remotes.RequestPurchase.OnServerEvent:Connect(function(p,id) action(p,"Buy",id,1) end)
Remotes.RequestZone.OnServerEvent:Connect(function(p,id) action(p,"Zone",id) end)
Remotes.RequestPrestige.OnServerEvent:Connect(function(p) action(p,"Rebirth") end)
Remotes.RequestSnapshot.OnServerEvent:Connect(function(p)
 local now=clock(); if now-(LastSnapshot[p] or 0)<.5 then return end
 LastSnapshot[p]=now; sync(p)
end)
Players.PlayerAdded:Connect(joined)
for _,p in ipairs(Players:GetPlayers()) do task.spawn(joined,p) end
Players.PlayerRemoving:Connect(function(p)
 save(p,true)
 Profiles[p]=nil; Writable[p]=nil; SaveModes[p]=nil; LastAction[p]=nil; LastSnapshot[p]=nil; ReceiptBusy[p]=nil; Closing[p]=nil
end)
task.spawn(function()
 local previous=clock(); local lastSync=previous
 while task.wait(MonetizationRules.AutoTapInterval) do
  local now=clock(); local dt=now-previous; previous=now
  for p,d in pairs(Profiles) do
   if p.Parent and not ReceiptBusy[p] then
    Economy:Tick(d,now,dt)
    local autoTapClicks, autoTapRemainder = MonetizationRules.AdvanceAutoTap(
     d.Runtime.OwnedPasses,
     d.Runtime.AutoTapAccumulator or 0,
     dt
    )
    d.Runtime.AutoTapAccumulator=autoTapRemainder
    for _=1,autoTapClicks do
     local clicked=Economy:Action(d,"Click",nil,nil,now)
     if clicked then sendClickFeedback(p,d) end
    end
   end
  end
  if now-lastSync>=1 then lastSync=now; for p in pairs(Profiles) do sync(p) end end
 end
end)
task.spawn(function()
 while task.wait(Config.AutoSaveSeconds) do for p in pairs(Profiles) do task.spawn(save,p,false) end end
end)
game:BindToClose(function()
 local pending=0
 for p in pairs(Profiles) do pending+=1; task.spawn(function() save(p,true); pending-=1 end) end
 local start=os.clock(); while pending>0 and os.clock()-start<25 do task.wait(.1) end
end)

