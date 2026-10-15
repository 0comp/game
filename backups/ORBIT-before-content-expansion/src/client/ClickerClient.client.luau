-- Full-screen 2D game; the server validates all rewards and purchases.
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local StarterGui = game:GetService("StarterGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Kit = game:GetService("ReplicatedStorage"):WaitForChild("ClickerKit")
local Config = require(Kit:WaitForChild("ThemeConfig"))
local MonetizationCatalog = require(Kit:WaitForChild("MonetizationCatalog"))
local MonetizationRules = require(Kit:WaitForChild("MonetizationRules"))
local UI = require(Kit:WaitForChild("UIBuilder"))
local Effects = require(script.Parent:WaitForChild("Effects"))
local Remotes = Kit:WaitForChild("Remotes")
local Request = Remotes:WaitForChild("RequestAction")
local player = Players.LocalPlayer
local view = UI.Build(player:WaitForChild("PlayerGui"))
local effects = Effects.new(view)
local state, lastClick, toastSerial = nil, 0, 0
local autoTapAccumulator = 0
local connections = {}
local function connect(signal, fn)
    local c = signal:Connect(fn)
    table.insert(connections, c)
    return c
end
local toastTween
local function toast(message)
    toastSerial += 1
    local serial = toastSerial
    if toastTween then
        toastTween:Cancel()
        toastTween = nil
    end
    view.ToastText.Text = message
    view.Toast.Visible = true
    if view.ToastDocked then
        view.ToastText.TextTransparency = view.ReducedMotion and 0 or 1
        if not view.ReducedMotion then
            toastTween = TweenService:Create(view.ToastText, TweenInfo.new(0.18), { TextTransparency = 0 })
            toastTween:Play()
        end
    else
        view.Toast.Position = UDim2.new(0.5, 0, 0, 62)
        if not view.ReducedMotion then
            view.Toast.Position = UDim2.new(0.5, 0, 0, 52)
            toastTween = TweenService:Create(view.Toast, TweenInfo.new(0.18), { Position = UDim2.new(0.5, 0, 0, 62) })
            toastTween:Play()
        end
    end
    task.delay(3, function()
        if toastSerial == serial and view.Gui.Parent then
            view.Toast.Visible = false
        end
    end)
end
local function action(kind, id, quantity)
    if state then
        Request:FireServer(kind, id, quantity)
    end
end
local function offerState(key)
    local row = view.ShopOffers[key]
    if not row or not state then
        return { Status = "Unavailable", CanPrompt = false }
    end
    local offer = row.Offer
    local owned = offer.Kind == "Pass" and state.OwnedPasses and state.OwnedPasses[key] == true or false
    local active = offer.Grant
            and offer.Grant.Type == "PaidBoost"
            and (state.PaidBoostEndsAt or 0) > workspace:GetServerTimeNow()
        or false
    local canFit = not offer.Grant
        or offer.Grant.Type ~= "Currency"
        or (state.Currency or 0) + offer.Grant.Amount <= Config.MaximumCurrency
    return MonetizationRules.OfferState(
        offer,
        view.ShopPrices[key] ~= nil,
        owned,
        active,
        canFit,
        offer.Kind ~= "Product" or state.CanSellDeveloperProducts ~= false,
        state.DeveloperProductsUnavailableReason
    )
end
local function promptOffer(key)
    local row = view.ShopOffers[key]
    if not row or not state then
        return
    end
    local decision = offerState(key)
    if not decision.CanPrompt then
        if row.Offer.Id <= 0 then
            toast("This offer is not enabled yet. The game owner needs to set its Roblox ID.")
        elseif decision.Status == "WalletFull" then
            toast("Spend some Energy before buying another pack.")
        elseif decision.Status == "PersistenceUnavailable" then
            toast("Developer Product purchases require a saved profile. Rejoin a published server with saving enabled.")
        elseif decision.Status == "StorageLimit" then
            toast("Developer Product purchases are paused because receipt history is near its safe storage limit.")
        elseif decision.Status == "Owned" then
            toast("You already own this pass.")
        else
            toast("Roblox has not returned a price for this offer yet.")
        end
        return
    end
    local ok = pcall(function()
        if row.Offer.Kind == "Pass" then
            MarketplaceService:PromptGamePassPurchase(player, row.Offer.Id)
        else
            MarketplaceService:PromptProductPurchase(player, row.Offer.Id)
        end
    end)
    if not ok then
        toast("Roblox could not open the purchase prompt. Please try again.")
    end
end
local function loadOfferPrices()
    for key, row in pairs(view.ShopOffers) do
        local offer = row.Offer
        if offer.Id > 0 then
            task.spawn(function()
                local infoType = offer.Kind == "Pass" and Enum.InfoType.GamePass or Enum.InfoType.Product
                local ok, info = pcall(function()
                    return MarketplaceService:GetProductInfoAsync(offer.Id, infoType)
                end)
                if not view.Gui.Parent then
                    return
                end
                if ok and type(info) == "table" and type(info.PriceInRobux) == "number" then
                    view.ShopPrices[key] = info.PriceInRobux
                end
                if state then
                    view:Render(state)
                end
            end)
        end
    end
end
local function click()
    if not state or view.Modal.Visible or view.Page ~= "Play" or (view.Compact and view.PlayPage ~= "Collect") then
        return
    end
    local now = os.clock()
    if now - lastClick < Config.ClickCooldown then
        return
    end
    lastClick = now
    effects:Press()
    action("Click")
end
connect(view.Target.Activated, click)
connect(UserInputService.InputBegan, function(input, processed)
    if not processed and (input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.ButtonA) then
        click()
    end
end)
for page, b in pairs(view.Nav) do
    connect(b.Activated, function()
        view:SetPage(page)
    end)
end
for key, row in pairs(view.ShopOffers) do
    connect(row.Button.Activated, function()
        promptOffer(key)
    end)
end
for key, row in pairs(view.CosmeticRows) do
    connect(row.Button.Activated, function()
        if state and state.OwnedPasses and state.OwnedPasses[row.Cosmetic.PassKey] then
            action("EquipCosmetic", key)
        else
            local pass = MonetizationCatalog.Passes[row.Cosmetic.PassKey]
            toast("Unlock this look with the " .. pass.Name .. " pass from the Passes section.")
        end
    end)
end
loadOfferPrices()
for page, b in pairs(view.MobileTabs) do
    connect(b.Activated, function()
        view:SetPlayPage(page)
    end)
end
for quantity, b in pairs(view.QuantityButtons) do
    connect(b.Activated, function()
        view.Quantity = quantity
        if state then
            view:Render(state)
        end
    end)
end
connect(view.AutoBuy.Activated, function()
    if state and state.AutoBuyUnlocked then
        action("AutoBuy", not state.AutoBuyEnabled)
    end
end)
for id, r in pairs(view.Rows) do
    connect(r.Buy.Activated, function()
        action("Buy", id, view.Quantity)
    end)
end
for id, r in pairs(view.Zones) do
    connect(r.Button.Activated, function()
        action("Zone", id)
    end)
end
local worldScrollTween, worldScrollGoal
local function cancelWorldScroll()
    local tween = worldScrollTween
    worldScrollTween = nil
    worldScrollGoal = nil
    if tween then
        tween:Cancel()
    end
end
local function updateWorldScrollButtons()
    local list = view.WorldList
    local vertical = list.ScrollingDirection == Enum.ScrollingDirection.Y
    local position = worldScrollGoal or list.CanvasPosition
    local offset = vertical and position.Y or position.X
    local maximum = math.max(
        0,
        vertical and (list.AbsoluteCanvasSize.Y - list.AbsoluteWindowSize.Y)
            or (list.AbsoluteCanvasSize.X - list.AbsoluteWindowSize.X)
    )
    view.WorldBack.Active = offset > 1
    view.WorldNext.Active = offset < maximum - 1
    view.WorldBack.TextTransparency = view.WorldBack.Active and 0 or 0.65
    view.WorldNext.TextTransparency = view.WorldNext.Active and 0 or 0.65
end
local function scrollWorlds(direction)
    local list = view.WorldList
    local vertical = list.ScrollingDirection == Enum.ScrollingDirection.Y
    local current = worldScrollGoal or list.CanvasPosition
    local first = view.Zones[Config.Zones[1].Id].Button
    local second = Config.Zones[2] and view.Zones[Config.Zones[2].Id].Button
    local stride = second
            and math.abs(
                vertical and (second.AbsolutePosition.Y - first.AbsolutePosition.Y)
                    or (second.AbsolutePosition.X - first.AbsolutePosition.X)
            )
        or 0
    if stride < 1 then
        stride = vertical and 80 or 230
    end
    local target = UI.WorldScrollOffset(
        vertical and current.Y or current.X,
        vertical and list.AbsoluteWindowSize.Y or list.AbsoluteWindowSize.X,
        vertical and list.AbsoluteCanvasSize.Y or list.AbsoluteCanvasSize.X,
        stride,
        direction
    )
    local goal = vertical and Vector2.new(0, target) or Vector2.new(target, 0)
    cancelWorldScroll()
    if view.ReducedMotion or goal == list.CanvasPosition then
        list.CanvasPosition = goal
        updateWorldScrollButtons()
        return
    end
    worldScrollGoal = goal
    local tween = TweenService:Create(
        list,
        TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { CanvasPosition = goal }
    )
    worldScrollTween = tween
    tween.Completed:Once(function()
        if worldScrollTween == tween then
            worldScrollTween = nil
            worldScrollGoal = nil
            updateWorldScrollButtons()
        end
    end)
    tween:Play()
    updateWorldScrollButtons()
end
connect(view.WorldList:GetPropertyChangedSignal("CanvasPosition"), updateWorldScrollButtons)
local function worldScrollResized()
    cancelWorldScroll()
    updateWorldScrollButtons()
end
connect(view.WorldList:GetPropertyChangedSignal("AbsoluteCanvasSize"), worldScrollResized)
connect(view.WorldList:GetPropertyChangedSignal("AbsoluteWindowSize"), worldScrollResized)
connect(view.WorldList:GetPropertyChangedSignal("ScrollingDirection"), worldScrollResized)
local function overWorldList(input)
    if view.Page ~= "Play" or not view.Worlds.Visible or view.Modal.Visible then
        return false
    end
    local p, s = view.WorldList.AbsolutePosition, view.WorldList.AbsoluteSize
    return input.Position.X >= p.X
        and input.Position.X <= p.X + s.X
        and input.Position.Y >= p.Y
        and input.Position.Y <= p.Y + s.Y
end
connect(UserInputService.InputBegan, function(input)
    if
        (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch)
        and overWorldList(input)
    then
        cancelWorldScroll()
        updateWorldScrollButtons()
    end
end)
connect(UserInputService.InputChanged, function(input)
    if input.UserInputType == Enum.UserInputType.MouseWheel and overWorldList(input) then
        cancelWorldScroll()
        updateWorldScrollButtons()
    end
end)
updateWorldScrollButtons()
connect(view.WorldBack.Activated, function()
    scrollWorlds(-1)
end)
connect(view.WorldNext.Activated, function()
    scrollWorlds(1)
end)
for filter, b in pairs(view.JournalButtons) do
    connect(b.Activated, function()
        view:SetFilter(filter)
    end)
end
for _, cards in pairs(view.Cards) do
    for _, r in pairs(cards) do
        connect(r.Button.Activated, function()
            if not state then
                return
            end
            if r.Kind == "Expedition" then
                if not r.Button.Active then
                    return
                end
                if state.Expedition then
                    if state.Expedition.Id == r.Id and workspace:GetServerTimeNow() >= state.Expedition.EndsAt then
                        action("ClaimExpedition")
                    else
                        toast("Your crew is travelling. Collect its cargo when the timer ends.")
                    end
                else
                    action("Expedition", r.Id)
                end
            elseif r.Kind == "Achievement" or r.Kind == "Daily" then
                if r.Item and r.Item.Ready then
                    action(r.Kind, r.Id)
                elseif r.Item and r.Item.Claimed then
                    toast("Reward already collected.")
                else
                    toast("Complete this objective to collect its reward.")
                end
            else
                action(r.Kind, r.Id)
            end
        end)
    end
end
local function ascend()
    if not state then
        return
    end
    if state.CanPrestige then
        view.Modal.Visible = true
    else
        toast(
            "Ascension unlocks at " .. UI.Number(state.PrestigeCost) .. " " .. string.lower(Config.Currency.Name) .. "."
        )
    end
end
connect(view.Rebirth.Activated, ascend)
connect(view.AscendButton.Activated, ascend)
connect(view.Cancel.Activated, function()
    view.Modal.Visible = false
end)
connect(view.Confirm.Activated, function()
    if state and state.CanPrestige then
        action("Rebirth")
    end
    view.Modal.Visible = false
end)
connect(view.Motion.Activated, function()
    view.ReducedMotion = not view.ReducedMotion
    view.Motion.Text = view.ReducedMotion and "Motion: REDUCED" or "Motion: ON"
end)
connect(view.Comet.Activated, function()
    if state then
        action("Collect", state.EventNonce)
    end
end)
connect(Remotes.StateUpdate.OnClientEvent, function(snapshot)
    if type(snapshot) == "table" and snapshot.Kind == "ClickFeedback" then
        local gain = snapshot.Gain
        if type(gain) == "number" and gain == gain and gain > 0 and gain < math.huge then
            effects:Pop(
                "+" .. UI.Number(gain),
                nil,
                view.Target.Position.X.Offset + math.random(-40, 40),
                view.Target.Position.Y.Offset - 45,
                true
            )
        end
        return
    end
    local previous = state
    state = snapshot
    view:Render(snapshot)
    effects:Update(previous, snapshot)
    if previous and snapshot.NoticeSerial ~= previous.NoticeSerial and snapshot.Notice and snapshot.Notice ~= "" then
        toast(snapshot.Notice)
    end
    if not previous and (snapshot.OfflineEarned or 0) > 0 then
        toast(
            "Welcome back! Your producers earned "
                .. UI.Number(snapshot.OfflineEarned)
                .. " "
                .. string.lower(Config.Currency.Name)
                .. " while you were away."
        )
    end
end)
task.spawn(function()
    local previous = os.clock()
    while view.Gui.Parent do
        task.wait(MonetizationRules.AutoTapInterval)
        if not view.Gui.Parent then
            break
        end
        local now = os.clock()
        local autoTapClicks, autoTapRemainder =
            MonetizationRules.AdvanceAutoTap(state and state.OwnedPasses or nil, autoTapAccumulator, now - previous)
        autoTapAccumulator = autoTapRemainder
        previous = now
        if
            state
            and not view.Modal.Visible
            and view.Page == "Play"
            and (not view.Compact or view.PlayPage == "Collect")
        then
            for _ = 1, autoTapClicks do
                effects:Press()
            end
        end
    end
end)
local viewportConnection
local function setCamera()
    local camera = workspace.CurrentCamera
    if camera then
        camera.CameraType = Enum.CameraType.Scriptable
        camera.CFrame = CFrame.new(0, 100, 0) * CFrame.Angles(-math.pi / 2, 0, 0)
        view:Layout(camera.ViewportSize)
    end
end
local function connectCamera()
    if viewportConnection then
        viewportConnection:Disconnect()
    end
    setCamera()
    if workspace.CurrentCamera then
        viewportConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(setCamera)
    end
end
connect(workspace:GetPropertyChangedSignal("CurrentCamera"), connectCamera)
connectCamera()
pcall(function()
    for _, kind in ipairs({
        Enum.CoreGuiType.Backpack,
        Enum.CoreGuiType.PlayerList,
        Enum.CoreGuiType.Chat,
        Enum.CoreGuiType.Health,
    }) do
        StarterGui:SetCoreGuiEnabled(kind, false)
    end
end)
task.spawn(function()
    local module = player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 10)
    if module then
        local ok, controls = pcall(function()
            return require(module):GetControls()
        end)
        if ok then
            controls:Disable()
        end
    end
end)
view.Gui.Destroying:Once(function()
    cancelWorldScroll()
    for _, c in ipairs(connections) do
        c:Disconnect()
    end
    if viewportConnection then
        viewportConnection:Disconnect()
    end
    effects:Destroy()
end)
Remotes.RequestSnapshot:FireServer()
task.spawn(function()
    for _ = 1, 20 do
        if state or not view.Gui.Parent then
            return
        end
        task.wait(1)
        Remotes.RequestSnapshot:FireServer()
    end
    if not state then
        toast("Connection delayed. Please rejoin.")
    end
end)
