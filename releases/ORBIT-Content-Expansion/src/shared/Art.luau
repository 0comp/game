-- Pure 2D UI. Build in StarterGui for an editable preview, or PlayerGui at runtime.
local Config = require(script.Parent.ThemeConfig)
local Catalog = require(script.Parent.UpgradeCatalog)
local T = Config.Theme
local C = Color3.fromRGB
local UI = {}

local function make(class, parent, name, props)
	local o = Instance.new(class)
	o.Name = name
	for k, v in pairs(props or {}) do o[k] = v end
	o.Parent = parent
	return o
end
local function round(o, r) make("UICorner", o, "Corner", {CornerRadius = UDim.new(0, r or 16)}) end
local function stroke(o, color, transparency, thickness)
	return make("UIStroke", o, "Outline", {Color = color or T.Border, Transparency = transparency or 0, Thickness = thickness or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border})
end
local function box(parent, name, color, radius)
	local o = make("Frame", parent, name, {BorderSizePixel = 0, BackgroundColor3 = color or T.Panel})
	if radius then round(o, radius) end
	return o
end
local function clear(parent, name)
	return make("Frame", parent, name, {BorderSizePixel = 0, BackgroundTransparency = 1})
end
local function label(parent, name, text, size, color, bold, align)
	return make("TextLabel", parent, name, {BackgroundTransparency = 1, BorderSizePixel = 0,
		Text = text, TextColor3 = color or T.Text, TextSize = size or 16,
		Font = bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		TextXAlignment = align or Enum.TextXAlignment.Left, TextYAlignment = Enum.TextYAlignment.Center})
end
local function place(o, x, y, w, h)
	o.Position = UDim2.fromOffset(x, y); o.Size = UDim2.fromOffset(w, h)
end
local function gradient(o, a, b, rotation)
	o.BackgroundColor3 = Color3.new(1,1,1)
	return make("UIGradient", o, "Gradient", {Color = ColorSequence.new(a, b), Rotation = rotation or 90})
end
local function button(parent, name, text, color)
	local b = make("TextButton", parent, name, {BackgroundColor3 = color or T.PanelRaised, BorderSizePixel = 0,
		Text = text or "", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = T.Text, AutoButtonColor = false})
	round(b, 12)
	return b
end
local function ellipse(parent, name, x, y, w, h, color, transparency)
	local o = box(parent, name, color, 999)
	place(o, x, y, w, h); o.BackgroundTransparency = transparency or 0
	return o
end

function UI.Number(n)
	n = math.max(0, tonumber(n) or 0)
	for _, v in ipairs({{1e18,"Qi"},{1e15,"Qa"},{1e12,"T"},{1e9,"B"},{1e6,"M"},{1e3,"K"}}) do
		if n >= v[1] then return (string.format("%.1f", n / v[1]):gsub("%.0$", "")) .. v[2] end
	end
	if n % 1 ~= 0 then return string.format("%.1f", n) end
	return tostring(math.floor(n))
end

