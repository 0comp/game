-- Persistent platform listeners; star views are disposed by the controller.
local Players=game:GetService("Players")
local Marketplace=game:GetService("MarketplaceService")
local Input=game:GetService("UserInputService")
local StarterGui=game:GetService("StarterGui")
local Kit=game:GetService("ReplicatedStorage"):WaitForChild("ClickerKit")
local Rules=require(Kit.MonetizationRules)
local Offers=require(Kit.MonetizationCatalog)
local Controller=require(script.Parent:WaitForChild("StarClientController"))
local Remotes=Kit:WaitForChild("Remotes")
local player=Players.LocalPlayer
local connections,alive={},true
local controller
local function connect(signal,fn)
    local c=signal:Connect(fn);table.insert(connections,c);return c
end
local function promptOffer(key,c)
    local row=c.View.ShopOffers[key];local s=c.State
    if not row or not s or c.Checkout or c.PendingTransition or s.TransactionBusy then return end
    local offer=row.Offer
    local owned=offer.Kind=="Pass" and s.OwnedPasses and s.OwnedPasses[key]==true or false
    local active=offer.Grant and offer.Grant.Type=="PaidBoost" and(s.PaidBoostEndsAt or 0)>workspace:GetServerTimeNow() or false
    local canFit=not offer.Grant or offer.Grant.Type~="Currency" or(s.Currency or 0)+offer.Grant.Amount<=c.View.Config.MaximumCurrency
    local decision=Rules.OfferState(offer,c.Prices[key]~=nil,owned,active,canFit,
        offer.Kind~="Product" or s.CanSellDeveloperProducts~=false,s.DeveloperProductsUnavailableReason)
    if not decision.CanPrompt then
        local messages={WalletFull="Spend some Energy before buying another pack.",
            PersistenceUnavailable="Purchases need cloud saving. Rejoin a published server with saving enabled.",
            StorageLimit="Purchases are paused because receipt history is near its storage limit.",
            Owned="You already own this pass."}
        c:Toast(messages[decision.Status] or "Roblox has not returned a price for this offer yet.");return
    end
    c:SetCheckout(true)
    local ok=pcall(function()
        if offer.Kind=="Pass" then Marketplace:PromptGamePassPurchase(player,offer.Id)
        else Marketplace:PromptProductPurchase(player,offer.Id)end
    end)
    if not ok then c:SetCheckout(false);c:Toast("Roblox could not open the purchase prompt. Please try again.")end
end
controller=Controller.new(player:WaitForChild("PlayerGui"),{
    SendAction=function(...)Remotes.RequestAction:FireServer(...)end,PromptOffer=promptOffer})
connect(Remotes.StateUpdate.OnClientEvent,function(s)controller:ApplySnapshot(s)end)
connect(Input.InputBegan,function(input,processed)
    if not processed and(input.KeyCode==Enum.KeyCode.Space or input.KeyCode==Enum.KeyCode.ButtonA)then controller:Click()end
    if(input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch)
        and controller:OverWorldList(input)then controller:CancelWorldScroll();controller:UpdateWorldScrollButtons()end
end)
connect(Input.InputChanged,function(input)
    if input.UserInputType==Enum.UserInputType.MouseWheel and controller:OverWorldList(input)then
        controller:CancelWorldScroll();controller:UpdateWorldScrollButtons()
    end
end)
connect(Marketplace.PromptGamePassPurchaseFinished,function(who)
    if who==player then controller:SetCheckout(false)end
end)
connect(Marketplace.PromptProductPurchaseFinished,function(userId)
    if userId==player.UserId then controller:SetCheckout(false)end
end)
for key,row in pairs(controller.View.ShopOffers)do
    local offer=row.Offer
    if offer.Id>0 then task.spawn(function()
        local ok,info=pcall(function()return Marketplace:GetProductInfoAsync(offer.Id,
            offer.Kind=="Pass" and Enum.InfoType.GamePass or Enum.InfoType.Product)end)
        if alive and ok and type(info)=="table" and type(info.PriceInRobux)=="number"then controller:SetPrice(key,info.PriceInRobux)end
    end)end
end
local viewportConnection
local function setCamera()
    local camera=workspace.CurrentCamera
    if camera then
        camera.CameraType=Enum.CameraType.Scriptable
        camera.CFrame=CFrame.new(0,100,0)*CFrame.Angles(-math.pi/2,0,0)
        controller:SetViewport(camera.ViewportSize)
    end
end
local function connectCamera()
    if viewportConnection then viewportConnection:Disconnect()end
    setCamera()
    if workspace.CurrentCamera then viewportConnection=workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(setCamera)end
end
connect(workspace:GetPropertyChangedSignal("CurrentCamera"),connectCamera);connectCamera()
pcall(function()
    for _,kind in ipairs({Enum.CoreGuiType.Backpack,Enum.CoreGuiType.PlayerList,Enum.CoreGuiType.Chat,Enum.CoreGuiType.Health})do
        StarterGui:SetCoreGuiEnabled(kind,false)
    end
end)
task.spawn(function()
    local module=player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule",10)
    if module and alive then
        local ok,controls=pcall(function()return require(module):GetControls()end)
        if ok and alive then controls:Disable()end
    end
end)
task.spawn(function()
    local previous=os.clock()
    while alive do
        task.wait(Rules.AutoTapInterval)
        if not alive then break end
        local now=os.clock();controller:AutoTapStep(now-previous);previous=now
    end
end)
connect(script.Destroying,function()
    alive=false
    for _,c in ipairs(connections)do c:Disconnect()end
    if viewportConnection then viewportConnection:Disconnect()end
    controller:Destroy()
end)
Remotes.RequestSnapshot:FireServer()
task.spawn(function()
    for _=1,20 do
        if controller.State or not alive then return end
        task.wait(1)
        if alive then Remotes.RequestSnapshot:FireServer()end
    end
    if alive and not controller.State then controller:Toast("Connection delayed. Please rejoin.")end
end)
