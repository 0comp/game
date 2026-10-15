-- Full-screen 2D game; the server validates all rewards and purchases.
local Players=game:GetService("Players")
local StarterGui=game:GetService("StarterGui")
local UserInputService=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local Kit=game:GetService("ReplicatedStorage"):WaitForChild("ClickerKit")
local Config=require(Kit:WaitForChild("ThemeConfig"))
local UI=require(Kit:WaitForChild("UIBuilder"))
local Effects=require(script.Parent:WaitForChild("Effects"))
local Remotes=Kit:WaitForChild("Remotes")
local Request=Remotes:WaitForChild("RequestAction")
local player=Players.LocalPlayer
local view=UI.Build(player:WaitForChild("PlayerGui"))
local effects=Effects.new(view)
local state,lastClick,toastSerial=nil,0,0
local connections={}
local function connect(signal,fn)
 local c=signal:Connect(fn); table.insert(connections,c); return c
end
local toastTween
local function toast(message)
 toastSerial+=1; local serial=toastSerial
 if toastTween then toastTween:Cancel(); toastTween=nil end
 view.ToastText.Text=message; view.Toast.Visible=true
 if view.ToastDocked then
  view.ToastText.TextTransparency=view.ReducedMotion and 0 or 1
  if not view.ReducedMotion then
   toastTween=TweenService:Create(view.ToastText,TweenInfo.new(.18),{TextTransparency=0}); toastTween:Play()
  end
 else
  view.Toast.Position=UDim2.new(.5,0,0,62)
  if not view.ReducedMotion then
   view.Toast.Position=UDim2.new(.5,0,0,52)
   toastTween=TweenService:Create(view.Toast,TweenInfo.new(.18),{Position=UDim2.new(.5,0,0,62)}); toastTween:Play()
  end
 end
 task.delay(3,function()
  if toastSerial==serial and view.Gui.Parent then
   view.Toast.Visible=false
  end
 end)
end
local function action(kind,id,quantity)
 if state then Request:FireServer(kind,id,quantity) end
end
local function click()
 if not state or view.Modal.Visible or view.Page~="Play" or (view.Compact and view.PlayPage~="Collect") then return end
 local now=os.clock(); if now-lastClick<Config.ClickCooldown then return end
 lastClick=now; effects:Press(); action("Click")
end
connect(view.Target.Activated,click)
connect(UserInputService.InputBegan,function(input,processed)
 if not processed and (input.KeyCode==Enum.KeyCode.Space or input.KeyCode==Enum.KeyCode.ButtonA) then click() end
end)
for page,b in pairs(view.Nav) do connect(b.Activated,function() view:SetPage(page) end) end
for page,b in pairs(view.MobileTabs) do connect(b.Activated,function() view:SetPlayPage(page) end) end
for quantity,b in pairs(view.QuantityButtons) do
 connect(b.Activated,function() view.Quantity=quantity; if state then view:Render(state) end end)
end
for id,r in pairs(view.Rows) do connect(r.Buy.Activated,function() action("Buy",id,view.Quantity) end) end
for id,r in pairs(view.Zones) do connect(r.Button.Activated,function() action("Zone",id) end) end
local function scrollWorlds(direction)
 local list=view.WorldList
 if view.Compact and not view.Landscape then
  list.CanvasPosition=Vector2.new(0,math.clamp(list.CanvasPosition.Y+direction*160,0,math.max(0,list.AbsoluteCanvasSize.Y-list.AbsoluteWindowSize.Y)))
 else
  list.CanvasPosition=Vector2.new(math.clamp(list.CanvasPosition.X+direction*240,0,math.max(0,list.AbsoluteCanvasSize.X-list.AbsoluteWindowSize.X)),0)
 end