-- Draw a silhouette as horizontal vector spans. No external art assets required.
local function polygon(parent, points, color)
	local low, high = 300, 0
	for _, p in ipairs(points) do low = math.min(low, p[2]); high = math.max(high, p[2]) end
	for y = low, high, 2 do
		local xs = {}
		for i, a in ipairs(points) do
			local b = points[i % #points + 1]
			if (a[2] <= y and b[2] > y) or (b[2] <= y and a[2] > y) then
				table.insert(xs, a[1] + (y - a[2]) / (b[2] - a[2]) * (b[1] - a[1]))
			end
		end
		table.sort(xs)
		local edge = math.sqrt(math.max(0, 142^2 - (y - 150)^2))
		for i = 1, #xs - 1, 2 do
			local a, b = math.max(xs[i], 150 - edge), math.min(xs[i + 1], 150 + edge)
			if b > a then
				local span = box(parent, "Land", color)
				place(span, a, y, b - a + 0.3, 2.2)
				gradient(span, color, color:Lerp(C(17, 69, 89), 0.25), 0)
			end
		end
	end
end

function UI.Planet(parent, zone)
	local art = clear(parent, "PlanetArt"); art.Size = UDim2.fromOffset(300, 300)
	art.AnchorPoint = Vector2.new(0.5, 0.5); art.Position = UDim2.fromScale(0.5, 0.5)
	local scale = make("UIScale", art, "ArtScale", {Scale = 1})
	local imageId = zone.ImageId or T.TargetImageId
	if imageId and imageId ~= "" then
		make("ImageLabel", art, "ThemeImage", {BackgroundTransparency = 1, Size = UDim2.fromScale(1,1), Image = imageId, ScaleType = Enum.ScaleType.Fit})
		return art, scale
	end
	local kind = zone.Art or "Earth"
	local colors = kind=="Pulsar" and {C(218,255,255),C(28,88,181)} or kind=="Oblivion" and {C(32,17,51),C(3,3,12)} or kind=="Void" and {C(58,35,89),C(8,7,19)} or kind=="Sun" and {C(255,239,150),C(239,95,45)} or kind=="Ice" and {C(151,215,255),C(53,82,201)} or kind=="Gas" and {zone.Color,zone.Color:Lerp(C(115,69,73),.65)} or kind == "Cookie" and {C(255,210,137),C(183,111,58)} or kind == "Moon" and {C(215,224,242),C(97,112,145)} or kind == "Mars" and {C(255,183,112),C(155,61,62)} or {C(77,203,255),C(31,78,169)}
	local halo = ellipse(art, "Atmosphere", -7,-7,314,314, zone.Color, 1)
	stroke(halo, zone.Color, 0.75, 7)
	local globe = ellipse(art, "Globe", 0,0,300,300,colors[1]); gradient(globe,colors[1],colors[2],40)
	stroke(globe, zone.Color, 0.15, 2)
	if kind == "Pulsar" then
        local ring = ellipse(art, "PulseRing", -18, -18, 336, 336, zone.Color, 1)
        stroke(ring, zone.Color, 0.4, 4)
        local rig = clear(art, "PulseBeams"); rig.Size = UDim2.fromOffset(300, 300)
        rig.AnchorPoint = Vector2.new(0.5, 0.5); rig.Position = UDim2.fromScale(0.5, 0.5)
        local jet = ellipse(rig, "JetGlow", 135, -36, 30, 372, zone.Color, 0.48)
        local beam = ellipse(rig, "JetCore", 145, -44, 10, 388, C(232, 255, 255), 0.15)
        ellipse(art, "StellarCore", 112, 112, 76, 76, C(239, 255, 255), 0.1)
    elseif kind == "Oblivion" then
        local ring = ellipse(art, "AccretionRing", -48, 110, 396, 80, zone.Color, 1)
        stroke(ring, zone.Color, 0.1, 10); ring.Rotation = -22
        local inner = ellipse(art, "InnerAccretion", -19, 101, 338, 98, C(255, 201, 139), 1)
        stroke(inner, C(255, 201, 139), 0.2, 4); inner.Rotation = -22
        local horizon = ellipse(art, "EventHorizon", 39, 39, 222, 222, C(3, 3, 12))
        stroke(horizon, zone.Color, 0.55, 3)
    elseif kind == "Earth" then
		local green = C(113,223,178)
		polygon(art, {{57,66},{96,43},{131,57},{141,87},{116,107},{122,133},{105,155},{85,146},{66,123},{47,107}}, green)
		polygon(art, {{113,151},{146,154},{173,180},{160,208},{145,244},{129,264},{120,225},{103,194}}, green)
		polygon(art, {{166,57},{211,51},{244,76},{264,110},{242,133},{238,151},{215,149},{205,127},{180,130},{162,101}}, green)
		polygon(art, {{177,135},{204,133},{221,157},{206,191},{181,208},{162,177}}, green)
		polygon(art, {{233,207},{255,201},{270,224},{246,241},{225,229}}, green)
		for _, p in ipairs({{52,96,75,9},{68,107,44,6},{181,85,69,8},{195,96,40,5},{50,183,48,7},{188,232,48,6}}) do
			ellipse(art,"Cloud",p[1],p[2],p[3],p[4],C(235,255,255),0.38)
		end
	elseif kind == "Cookie" then
		globe.Outline.Color=C(133,73,41); globe.Outline.Thickness=7
		for _,p in ipairs({{54,58,29},{124,32,22},{207,64,31},{78,127,26},{167,111,32},{225,169,27},{121,206,31},{51,211,20},{195,236,22}}) do
			local chip=ellipse(art,"ChocolateChip",p[1],p[2],p[3],p[3]*.9,C(75,44,37))
			chip.Rotation=p[1]%40; round(chip,6)
			ellipse(chip,"Highlight",4,4,p[3]*.4,4,C(127,76,49),.3)
		end
		for _,p in ipairs({{94,74},{168,55},{104,165},{193,193},{72,188},{234,120},{155,253}}) do ellipse(art,"Crumb",p[1],p[2],6,6,C(149,92,47),.35) end
	elseif kind=="Gas" or kind=="Ice" or kind=="Sun" or kind=="Void" then
		local stripeColor=kind=="Void" and C(222,156,255) or colors[1]:Lerp(colors[2],.4)
		for i=1,8 do
			local y=28+i*27
			local edge=math.sqrt(math.max(0,142^2-(y-150)^2))
			local band=ellipse(art,"Band",150-edge+5,y,math.max(4,edge*2-10),kind=="Void" and 2 or 8,stripeColor,kind=="Void" and .6 or .42)
		end
		if zone.Rings then
			local ring=ellipse(art,"PlanetRing",-49,103,398,92,zone.Color,1); stroke(ring,zone.Color,.25,8); ring.Rotation=-19
		end
	else
		local craterColor = kind == "Moon" and C(94,109,144) or C(138,63,62)
		for _, p in ipairs({{62,67,40},{175,42,27},{193,105,51},{70,168,56},{181,211,31},{135,138,17},{110,53,12}}) do
			local crater=ellipse(art,"Crater",p[1],p[2],p[3],p[3]*0.84,craterColor,0.44)
			stroke(crater,colors[1],0.84,2)
		end
	end
	local shadowColor=kind=="Cookie" and C(55,27,18) or C(10,20,50)
	local shade = ellipse(art,"NightSide",0,0,300,300,shadowColor,0)
	local g = gradient(shade,shadowColor,shadowColor,10)
	g.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.5,.96),NumberSequenceKeypoint.new(1,.27)})
	if kind~="Cookie" then ellipse(art,"PolarLight",117,13,64,9,C(234,255,255),.5) end
	return art, scale
