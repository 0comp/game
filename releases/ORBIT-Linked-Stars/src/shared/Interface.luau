local function create(providedConfig, providedCatalog, providedProgression)
-- Responsive, asset-independent 2D interface. Motion is owned by client/Effects.
local Config = providedConfig or require(script.Parent.ThemeConfig)
local Catalog = providedCatalog or require(script.Parent.UpgradeCatalog)
local Progression = providedProgression or require(script.Parent.ProgressionCatalog)
local MonetizationCatalog = require(script.Parent.MonetizationCatalog)
local MonetizationRules = require(script.Parent.MonetizationRules)
local ShopViewModel = require(script.Parent.ShopViewModel)
local ShopModel = ShopViewModel.Build(MonetizationCatalog)
local Art = require(script.Parent.Art).ForConfig(Config, Catalog)
local T = Config.Theme
local defaultAccents = { Primary = T.Accent, Secondary = T.AccentAlt }
local UI = { Number = Art.Number }
local purchaseQuantities: { number | string } = { 1, 10, "Max" }
local cosmeticPalettes = {
    SupporterAura = { Accent = Color3.fromRGB(255, 211, 125), AccentAlt = Color3.fromRGB(190, 132, 48) },
    NebulaPalette = {
        Primary = Color3.fromRGB(179, 127, 255),
        Secondary = Color3.fromRGB(54, 35, 115),
        Accent = Color3.fromRGB(233, 164, 255),
        AccentAlt = Color3.fromRGB(179, 127, 255),
    },
    AuroraPalette = {
        Primary = Color3.fromRGB(133, 245, 204),
        Secondary = Color3.fromRGB(34, 106, 135),
        Accent = Color3.fromRGB(166, 255, 222),
        AccentAlt = Color3.fromRGB(133, 245, 204),
    },
}
local function make(class, parent, name, p)
    local o = Instance.new(class)
    o.Name = name
    for k, v in pairs(p or {}) do
        o[k] = v
    end
    o.Parent = parent
    return o
end
local function pos(o, x, y, w, h)
    o.Position = UDim2.fromOffset(x, y)
    o.Size = UDim2.fromOffset(w, h)
end
local function corner(o, r)
    make("UICorner", o, "Corner", { CornerRadius = UDim.new(0, r or 14) })
end
local function outline(o, c, a)
    return make(
        "UIStroke",
        o,
        "Outline",
        { Color = c or T.Border, Transparency = a or 0, Thickness = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }
    )
end
local function frame(parent, name, color, r)
    local o = make("Frame", parent, name, { BorderSizePixel = 0, BackgroundColor3 = color or T.Panel })
    if r then
        corner(o, r)
    end
    return o
end
local function clear(parent, name)
    return make("Frame", parent, name, { BackgroundTransparency = 1, BorderSizePixel = 0 })
end
local function text(parent, name, value, size, color, bold, align)
    return make("TextLabel", parent, name, {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = value or "",
        TextSize = size or 14,
        TextColor3 = color or T.Text,
        Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
        TextXAlignment = align or Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
    })
end
local function button(parent, name, value, color)
    local o = make("TextButton", parent, name, {
        BackgroundColor3 = color or T.PanelRaised,
        BorderSizePixel = 0,
        Text = value or "",
        TextColor3 = T.Text,
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false,
    })
    corner(o, 10)
    return o
end
local function circle(parent, name, size, color)
    local o = frame(parent, name, color, 999)
    o.Size = UDim2.fromOffset(size, size)
    return o
end
local function scroll(parent, name, horizontal)
    return make("ScrollingFrame", parent, name, {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.AccentAlt,
        CanvasSize = UDim2.fromOffset(0, 0),
        AutomaticCanvasSize = horizontal and Enum.AutomaticSize.X or Enum.AutomaticSize.Y,
        ScrollingDirection = horizontal and Enum.ScrollingDirection.X or Enum.ScrollingDirection.Y,
    })
end
local function formatTime(seconds)
    seconds = math.max(0, math.ceil(seconds))
    return seconds >= 3600 and string.format("%dh %02dm", math.floor(seconds / 3600), math.floor(seconds % 3600 / 60))
        or string.format("%02d:%02d", math.floor(seconds / 60), seconds % 60)
end
UI.Time = formatTime

-- Page through complete cards; native wheel/swipe offsets may sit between cards.
function UI.WorldScrollOffset(current, window, canvasSize, stride, direction)
    local maximum = math.max(0, canvasSize - window)
    current = math.clamp(current, 0, maximum)
    if direction == 0 then
        return current
    end
    stride = math.max(1, stride)
    local page = math.max(1, math.floor(window / stride))
    local index = direction > 0 and math.floor(current / stride + 0.001) or math.ceil(current / stride - 0.001)
    return math.clamp((index + direction * page) * stride, 0, maximum)
end

local function paidBoostText(endsAt, now)
    if
        type(endsAt) ~= "number"
        or type(now) ~= "number"
        or endsAt ~= endsAt
        or now ~= now
        or endsAt == math.huge
        or now == math.huge
        or endsAt <= now
    then
        return nil
    end
    local remaining = math.ceil(endsAt - now)
    if remaining <= 0 then
        return nil
    end
    local hours = math.floor(remaining / 3600)
    local minutes = math.floor(remaining % 3600 / 60)
    local seconds = remaining % 60
    local parts = {}
    if hours > 0 then
        table.insert(parts, hours .. "h")
    end
    if minutes > 0 then
        table.insert(parts, minutes .. "m")
    end
    if seconds > 0 or #parts == 0 then
        table.insert(parts, seconds .. "s")
    end
    return "PAID x2 | " .. table.concat(parts, " ") .. " LEFT"
end
UI.PaidBoostText = paidBoostText

function UI.PaidProductionText(state, now)
    if type(state) ~= "table" then
        return nil
    end
    local timedBoost = paidBoostText(state.PaidBoostEndsAt or 0, now)
    local ownsDoubleProduction = type(state.OwnedPasses) == "table"
        and state.OwnedPasses.DoubleProduction == true
    if ownsDoubleProduction then
        if timedBoost then
            return "PAID PRODUCTION x4\nPASS x2 + " .. timedBoost
        end
        return "DOUBLE PRODUCTION PASS: x2"
    end
    return timedBoost
end