end
connect(view.WorldBack.Activated,function() scrollWorlds(-1) end)
connect(view.WorldNext.Activated,function() scrollWorlds(1) end)
for filter,b in pairs(view.JournalButtons) do connect(b.Activated,function() view:SetFilter(filter) end) end
for _,cards in pairs(view.Cards) do
 for _,r in pairs(cards) do
  connect(r.Button.Activated,function()
   if not state then return end
   if r.Kind=="Expedition" then
    if state.Expedition then
     if state.Expedition.Id==r.Id and workspace:GetServerTimeNow()>=state.Expedition.EndsAt then action("ClaimExpedition")
     else toast("Your crew is travelling. Collect its cargo when the timer ends.") end
    else action("Expedition",r.Id) end
   elseif r.Kind=="Achievement" or r.Kind=="Daily" then
    if r.Item and r.Item.Ready then action(r.Kind,r.Id)
    elseif r.Item and r.Item.Claimed then toast("Reward already collected.")
    else toast("Complete this objective to collect its reward.") end
   else action(r.Kind,r.Id) end
  end)
 end
end
local function rebirth()
 if not state then return end
 if state.CanPrestige then view.Modal.Visible=true
 else toast("Rebirth unlocks at "..UI.Number(state.PrestigeCost).." "..string.lower(Config.Currency.Name)..".") end
end
connect(view.Rebirth.Activated,rebirth)
connect(view.AscendButton.Activated,rebirth)
connect(view.Cancel.Activated,function() view.Modal.Visible=false end)
connect(view.Confirm.Activated,function() if state and state.CanPrestige then action("Rebirth") end; view.Modal.Visible=false end)
connect(view.Motion.Activated,function()
 view.ReducedMotion=not view.ReducedMotion; view.Motion.Text=view.ReducedMotion and "Motion: REDUCED" or "Motion: ON"
end)
connect(view.Comet.Activated,function() if state then action("Collect",state.EventNonce) end end)
connect(Remotes.StateUpdate.OnClientEvent,function(snapshot)
 local previous=state; state=snapshot; view:Render(snapshot); effects:Update(previous,snapshot)
 if previous and snapshot.NoticeSerial~=previous.NoticeSerial and snapshot.Notice and snapshot.Notice~="" then toast(snapshot.Notice) end
 if not previous and (snapshot.OfflineEarned or 0)>0 then
  toast("Welcome back! Your producers earned "..UI.Number(snapshot.OfflineEarned).." "..string.lower(Config.Currency.Name).." while you were away.")
 end
end)
local viewportConnection
local function setCamera()
 local camera=workspace.CurrentCamera
 if camera then
  camera.CameraType=Enum.CameraType.Scriptable
  camera.CFrame=CFrame.new(0,100,0)*CFrame.Angles(-math.pi/2,0,0)
  view:Layout(camera.ViewportSize)
 end
end
local function connectCamera()
 if viewportConnection then viewportConnection:Disconnect() end
 setCamera()
 if workspace.CurrentCamera then viewportConnection=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(setCamera) end
end
connect(workspace:GetPropertyChangedSignal("CurrentCamera"),connectCamera)
connectCamera()
pcall(function()
 for _,kind in ipairs({Enum.CoreGuiType.Backpack,Enum.CoreGuiType.PlayerList,Enum.CoreGuiType.Chat,Enum.CoreGuiType.Health}) do StarterGui:SetCoreGuiEnabled(kind,false) end
end)
task.spawn(function()
 local module=player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule",10)
 if module then local ok,controls=pcall(function() return require(module):GetControls() end); if ok then controls:Disable() end end
end)
view.Gui.Destroying:Once(function()
 for _,c in ipairs(connections) do c:Disconnect() end
 if viewportConnection then viewportConnection:Disconnect() end
 effects:Destroy()
end)
Remotes.RequestSnapshot:FireServer()
task.spawn(function()
 for _=1,20 do
  if state or not view.Gui.Parent then return end
  task.wait(1); Remotes.RequestSnapshot:FireServer()
 end
 if not state then toast("Connection delayed. Please rejoin.") end
end)