end

local function icon(parent, kind, color)
	local area = clear(parent,"Icon"); place(area,0,0,48,48)
	if kind == "Bolt" then
		local a=box(area,"BoltTop",color,2); place(a,19,7,13,21); a.Rotation=28
		local b=box(area,"BoltBottom",color,2); place(b,15,22,13,20); b.Rotation=28
	elseif kind == "Drone" then
		local a=box(area,"Arm",color,3); place(a,9,22,31,4)
		local b=box(area,"Arm",color,3); place(b,22,9,4,31)
		for _,p in ipairs({{5,5},{30,5},{5,30},{30,30}}) do local r=ellipse(area,"Rotor",p[1],p[2],13,13,color,1); stroke(r,color,.1,2) end
		local body=box(area,"Body",color,5); place(body,17,17,14,14)
		ellipse(area,"Lens",21,21,6,6,T.Panel,0)
	elseif kind == "Solar" then
		local panel=box(area,"Cells",color,4); place(panel,5,8,38,28)
		for i=1,3 do local a=box(area,"Grid",T.Panel); place(a,5+i*9,8,2,28) end
		local a=box(area,"Grid",T.Panel); place(a,5,21,38,2)
		local a=box(area,"Stand",color,2); place(a,22,35,4,8)
	else
		for _,x in ipairs({3,32}) do local a=box(area,"Panel",color,3); place(a,x,12,13,24); local b=box(a,"Cell",T.Panel); place(b,5,0,2,24) end
		local a=box(area,"Body",color,5); place(a,19,15,10,20)
		local a=box(area,"Antenna",color,2); place(a,23,4,2,12)
		ellipse(area,"Dish",17,3,14,7,color)
	end
	return area
end


UI.Icon=icon
return UI