function UI.Build(parent)
    local old = parent:FindFirstChild("ClickerGameUI")
    if old then
        old:Destroy()
    end
    local gui = make("ScreenGui", parent, "ClickerGameUI", {
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ScreenInsets = Enum.ScreenInsets.None,
        ClipToDeviceSafeArea = false,
        DisplayOrder = 10,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })
    local bg = frame(gui, "Background", Color3.new(1, 1, 1))
    bg.Size = UDim2.fromScale(1, 1)
    make(
        "UIGradient",
        bg,
        "Gradient",
        { Color = ColorSequence.new(T.Background, T.SkyBottom:Lerp(T.Background, 0.6)), Rotation = 35 }
    )
    local canvas = clear(bg, "Canvas")
    canvas.AnchorPoint = Vector2.new(0.5, 0.5)
    local scale = make("UIScale", canvas, "ResponsiveScale", { Scale = 1 })
    local v = {
        Gui = gui,
        Canvas = canvas,
        Scale = scale,
        Page = "Play",
        PlayPage = "Collect",
        JournalFilter = "Achievements",
        Quantity = 1,
        ReducedMotion = false,
        Rows = {},
        Zones = {},
        Nav = {},
        MobileTabs = {},
        QuantityButtons = {},
        Cards = {},
        Panels = {},
        Stars = {},
        ShopOffers = {},
        CosmeticRows = {},
        ShopPrices = {},
    }
    local header = clear(canvas, "Header")
    v.Header = header
    local logo = frame(header, "Logo", T.Accent, 10)
    pos(logo, 0, 4, 42, 42)
    Art.Icon(logo, "Bolt", T.Background).Size = UDim2.fromOffset(42, 42)
    v.Title = text(header, "Title", Config.GameTitle, 28, nil, true)
    pos(v.Title, 55, 0, 230, 31)
    v.Tagline = text(header, "Tagline", Config.Tagline, 11, T.MutedText, true)
    pos(v.Tagline, 57, 32, 230, 16)
    for _, name in ipairs({ "Play", "Research", "Expeditions", "Journal", "Ascension", "Shop" }) do
        v.Nav[name] = button(header, name, name)
    end
    v.Motion = button(header, "Motion", "Motion: ON")
    v.Motion.TextSize = 12
    v.Objective = text(header, "Objective", "Build your first producer.", 14, T.MutedText)
    v.Wallet = text(header, "Stars", "0 STARS", 13, T.AccentAlt, true, Enum.TextXAlignment.Right)
    v.SaveStatus = text(header, "SaveStatus", "CONNECTING", 10, T.MutedText, true, Enum.TextXAlignment.Right)
    local line = frame(header, "Divider", T.Border)
    line.Position = UDim2.new(0, 0, 1, -1)
    line.Size = UDim2.new(1, 0, 0, 1)

    local scene = frame(canvas, "Collect", Color3.new(1, 1, 1), 22)
    outline(scene, T.Border, 0.35)
    v.Scene = scene
    make("UIGradient", scene, "Sky", { Color = ColorSequence.new(T.SkyTop, T.SkyBottom), Rotation = 40 })
    local starfield = clear(scene, "Starfield")
    starfield.Size = UDim2.fromScale(1, 1)
    starfield.ClipsDescendants = true
    local random = Random.new(37)
    for i = 1, 48 do
        local s = circle(starfield, "Star", i % 6 == 0 and 3 or 2, T.MutedText)
        s.Position = UDim2.fromScale(random:NextNumber(0.04, 0.96), random:NextNumber(0.06, 0.94))
        s.BackgroundTransparency = random:NextNumber(0.2, 0.8)
        if i % 3 == 0 then
            table.insert(v.Stars, { Object = s, Phase = random:NextNumber(0, 6), Alpha = s.BackgroundTransparency })
        end
    end
    v.SceneTag = text(scene, "WorldTag", "01 / EARTH", 12, T.Accent, true)
    v.Boost = text(scene, "Multiplier", "x1 WORLD BOOST", 12, T.MutedText, true, Enum.TextXAlignment.Right)
    v.Currency = text(scene, "Balance", "0", 64, nil, true, Enum.TextXAlignment.Center)
    v.CurrencyName = text(
        scene,
        "CurrencyName",
        string.upper(Config.Currency.Name),
        12,
        T.MutedText,
        true,
        Enum.TextXAlignment.Center
    )
    v.Rates = text(scene, "Rates", "1 / click     +0 / sec", 14, T.Text, false, Enum.TextXAlignment.Center)
    v.Orbit = frame(scene, "Orbit", T.AccentAlt, 999)
    v.Orbit.BackgroundTransparency = 1
    v.OrbitOutline = outline(v.Orbit, T.AccentAlt, 0.7)
    v.Orbit.Rotation = -18
    v.Orbit.Visible = T.ShowOrbit ~= false
    v.OrbitDot = circle(v.Orbit, "Satellite", 8, T.AccentAlt)
    v.OrbitDot.AnchorPoint = Vector2.new(0.5, 0.5)
    local target = button(scene, "ClickTargetButton", "")
    target.BackgroundTransparency = 1
    target.AnchorPoint = Vector2.new(0.5, 0.5)
    v.Target = target
    target.ZIndex = 2
    v.Bounce = make("UIScale", target, "Bounce", { Scale = 1 })
    v.Art, v.ArtScale = Art.Planet(target, Config.Zones[1])
    v.CurrentZone = Config.Zones[1].Id
    v.AppliedCosmeticZone = v.CurrentZone
    v.TargetHint =
        text(scene, "ClickHint", T.ClickPrompt or "CLICK TO COLLECT", 12, nil, true, Enum.TextXAlignment.Center)
    local burst = frame(scene, "Burst", T.Background:Lerp(T.PanelRaised, 0.5), 12)
    outline(burst, T.Accent, 0.75)
    v.BurstPanel = burst
    burst.ZIndex = 10
    v.BurstTitle = text(burst, "Title", T.BurstName or "BOOST", 12, T.Accent, true)
    v.BurstCount = text(burst, "Count", "0 / 20", 12, T.Accent, true, Enum.TextXAlignment.Right)
    v.BurstTrack = frame(burst, "Track", T.PanelRaised, 4)
    v.BurstFill = frame(v.BurstTrack, "Fill", T.Accent, 4)
    v.BurstFill.Size = UDim2.fromScale(0, 1)
    v.BurstNote = text(burst, "Hint", "Click to charge a x3 production burst", 11, T.MutedText)
    v.SceneObjective =
        text(scene, "Objective", "First goal: buy a producer", 13, T.MutedText, false, Enum.TextXAlignment.Center)
    v.SceneObjective.TextWrapped = true
    v.TargetHint.ZIndex = 10
    v.SceneObjective.ZIndex = 10
    v.CollectorLayer = clear(scene, "Collectors")
    v.CollectorLayer.Size = UDim2.fromScale(1, 1)
    v.CollectorLayer.ZIndex = 3
    -- Keep the orbiting drones visible in front of every planet illustration.
    v.CollectorLayer.Active = false
    v.Particles = clear(scene, "Feedback")
    v.Particles.Size = UDim2.fromScale(1, 1)
    v.Particles.ZIndex = 8
    v.Comet = button(scene, "Bonus", T.CollectibleName or "BONUS", T.AccentAlt)
    v.Comet.TextSize = 12
    v.Comet.TextColor3 = T.Background
    v.Comet.AnchorPoint = Vector2.new(0.5, 0.5)
    v.Comet.ZIndex = 9
    v.Comet.Visible = false
    v.CometTimer = text(v.Comet, "Timer", "10s", 10, T.Text, true, Enum.TextXAlignment.Center)
    v.CometTimer.Position = UDim2.fromScale(0, 1)
    v.CometTimer.Size = UDim2.new(1, 0, 0, 16)

    local shop = frame(canvas, "Upgrades", T.Panel, 22)
    outline(shop, T.Border, 0.35)
    v.Shop = shop
    v.ProductionTitle = text(shop, "Title", "PRODUCTION", 19, nil, true)
    v.ShopSub = text(shop, "Subtitle", #Catalog .. " tiers. Build an empire.", 12, T.MutedText)
    v.AutoBuy = button(shop, "AutoBuy", "AUTO RESEARCH: LOCKED")
    v.AutoBuy.TextSize = 11
    for _, q in ipairs(purchaseQuantities) do
        v.QuantityButtons[q] = button(shop, "Buy" .. q, q == "Max" and "BUY MAX" or "BUY x" .. q)
        v.QuantityButtons[q].TextSize = 11
    end
    v.List = scroll(shop, "List")
    make("UIListLayout", v.List, "Layout", { Padding = UDim.new(0, 9), SortOrder = Enum.SortOrder.LayoutOrder })
    for i, def in ipairs(Catalog) do
        local p = Config.UpgradePresentation[def.Id] or {}
        local row = frame(v.List, def.Id, T.PanelRaised, 13)
        row.Size = UDim2.new(1, -5, 0, 100)
        row.LayoutOrder = i
        local lineStroke = outline(row, T.Border, 0.2)
        local badge = frame(row, "IconTile", (p.Color or T.Accent):Lerp(T.Panel, 0.85), 12)
        pos(badge, 14, 18, 50, 50)
        if p.ImageId and p.ImageId ~= "" then
            make("ImageLabel", badge, "Image", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                Image = p.ImageId,
                ScaleType = Enum.ScaleType.Fit,
            })
        else
            Art.Icon(badge, p.Icon or "Bolt", p.Color or T.Accent).Position = UDim2.fromOffset(1, 1)
        end
        local name = text(row, "UpgradeName", p.Name or def.Id, 16, nil, true)
        pos(name, 78, 12, 260, 23)
        local desc = text(row, "Description", p.Description or "", 12, T.MutedText)
        pos(desc, 78, 37, 270, 18)
        local owned = text(row, "Owned", "OWNED 0", 11, T.MutedText, true)
        pos(owned, 78, 66, 170, 21)
        local buy = button(row, "Buy", "", T.Panel)
        buy.TextSize = 13
        v.Rows[def.Id] =
            { Frame = row, Name = name, Desc = desc, Owned = owned, Buy = buy, Stroke = lineStroke, Definition = def }
    end
    v.Rebirth = button(shop, "Rebirth", "", T.AccentAlt:Lerp(T.Panel, 0.8))
    outline(v.Rebirth, T.AccentAlt, 0.55)
    v.RebirthTitle = text(v.Rebirth, "Title", Config.Prestige.ButtonName, 14, T.AccentAlt, true)
    v.RebirthCost = text(v.Rebirth, "Cost", "1M EN", 12, T.AccentAlt, true, Enum.TextXAlignment.Right)

    local worlds = frame(canvas, "Worlds", T.Panel, 22)
    outline(worlds, T.Border, 0.35)
    v.Worlds = worlds
    v.WorldTitle = text(worlds, "Title", T.WorldTitle or "WORLDS", 12, nil, true)
    v.WorldProgress =
        text(worlds, "Progress", "1 / " .. #Config.Zones, 11, T.MutedText, true, Enum.TextXAlignment.Right)
    v.WorldBack = button(worlds, "Previous", "<")
    v.WorldNext = button(worlds, "Next", ">")
    v.WorldList = scroll(worlds, "List", true)
    v.WorldList.ScrollBarThickness = 10
    v.WorldList.ScrollBarImageTransparency = 0.1
    v.WorldLayout = make("UIListLayout", v.WorldList, "Layout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })
    for i, z in ipairs(Config.Zones) do
        local b = button(v.WorldList, z.Id, "")
        b.LayoutOrder = i
        local lineStroke = outline(b, T.Border, 0.5)
        local ball = clear(b, "MiniPlanet")
        pos(ball, 12, 16, 36, 36)
        local miniArt,miniScale=Art.Planet(ball,z,true)
        miniScale.Scale=.12
        local n = text(b, "Name", z.Name, 14, nil, true)
        pos(n, 60, 10, 145, 24)
        local status = text(b, "Status", "", 11, T.MutedText, true)
        pos(status, 60, 37, 145, 18)
        v.Zones[z.Id] = { Button = b, Status = status, Stroke = lineStroke, Definition = z }
    end
    v.Goal = text(worlds, "Goal", "", 11, T.MutedText, true)
    v.GoalAmount = text(worlds, "GoalAmount", "", 11, T.MutedText, true, Enum.TextXAlignment.Right)
    v.GoalTrack = frame(worlds, "GoalTrack", T.PanelRaised, 3)
    v.GoalFill = frame(v.GoalTrack, "Fill", T.Accent, 3)
    local nav = clear(canvas, "MobileTabs")
    v.MobileNav = nav
    for _, name in ipairs({ "Collect", "Upgrades", "Worlds" }) do
        v.MobileTabs[name] = button(nav, name, name)
    end

    local descriptions = {
        Research = "Standard research resets on Ascend. Auto Buy stays; interstellar upgrades are permanent.",
        Expeditions = "Send a crew, keep playing, then collect its cargo. One expedition can travel at a time.",
        Journal = "Collect one-time achievements and daily rewards. Daily objectives reset at midnight UTC.",
        Ascension = "Ordinary upgrades survive Ascend but reset on star discovery. Interstellar upgrades stay.",
    }
    for _, page in ipairs({ "Research", "Expeditions", "Journal", "Ascension" }) do
        local panel = frame(canvas, page, T.Panel, 22)
        outline(panel, T.Border, 0.35)
        v.Panels[page] = panel
        local title = text(panel, "Title", string.upper(page), 24, nil, true)
        local sub = text(panel, "Subtitle", descriptions[page], 13, T.MutedText)
        sub.TextWrapped = true
        local list = scroll(panel, "List")
        local grid = make(
            "UIGridLayout",
            list,
            "Grid",
            { CellPadding = UDim2.fromOffset(12, 12), SortOrder = Enum.SortOrder.LayoutOrder }
        )
        v.Cards[page] = {}
        v[page .. "List"] = list
        v[page .. "Grid"] = grid
        local defs = page == "Ascension" and Progression.Permanent
            or page == "Journal" and Progression.Achievements
            or Progression[page]
        local function card(def, kind, index)
            local presentation=(Config[kind.."Presentation"] or {})[def.Id]
            local row = frame(list, kind .. def.Id, T.PanelRaised, 14)
            row.LayoutOrder = index
            outline(row, T.Border, 0.15)
            local n = text(row, "Name", presentation and presentation.Name or def.Name, 17, nil, true)
            local iconTile
            if presentation then
                iconTile=frame(row,"UpgradeIcon",presentation.Color:Lerp(T.Panel,.85),9)
                local icon=Art.Icon(iconTile,presentation.Icon,presentation.Color)
                make("UIScale",icon,"IconScale",{Scale=.75})
            end
            local detail = text(row, "Detail", def.Description or "", 12, T.MutedText)
            detail.TextWrapped = true
            local status = text(row, "Status", "", 12, T.AccentAlt, true)
            local reward = text(row, "Reward", "", 12, T.MutedText)
            local buy = button(row, "Action", "", T.Accent)
            buy.TextColor3 = T.Background
            buy.TextSize = 12
            local track = frame(row, "Track", T.Panel, 3)
            local fill = frame(track, "Fill", T.Accent, 3)
            v.Cards[page][kind .. def.Id] = {
                Frame = row,
                IconTile = iconTile,
                Name = n,
                Detail = detail,
                Status = status,
                Reward = reward,
                Button = buy,
                Track = track,
                Fill = fill,
                Definition = def,
                Kind = kind,
                Id = def.Id,
            }
        end
        for i, def in ipairs(defs) do
            card(
                def,
                page == "Ascension" and "Permanent"
                    or page == "Journal" and "Achievement"
                    or page == "Expeditions" and "Expedition"
                    or "Research",
                i
            )
        end
        if page == "Journal" then
            for i, def in ipairs(Progression.Daily) do
                card(def, "Daily", i)
            end
        end
        pos(title, 24, 16, 500, 34)
        pos(sub, 24, 54, 1000, 36)
    end
    v.AutoBuy.Parent = v.Panels.Research
    local shopPanel = frame(canvas, "Shop", T.Panel, 22)
    outline(shopPanel, T.Border, 0.35)
    v.Panels.Shop = shopPanel
    local shopTitle = text(shopPanel, "Title", "ORBIT SHOP", 24, nil, true)
    local shopSubtitle = text(
        shopPanel,
        "Subtitle",
        "Set real Roblox offer IDs to enable checkout. Prices load from Roblox.",
        13,
        T.MutedText
    )
    shopSubtitle.TextWrapped = true
    v.ShopTitle = shopTitle
    v.ShopSubtitle = shopSubtitle
    local shopList = scroll(shopPanel, "Offers")
    v.ShopList = shopList
    make("UIListLayout", shopList, "Layout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder })
    local shopOrder = 0
    local function shopHeading(name, description)
        shopOrder += 1
        local heading = clear(shopList, "Section" .. shopOrder)
        heading.LayoutOrder = shopOrder
        heading.Size = UDim2.new(1, -5, 0, 35)
        local label = text(heading, "Title", name, 13, T.Accent, true)
        label.Position = UDim2.fromOffset(8, 0)
        label.Size = UDim2.new(1, -16, 0, 18)
        local note = text(heading, "Description", description, 11, T.MutedText)
        note.Position = UDim2.fromOffset(8, 18)
        note.Size = UDim2.new(1, -16, 0, 15)
    end
    for _, section in ipairs(ShopModel.Sections) do
        shopHeading(section.Title, section.Description)
        for _, entry in ipairs(section.Offers) do
            shopOrder += 1
            local row = frame(shopList, "Offer" .. entry.Key, T.PanelRaised, 12)
            row.LayoutOrder = shopOrder
            row.Size = UDim2.new(1, -5, 0, 86)
            outline(row, T.Border, 0.2)
            local name = text(row, "Name", entry.Name, 15, nil, true)
            name.TextTruncate = Enum.TextTruncate.AtEnd
            local detail = text(row, "Benefit", entry.Benefit, 12, T.MutedText)
            detail.TextWrapped = true
            local status =
                text(row, "Status", entry.Enabled and "Loading price…" or "Offer ID needed", 12, T.AccentAlt, true)
            local prompt = button(
                row,
                "Purchase",
                entry.Enabled and "LOADING" or "ID NEEDED",
                entry.Enabled and T.Accent or T.Panel
            )
            prompt.TextColor3 = entry.Enabled and T.Background or T.MutedText
            prompt.TextSize = 12
            prompt.Active = entry.Enabled
            v.ShopOffers[entry.Key] = {
                Frame = row,
                Name = name,
                Benefit = detail,
                Status = status,
                Button = prompt,
                Entry = entry,
                Offer = entry.Offer,
            }
        end
    end
    shopHeading("COSMETICS", "Choose an unlocked planet look. Each palette is included with its pass.")
    for _, cosmetic in ipairs(ShopModel.Cosmetics) do
        shopOrder += 1
        local row = frame(shopList, "Cosmetic" .. cosmetic.Key, T.PanelRaised, 12)
        row.LayoutOrder = shopOrder
        row.Size = UDim2.new(1, -5, 0, 58)
        outline(row, T.Border, 0.2)
        local name = text(row, "Name", cosmetic.Name, 14, nil, true)
        local detail =
            text(row, "Status", "Unlock with " .. MonetizationCatalog.Passes[cosmetic.PassKey].Name, 12, T.MutedText)
        local equip = button(row, "Equip", "LOCKED", T.Panel)
        equip.TextSize = 12
        equip.TextColor3 = T.MutedText
        equip.Active = false
        v.CosmeticRows[cosmetic.Key] =
            { Frame = row, Name = name, Status = detail, Button = equip, Cosmetic = cosmetic }
    end
    v.JournalButtons = {
        Achievements = button(v.Panels.Journal, "Achievements", "ACHIEVEMENTS"),
        Daily = button(v.Panels.Journal, "Daily", "DAILY GOALS"),
    }
    v.AscendBanner = frame(v.Panels.Ascension, "RebirthBanner", T.AccentAlt:Lerp(T.Panel, 0.8), 14)
    outline(v.AscendBanner, T.AccentAlt, 0.5)
    v.AscendText = text(v.AscendBanner, "Summary", "", 15, nil, true)
    v.AscendText.TextWrapped = true
    v.AscendButton = button(v.AscendBanner, "Rebirth", Config.Prestige.ButtonName, T.AccentAlt)
    v.Route = clear(v.Panels.Expeditions, "Route")
    v.RouteTrack = frame(v.Route, "Track", T.Border, 3)
    v.RouteTrack.Position = UDim2.new(0.08, 0, 0.5, -2)
    v.RouteTrack.Size = UDim2.new(0.84, 0, 0, 4)
    local home = circle(v.Route, "Home", 20, T.Accent)
    home.Position = UDim2.new(0.08, -10, 0.5, -10)
    local endPoint = circle(v.Route, "Destination", 20, T.AccentAlt)
    endPoint.Position = UDim2.new(0.92, -10, 0.5, -10)
    v.Ship = circle(v.Route, "Ship", 16, T.Text)
    v.Ship.AnchorPoint = Vector2.new(0.5, 0.5)
    v.Ship.Position = UDim2.fromScale(0.08, 0.5)
    v.RouteLabel =
        text(v.Route, "Label", "Choose an expedition below", 12, T.MutedText, false, Enum.TextXAlignment.Center)
    v.RouteLabel.Position = UDim2.new(0, 0, 1, -16)
    v.RouteLabel.Size = UDim2.new(1, 0, 0, 16)

    v.ToastDocked = Config.NotificationPlacement == "BottomRight"
    local toast = frame(gui, "Notification", T.PanelRaised, 14)
    outline(toast, T.Accent, 0.5)
    toast.AnchorPoint = v.ToastDocked and Vector2.new(1, 1) or Vector2.new(0.5, 0)
    toast.Position = v.ToastDocked and UDim2.new(1, -16, 1, -12) or UDim2.new(0.5, 0, 0, 70)
    toast.Size = UDim2.fromOffset(370, 58)
    toast.ZIndex = 30
    toast.Visible = false
    v.Toast = toast
    v.ToastText = text(toast, "Text", "", 14, T.Text, true, Enum.TextXAlignment.Center)
    v.ToastText.Position = UDim2.fromOffset(12, 6)
    v.ToastText.Size = UDim2.new(1, -24, 1, -12)
    v.ToastText.TextWrapped = true
    local paidBoostTimer = frame(gui, "PaidBoostTimer", T.PanelRaised, 14)
    outline(paidBoostTimer, T.AccentAlt, 0.35)
    paidBoostTimer.AnchorPoint = Vector2.new(1, 0)
    paidBoostTimer.Position = UDim2.new(1, -16, 0, 16)
    paidBoostTimer.Size = UDim2.fromOffset(330, 42)
    paidBoostTimer.ZIndex = 15
    paidBoostTimer.Visible = false
    v.PaidBoostTimer = paidBoostTimer
    v.PaidBoostTimerText = text(paidBoostTimer, "Text", "", 13, T.AccentAlt, true, Enum.TextXAlignment.Center)
    v.PaidBoostTimerText.Position = UDim2.fromOffset(10, 4)
    v.PaidBoostTimerText.Size = UDim2.new(1, -20, 1, -8)
    v.PaidBoostTimerText.TextWrapped = true
    v.PaidBoostTimerText.ZIndex = 16
    local modal = button(gui, "RebirthConfirmation", "", Color3.fromRGB(3, 6, 17))
    modal.BackgroundTransparency = 0.18
    modal.Size = UDim2.fromScale(1, 1)
    modal.ZIndex = 20
    modal.Visible = false
    v.Modal = modal
    local dialog = frame(modal, "Dialog", T.Panel, 20)
    dialog.AnchorPoint = Vector2.new(0.5, 0.5)
    dialog.Position = UDim2.fromScale(0.5, 0.5)
    dialog.Size = UDim2.fromOffset(340, 285)
    outline(dialog, T.AccentAlt, 0.3)
    local title = text(dialog, "Title", "Ready for a fresh start?", 21, nil, true)
    pos(title, 22, 20, 296, 35)
    v.ConfirmDetail = text(dialog, "Detail", "", 14, T.MutedText)
    pos(v.ConfirmDetail, 22, 63, 296, 120)
    v.ConfirmDetail.TextWrapped = true
    v.Confirm = button(dialog, "Confirm", Config.Prestige.ButtonName, T.AccentAlt)
    pos(v.Confirm, 22, 196, 296, 40)
    v.Cancel = button(dialog, "Cancel", "Keep playing", T.PanelRaised)
    pos(v.Cancel, 22, 243, 296, 28)

    function v:ApplyCosmetic(key)
        if self.AppliedCosmetic == key and self.AppliedCosmeticZone == self.CurrentZone then
            return
        end
        local zone
        for _, candidate in ipairs(Config.Zones) do
            if candidate.Id == self.CurrentZone then
                zone = candidate
                break
            end
        end
        if not zone then
            return
        end
        if self.Art then
            self.Art:Destroy()
        end
        self.Art, self.ArtScale = Art.Planet(self.Target, zone)
        self.ArtScale.Scale = (self.Diameter or 300) / 300
        self.AppliedCosmetic = key
        self.AppliedCosmeticZone = self.CurrentZone
        local palette = cosmeticPalettes[key]
        T.Accent = palette and palette.Accent or defaultAccents.Primary
        T.AccentAlt = palette and palette.AccentAlt or defaultAccents.Secondary
        local accent = palette and palette.Accent or T.AccentAlt
        self.OrbitOutline.Color = accent
        self.OrbitOutline.Transparency = palette and 0.28 or 0.7
        self.OrbitOutline.Thickness = key == "SupporterAura" and 3 or 1
        self.OrbitDot.BackgroundColor3 = accent
        self.SceneTag.TextColor3 = accent
        if not palette then
            return
        end
        local globe = self.Art:FindFirstChild("Globe")
        if palette.Primary and globe then
            globe.BackgroundColor3 = palette.Primary
            local gradient = globe:FindFirstChildOfClass("UIGradient")
            if gradient then
                gradient.Color = ColorSequence.new(palette.Primary, palette.Secondary)
            end
            local border = globe:FindFirstChildOfClass("UIStroke")
            if border then
                border.Color = accent
            end
            for _, span in ipairs(self.Art:GetChildren()) do
                if span.Name == "Land" or span:GetAttribute("CosmeticSurface") == true then
                    span.BackgroundColor3 = accent
                    local landGradient = span:FindFirstChildOfClass("UIGradient")
                    if landGradient then
                        landGradient.Color = ColorSequence.new(accent, palette.Secondary)
                    end
                end
            end
            local image = self.Art:FindFirstChild("ThemeImage")
            if image then
                image.ImageColor3 = palette.Primary
            end
        end
    end
    function v:SetPage(page)
        self.Page = page
        self:Layout(self.Viewport)
    end
    function v:SetPlayPage(page)
        self.PlayPage = page
        self:Layout(self.Viewport)
    end
    function v:SetFilter(filter)
        self.JournalFilter = filter
        if self.State then
            self:Render(self.State)
        end
    end
    function v:Layout(viewport)
        viewport = viewport or Vector2.new(1280, 800)
        self.Viewport = viewport
        self.Toast.Size = UDim2.fromOffset(math.min(370, viewport.X - 32), 58)
        self.PaidBoostTimer.Size = UDim2.fromOffset(math.max(1, math.min(330, viewport.X - 32)), 42)
        self.PaidBoostTimer.Position = UDim2.new(1, -16, 0, 16)
        local compact = viewport.X < 700 or viewport.Y < 420 or viewport.X < viewport.Y
        local landscape = compact and viewport.X > viewport.Y
        self.Compact = compact
        self.Landscape = landscape
        local w, h, s
        if compact then
            w = landscape and 740 or 430
            s = math.min((viewport.X - (landscape and 112 or 32)) / w, 1.25)
            h = (viewport.Y - 108) / s
        else
            w, h = 1280, 720
            s = math.min((viewport.X - 40) / w, (viewport.Y - 88) / h, 1.45)
        end
        canvas.Size = UDim2.fromOffset(w, h)
        canvas.Position = UDim2.new(0.5, 0, 0.5, compact and 15 or 20)
        scale.Scale = s
        if self.ToastDocked then
            -- Keep compact notifications above the bottom Play navigation.
            self.Toast.Position = UDim2.new(1, -16, 1, compact and -(51 + 46 * s) or -12)
        end
        local headerH = compact and (landscape and 76 or 112) or 88
        pos(header, 0, 0, w, headerH)
        for i, name in ipairs({ "Play", "Research", "Expeditions", "Journal", "Ascension", "Shop" }) do
            local start = compact and (landscape and 240 or 0) or 304
            local width = compact and (landscape and w - 240 or w) or 680
            local step = width / 6
            local label = compact and not landscape and ({ Expeditions = "Trips", Ascension = "Ascend" })[name] or name
            self.Nav[name].Text = label
            local navY = compact and (landscape and 0 or 58) or 2
            pos(self.Nav[name], start + (i - 1) * step, navY, step - 6, compact and 52 or 40)
            self.Nav[name].TextSize = compact and 12 or 13
            self.Nav[name].BackgroundColor3 = self.Page == name and T.Accent or T.PanelRaised
            self.Nav[name].TextColor3 = self.Page == name and T.Background or T.MutedText
        end
        self.Tagline.Visible = not landscape
        self.Title.TextSize = landscape and 23 or 28
        self.Objective.Visible = not (compact and not landscape)
        pos(self.Objective, 0, 51, compact and 440 or 900, 25)
        pos(self.Wallet, w - 250, 49, 110, 25)
        pos(self.SaveStatus, w - 132, 65, 132, 16)
        pos(self.Motion, w - 130, 2, 130, 35)
        if compact then
            pos(self.Motion, w - 130, 32, 130, 22)
            self.Motion.TextSize = 10
            pos(self.Wallet, w - 130, 4, 130, 22)
            self.SaveStatus.Visible = false
        end
        if landscape then
            self.Motion.Visible = false
            pos(self.Wallet, w - 180, 47, 180, 22)
        else
            self.Motion.Visible = true
        end
        if not compact then
            self.SaveStatus.Visible = true
        end
        local bodyY = headerH + 12
        local bodyH = h - bodyY
        local playH = bodyH - (compact and 58 or 0)
        if compact then
            pos(scene, 0, bodyY, w, playH)
            pos(shop, 0, bodyY, w, playH)
            pos(worlds, 0, bodyY, w, playH)
            pos(nav, 0, h - 46, w, 46)
            for i, name in ipairs({ "Collect", "Upgrades", "Worlds" }) do
                local b = self.MobileTabs[name]
                pos(b, (i - 1) * (w + 8) / 3, 0, (w - 16) / 3, 46)
                b.BackgroundColor3 = self.PlayPage == name and T.Accent or T.PanelRaised
                b.TextColor3 = self.PlayPage == name and T.Background or T.MutedText
            end
        else
            pos(scene, 0, bodyY, 824, 420)
            pos(shop, 844, bodyY, 436, bodyH)
            pos(worlds, 0, bodyY + 438, 824, bodyH - 438)
        end
        scene.Visible = self.Page == "Play" and (not compact or self.PlayPage == "Collect")
        shop.Visible = self.Page == "Play" and (not compact or self.PlayPage == "Upgrades")
        worlds.Visible = self.Page == "Play" and (not compact or self.PlayPage == "Worlds")
        nav.Visible = self.Page == "Play" and compact
        local sw = compact and w or 824
        local sh = compact and playH or 438
        pos(self.SceneTag, 22, 13, sw * 0.55, 22)
        pos(self.Boost, sw * 0.58, 13, sw * 0.42 - 22, 22)
        local d, cx, cy
        if not compact then
            pos(self.Currency, 20, 80, 310, 76)
            self.Currency.TextSize = 70
            pos(self.CurrencyName, 20, 154, 310, 20)
            pos(self.Rates, 20, 182, 310, 24)
            pos(burst, 26, 229, 298, 82)
            pos(self.SceneObjective, 24, 326, 302, 58)
            d, cx, cy = 300, 575, 229
            pos(self.TargetHint, 370, 390, 410, 24)
        elseif landscape then
            pos(self.Currency, 16, 30, sw * 0.44, 42)
            self.Currency.TextSize = 38
            pos(self.CurrencyName, 16, 73, sw * 0.44, 17)
            pos(self.Rates, 16, 95, sw * 0.44, 20)
            pos(burst, 20, sh - 46, sw * 0.43, 35)
            self.SceneObjective.Visible = false
            d = math.max(60, sh - 36)
            cx, cy = sw * 0.73, sh * 0.48
            pos(self.TargetHint, sw * 0.5, sh - 24, sw * 0.48, 20)
        elseif sh < 380 then
            -- Short portrait windows reserve a separate row for Overdrive.
            pos(self.Currency, 12, 28, sw * 0.44, 42)
            self.Currency.TextSize = 36
            pos(self.CurrencyName, 12, 72, sw * 0.44, 18)
            pos(self.Rates, 12, 97, sw * 0.44, 22)
            d = math.min(156, math.max(40, sh - 138))
            cx, cy = sw * 0.74, 28 + d / 2
            pos(self.TargetHint, sw * 0.5, 36 + d, sw * 0.48, 20)
            pos(burst, 16, sh - 76, sw - 32, 50)
            pos(self.SceneObjective, 16, sh - 23, sw - 32, 20)
        else
            pos(self.Currency, 0, 35, sw, 58)
            self.Currency.TextSize = 56
            pos(self.CurrencyName, 0, 92, sw, 18)
            pos(self.Rates, 0, 117, sw, 22)
            d = math.min(278, math.max(100, sh - 290))
            cx, cy = sw / 2, 155 + d / 2
            pos(burst, 24, sh - 100, sw - 48, 64)
            pos(self.SceneObjective, 20, sh - 32, sw - 40, 25)
            pos(self.TargetHint, 0, sh - 133, sw, 22)
        end
        if not landscape then
            self.SceneObjective.Visible = true
        end
        self.Target.Position = UDim2.fromOffset(cx, cy)
        self.Target.Size = UDim2.fromOffset(d, d)
        self.Diameter = d
        self.ArtScale.Scale = d / 300
        pos(self.Orbit, cx - d * 0.78, cy - d * 0.21, d * 1.56, d * 0.5)
        local bw = burst.Size.X.Offset
        local shortPortrait = compact and not landscape and sh < 380
        pos(self.BurstTitle, 12, (landscape or shortPortrait) and 1 or 9, bw - 96, 18)
        pos(self.BurstCount, bw - 94, (landscape or shortPortrait) and 1 or 9, 82, 18)
        pos(self.BurstTrack, 12, (landscape or shortPortrait) and 24 or 34, bw - 24, 6)
        pos(self.BurstNote, 12, landscape and 48 or compact and 46 or 48, bw - 24, compact and 14 or 23)
        self.BurstNote.Visible = not landscape and not shortPortrait
        self.Comet.Size = UDim2.fromOffset(116, 38)
        self.Comet.Position = UDim2.fromOffset(compact and 78 or 390, landscape and 45 or 75)
        local shopW = compact and w or 436
        local shopH = compact and playH or bodyH
        pos(self.ProductionTitle, 20, 16, shopW - 40, 25)
        pos(self.ShopSub, 20, 44, shopW - 40, 20)
        for i, q in ipairs(purchaseQuantities) do
            pos(self.QuantityButtons[q], 16 + (i - 1) * (shopW - 24) / 3, 72, (shopW - 40) / 3, 28)
        end
        pos(self.List, 15, 111, shopW - 30, math.max(25, shopH - 176))
        pos(self.Rebirth, 16, shopH - 52, shopW - 32, 36)
        pos(self.RebirthTitle, 12, 5, 170, 25)
        pos(self.RebirthCost, shopW - 182, 5, 130, 25)
        if landscape then
            self.ShopSub.Visible = false
            pos(self.ProductionTitle, 18, 10, 230, 26)
            for i, q in ipairs(purchaseQuantities) do
                pos(self.QuantityButtons[q], shopW - 290 + (i - 1) * 90, 9, 84, 28)
            end
            pos(self.List, 15, 46, shopW - 30, shopH - 55)
            self.Rebirth.Visible = false
        else
            self.ShopSub.Visible = true
            self.Rebirth.Visible = not self.State or self.State.PrestigeEnabled
        end
        for _, r in pairs(self.Rows) do
            pos(r.Buy, shopW - 145, 62, 94, 28)
        end
        local ww = compact and w or 824
        local wh = compact and playH or bodyH - 438
        self.WorldTitle.Text = compact and "PLANETS" or (T.WorldTitle or "WORLDS")
        pos(self.WorldTitle, 22, 16, ww - 312, 24)
        pos(self.WorldProgress, ww - 280, 16, 144, 24)
        pos(self.WorldBack, ww - 126, 6, 46, 44)
        pos(self.WorldNext, ww - 74, 6, 46, 44)
        pos(self.WorldList, 20, 58, ww - 40, math.max(35, wh - 106))
        local vertical = compact and not landscape
        self.WorldLayout.FillDirection = vertical and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
        self.WorldList.AutomaticCanvasSize = vertical and Enum.AutomaticSize.Y or Enum.AutomaticSize.X
        self.WorldList.ScrollingDirection = vertical and Enum.ScrollingDirection.Y or Enum.ScrollingDirection.X
        self.WorldList.HorizontalScrollBarInset = vertical and Enum.ScrollBarInset.None or Enum.ScrollBarInset.Always
        self.WorldList.VerticalScrollBarInset = vertical and Enum.ScrollBarInset.Always or Enum.ScrollBarInset.None
        for _, r in pairs(self.Zones) do
            r.Button.Size = vertical and UDim2.new(1, -5, 0, 70) or UDim2.fromOffset(220, 64)
        end
        pos(self.Goal, 22, wh - 37, ww * 0.6, 18)
        pos(self.GoalAmount, ww * 0.58, wh - 37, ww * 0.42 - 22, 18)
        pos(self.GoalTrack, 22, wh - 14, ww - 44, 4)
        for page, panel in pairs(self.Panels) do
            pos(panel, 0, bodyY, w, bodyH)
            panel.Visible = self.Page == page
            if page == "Shop" then
                pos(self.ShopTitle, 24, 16, w - 48, 33)
                pos(self.ShopSubtitle, 24, 53, w - 48, 34)
            else
                pos(panel.Title, 24, 16, page == "Research" and w - 260 or w - 48, 33)
                pos(panel.Subtitle, 24, 53, w - 48, 34)
                if page == "Research" then
                    pos(self.AutoBuy, w - 210, 16, 186, 36)
                end
            end
            if page == "Shop" then
                local top = landscape and 58 or 99
                panel.Subtitle.Visible = not landscape
                pos(self.ShopList, 22, top, w - 44, math.max(30, bodyH - top - 20))
                local cw = w - 44
                for _, r in pairs(self.ShopOffers) do
                    pos(r.Name, 16, 9, cw - 155, 22)
                    pos(r.Benefit, 16, 32, cw - 155, 22)
                    pos(r.Status, 16, 58, cw - 155, 17)
                    pos(r.Button, cw - 132, 17, 112, 52)
                end
                for _, r in pairs(self.CosmeticRows) do
                    pos(r.Name, 16, 8, cw - 155, 20)
                    pos(r.Status, 16, 30, cw - 155, 18)
                    pos(r.Button, cw - 132, 3, 112, 52)
                end
            else
                local top = page == "Journal" and 130
                    or page == "Ascension" and 186
                    or page == "Expeditions" and 160
                    or 99
                if landscape then
                    panel.Subtitle.Visible = false
                    top = page == "Journal" and 91 or page == "Ascension" and 115 or page == "Expeditions" and 104 or 58
                else
                    panel.Subtitle.Visible = true
                end
                local list = self[page .. "List"]
                pos(list, 22, top, w - 44, math.max(30, bodyH - top - 20))
                local columns = (compact and not landscape) and 1 or page == "Expeditions" and 3 or 2
                local height = landscape and 100 or page == "Expeditions" and 154 or 126
                local cw = (w - 44 - 12 * (columns - 1) - 6) / columns
                self[page .. "Grid"].CellSize = UDim2.fromOffset(cw, height)
                for _, r in pairs(self.Cards[page]) do
                    pos(r.Name, 16, 12, cw - 32, 24)
                    if r.IconTile then pos(r.IconTile,14,8,36,36);pos(r.Name,60,12,cw-76,24)end
                    pos(r.Detail, 16, 39, cw - 32, 32)
                    pos(r.Status, 16, page == "Expeditions" and 77 or 74, cw - 130, 22)
                    pos(r.Reward, 16, page == "Expeditions" and 102 or 96, cw - 125, 20)
                    pos(r.Button, cw - 116, height - 45, 100, 30)
                    pos(r.Track, 16, height - 7, cw - 32, 3)
                    r.Detail.Visible = not landscape or page == "Journal"
                    r.Name.TextSize = landscape and 15 or 17
                    if landscape then
                        pos(r.Name, 16, 6, cw - 32, 22)
                        if r.IconTile then pos(r.IconTile,14,4,28,28);pos(r.Name,50,6,cw-66,22)
                            r.IconTile.Icon.IconScale.Scale=.58 end
                        pos(r.Detail, 16, 30, cw - 32, 20)
                        pos(r.Status, 16, page == "Journal" and 65 or 33, cw - 32, 20)
                        pos(r.Reward, 16, 64, cw - 130, 20)
                        pos(r.Button, cw - 116, 55, 100, 30)
                    end
                    if r.IconTile and not landscape then r.IconTile.Icon.IconScale.Scale=.75 end
                end
            end
        end
        pos(self.JournalButtons.Achievements, 24, landscape and 52 or 89, (w - 60) / 2, 30)
        pos(self.JournalButtons.Daily, 36 + (w - 60) / 2, landscape and 52 or 89, (w - 60) / 2, 30)
        pos(self.AscendBanner, 22, landscape and 52 or 96, w - 44, landscape and 52 or 75)
        pos(self.AscendText, 14, 5, w - 208, landscape and 42 or 65)
        pos(self.AscendButton, w - 177, landscape and 8 or 19, 119, 34)
        pos(self.Route, 24, landscape and 46 or 91, w - 48, landscape and 48 or 58)
        if self.State then
            self:Render(self.State)
        end
    end
    function v:UpdatePaidBoostTimer(now)
        local s = self.State
        local label = UI.PaidProductionText(s, now)
        self.PaidBoostTimer.Visible = label ~= nil
        if label then
            if self.PaidBoostTimerText.Text ~= label then
                self.PaidBoostTimerText.Text = label
            end
            self.PaidBoostTimer.Position = UDim2.new(1, -16, 0, 16)
        end
    end
    function v:UpdateExpeditions(now)
        local s = self.State
        if not s then
            return
        end
        local trip = s.Expedition
        self.Ship.Position = UDim2.fromScale(0.08, 0.5)
        self.RouteLabel.Text = "Choose an expedition below"
        for _, r in pairs(self.Cards.Expeditions) do
            local item = r.Item
            if item then
                local enabled = false
                r.Fill.Size = UDim2.fromScale(0, 1)
                r.Status.Text = "REWARD " .. Art.Number(item.Reward) .. " " .. Config.Currency.ShortName
                if trip and trip.Id == r.Id then
                    local remaining = math.max(0, trip.EndsAt - now)
                    local progress = 1 - math.clamp(remaining / item.Duration, 0, 1)
                    enabled = remaining <= 0
                    r.Button.Text = enabled and "COLLECT" or formatTime(remaining)
                    r.Status.Text = "CARGO " .. Art.Number(trip.Reward) .. " " .. Config.Currency.ShortName
                    r.Fill.Size = UDim2.fromScale(progress, 1)
                    self.Ship.Position = UDim2.fromScale(0.08 + 0.84 * progress, 0.5)
                    self.RouteLabel.Text = enabled and "Cargo arrived! Collect your reward below."
                        or item.Name .. " / " .. formatTime(remaining) .. " remaining"
                elseif trip then
                    r.Button.Text = "CREW BUSY"
                elseif item.Locked then
                    r.Button.Text = "LOCKED"
                elseif s.Currency < item.Cost then
                    r.Button.Text = "NEED ENERGY"
                else
                    r.Button.Text = "SEND CREW"
                    enabled = true
                end
                r.Button.Active = enabled
                r.Button.BackgroundColor3 = enabled and T.Accent or T.Panel
                r.Button.TextColor3 = enabled and T.Background or T.MutedText
            end
        end
    end
    function v:Render(s)
        self.State = s
        self:UpdatePaidBoostTimer(s.ServerTime or workspace:GetServerTimeNow())
        if not self.Animated then
            self.Currency.Text = Art.Number(s.Currency)
        end
        self.Rates.Text = Art.Number(s.ClickPower) .. " / click     +" .. Art.Number(s.PassiveRate) .. " / sec"
        self.Wallet.Text = Art.Number(s.Stars or 0) .. " STARS"
        self.Objective.Text = s.Objective or T.Mission
        self.SceneObjective.Text = s.Objective or T.ClickHint
        self.SaveStatus.Text = s.SaveMode == "Cloud" and "CLOUD SAVING"
            or s.SaveMode == "Retrying" and "SAVE RETRYING"
            or "TEMPORARY PROGRESS"
        self.Nav.Journal.Text = (s.Claimable or 0) > 0 and "Journal (" .. s.Claimable .. ")"
            or (self.Compact and not self.Landscape and "Log" or "Journal")
        for key, row in pairs(self.ShopOffers) do
            local offer = row.Offer
            local owned = offer.Kind == "Pass" and s.OwnedPasses and s.OwnedPasses[key] == true or false
            local active = offer.Grant
                    and offer.Grant.Type == "PaidBoost"
                    and (s.PaidBoostEndsAt or 0) > (s.ServerTime or 0)
                or false
            local canFit = not offer.Grant
                or offer.Grant.Type ~= "Currency"
                or (s.Currency or 0) + offer.Grant.Amount <= Config.MaximumCurrency
            local price = self.ShopPrices[key]
            local canTransact = offer.Kind ~= "Product" or s.CanSellDeveloperProducts ~= false
            local offerState = MonetizationRules.OfferState(
                offer,
                price ~= nil,
                owned,
                active,
                canFit,
                canTransact,
                s.DeveloperProductsUnavailableReason
            )
            row.Status.Text = offer.Id <= 0 and "Configure this Roblox offer ID to enable it"
                or offerState.Status == "Owned" and "Owned on this account"
                or offerState.Status == "Active" and ("Active for " .. formatTime(
                    (s.PaidBoostEndsAt or 0) - (s.ServerTime or 0)
                ))
                or offerState.Status == "PersistenceUnavailable" and "Saved progress is required for purchases"
                or offerState.Status == "StorageLimit" and "Purchases paused: receipt storage is nearly full"
                or offerState.Status == "WalletFull" and "Wallet is full for this pack"
                or price == nil and "Price unavailable from Roblox"
                or "Available"
            row.Button.Text = offer.Id <= 0 and "SET ID"
                or offerState.Status == "Owned" and "OWNED"
                or offerState.Status == "PersistenceUnavailable" and "SAVE REQUIRED"
                or offerState.Status == "StorageLimit" and "PAUSED"
                or offerState.Status == "WalletFull" and "WALLET FULL"
                or price ~= nil and ("R$ " .. tostring(price))
                or "UNAVAILABLE"
            row.Button.Active = offerState.CanPrompt
            row.Button.BackgroundColor3 = offerState.CanPrompt and T.Accent or T.Panel
            row.Button.TextColor3 = offerState.CanPrompt and T.Background or T.MutedText
        end
        for key, row in pairs(self.CosmeticRows) do
            local cosmetic = row.Cosmetic
            local unlocked = s.OwnedPasses and s.OwnedPasses[cosmetic.PassKey] == true or false
            local equipped = s.EquippedCosmetic == key
            row.Status.Text = equipped and "Equipped"
                or unlocked and "Unlocked"
                or ("Unlock with " .. MonetizationCatalog.Passes[cosmetic.PassKey].Name)
            row.Button.Text = equipped and "EQUIPPED" or unlocked and "EQUIP" or "LOCKED"
            row.Button.Active = unlocked and not equipped
            row.Button.BackgroundColor3 = row.Button.Active and T.Accent or T.Panel
            row.Button.TextColor3 = row.Button.Active and T.Background or T.MutedText
        end
        for q, b in pairs(self.QuantityButtons) do
            b.BackgroundColor3 = self.Quantity == q and T.Accent or T.PanelRaised
            b.TextColor3 = self.Quantity == q and T.Background or T.MutedText
        end
        self.AutoBuy.Active = s.AutoBuyUnlocked == true
        self.AutoBuy.Text = not s.AutoBuyUnlocked
                and (s.AutoBuyWorldsMet == false
                    and ("AUTO: " .. (s.AutoBuyRequiredWorld or Progression.AutoBuy.RequiredWorld) .. " WORLDS")
                    or "BUY AUTO BUY BELOW")
            or s.AutoBuyEnabled and "AUTO RESEARCH: ON"
            or "AUTO RESEARCH: OFF"
        self.AutoBuy.BackgroundColor3 = s.AutoBuyEnabled and T.Accent or T.PanelRaised
        self.AutoBuy.TextColor3 = s.AutoBuyEnabled and T.Background or T.MutedText
        self.ShopSub.Text = #Catalog .. " tiers. Build an empire."
        for id, r in pairs(self.Rows) do
            local u = s.Upgrades[id]
            if u then
                local afford = not u.Locked and s.Currency >= u.Cost
                r.Owned.Text = "OWNED " .. Art.Number(u.Owned)
                r.Buy.Text = u.Locked and "LOCKED"
                    or self.Quantity == 1 and (Art.Number(u.Cost) .. " " .. Config.Currency.ShortName)
                    or "BUY " .. (self.Quantity == "Max" and "MAX" or "x10")
                r.Desc.Text = u.Locked and ("Unlock " .. u.RequiredWorld .. " worlds to access")
                    or (Config.UpgradePresentation[id] or {}).Description
                    or ""
                r.Buy.BackgroundColor3 = afford and T.Accent or T.Panel
                r.Buy.TextColor3 = afford and T.Background or T.MutedText
                r.Stroke.Color = afford and T.Accent or T.Border
                r.Stroke.Transparency = afford and 0.65 or 0.2
            end
        end
        local unlocked, nextZone = 0, nil
        for i, z in ipairs(s.Zones) do
            local r = self.Zones[z.Id]
            if z.Unlocked then
                unlocked += 1
            elseif not nextZone then
                nextZone = z
            end
            if r then
                r.Status.Text = z.Current and "ACTIVE / x" .. z.Multiplier
                    or z.Unlocked and "TRAVEL / x" .. z.Multiplier
                    or Art.Number(z.UnlockCost) .. " " .. Config.Currency.ShortName
                r.Status.TextColor3 = z.Current and T.Accent or T.MutedText
                r.Stroke.Color = z.Current and T.Accent or T.Border
            end
            if z.Current then
                self.SceneTag.Text = string.format("%02d / %s", i, string.upper(z.Name))
                self.Boost.Text = "x" .. z.Multiplier .. " WORLD BOOST"
                if self.CurrentZone ~= z.Id then
                    self.CurrentZone = z.Id
                end
            end
        end
        self:ApplyCosmetic(s.EquippedCosmetic)
        self.WorldProgress.Text = unlocked .. " / " .. #Config.Zones .. " WORLDS"
        self.Goal.Text = nextZone and "NEXT: " .. string.upper(nextZone.Name) or T.AllWorldsText
        self.GoalAmount.Text = nextZone
                and Art.Number(s.Currency) .. " / " .. Art.Number(nextZone.UnlockCost) .. " " .. Config.Currency.ShortName
            or "ALL UNLOCKED"
        self.GoalFill.Size = UDim2.fromScale(nextZone and math.clamp(s.Currency / nextZone.UnlockCost, 0, 1) or 1, 1)
        self.RebirthCost.Text = s.CanPrestige and "+" .. Art.Number(s.RebirthGain) .. " STARS >"
            or Art.Number(s.PrestigeCost) .. " " .. Config.Currency.ShortName
        self.AscendText.Text = ""
            .. Art.Number(s.Stars or 0)
            .. " stars available\n"
            .. (
                s.CanPrestige and "Ascend now for +" .. Art.Number(s.RebirthGain) .. " stars"
                or "Ascension unlocks at " .. Art.Number(s.PrestigeCost) .. " " .. Config.Currency.ShortName
            )
        self.AscendButton.BackgroundColor3 = s.CanPrestige and T.AccentAlt or T.PanelRaised
        self.ConfirmDetail.Text = "Gain "
            .. Art.Number(s.RebirthGain or 1)
            .. " stars and +"
            .. Art.Number(Config.Prestige.MultiplierPerPrestige * 100)
            .. "% production.\n\n"
            .. Config.Currency.Name
            .. ", producers and other research reset.\nAuto Buy, worlds, achievements, stars and permanent upgrades stay."
        for _, kind in ipairs({ "Research", "Permanent", "Expeditions", "Achievements", "Daily" }) do
            local page = kind == "Permanent" and "Ascension"
                or (kind == "Achievements" or kind == "Daily") and "Journal"
                or kind
            for _, item in ipairs(s[kind] or {}) do
                local key = (kind == "Expeditions" and "Expedition" or kind == "Achievements" and "Achievement" or kind)
                    .. item.Id
                local r = self.Cards[page][key]
                if r then
                    r.Item = item
                    if kind == "Research" or kind == "Permanent" then
                        local max = item.Level >= item.Max
                        local wallet = kind == "Permanent" and (s.Stars or 0) or s.Currency
                        local afford = not max and not item.Locked and wallet >= item.Cost
                        local autoBuyResearch = kind == "Research" and item.Id == Progression.AutoBuy.ResearchId
                        r.Status.Text = autoBuyResearch and (max and "PERMANENTLY UNLOCKED"
                            or item.Locked and ("REQUIRES " .. item.RequiredWorld .. " WORLDS")
                            or "KEPT AFTER ASCEND")
                            or ("LEVEL " .. item.Level .. " / " .. item.Max)
                        r.Reward.Text = max and (autoBuyResearch and "Permanent unlock" or "Fully upgraded")
                            or Art.Number(item.Cost)
                                .. (kind == "Permanent" and " STARS" or " " .. Config.Currency.ShortName)
                        r.Button.Active = not item.Locked
                        r.Button.Text = autoBuyResearch and (max and "OWNED"
                            or item.Locked and (item.RequiredWorld .. " WORLDS") or "BUY")
                            or (max and "MAXED" or "UPGRADE")
                        r.Button.BackgroundColor3 = afford and T.Accent or T.Panel
                        r.Button.TextColor3 = afford and T.Background or T.MutedText
                        r.Fill.Size = UDim2.fromScale(item.Level / item.Max, 1)
                    elseif kind == "Expeditions" then
                        r.Status.Text = "REWARD " .. Art.Number(item.Reward) .. " " .. Config.Currency.ShortName
                        r.Reward.Text = formatTime(item.Duration) .. " / COST " .. Art.Number(item.Cost)
                    else
                        r.Frame.Visible = self.JournalFilter == kind
                        r.Detail.Text = Art.Number(item.Progress) .. " / " .. Art.Number(item.Goal)
                        r.Status.Text = item.Stars > 0 and "+" .. item.Stars .. " STARS"
                            or "+" .. Art.Number(item.Energy) .. " " .. Config.Currency.ShortName
                        r.Button.Text = item.Claimed and "COLLECTED" or item.Ready and "CLAIM" or "IN PROGRESS"
                        r.Button.BackgroundColor3 = item.Ready and T.Accent or T.Panel
                        r.Button.TextColor3 = item.Ready and T.Background or T.MutedText
                        r.Fill.Size = UDim2.fromScale(math.clamp(item.Progress / item.Goal, 0, 1), 1)
                    end
                end
            end
        end
        self:UpdateExpeditions(s.ServerTime or workspace:GetServerTimeNow())
        for kind, b in pairs(self.JournalButtons) do
            b.BackgroundColor3 = self.JournalFilter == kind and T.Accent or T.PanelRaised
            b.TextColor3 = self.JournalFilter == kind and T.Background or T.MutedText
        end
    end
    v:Layout(Vector2.new(1280, 800))
    local initial = {
        Currency = 0,
        ClickPower = Config.BaseClickPower,
        PassiveRate = 0,
        Stars = 0,
        PrestigeCost = Config.Prestige.BaseRequirement,
        PrestigeEnabled = Config.Prestige.Enabled,
        RebirthGain = 1,
        CanPrestige = false,
        Upgrades = {},
        Zones = {},
        SaveMode = "Temporary",
        Objective = "First goal: buy " .. Config.UpgradePresentation[Catalog[1].Id].Name,
    }
    for _, d in ipairs(Catalog) do
        initial.Upgrades[d.Id] =
            { Owned = 0, Cost = d.BaseCost, Locked = (d.RequiredWorld or 1) > 1, RequiredWorld = d.RequiredWorld or 1 }
    end
    for i, z in ipairs(Config.Zones) do
        initial.Zones[i] = {
            Id = z.Id,
            Name = z.Name,
            UnlockCost = z.UnlockCost,
            Multiplier = z.Multiplier,
            Unlocked = i == 1,
            Current = i == 1,
        }
    end
    v:Render(initial)
    require(script.Parent.StarMapView).Attach(v, Config)
    return v
end
return UI
end
local default = create()
default.ForConfig = create
return default
