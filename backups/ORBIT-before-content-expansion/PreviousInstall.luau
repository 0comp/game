-- ORBIT / Space standalone game. Install into its own Roblox experience.
-- Run the entire file in Roblox Studio's Command Bar while Play is stopped.
-- Reusable 2D clicker template: original art, animation and extended progression.
assert(not game:GetService("RunService"):IsRunning(),"Stop Play before installing.")
local function ensure(parent,name,className)
 local item=parent:FindFirstChild(name)
 if item then assert(item.ClassName==className,"Conflicting class at "..item:GetFullName());return item end
 item=Instance.new(className);item.Name=name;item.Parent=parent;return item
end
local shared=ensure(game:GetService("ReplicatedStorage"),"ClickerKit","Folder")
ensure(shared,"Themes","Folder")
local remotes=ensure(shared,"Remotes","Folder")
for _,name in ipairs({"RequestAction","RequestClick","RequestPurchase","RequestZone","RequestPrestige","RequestSnapshot","StateUpdate"}) do ensure(remotes,name,"RemoteEvent") end
ensure(game:GetService("ServerScriptService"),"ClickerTemplate","Folder")
assert(game:GetService("StarterPlayer"):FindFirstChildOfClass("StarterPlayerScripts"),"StarterPlayerScripts missing")
local function setSource(path,className,source)
 local parts=string.split(path,".");local parent=game:GetService(table.remove(parts,1))
 for i=1,#parts-1 do parent=parent:FindFirstChild(parts[i]);assert(parent,"Missing folder for "..path) end
 ensure(parent,parts[#parts],className).Source=source
end
setSource("ReplicatedStorage.ClickerKit.Art","ModuleScript",[====[
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
	local colors = kind=="Void" and {C(58,35,89),C(8,7,19)} or kind=="Sun" and {C(255,239,150),C(239,95,45)} or kind=="Ice" and {C(151,215,255),C(53,82,201)} or kind=="Gas" and {zone.Color,zone.Color:Lerp(C(115,69,73),.65)} or kind == "Cookie" and {C(255,210,137),C(183,111,58)} or kind == "Moon" and {C(215,224,242),C(97,112,145)} or kind == "Mars" and {C(255,183,112),C(155,61,62)} or {C(77,203,255),C(31,78,169)}
	local halo = ellipse(art, "Atmosphere", -7,-7,314,314, zone.Color, 1)
	stroke(halo, zone.Color, 0.75, 7)
	local globe = ellipse(art, "Globe", 0,0,300,300,colors[1]); gradient(globe,colors[1],colors[2],40)
	stroke(globe, zone.Color, 0.15, 2)
	if kind == "Earth" then
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
]====])
setSource("ReplicatedStorage.ClickerKit.Interface","ModuleScript",[====[
-- Responsive, asset-independent 2D interface. Motion is owned by client/Effects.
local Config=require(script.Parent.ThemeConfig)
local Catalog=require(script.Parent.UpgradeCatalog)
local Progression=require(script.Parent.ProgressionCatalog)
local Art=require(script.Parent.Art)
local T=Config.Theme
local UI={Number=Art.Number}
local function make(class,parent,name,p)
	local o=Instance.new(class); o.Name=name
	for k,v in pairs(p or {}) do o[k]=v end
	o.Parent=parent; return o
end
local function pos(o,x,y,w,h) o.Position=UDim2.fromOffset(x,y); o.Size=UDim2.fromOffset(w,h) end
local function corner(o,r) make("UICorner",o,"Corner",{CornerRadius=UDim.new(0,r or 14)}) end
local function outline(o,c,a) return make("UIStroke",o,"Outline",{Color=c or T.Border,Transparency=a or 0,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}) end
local function frame(parent,name,color,r)
	local o=make("Frame",parent,name,{BorderSizePixel=0,BackgroundColor3=color or T.Panel})
	if r then corner(o,r) end; return o
end
local function clear(parent,name) return make("Frame",parent,name,{BackgroundTransparency=1,BorderSizePixel=0}) end
local function text(parent,name,value,size,color,bold,align)
	return make("TextLabel",parent,name,{BackgroundTransparency=1,BorderSizePixel=0,Text=value or "",TextSize=size or 14,
		TextColor3=color or T.Text,Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,
		TextXAlignment=align or Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Center})
end
local function button(parent,name,value,color)
	local o=make("TextButton",parent,name,{BackgroundColor3=color or T.PanelRaised,BorderSizePixel=0,Text=value or "",
		TextColor3=T.Text,TextSize=14,Font=Enum.Font.GothamBold,AutoButtonColor=false})
	corner(o,10); return o
end
local function circle(parent,name,size,color)
	local o=frame(parent,name,color,999); o.Size=UDim2.fromOffset(size,size); return o
end
local function scroll(parent,name,horizontal)
	return make("ScrollingFrame",parent,name,{BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,
		ScrollBarImageColor3=T.AccentAlt,CanvasSize=UDim2.fromOffset(0,0),AutomaticCanvasSize=horizontal and Enum.AutomaticSize.X or Enum.AutomaticSize.Y,
		ScrollingDirection=horizontal and Enum.ScrollingDirection.X or Enum.ScrollingDirection.Y})
end
local function formatTime(seconds)
	seconds=math.max(0,math.ceil(seconds))
	return seconds>=3600 and string.format("%dh %02dm",math.floor(seconds/3600),math.floor(seconds%3600/60)) or string.format("%02d:%02d",math.floor(seconds/60),seconds%60)
end
UI.Time=formatTime

function UI.Build(parent)
	local old=parent:FindFirstChild("ClickerGameUI"); if old then old:Destroy() end
	local gui=make("ScreenGui",parent,"ClickerGameUI",{ResetOnSpawn=false,IgnoreGuiInset=true,ScreenInsets=Enum.ScreenInsets.None,
		ClipToDeviceSafeArea=false,DisplayOrder=10,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
	local bg=frame(gui,"Background",Color3.new(1,1,1)); bg.Size=UDim2.fromScale(1,1)
	make("UIGradient",bg,"Gradient",{Color=ColorSequence.new(T.Background,T.SkyBottom:Lerp(T.Background,.6)),Rotation=35})
	local canvas=clear(bg,"Canvas"); canvas.AnchorPoint=Vector2.new(.5,.5)
	local scale=make("UIScale",canvas,"ResponsiveScale",{Scale=1})
	local v={Gui=gui,Canvas=canvas,Scale=scale,Page="Play",PlayPage="Collect",JournalFilter="Achievements",Quantity=1,ReducedMotion=false,
		Rows={},Zones={},Nav={},MobileTabs={},QuantityButtons={},Cards={},Panels={},Stars={}}
	local header=clear(canvas,"Header"); v.Header=header
	local logo=frame(header,"Logo",T.Accent,10); pos(logo,0,4,42,42); Art.Icon(logo,"Bolt",T.Background).Size=UDim2.fromOffset(42,42)
	v.Title=text(header,"Title",Config.GameTitle,28,nil,true); pos(v.Title,55,0,230,31)
	v.Tagline=text(header,"Tagline",Config.Tagline,11,T.MutedText,true); pos(v.Tagline,57,32,230,16)
	for _,name in ipairs({"Play","Research","Expeditions","Journal","Ascension"}) do v.Nav[name]=button(header,name,name) end
	v.Motion=button(header,"Motion","Motion: ON"); v.Motion.TextSize=12
	v.Objective=text(header,"Objective","Build your first producer.",14,T.MutedText)
	v.Wallet=text(header,"Stars","0 STARS",13,T.AccentAlt,true,Enum.TextXAlignment.Right)
	v.SaveStatus=text(header,"SaveStatus","CONNECTING",10,T.MutedText,true,Enum.TextXAlignment.Right)
	local line=frame(header,"Divider",T.Border); line.Position=UDim2.new(0,0,1,-1); line.Size=UDim2.new(1,0,0,1)

	local scene=frame(canvas,"Collect",Color3.new(1,1,1),22); outline(scene,T.Border,.35); v.Scene=scene
	make("UIGradient",scene,"Sky",{Color=ColorSequence.new(T.SkyTop,T.SkyBottom),Rotation=40})
	local starfield=clear(scene,"Starfield"); starfield.Size=UDim2.fromScale(1,1); starfield.ClipsDescendants=true
	local random=Random.new(37)
	for i=1,48 do
		local s=circle(starfield,"Star",i%6==0 and 3 or 2,T.MutedText); s.Position=UDim2.fromScale(random:NextNumber(.04,.96),random:NextNumber(.06,.94)); s.BackgroundTransparency=random:NextNumber(.2,.8)
		if i%3==0 then table.insert(v.Stars,{Object=s,Phase=random:NextNumber(0,6),Alpha=s.BackgroundTransparency}) end
	end
	v.SceneTag=text(scene,"WorldTag","01 / EARTH",12,T.Accent,true)
	v.Boost=text(scene,"Multiplier","x1 WORLD BOOST",12,T.MutedText,true,Enum.TextXAlignment.Right)
	v.Currency=text(scene,"Balance","0",64,nil,true,Enum.TextXAlignment.Center)
	v.CurrencyName=text(scene,"CurrencyName",string.upper(Config.Currency.Name),12,T.MutedText,true,Enum.TextXAlignment.Center)
	v.Rates=text(scene,"Rates","1 / click     +0 / sec",14,T.Text,false,Enum.TextXAlignment.Center)
	v.Orbit=frame(scene,"Orbit",T.AccentAlt,999); v.Orbit.BackgroundTransparency=1; outline(v.Orbit,T.AccentAlt,.7); v.Orbit.Rotation=-18; v.Orbit.Visible=T.ShowOrbit~=false
	v.OrbitDot=circle(v.Orbit,"Satellite",8,T.AccentAlt); v.OrbitDot.AnchorPoint=Vector2.new(.5,.5)
	local target=button(scene,"ClickTargetButton",""); target.BackgroundTransparency=1; target.AnchorPoint=Vector2.new(.5,.5); v.Target=target
	v.Bounce=make("UIScale",target,"Bounce",{Scale=1}); v.Art,v.ArtScale=Art.Planet(target,Config.Zones[1]); v.CurrentZone=Config.Zones[1].Id
	v.TargetHint=text(scene,"ClickHint",T.ClickPrompt or "CLICK TO COLLECT",12,nil,true,Enum.TextXAlignment.Center)
	local burst=frame(scene,"Burst",T.Background:Lerp(T.PanelRaised,.5),12); outline(burst,T.Accent,.75); v.BurstPanel=burst
	v.BurstTitle=text(burst,"Title",T.BurstName or "BOOST",12,T.Accent,true)
	v.BurstCount=text(burst,"Count","0 / 20",12,T.Accent,true,Enum.TextXAlignment.Right)
	v.BurstTrack=frame(burst,"Track",T.PanelRaised,4); v.BurstFill=frame(v.BurstTrack,"Fill",T.Accent,4); v.BurstFill.Size=UDim2.fromScale(0,1)
	v.BurstNote=text(burst,"Hint","Click to charge a x3 production burst",11,T.MutedText)
	v.SceneObjective=text(scene,"Objective","First goal: buy a producer",13,T.MutedText,false,Enum.TextXAlignment.Center); v.SceneObjective.TextWrapped=true
	v.CollectorLayer=clear(scene,"Collectors"); v.CollectorLayer.Size=UDim2.fromScale(1,1); v.CollectorLayer.ZIndex=3
	v.Particles=clear(scene,"Feedback"); v.Particles.Size=UDim2.fromScale(1,1); v.Particles.ZIndex=8
	v.Comet=button(scene,"Bonus",T.CollectibleName or "BONUS",T.AccentAlt); v.Comet.TextSize=12; v.Comet.TextColor3=T.Background; v.Comet.AnchorPoint=Vector2.new(.5,.5); v.Comet.ZIndex=9; v.Comet.Visible=false
	v.CometTimer=text(v.Comet,"Timer","10s",10,T.Text,true,Enum.TextXAlignment.Center); v.CometTimer.Position=UDim2.new(0,0,1,0); v.CometTimer.Size=UDim2.new(1,0,0,16)

	local shop=frame(canvas,"Upgrades",T.Panel,22); outline(shop,T.Border,.35); v.Shop=shop
	v.ShopTitle=text(shop,"Title","PRODUCTION",19,nil,true)
	v.ShopSub=text(shop,"Subtitle",#Catalog.." tiers. Build an empire.",12,T.MutedText)
	for i,q in ipairs({1,10,"Max"}) do v.QuantityButtons[q]=button(shop,"Buy"..q,q=="Max" and "BUY MAX" or "BUY x"..q); v.QuantityButtons[q].TextSize=11 end
	v.List=scroll(shop,"List"); make("UIListLayout",v.List,"Layout",{Padding=UDim.new(0,9),SortOrder=Enum.SortOrder.LayoutOrder})
	for i,def in ipairs(Catalog) do
		local p=Config.UpgradePresentation[def.Id] or {}
		local row=frame(v.List,def.Id,T.PanelRaised,13); row.Size=UDim2.new(1,-5,0,100); row.LayoutOrder=i
		local lineStroke=outline(row,T.Border,.2)
		local badge=frame(row,"IconTile",(p.Color or T.Accent):Lerp(T.Panel,.85),12); pos(badge,14,18,50,50)
		if p.ImageId and p.ImageId~="" then make("ImageLabel",badge,"Image",{BackgroundTransparency=1,Size=UDim2.fromScale(1,1),Image=p.ImageId,ScaleType=Enum.ScaleType.Fit})
		else Art.Icon(badge,p.Icon or "Bolt",p.Color or T.Accent).Position=UDim2.fromOffset(1,1) end
		local name=text(row,"UpgradeName",p.Name or def.Id,16,nil,true); pos(name,78,12,260,23)
		local desc=text(row,"Description",p.Description or "",12,T.MutedText); pos(desc,78,37,270,18)
		local owned=text(row,"Owned","OWNED 0",11,T.MutedText,true); pos(owned,78,66,170,21)
		local buy=button(row,"Buy","",T.Panel); buy.TextSize=13
		v.Rows[def.Id]={Frame=row,Name=name,Desc=desc,Owned=owned,Buy=buy,Stroke=lineStroke,Definition=def}
	end
	v.Rebirth=button(shop,"Rebirth","",T.AccentAlt:Lerp(T.Panel,.8)); outline(v.Rebirth,T.AccentAlt,.55)
	v.RebirthTitle=text(v.Rebirth,"Title",Config.Prestige.ButtonName,14,T.AccentAlt,true)
	v.RebirthCost=text(v.Rebirth,"Cost","1M EN",12,T.AccentAlt,true,Enum.TextXAlignment.Right)

	local worlds=frame(canvas,"Worlds",T.Panel,22); outline(worlds,T.Border,.35); v.Worlds=worlds
	v.WorldTitle=text(worlds,"Title",T.WorldTitle or "WORLDS",12,nil,true)
	v.WorldProgress=text(worlds,"Progress","1 / "..#Config.Zones,11,T.MutedText,true,Enum.TextXAlignment.Right)
	v.WorldBack=button(worlds,"Previous","<"); v.WorldNext=button(worlds,"Next",">")
	v.WorldList=scroll(worlds,"List",true)
	v.WorldLayout=make("UIListLayout",v.WorldList,"Layout",{FillDirection=Enum.FillDirection.Horizontal,Padding=UDim.new(0,10),SortOrder=Enum.SortOrder.LayoutOrder})
	for i,z in ipairs(Config.Zones) do
		local b=button(v.WorldList,z.Id,""); b.LayoutOrder=i
		local lineStroke=outline(b,T.Border,.5)
		local ball=circle(b,"MiniPlanet",36,z.Color); pos(ball,12,16,36,36); make("UIGradient",ball,"Gradient",{Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(80,90,130)),Rotation=40})
		local n=text(b,"Name",z.Name,14,nil,true); pos(n,60,10,145,24)
		local status=text(b,"Status","",11,T.MutedText,true); pos(status,60,37,145,18)
		v.Zones[z.Id]={Button=b,Status=status,Stroke=lineStroke,Definition=z}
	end
	v.Goal=text(worlds,"Goal","",11,T.MutedText,true)
	v.GoalAmount=text(worlds,"GoalAmount","",11,T.MutedText,true,Enum.TextXAlignment.Right)
	v.GoalTrack=frame(worlds,"GoalTrack",T.PanelRaised,3); v.GoalFill=frame(v.GoalTrack,"Fill",T.Accent,3)
	local nav=clear(canvas,"MobileTabs"); v.MobileNav=nav
	for _,name in ipairs({"Collect","Upgrades","Worlds"}) do v.MobileTabs[name]=button(nav,name,name) end

	local descriptions={Research="Spend "..string.lower(Config.Currency.Name).." on stronger clicks, production, and logistics. Research resets on rebirth.",
		Expeditions="Send a crew, keep playing, then collect its cargo. One expedition can travel at a time.",
		Journal="Collect one-time achievements and daily rewards. Daily objectives reset at midnight UTC.",
		Ascension="Rebirth for stars. Permanent upgrades and unlocked worlds survive every fresh start."}
	for _,page in ipairs({"Research","Expeditions","Journal","Ascension"}) do
		local panel=frame(canvas,page,T.Panel,22); outline(panel,T.Border,.35); v.Panels[page]=panel
		local title=text(panel,"Title",string.upper(page),24,nil,true)
		local sub=text(panel,"Subtitle",descriptions[page],13,T.MutedText); sub.TextWrapped=true
		local list=scroll(panel,"List")
		local grid=make("UIGridLayout",list,"Grid",{CellPadding=UDim2.fromOffset(12,12),SortOrder=Enum.SortOrder.LayoutOrder})
		v.Cards[page]={}; v[page.."List"]=list; v[page.."Grid"]=grid
		local defs=page=="Ascension" and Progression.Permanent or page=="Journal" and Progression.Achievements or Progression[page]
		local function card(def,kind,index)
			local row=frame(list,kind..def.Id,T.PanelRaised,14); row.LayoutOrder=index; outline(row,T.Border,.15)
			local n=text(row,"Name",def.Name,17,nil,true)
			local detail=text(row,"Detail",def.Description or "",12,T.MutedText); detail.TextWrapped=true
			local status=text(row,"Status","",12,T.AccentAlt,true)
			local reward=text(row,"Reward","",12,T.MutedText)
			local buy=button(row,"Action","",T.Accent); buy.TextColor3=T.Background; buy.TextSize=12
			local track=frame(row,"Track",T.Panel,3); local fill=frame(track,"Fill",T.Accent,3)
			v.Cards[page][kind..def.Id]={Frame=row,Name=n,Detail=detail,Status=status,Reward=reward,Button=buy,Track=track,Fill=fill,Definition=def,Kind=kind,Id=def.Id}
		end
		for i,def in ipairs(defs) do card(def,page=="Ascension" and "Permanent" or page=="Journal" and "Achievement" or page=="Expeditions" and "Expedition" or "Research",i) end
		if page=="Journal" then for i,def in ipairs(Progression.Daily) do card(def,"Daily",i) end end
		pos(title,24,16,500,34); pos(sub,24,54,1000,36)
	end
	v.JournalButtons={Achievements=button(v.Panels.Journal,"Achievements","ACHIEVEMENTS"),Daily=button(v.Panels.Journal,"Daily","DAILY GOALS")}
	v.AscendBanner=frame(v.Panels.Ascension,"RebirthBanner",T.AccentAlt:Lerp(T.Panel,.8),14); outline(v.AscendBanner,T.AccentAlt,.5)
	v.AscendText=text(v.AscendBanner,"Summary","",15,nil,true); v.AscendText.TextWrapped=true
	v.AscendButton=button(v.AscendBanner,"Rebirth",Config.Prestige.ButtonName,T.AccentAlt)
	v.Route=clear(v.Panels.Expeditions,"Route")
	v.RouteTrack=frame(v.Route,"Track",T.Border,3); v.RouteTrack.Position=UDim2.new(.08,0,.5,-2); v.RouteTrack.Size=UDim2.new(.84,0,0,4)
	local home=circle(v.Route,"Home",20,T.Accent); home.Position=UDim2.new(.08,-10,.5,-10)
	local endPoint=circle(v.Route,"Destination",20,T.AccentAlt); endPoint.Position=UDim2.new(.92,-10,.5,-10)
	v.Ship=circle(v.Route,"Ship",16,T.Text); v.Ship.AnchorPoint=Vector2.new(.5,.5); v.Ship.Position=UDim2.fromScale(.08,.5)
	v.RouteLabel=text(v.Route,"Label","Choose an expedition below",12,T.MutedText,false,Enum.TextXAlignment.Center); v.RouteLabel.Position=UDim2.new(0,0,1,-16); v.RouteLabel.Size=UDim2.new(1,0,0,16)

	v.ToastDocked=Config.NotificationPlacement=="BottomRight"
	local toast=frame(gui,"Notification",T.PanelRaised,14); outline(toast,T.Accent,.5); toast.AnchorPoint=v.ToastDocked and Vector2.new(1,1) or Vector2.new(.5,0); toast.Position=v.ToastDocked and UDim2.new(1,-16,1,-12) or UDim2.new(.5,0,0,70); toast.Size=UDim2.fromOffset(370,58); toast.ZIndex=30; toast.Visible=false; v.Toast=toast
	v.ToastText=text(toast,"Text","",14,T.Text,true,Enum.TextXAlignment.Center); v.ToastText.Position=UDim2.fromOffset(12,6); v.ToastText.Size=UDim2.new(1,-24,1,-12); v.ToastText.TextWrapped=true
	local modal=button(gui,"RebirthConfirmation","",Color3.fromRGB(3,6,17)); modal.BackgroundTransparency=.18; modal.Size=UDim2.fromScale(1,1); modal.ZIndex=20; modal.Visible=false; v.Modal=modal
	local dialog=frame(modal,"Dialog",T.Panel,20); dialog.AnchorPoint=Vector2.new(.5,.5); dialog.Position=UDim2.fromScale(.5,.5); dialog.Size=UDim2.fromOffset(340,285); outline(dialog,T.AccentAlt,.3)
	local title=text(dialog,"Title","Ready for a fresh start?",21,nil,true); pos(title,22,20,296,35)
	v.ConfirmDetail=text(dialog,"Detail","",14,T.MutedText); pos(v.ConfirmDetail,22,63,296,120); v.ConfirmDetail.TextWrapped=true
	v.Confirm=button(dialog,"Confirm",Config.Prestige.ButtonName,T.AccentAlt); pos(v.Confirm,22,196,296,40)
	v.Cancel=button(dialog,"Cancel","Keep playing",T.PanelRaised); pos(v.Cancel,22,243,296,28)

	function v:SetPage(page) self.Page=page; self:Layout(self.Viewport) end
	function v:SetPlayPage(page) self.PlayPage=page; self:Layout(self.Viewport) end
	function v:SetFilter(filter) self.JournalFilter=filter; if self.State then self:Render(self.State) end end
	function v:Layout(viewport)
		viewport=viewport or Vector2.new(1280,800); self.Viewport=viewport
		self.Toast.Size=UDim2.fromOffset(math.min(370,viewport.X-32),58)
		local compact=viewport.X<700 or viewport.Y<420 or viewport.X<viewport.Y
		local landscape=compact and viewport.X>viewport.Y; self.Compact=compact; self.Landscape=landscape
		local w,h,s
		if compact then w=landscape and 740 or 430; s=math.min((viewport.X-(landscape and 112 or 32))/w,1.25); h=(viewport.Y-108)/s
		else w,h=1280,720; s=math.min((viewport.X-40)/w,(viewport.Y-88)/h,1.45) end
		canvas.Size=UDim2.fromOffset(w,h); canvas.Position=UDim2.new(.5,0,.5,compact and 15 or 20); scale.Scale=s
		local headerH=compact and (landscape and 76 or 112) or 88
		pos(header,0,0,w,headerH)
		for i,name in ipairs({"Play","Research","Expeditions","Journal","Ascension"}) do
			local start=compact and (landscape and 240 or 0) or 304
			local width=compact and (landscape and w-240 or w) or 680
			pos(self.Nav[name],start+(i-1)*(width/5),compact and (landscape and 0 or 62) or 2,width/5-6,40)
			self.Nav[name].TextSize=compact and 11 or 14; self.Nav[name].BackgroundColor3=self.Page==name and T.Accent or T.PanelRaised; self.Nav[name].TextColor3=self.Page==name and T.Background or T.MutedText
		end
		self.Tagline.Visible=not landscape; self.Title.TextSize=landscape and 23 or 28
		self.Objective.Visible=not (compact and not landscape)
		pos(self.Objective,0,51,compact and 440 or 900,25)
		pos(self.Wallet,w-250,49,110,25); pos(self.SaveStatus,w-132,65,132,16)
		pos(self.Motion,w-130,2,130,35)
		if compact then pos(self.Motion,w-130,32,130,22); self.Motion.TextSize=10; pos(self.Wallet,w-130,4,130,22); self.SaveStatus.Visible=false end
		if landscape then self.Motion.Visible=false; pos(self.Wallet,w-180,47,180,22) else self.Motion.Visible=true end
		if not compact then self.SaveStatus.Visible=true end
		local bodyY=headerH+12; local bodyH=h-bodyY; local playH=bodyH-(compact and 58 or 0)
		if compact then
			pos(scene,0,bodyY,w,playH); pos(shop,0,bodyY,w,playH); pos(worlds,0,bodyY,w,playH)
			pos(nav,0,h-46,w,46)
			for i,name in ipairs({"Collect","Upgrades","Worlds"}) do local b=self.MobileTabs[name]; pos(b,(i-1)*(w+8)/3,0,(w-16)/3,46); b.BackgroundColor3=self.PlayPage==name and T.Accent or T.PanelRaised; b.TextColor3=self.PlayPage==name and T.Background or T.MutedText end
		else pos(scene,0,bodyY,824,438); pos(shop,844,bodyY,436,bodyH); pos(worlds,0,bodyY+456,824,bodyH-456) end
		scene.Visible=self.Page=="Play" and (not compact or self.PlayPage=="Collect"); shop.Visible=self.Page=="Play" and (not compact or self.PlayPage=="Upgrades"); worlds.Visible=self.Page=="Play" and (not compact or self.PlayPage=="Worlds"); nav.Visible=self.Page=="Play" and compact
		local sw=compact and w or 824; local sh=compact and playH or 438
		pos(self.SceneTag,22,13,sw*.55,22); pos(self.Boost,sw*.58,13,sw*.42-22,22)
		local d,cx,cy
		if not compact then
			pos(self.Currency,20,80,310,76); self.Currency.TextSize=70; pos(self.CurrencyName,20,154,310,20); pos(self.Rates,20,182,310,24)
			pos(burst,26,229,298,82); pos(self.SceneObjective,24,326,302,58)
			d,cx,cy=300,575,229; pos(self.TargetHint,370,390,410,24)
		elseif landscape then
			pos(self.Currency,16,30,sw*.44,42); self.Currency.TextSize=38; pos(self.CurrencyName,16,73,sw*.44,17); pos(self.Rates,16,95,sw*.44,20)
			pos(burst,20,sh-46,sw*.43,35); self.SceneObjective.Visible=false
			d=math.max(60,sh-36); cx,cy=sw*.73,sh*.48; pos(self.TargetHint,sw*.5,sh-24,sw*.48,20)
		else
			pos(self.Currency,0,35,sw,58); self.Currency.TextSize=56; pos(self.CurrencyName,0,92,sw,18); pos(self.Rates,0,117,sw,22)
			d=math.min(278,math.max(100,sh-290)); cx,cy=sw/2,sh*.51
			pos(burst,24,sh-100,sw-48,64); pos(self.SceneObjective,20,sh-32,sw-40,25); pos(self.TargetHint,0,sh-133,sw,22)
		end
		if not landscape then self.SceneObjective.Visible=true end
		self.Target.Position=UDim2.fromOffset(cx,cy); self.Target.Size=UDim2.fromOffset(d,d); self.Diameter=d; self.ArtScale.Scale=d/300
		pos(self.Orbit,cx-d*.78,cy-d*.21,d*1.56,d*.5)
		local bw=burst.Size.X.Offset
		pos(self.BurstTitle,12,landscape and 1 or 9,bw-96,18); pos(self.BurstCount,bw-94,landscape and 1 or 9,82,18)
		pos(self.BurstTrack,12,landscape and 24 or 34,bw-24,6); pos(self.BurstNote,12,landscape and 48 or compact and 46 or 48,bw-24,compact and 14 or 23); self.BurstNote.Visible=not landscape
		self.Comet.Size=UDim2.fromOffset(116,38); self.Comet.Position=UDim2.fromOffset(compact and 78 or 390,landscape and 45 or 75)
		local shopW=compact and w or 436; local shopH=compact and playH or bodyH
		pos(self.ShopTitle,20,16,shopW-40,25); pos(self.ShopSub,20,44,shopW-40,20)
		for i,q in ipairs({1,10,"Max"}) do pos(self.QuantityButtons[q],16+(i-1)*(shopW-24)/3,72,(shopW-40)/3,28) end
		pos(self.List,15,111,shopW-30,math.max(25,shopH-176)); pos(self.Rebirth,16,shopH-52,shopW-32,36)
		pos(self.RebirthTitle,12,5,170,25); pos(self.RebirthCost,shopW-182,5,130,25)
		if landscape then self.ShopSub.Visible=false; pos(self.ShopTitle,18,10,230,26); for i,q in ipairs({1,10,"Max"}) do pos(self.QuantityButtons[q],shopW-290+(i-1)*90,9,84,28) end; pos(self.List,15,46,shopW-30,shopH-55); self.Rebirth.Visible=false else self.ShopSub.Visible=true; self.Rebirth.Visible=not self.State or self.State.PrestigeEnabled end
		for _,r in pairs(self.Rows) do pos(r.Buy,shopW-145,62,94,28) end
		local ww=compact and w or 824; local wh=compact and playH or bodyH-456
		pos(self.WorldTitle,22,13,ww-270,24); pos(self.WorldProgress,ww-240,13,134,24)
		pos(self.WorldBack,ww-94,9,32,32); pos(self.WorldNext,ww-56,9,32,32)
		pos(self.WorldList,20,46,ww-40,math.max(35,wh-93))
		local vertical=compact and not landscape
		self.WorldLayout.FillDirection=vertical and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
		self.WorldList.AutomaticCanvasSize=vertical and Enum.AutomaticSize.Y or Enum.AutomaticSize.X; self.WorldList.ScrollingDirection=vertical and Enum.ScrollingDirection.Y or Enum.ScrollingDirection.X
		for _,r in pairs(self.Zones) do r.Button.Size=vertical and UDim2.new(1,-5,0,70) or UDim2.fromOffset(220,66) end
		pos(self.Goal,22,wh-37,ww*.6,18); pos(self.GoalAmount,ww*.58,wh-37,ww*.42-22,18); pos(self.GoalTrack,22,wh-14,ww-44,4)
		for page,panel in pairs(self.Panels) do
			pos(panel,0,bodyY,w,bodyH); panel.Visible=self.Page==page
			pos(panel.Title,24,16,w-48,33); pos(panel.Subtitle,24,53,w-48,34)
			local top=page=="Journal" and 130 or page=="Ascension" and 186 or page=="Expeditions" and 160 or 99
			if landscape then panel.Subtitle.Visible=false; top=page=="Journal" and 91 or page=="Ascension" and 115 or page=="Expeditions" and 104 or 58 else panel.Subtitle.Visible=true end
			local list=self[page.."List"]; pos(list,22,top,w-44,math.max(30,bodyH-top-20))
			local columns=(compact and not landscape) and 1 or page=="Expeditions" and 3 or 2
			local height=landscape and 100 or page=="Expeditions" and 154 or 126; local cw=(w-44-12*(columns-1)-6)/columns
			self[page.."Grid"].CellSize=UDim2.fromOffset(cw,height)
			for _,r in pairs(self.Cards[page]) do
				pos(r.Name,16,12,cw-32,24); pos(r.Detail,16,39,cw-32,32); pos(r.Status,16,page=="Expeditions" and 77 or 74,cw-130,22)
				pos(r.Reward,16,page=="Expeditions" and 102 or 96,cw-125,20); pos(r.Button,cw-116,height-45,100,30)
				pos(r.Track,16,height-7,cw-32,3)
				r.Detail.Visible=not landscape or page=="Journal"; r.Name.TextSize=landscape and 15 or 17
				if landscape then
					pos(r.Name,16,6,cw-32,22)
					pos(r.Detail,16,30,cw-32,20)
					pos(r.Status,16,page=="Journal" and 65 or 33,cw-32,20)
					pos(r.Reward,16,64,cw-130,20)
					pos(r.Button,cw-116,55,100,30)
				end
			end
		end
		pos(self.JournalButtons.Achievements,24,landscape and 52 or 89,(w-60)/2,30); pos(self.JournalButtons.Daily,36+(w-60)/2,landscape and 52 or 89,(w-60)/2,30)
		pos(self.AscendBanner,22,landscape and 52 or 96,w-44,landscape and 52 or 75); pos(self.AscendText,14,5,w-208,landscape and 42 or 65); pos(self.AscendButton,w-177,landscape and 8 or 19,119,34)
		pos(self.Route,24,landscape and 46 or 91,w-48,landscape and 48 or 58)
		if self.State then self:Render(self.State) end
	end
	function v:Render(s)
		self.State=s
		if not self.Animated then self.Currency.Text=Art.Number(s.Currency) end
		self.Rates.Text=Art.Number(s.ClickPower).." / click     +"..Art.Number(s.PassiveRate).." / sec"
		self.Wallet.Text=Art.Number(s.Stars or 0).." STARS"
		self.Objective.Text=s.Objective or T.Mission; self.SceneObjective.Text=s.Objective or T.ClickHint
		self.SaveStatus.Text=s.SaveMode=="Cloud" and "CLOUD SAVING" or s.SaveMode=="Retrying" and "SAVE RETRYING" or "TEMPORARY PROGRESS"
		self.Nav.Journal.Text=(s.Claimable or 0)>0 and "Journal ("..s.Claimable..")" or "Journal"
		for q,b in pairs(self.QuantityButtons) do b.BackgroundColor3=self.Quantity==q and T.Accent or T.PanelRaised; b.TextColor3=self.Quantity==q and T.Background or T.MutedText end
		for id,r in pairs(self.Rows) do
			local u=s.Upgrades[id]; if u then
				local afford=not u.Locked and s.Currency>=u.Cost
				r.Owned.Text="OWNED "..Art.Number(u.Owned); r.Buy.Text=u.Locked and "LOCKED" or self.Quantity==1 and (Art.Number(u.Cost).." "..Config.Currency.ShortName) or "BUY "..(self.Quantity=="Max" and "MAX" or "x10")
				r.Desc.Text=u.Locked and ("Unlock "..u.RequiredWorld.." worlds to access") or (Config.UpgradePresentation[id] or {}).Description or ""
				r.Buy.BackgroundColor3=afford and T.Accent or T.Panel; r.Buy.TextColor3=afford and T.Background or T.MutedText; r.Stroke.Color=afford and T.Accent or T.Border; r.Stroke.Transparency=afford and .65 or .2
			end
		end
		local unlocked,nextZone=0,nil
		for i,z in ipairs(s.Zones) do
			local r=self.Zones[z.Id]
			if z.Unlocked then unlocked+=1 elseif not nextZone then nextZone=z end
			if r then r.Status.Text=z.Current and "ACTIVE / x"..z.Multiplier or z.Unlocked and "TRAVEL / x"..z.Multiplier or Art.Number(z.UnlockCost).." "..Config.Currency.ShortName; r.Status.TextColor3=z.Current and T.Accent or T.MutedText; r.Stroke.Color=z.Current and T.Accent or T.Border end
			if z.Current then
				self.SceneTag.Text=string.format("%02d / %s",i,string.upper(z.Name)); self.Boost.Text="x"..z.Multiplier.." WORLD BOOST"
				if self.CurrentZone~=z.Id then self.CurrentZone=z.Id; self.Art:Destroy(); self.Art,self.ArtScale=Art.Planet(target,r.Definition); self.ArtScale.Scale=(self.Diameter or 300)/300 end
			end
		end
		self.WorldProgress.Text=unlocked.." / "..#Config.Zones.." WORLDS"
		self.Goal.Text=nextZone and "NEXT: "..string.upper(nextZone.Name) or T.AllWorldsText
		self.GoalAmount.Text=nextZone and Art.Number(s.Currency).." / "..Art.Number(nextZone.UnlockCost).." "..Config.Currency.ShortName or "ALL UNLOCKED"
		self.GoalFill.Size=UDim2.new(nextZone and math.clamp(s.Currency/nextZone.UnlockCost,0,1) or 1,0,1,0)
		self.RebirthCost.Text=s.CanPrestige and "+"..Art.Number(s.RebirthGain).." STARS >" or Art.Number(s.PrestigeCost).." "..Config.Currency.ShortName
		self.AscendText.Text=""..Art.Number(s.Stars or 0).." stars available\n"..(s.CanPrestige and "Rebirth now for +"..Art.Number(s.RebirthGain).." stars" or "Rebirth unlocks at "..Art.Number(s.PrestigeCost).." "..Config.Currency.ShortName)
		self.AscendButton.BackgroundColor3=s.CanPrestige and T.AccentAlt or T.PanelRaised
		self.ConfirmDetail.Text="Gain "..Art.Number(s.RebirthGain or 1).." stars and +"..Art.Number(Config.Prestige.MultiplierPerPrestige*100).."% production.\n\n"..Config.Currency.Name..", producers and research reset. Worlds, achievements, stars and permanent upgrades stay yours."
		for _,kind in ipairs({"Research","Permanent","Expeditions","Achievements","Daily"}) do
			local page=kind=="Permanent" and "Ascension" or (kind=="Achievements" or kind=="Daily") and "Journal" or kind
			for _,item in ipairs(s[kind] or {}) do
				local key=(kind=="Expeditions" and "Expedition" or kind=="Achievements" and "Achievement" or kind)..item.Id
				local r=self.Cards[page][key]
				if r then
					r.Item=item
					if kind=="Research" or kind=="Permanent" then
						local max=item.Level>=item.Max; local wallet=kind=="Permanent" and (s.Stars or 0) or s.Currency; local afford=not max and wallet>=item.Cost
						r.Status.Text="LEVEL "..item.Level.." / "..item.Max; r.Reward.Text=max and "Fully upgraded" or Art.Number(item.Cost)..(kind=="Permanent" and " STARS" or " "..Config.Currency.ShortName)
						r.Button.Text=max and "MAXED" or "UPGRADE"; r.Button.BackgroundColor3=afford and T.Accent or T.Panel; r.Button.TextColor3=afford and T.Background or T.MutedText; r.Fill.Size=UDim2.new(item.Level/item.Max,0,1,0)
					elseif kind=="Expeditions" then
						r.Status.Text="REWARD "..Art.Number(item.Reward).." "..Config.Currency.ShortName; r.Reward.Text=formatTime(item.Duration).." / COST "..Art.Number(item.Cost); r.Button.Text=item.Locked and "LOCKED" or "SEND CREW"
						r.Button.BackgroundColor3=not item.Locked and not s.Expedition and s.Currency>=item.Cost and T.Accent or T.Panel; r.Button.TextColor3=T.Text
					else
						r.Frame.Visible=self.JournalFilter==kind; r.Detail.Text=Art.Number(item.Progress).." / "..Art.Number(item.Goal)
						r.Status.Text=item.Stars>0 and "+"..item.Stars.." STARS" or "+"..Art.Number(item.Energy).." "..Config.Currency.ShortName
						r.Button.Text=item.Claimed and "COLLECTED" or item.Ready and "CLAIM" or "IN PROGRESS"; r.Button.BackgroundColor3=item.Ready and T.Accent or T.Panel; r.Button.TextColor3=item.Ready and T.Background or T.MutedText
						r.Fill.Size=UDim2.new(math.clamp(item.Progress/item.Goal,0,1),0,1,0)
					end
				end
			end
		end
		for kind,b in pairs(self.JournalButtons) do b.BackgroundColor3=self.JournalFilter==kind and T.Accent or T.PanelRaised; b.TextColor3=self.JournalFilter==kind and T.Background or T.MutedText end
	end
	v:Layout(Vector2.new(1280,800))
	local initial={Currency=0,ClickPower=Config.BaseClickPower,PassiveRate=0,Stars=0,PrestigeCost=Config.Prestige.BaseRequirement,PrestigeEnabled=Config.Prestige.Enabled,RebirthGain=1,CanPrestige=false,Upgrades={},Zones={},SaveMode="Temporary",Objective="First goal: buy "..(Config.UpgradePresentation[Catalog[1].Id].Name)}
	for _,d in ipairs(Catalog) do initial.Upgrades[d.Id]={Owned=0,Cost=d.BaseCost,Locked=(d.RequiredWorld or 1)>1,RequiredWorld=d.RequiredWorld or 1} end
	for i,z in ipairs(Config.Zones) do initial.Zones[i]={Id=z.Id,Name=z.Name,UnlockCost=z.UnlockCost,Multiplier=z.Multiplier,Unlocked=i==1,Current=i==1} end
	v:Render(initial)
	return v
end
return UI
]====])
setSource("ReplicatedStorage.ClickerKit.ProgressionCatalog","ModuleScript",[====[
-- Theme-independent progression. IDs are stable save keys.
return {
	Burst = {Clicks = 20, Duration = 6, Multiplier = 3},
	Collectible = {FirstDelay = 20, Interval = 55, Lifetime = 10},
	Offline = {Hours = 2, Efficiency = .5},
	Research = {
		{Id="Focus",Name="Focused clicks",Description="+20% click power per level",Cost=100,Growth=1.9,Max=10},
		{Id="Efficiency",Name="Efficient production",Description="+15% passive income per level",Cost=250,Growth=1.9,Max=10},
		{Id="Discount",Name="Bulk buying",Description="2% cheaper producers per level",Cost=500,Growth=2.1,Max=10},
		{Id="Logistics",Name="Better logistics",Description="+15% expedition rewards per level",Cost=1000,Growth=2,Max=10},
		{Id="Capacity",Name="Boost capacity",Description="+0.75 seconds of boost per level",Cost=2500,Growth=2.2,Max=8},
		{Id="Storage",Name="Offline storage",Description="+30 minutes of offline production per level",Cost=5000,Growth=2.2,Max=6},
	},
	Permanent = {
		{Id="Mastery",Name="Production mastery",Description="Permanent +10% to all production",Cost=1,Growth=1.45,Max=25},
		{Id="Touch",Name="Expert touch",Description="Permanent +25% click power",Cost=2,Growth=1.5,Max=15},
		{Id="Automation",Name="Automation",Description="Permanent +20% passive income",Cost=2,Growth=1.5,Max=15},
		{Id="Cargo",Name="Valuable cargo",Description="Permanent +25% expedition rewards",Cost=3,Growth=1.6,Max=10},
		{Id="Power",Name="Lasting power",Description="Permanent +1 second of boost",Cost=3,Growth=1.6,Max=10},
		{Id="Clock",Name="Time bank",Description="Permanent +1 hour of offline capacity",Cost=4,Growth=1.7,Max=8},
	},
	Expeditions = {
		{Id="Scout",Name="Quick delivery",Description="A quick trip with a quick return.",Duration=30,Cost=50,Reward=150,IncomeSeconds=10,World=1},
		{Id="Survey",Name="Supply run",Description="Build a steady stream of useful supplies.",Duration=120,Cost=500,Reward=1800,IncomeSeconds=90,World=2},
		{Id="Deep",Name="Long haul",Description="Send a crew on a valuable long-distance trip.",Duration=600,Cost=10000,Reward=100000,IncomeSeconds=600,World=3},
	},
	Achievements = {
		{Id="Click10",Name="First steps",Metric="Clicks",Goal=10,Energy=15},
		{Id="Click50",Name="Getting into rhythm",Metric="Clicks",Goal=50,Energy=75},
		{Id="Click250",Name="A busy pair of hands",Metric="Clicks",Goal=250,Energy=500},
		{Id="Click1000",Name="Click specialist",Metric="Clicks",Goal=1000,Stars=2},
		{Id="Click10000",Name="Unstoppable",Metric="Clicks",Goal=10000,Stars=10},
		{Id="Own5",Name="A small operation",Metric="Owned",Goal=5,Energy=150},
		{Id="Own25",Name="Scaling up",Metric="Owned",Goal=25,Stars=2},
		{Id="Own100",Name="Industrial strength",Metric="Owned",Goal=100,Stars=5},
		{Id="Earn1K",Name="First thousand",Metric="Earned",Goal=1000,Energy=250},
		{Id="Earn100K",Name="Six figures",Metric="Earned",Goal=100000,Stars=2},
		{Id="Earn10M",Name="A serious empire",Metric="Earned",Goal=10000000,Stars=4},
		{Id="Earn1B",Name="Billionaire",Metric="Earned",Goal=1000000000,Stars=8},
		{Id="World3",Name="Beyond the beginning",Metric="Worlds",Goal=3,Stars=3},
		{Id="World6",Name="A wider horizon",Metric="Worlds",Goal=6,Stars=6},
		{Id="Trips5",Name="Frequent traveler",Metric="Trips",Goal=5,Stars=3},
		{Id="Rebirth1",Name="A fresh start",Metric="Rebirths",Goal=1,Stars=2},
	},
	Daily = {
		{Id="DailyClicks",Name="Make 100 clicks",Metric="Clicks",Goal=100,Energy=50,IncomeSeconds=10},
		{Id="DailyBuy",Name="Buy 10 producers",Metric="Purchases",Goal=10,Energy=100,IncomeSeconds=20},
		{Id="DailyTrip",Name="Complete an expedition",Metric="Trips",Goal=1,Energy=200,IncomeSeconds=30},
	},
}
]====])
setSource("ReplicatedStorage.ClickerKit.ThemeConfig","ModuleScript",[====[
-- ORBIT is a standalone Space game.
return require(script.Parent.Themes:WaitForChild("Space"))
]====])
setSource("ReplicatedStorage.ClickerKit.Themes.Bakery","ModuleScript",[====[
-- A second theme using exactly the same server, UI and upgrade balance.
local function copy(value)
	if type(value) ~= "table" then return value end
	local result = {}
	for key, item in pairs(value) do result[key] = copy(item) end
	return result
end
local Config = copy(require(script.Parent.Space))
local C = Color3.fromRGB
Config.GameTitle = "CRUMBLE"
Config.Tagline = "COOKIE CLICKER"
Config.DataStoreName = "CrumbleClicker_v1"
Config.Currency = {Name = "Cookies", ShortName = "CK"}
Config.Theme = {
	Background = C(29,18,25), Panel = C(47,29,38), PanelRaised = C(65,42,49),
	Accent = C(255,205,120), AccentAlt = C(238,159,182),
	Text = C(255,245,229), MutedText = C(187,158,160), Border = C(100,68,77),
	SkyTop = C(48,29,42), SkyBottom = C(78,41,47),
	TargetName = "Cookie", TargetImageId = "", ClickPrompt = "CLICK THE COOKIE", ShowOrbit = false,
	ClickHint = "A little dough goes a long way.", Mission = "BAKE YOUR WAY TO A COOKIE EMPIRE",
	WorldTitle = "GROW YOUR BAKERY", ShopSubtitle = "Fresh upgrades. More cookies.",
	ShopTip = "Hire a baker to keep producing between clicks.", AllWorldsText = "YOUR BAKERY EMPIRE IS COMPLETE",
	BurstName="SUGAR RUSH", CollectibleName="GOLDEN CRUMB", CollectorStyle="Cookie",
}
Config.UpgradePresentation = {
	TapCoil = {Name = "Better recipe", Description = "+1 cookie per click", Icon = "Bolt", Color = C(255,205,120)},
	MiniDrones = {Name = "Helpful baker", Description = "+1 cookie per second", Icon = "Drone", Color = C(238,159,182)},
	SolarArray = {Name = "Cookie oven", Description = "+8 cookies per second", Icon = "Solar", Color = C(255,178,109)},
	OrbitalFleet = {Name = "Cookie factory", Description = "+55 cookies per second", Icon = "Satellite", Color = C(184,160,255)},
	Reactor={Name="Mixing station",Description="+150 cookies per second",Icon="Solar",Color=C(255,200,109)},
	LunarMine={Name="Chocolate lab",Description="+1K cookies per second",Icon="Satellite",Color=C(199,207,230)},
	FusionLab={Name="Confectionery",Description="+6K cookies per second",Icon="Bolt",Color=C(255,145,113)},
	DysonArray={Name="Cookie city",Description="+40K cookies per second",Icon="Solar",Color=C(255,214,135)},
	StarForge={Name="Sugar foundry",Description="+250K cookies per second",Icon="Bolt",Color=C(255,170,111)},
	NebulaHarvester={Name="Dream bakery",Description="+1.5M cookies per second",Icon="Drone",Color=C(189,148,255)},
	QuantumGate={Name="Cookie portal",Description="+10M cookies per second",Icon="Satellite",Color=C(103,213,255)},
	UniverseEngine={Name="Infinite oven",Description="+60M cookies per second",Icon="Solar",Color=C(172,242,111)},
}
Config.Zones = {
	{Id="Home",Name="Home bakery",UnlockCost=0,Multiplier=1,Art="Cookie",Color=C(255,205,120)},
	{Id="Shop",Name="Cookie shop",UnlockCost=1200,Multiplier=2,Art="Cookie",Color=C(238,159,182)},
	{Id="Factory",Name="Factory",UnlockCost=40000,Multiplier=3,Art="Cookie",Color=C(255,178,109)},
	{Id="City",Name="Cookie city",UnlockCost=1200000,Multiplier=4,Art="Cookie",Color=C(249,199,141)},
	{Id="Kingdom",Name="Sugar kingdom",UnlockCost=35000000,Multiplier=5,Art="Cookie",Color=C(255,171,211)},
	{Id="Dream",Name="Dream bakery",UnlockCost=1000000000,Multiplier=6,Art="Cookie",Color=C(184,160,255)},
	{Id="Galaxy",Name="Cookie galaxy",UnlockCost=30000000000,Multiplier=8,Art="Cookie",Color=C(255,215,117)},
	{Id="Infinity",Name="Infinite bakery",UnlockCost=300000000000,Multiplier=10,Art="Cookie",Color=C(173,240,209)},
}
return Config
]====])
setSource("ReplicatedStorage.ClickerKit.Themes.Space","ModuleScript",[====[
-- SPACE PRESET: edit art, copy, colors and worlds here. Economy lives in UpgradeCatalog.
local C = Color3.fromRGB
return {
	Version = 1,
	GameTitle = "ORBIT",
	Tagline = "ENERGY CLICKER",
	NotificationPlacement = "BottomRight",
	DataStoreName = "OrbitEnergyClicker_v1",
	AutoSaveSeconds = 60,
	ClickCooldown = 0.075,
	MaximumCurrency = 1e18,
	BaseClickPower = 1,
	Currency = {Name = "Energy", ShortName = "EN"},
	Theme = {
		Background = C(9, 12, 29), Panel = C(18, 24, 47), PanelRaised = C(28, 37, 65),
		Accent = C(172, 242, 111), AccentAlt = C(154, 143, 255),
		Text = C(241, 245, 255), MutedText = C(143, 157, 186),
		Border = C(48, 62, 93), SkyTop = C(13, 24, 47), SkyBottom = C(31, 24, 63),
		TargetName = "Earth", TargetImageId = "", -- Optional transparent Roblox image for any theme.
		ClickPrompt = "CLICK THE PLANET", ClickHint = "Every click starts something bigger.",
		Mission = "BUILD A LITTLE ENERGY EMPIRE", WorldTitle = "THE NEXT FRONTIER",
		ShopSubtitle = "Small upgrades. Bigger possibilities.", ShopTip = "Buy a drone to keep earning between clicks.",
		AllWorldsText = "THE UNIVERSE IS YOURS",
		BurstName = "OVERDRIVE", CollectibleName = "COMET", CollectorStyle = "Drone",
	},
	UpgradePresentation = {
		TapCoil = {Name = "Tap amplifier", Description = "+1 energy per click", Icon = "Bolt", Color = C(172, 242, 111)},
		MiniDrones = {Name = "Collector drone", Description = "+1 energy per second", Icon = "Drone", Color = C(103, 213, 255)},
		SolarArray = {Name = "Solar array", Description = "+8 energy per second", Icon = "Solar", Color = C(255, 200, 109)},
		OrbitalFleet = {Name = "Orbital fleet", Description = "+55 energy per second", Icon = "Satellite", Color = C(184, 160, 255)},
		Reactor = {Name="Orbital reactor",Description="+150 energy per second",Icon="Solar",Color=C(255,200,109)},
		LunarMine = {Name="Lunar mine",Description="+1K energy per second",Icon="Satellite",Color=C(199,207,230)},
		FusionLab = {Name="Fusion lab",Description="+6K energy per second",Icon="Bolt",Color=C(255,145,113)},
		DysonArray = {Name="Dyson array",Description="+40K energy per second",Icon="Solar",Color=C(255,214,135)},
		StarForge = {Name="Star forge",Description="+250K energy per second",Icon="Bolt",Color=C(255,170,111)},
		NebulaHarvester = {Name="Nebula harvester",Description="+1.5M energy per second",Icon="Drone",Color=C(189,148,255)},
		QuantumGate = {Name="Quantum gate",Description="+10M energy per second",Icon="Satellite",Color=C(103,213,255)},
		UniverseEngine = {Name="Universe engine",Description="+60M energy per second",Icon="Solar",Color=C(172,242,111)},
	},
	-- Art = Earth, Moon, Mars, Gas, Ice, Sun, Void or Cookie; ImageId overrides the built-in 2D illustration.
	Zones = {
		{Id = "Earth", Name = "Earth", Subtitle = "The pale blue beginning", UnlockCost = 0, Multiplier = 1, Art = "Earth", Color = C(93, 207, 255)},
		{Id = "Moon", Name = "Moon", Subtitle = "A giant leap in production", UnlockCost = 1200, Multiplier = 2, Art = "Moon", Color = C(199, 207, 230)},
		{Id = "Mars", Name = "Mars", Subtitle = "Your next frontier", UnlockCost = 40000, Multiplier = 3, Art = "Mars", Color = C(255, 145, 113)},
		{Id="Jupiter",Name="Jupiter",UnlockCost=1200000,Multiplier=4,Art="Gas",Color=C(244,191,136)},
		{Id="Saturn",Name="Saturn",UnlockCost=35000000,Multiplier=5,Art="Gas",Rings=true,Color=C(234,215,157)},
		{Id="Neptune",Name="Neptune",UnlockCost=1000000000,Multiplier=6,Art="Ice",Color=C(112,151,255)},
		{Id="Nova",Name="Nova",UnlockCost=30000000000,Multiplier=8,Art="Sun",Color=C(255,174,91)},
		{Id="Singularity",Name="Singularity",UnlockCost=300000000000,Multiplier=10,Art="Void",Color=C(201,144,255)},
	},
	Prestige = {Enabled = true, ButtonName = "Rebirth", BaseRequirement = 1000000, RequirementMultiplier = 4, MultiplierPerPrestige = 0.25},
}
]====])
setSource("ReplicatedStorage.ClickerKit.UIBuilder","ModuleScript",[====[
-- Stable entry point for the template preview and game client.
return require(script.Parent.Interface)
]====])
setSource("ReplicatedStorage.ClickerKit.UpgradeCatalog","ModuleScript",[====[
-- Balance data only. ThemeConfig supplies player-facing names and descriptions.
return {
	{
		Id = "TapCoil",
		BaseCost = 15,
		CostMultiplier = 1.35,
		ClickBonus = 1,
		PassivePerSecond = 0,
	},
	{
		Id = "MiniDrones",
		BaseCost = 35,
		CostMultiplier = 1.20,
		ClickBonus = 0,
		PassivePerSecond = 1,
	},
	{
		Id = "SolarArray",
		BaseCost = 240,
		CostMultiplier = 1.20,
		ClickBonus = 0,
		PassivePerSecond = 8,
	},
	{
		Id = "OrbitalFleet",
		BaseCost = 1800,
		CostMultiplier = 1.20,
		ClickBonus = 0,
		PassivePerSecond = 55,
	},
	{Id="Reactor",BaseCost=15000,CostMultiplier=1.18,ClickBonus=0,PassivePerSecond=150,RequiredWorld=2},
	{Id="LunarMine",BaseCost=180000,CostMultiplier=1.18,ClickBonus=0,PassivePerSecond=1000,RequiredWorld=2},
	{Id="FusionLab",BaseCost=2400000,CostMultiplier=1.18,ClickBonus=0,PassivePerSecond=6000,RequiredWorld=3},
	{Id="DysonArray",BaseCost=35000000,CostMultiplier=1.18,ClickBonus=0,PassivePerSecond=40000,RequiredWorld=4},
	{Id="StarForge",BaseCost=550000000,CostMultiplier=1.18,ClickBonus=0,PassivePerSecond=250000,RequiredWorld=5},
	{Id="NebulaHarvester",BaseCost=9000000000,CostMultiplier=1.18,ClickBonus=0,PassivePerSecond=1500000,RequiredWorld=6},
	{Id="QuantumGate",BaseCost=160000000000,CostMultiplier=1.18,ClickBonus=0,PassivePerSecond=10000000,RequiredWorld=7},
	{Id="UniverseEngine",BaseCost=3000000000000,CostMultiplier=1.18,ClickBonus=0,PassivePerSecond=60000000,RequiredWorld=8},
}
]====])
setSource("ServerScriptService.ClickerTemplate.ClickerServer","Script",[====[
-- Server-authoritative progression and session-owned persistence.
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local DataStoreService=game:GetService("DataStoreService")
local HttpService=game:GetService("HttpService")
local RunService=game:GetService("RunService")
local Kit=ReplicatedStorage:WaitForChild("ClickerKit")
local Config=require(Kit:WaitForChild("ThemeConfig"))
local Catalog=require(Kit:WaitForChild("UpgradeCatalog"))
local Progression=require(Kit:WaitForChild("ProgressionCatalog"))
local Economy=require(script.Parent:WaitForChild("Economy")).new(Config,Catalog,Progression)
local Remotes=Kit:WaitForChild("Remotes")
local ActionRemote=Remotes:FindFirstChild("RequestAction") or Instance.new("RemoteEvent")
ActionRemote.Name="RequestAction"; ActionRemote.Parent=Remotes
local StateUpdate=Remotes:WaitForChild("StateUpdate")
local Profiles,SaveModes,Writable,Saving,Loading,LastAction,LastSnapshot={},{},{},{},{},{},{}
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
 if stats then stats[Config.Currency.Name].Value=d.Currency; stats.Rebirths.Value=d.Prestiges end
 StateUpdate:FireClient(player,Economy:Snapshot(d,clock(),SaveModes[player] or "Temporary"))
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
 while Saving[player] do task.wait(.1); if Profiles[player]~=d or os.clock()-started>20 then return end end
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
 if canSave then Economy:Offline(d,now) end
 Profiles[player]=d; Writable[player]=canSave; SaveModes[player]=canSave and "Cloud" or "Temporary"; Loading[player]=nil
 local old=player:FindFirstChild("leaderstats"); if old then old:Destroy() end
 local stats=Instance.new("Folder"); stats.Name="leaderstats"
 local currency=Instance.new("NumberValue"); currency.Name=Config.Currency.Name; currency.Parent=stats
 local rebirths=Instance.new("IntValue"); rebirths.Name="Rebirths"; rebirths.Parent=stats
 stats.Parent=player; sync(player)
end
local function action(player,kind,id,quantity)
 local d=Profiles[player]; if not d or type(kind)~="string" then return end
 local now=clock()
 LastAction[player]=LastAction[player] or {}
 local bucket=kind=="Click" and "Click" or "Other"
 if now-(LastAction[player][bucket] or 0)<(kind=="Click" and Config.ClickCooldown or .12) then return end
 LastAction[player][bucket]=now
 local ok,message=Economy:Action(d,kind,id,quantity,now)
 if not ok and message then Economy:Notice(d,message,"Error") end
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
 Profiles[p]=nil; Writable[p]=nil; SaveModes[p]=nil; LastAction[p]=nil; LastSnapshot[p]=nil; Closing[p]=nil
end)
task.spawn(function()
 local previous=clock(); local lastSync=previous
 while task.wait(.25) do
  local now=clock(); local dt=now-previous; previous=now
  for p,d in pairs(Profiles) do if p.Parent then Economy:Tick(d,now,dt) end end
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
]====])
setSource("ServerScriptService.ClickerTemplate.Economy","ModuleScript",[====[
-- Deterministic economy. All actions receive server time; clients never supply rewards.
local Economy = {}
Economy.__index = Economy
local function number(v, fallback, max)
	if type(v)~="number" or v~=v or v==math.huge or v==-math.huge then return fallback or 0 end
	return math.clamp(v,0,max or 1e18)
end
local function count(v,max) return math.floor(number(v,0,max or 1000000)) end
local function clone(t) local r={}; for k,v in pairs(t or {}) do r[k]=type(v)=="table" and clone(v) or v end; return r end
local function find(list,id) for _,v in ipairs(list) do if v.Id==id then return v end end end
function Economy.new(config,catalog,progression)
	return setmetatable({Config=config,Catalog=catalog,P=progression},Economy)
end
function Economy:New(now)
	return {Currency=0,LifetimeCurrency=0,RunEarned=0,TotalClicks=0,LifetimePurchases=0,TotalExpeditions=0,
		Upgrades={},Research={},Permanent={},ClaimedAchievements={},UnlockedZones={[self.Config.Zones[1].Id]=true},
		CurrentZone=self.Config.Zones[1].Id,Prestiges=0,Stars=0,Expedition=nil,LastSeen=now,
		Daily={Day=math.floor(now/86400),Baseline={Clicks=0,Purchases=0,Trips=0},Claimed={}},
		Runtime={Charge=0,BurstEndsAt=0,EventEndsAt=0,EventNextAt=now+self.P.Collectible.FirstDelay,EventNonce=0,
			NoticeSerial=0,Notice="",NoticeKind="",OfflineEarned=0,OfflineSeconds=0}}
end
function Economy:Normalize(saved,now)
	local d=self:New(now)
	if type(saved)~="table" then return d end
	for _,k in ipairs({"Currency","LifetimeCurrency","RunEarned","Stars"}) do d[k]=number(saved[k],0,self.Config.MaximumCurrency) end
	for _,k in ipairs({"TotalClicks","LifetimePurchases","TotalExpeditions","Prestiges"}) do d[k]=count(saved[k],9e15) end
	for _,v in ipairs(self.Catalog) do d.Upgrades[v.Id]=count(type(saved.Upgrades)=="table" and saved.Upgrades[v.Id],100000) end
	for _,kind in ipairs({"Research","Permanent"}) do
		for _,v in ipairs(self.P[kind]) do d[kind][v.Id]=count(type(saved[kind])=="table" and saved[kind][v.Id],v.Max) end
	end
	for _,z in ipairs(self.Config.Zones) do if type(saved.UnlockedZones)=="table" and saved.UnlockedZones[z.Id]==true then d.UnlockedZones[z.Id]=true end end
	if type(saved.CurrentZone)=="string" and d.UnlockedZones[saved.CurrentZone] then d.CurrentZone=saved.CurrentZone end
	for _,a in ipairs(self.P.Achievements) do
		if type(saved.ClaimedAchievements)=="table" and saved.ClaimedAchievements[a.Id]==true then d.ClaimedAchievements[a.Id]=true end
	end
	d.LastSeen=number(saved.LastSeen,now,now)
	if type(saved.Expedition)=="table" then
		local def=find(self.P.Expeditions,saved.Expedition.Id)
		if def then d.Expedition={Id=def.Id,EndsAt=number(saved.Expedition.EndsAt,now,now+def.Duration),Reward=number(saved.Expedition.Reward,0,self.Config.MaximumCurrency)} end
	end
	local daily=saved.Daily
	if type(daily)=="table" and daily.Day==d.Daily.Day then
		if type(daily.Baseline)=="table" then
			for metric,total in pairs({Clicks=d.TotalClicks,Purchases=d.LifetimePurchases,Trips=d.TotalExpeditions}) do d.Daily.Baseline[metric]=number(daily.Baseline[metric],total,total) end
		end
		for _,a in ipairs(self.P.Daily) do if type(daily.Claimed)=="table" and daily.Claimed[a.Id]==true then d.Daily.Claimed[a.Id]=true end end
	else self:ResetDaily(d,now) end
	return d
end
function Economy:ResetDaily(d,now)
	d.Daily={Day=math.floor(now/86400),Baseline={Clicks=d.TotalClicks,Purchases=d.LifetimePurchases,Trips=d.TotalExpeditions},Claimed={}}
end
function Economy:Serialize(d,now)
	local result={Version=2,LastSeen=now}
	for _,k in ipairs({"Currency","LifetimeCurrency","RunEarned","TotalClicks","LifetimePurchases","TotalExpeditions","Prestiges","Stars","CurrentZone"}) do result[k]=d[k] end
	for _,k in ipairs({"Upgrades","Research","Permanent","ClaimedAchievements","UnlockedZones","Daily"}) do result[k]=clone(d[k]) end
	result.Expedition=d.Expedition and clone(d.Expedition) or nil
	return result
end
function Economy:WorldCount(d) local n=0; for _,z in ipairs(self.Config.Zones) do if d.UnlockedZones[z.Id] then n+=1 end end; return n end
function Economy:Zone(d) return find(self.Config.Zones,d.CurrentZone) or self.Config.Zones[1] end
function Economy:BurstMultiplier(d,now) return d.Runtime.BurstEndsAt>now and self.P.Burst.Multiplier or 1 end
function Economy:BurstDuration(d) return self.P.Burst.Duration+(d.Research.Capacity or 0)*.75+(d.Permanent.Power or 0) end
function Economy:Mastery(d) return (1+d.Prestiges*self.Config.Prestige.MultiplierPerPrestige)*(1+(d.Permanent.Mastery or 0)*.1) end
function Economy:ClickPower(d,now)
	local base=self.Config.BaseClickPower
	for _,v in ipairs(self.Catalog) do base+=v.ClickBonus*(d.Upgrades[v.Id] or 0) end
	return base*self:Zone(d).Multiplier*self:Mastery(d)*(1+(d.Research.Focus or 0)*.2)*(1+(d.Permanent.Touch or 0)*.25)*self:BurstMultiplier(d,now)
end
function Economy:Passive(d,now,unboosted)
	local rate=0; for _,v in ipairs(self.Catalog) do rate+=v.PassivePerSecond*(d.Upgrades[v.Id] or 0) end
	rate*=self:Zone(d).Multiplier*self:Mastery(d)*(1+(d.Research.Efficiency or 0)*.15)*(1+(d.Permanent.Automation or 0)*.2)
	return math.min(rate*(unboosted and 1 or self:BurstMultiplier(d,now)),self.Config.MaximumCurrency)
end
function Economy:Cost(def,owned,d,producer)
	local price=(def.BaseCost or def.Cost)*(def.CostMultiplier or def.Growth)^math.min(owned,1000)
	if producer then price*=1-(d.Research.Discount or 0)*.02 end
	return math.max(1,math.floor(math.min(price,self.Config.MaximumCurrency)+.5))
end
function Economy:Add(d,amount)
	amount=number(amount,0,self.Config.MaximumCurrency)
	local earned=math.min(amount,self.Config.MaximumCurrency-d.Currency)
	d.Currency+=earned; d.LifetimeCurrency=math.min(self.Config.MaximumCurrency,d.LifetimeCurrency+earned); d.RunEarned=math.min(self.Config.MaximumCurrency,d.RunEarned+earned)
	return earned
end
function Economy:Notice(d,text,kind)
	d.Runtime.NoticeSerial+=1; d.Runtime.Notice=text; d.Runtime.NoticeKind=kind or "Reward"
end
function Economy:Offline(d,now)
	local hours=self.P.Offline.Hours+(d.Research.Storage or 0)*.5+(d.Permanent.Clock or 0)
	local seconds=math.clamp(now-d.LastSeen,0,math.min(hours,24)*3600)
	if seconds>=60 then
		d.Runtime.OfflineEarned=self:Add(d,self:Passive(d,now,true)*seconds*self.P.Offline.Efficiency)
		d.Runtime.OfflineSeconds=seconds
	end
	d.LastSeen=now
end
function Economy:Metric(d,metric)
	if metric=="Clicks" then return d.TotalClicks elseif metric=="Earned" then return d.LifetimeCurrency elseif metric=="Trips" then return d.TotalExpeditions
	elseif metric=="Rebirths" then return d.Prestiges elseif metric=="Purchases" then return d.LifetimePurchases elseif metric=="Worlds" then return self:WorldCount(d)
	elseif metric=="Owned" then local n=0; for _,v in pairs(d.Upgrades) do n+=v end; return n end
	return 0
end
function Economy:RebirthCost(d) return math.min(self.Config.MaximumCurrency,self.Config.Prestige.BaseRequirement*self.Config.Prestige.RequirementMultiplier^math.min(d.Prestiges,15)) end
function Economy:RebirthGain(d) return math.clamp(math.floor(math.sqrt(d.RunEarned/self.Config.Prestige.BaseRequirement)),1,100) end
function Economy:Tick(d,now,dt)
	if d.Daily.Day~=math.floor(now/86400) then self:ResetDaily(d,now) end
	-- Integrate the boosted and ordinary portions separately across expiry.
	local elapsed=math.clamp(dt,0,5)
	local boosted=math.clamp(d.Runtime.BurstEndsAt-(now-elapsed),0,elapsed)
	local base=self:Passive(d,now,true)
	self:Add(d,base*((elapsed-boosted)+boosted*self.P.Burst.Multiplier))
	if d.Runtime.EventEndsAt>0 and now>=d.Runtime.EventEndsAt then d.Runtime.EventEndsAt=0 end
	if now>=d.Runtime.EventNextAt then
		d.Runtime.EventEndsAt=now+self.P.Collectible.Lifetime; d.Runtime.EventNextAt=now+self.P.Collectible.Interval; d.Runtime.EventNonce+=1
	end
end
function Economy:Action(d,action,id,quantity,now)
	if type(action)~="string" then return false,"Unknown action." end
	if d.Daily.Day~=math.floor(now/86400) then self:ResetDaily(d,now) end
	if action=="Click" then
		if d.Runtime.BurstEndsAt<=now then
			d.Runtime.Charge+=1
			if d.Runtime.Charge>=self.P.Burst.Clicks then d.Runtime.Charge=0; d.Runtime.BurstEndsAt=now+self:BurstDuration(d); self:Notice(d,"BOOST ACTIVE! x"..self.P.Burst.Multiplier.." production","Burst") end
		end
		local gained=self:Add(d,self:ClickPower(d,now)); d.TotalClicks+=1; d.Runtime.LastClickGain=gained
		return true
	elseif action=="Buy" then
		local def=find(self.Catalog,id); if not def then return false,"Unknown producer." end
		if self:WorldCount(d)<(def.RequiredWorld or 1) then return false,"Unlock more worlds first." end
		local limit=quantity=="Max" and 100 or quantity==10 and 10 or 1
		local bought=0
		for _=1,limit do
			local owned=d.Upgrades[id] or 0; if owned>=100000 then break end
			local cost=self:Cost(def,owned,d,true); if d.Currency<cost then break end
			d.Currency-=cost; d.Upgrades[id]=owned+1; bought+=1; d.LifetimePurchases+=1
		end
		if bought==0 then return false,"Not enough "..string.lower(self.Config.Currency.Name).."." end
		self:Notice(d,"Purchased "..bought.." "..((self.Config.UpgradePresentation[id] or {}).Name or id),"Purchase")
		return true
	elseif action=="Zone" then
		local z=find(self.Config.Zones,id); if not z then return false,"Unknown world." end
		if not d.UnlockedZones[id] then
			if d.Currency<z.UnlockCost then return false,"Not enough to unlock "..z.Name.."." end
			d.Currency-=z.UnlockCost; d.UnlockedZones[id]=true; self:Notice(d,z.Name.." unlocked! x"..z.Multiplier.." production","World")
		end
		d.CurrentZone=id; return true
	elseif action=="Research" or action=="Permanent" then
		local defs=self.P[action]; local def=find(defs,id); if not def then return false,"Unknown upgrade." end
		local level=d[action][id] or 0; if level>=def.Max then return false,"Already at maximum level." end
		local cost=self:Cost(def,level,d); local wallet=action=="Permanent" and "Stars" or "Currency"
		if d[wallet]<cost then return false,"Not enough "..(wallet=="Stars" and "stars" or string.lower(self.Config.Currency.Name)).."." end
		d[wallet]-=cost; d[action][id]=level+1; self:Notice(d,def.Name.." upgraded to level "..(level+1),"Research"); return true
	elseif action=="Expedition" then
		if d.Expedition then return false,"Finish your current expedition first." end
		local def=find(self.P.Expeditions,id); if not def then return false,"Unknown expedition." end
		if self:WorldCount(d)<def.World then return false,"Unlock more worlds first." end
		if d.Currency<def.Cost then return false,"Not enough to launch this expedition." end
		local multiplier=(1+(d.Research.Logistics or 0)*.15)*(1+(d.Permanent.Cargo or 0)*.25)
		local reward=math.min(self.Config.MaximumCurrency,(def.Reward+self:Passive(d,now,true)*def.IncomeSeconds)*multiplier)
		d.Currency-=def.Cost; d.Expedition={Id=id,EndsAt=now+def.Duration,Reward=reward}; self:Notice(d,def.Name.." is on its way.","Expedition"); return true
	elseif action=="ClaimExpedition" then
		if not d.Expedition or now<d.Expedition.EndsAt then return false,"Your expedition is still traveling." end
		local reward=d.Expedition.Reward; d.Expedition=nil; self:Add(d,reward); d.TotalExpeditions+=1; self:Notice(d,"Expedition complete! Cargo collected.","Reward"); return true
	elseif action=="Achievement" or action=="Daily" then
		local def=find(action=="Daily" and self.P.Daily or self.P.Achievements,id); if not def then return false,"Unknown reward." end
		local claimed=action=="Daily" and d.Daily.Claimed or d.ClaimedAchievements
		local metric=self:Metric(d,def.Metric)-(action=="Daily" and (d.Daily.Baseline[def.Metric] or 0) or 0)
		if claimed[id] then return false,"Reward already collected." end
		if metric<def.Goal then return false,"Objective is not complete yet." end
		claimed[id]=true; self:Add(d,(def.Energy or 0)+self:Passive(d,now,true)*(def.IncomeSeconds or 0)); d.Stars=math.min(self.Config.MaximumCurrency,d.Stars+(def.Stars or 0))
		self:Notice(d,def.Name.." reward collected!","Achievement"); return true
	elseif action=="Collect" then
		if d.Runtime.EventEndsAt<=now or id~=d.Runtime.EventNonce then return false,"That bonus has passed." end
		d.Runtime.EventEndsAt=0; self:Add(d,math.max(25,self:ClickPower(d,now)*10+self:Passive(d,now,true)*15)); self:Notice(d,"Bonus collected!","Collect"); return true
	elseif action=="Rebirth" then
		if not self.Config.Prestige.Enabled or d.Currency<self:RebirthCost(d) then return false,"You are not ready to rebirth." end
		local stars=self:RebirthGain(d); d.Stars=math.min(self.Config.MaximumCurrency,d.Stars+stars); d.Prestiges+=1
		d.Currency=0; d.RunEarned=0; d.Upgrades={}; d.Research={}; d.Runtime.Charge=0; d.Runtime.BurstEndsAt=0
		self:Notice(d,"Rebirth complete! +"..stars.." stars. Permanent upgrades are waiting.","Rebirth"); return true
	end
	return false,"Unknown action."
end
function Economy:Snapshot(d,now,saveMode)
	local s={Currency=d.Currency,LifetimeCurrency=d.LifetimeCurrency,RunEarned=d.RunEarned,TotalClicks=d.TotalClicks,
		ClickPower=self:ClickPower(d,now),PassiveRate=self:Passive(d,now),BasePassiveRate=self:Passive(d,now,true),
		CurrentZone=d.CurrentZone,ZoneMultiplier=self:Zone(d).Multiplier,Prestiges=d.Prestiges,Stars=d.Stars,
		PrestigeEnabled=self.Config.Prestige.Enabled,PrestigeCost=self:RebirthCost(d),RebirthGain=self:RebirthGain(d),
		CanPrestige=self.Config.Prestige.Enabled and d.Currency>=self:RebirthCost(d),PrestigeMultiplier=self:Mastery(d),
		BurstCharge=d.Runtime.Charge,BurstEndsAt=d.Runtime.BurstEndsAt,BurstDuration=self:BurstDuration(d),BurstNeeded=self.P.Burst.Clicks,BurstMultiplier=self.P.Burst.Multiplier,
		EventEndsAt=d.Runtime.EventEndsAt,EventNonce=d.Runtime.EventNonce,ServerTime=now,SaveMode=saveMode,
		NoticeSerial=d.Runtime.NoticeSerial,Notice=d.Runtime.Notice,NoticeKind=d.Runtime.NoticeKind,LastClickGain=d.Runtime.LastClickGain or 0,
		OfflineEarned=d.Runtime.OfflineEarned,OfflineSeconds=d.Runtime.OfflineSeconds,Expedition=d.Expedition and clone(d.Expedition) or nil,
		Upgrades={},Zones={},Research={},Permanent={},Expeditions={},Achievements={},Daily={},Claimable=0}
	local worlds=self:WorldCount(d)
	for _,v in ipairs(self.Catalog) do
		s.Upgrades[v.Id]={Owned=d.Upgrades[v.Id] or 0,Cost=self:Cost(v,d.Upgrades[v.Id] or 0,d,true),Locked=worlds<(v.RequiredWorld or 1),RequiredWorld=v.RequiredWorld or 1}
	end
	for i,z in ipairs(self.Config.Zones) do s.Zones[i]={Id=z.Id,Name=z.Name,UnlockCost=z.UnlockCost,Multiplier=z.Multiplier,Unlocked=d.UnlockedZones[z.Id]==true,Current=d.CurrentZone==z.Id} end
	for _,kind in ipairs({"Research","Permanent"}) do
		for i,v in ipairs(self.P[kind]) do local level=d[kind][v.Id] or 0; s[kind][i]={Id=v.Id,Name=v.Name,Description=v.Description,Level=level,Max=v.Max,Cost=self:Cost(v,level,d)} end
	end
	for i,v in ipairs(self.P.Expeditions) do
		local multiplier=(1+(d.Research.Logistics or 0)*.15)*(1+(d.Permanent.Cargo or 0)*.25)
		s.Expeditions[i]={Id=v.Id,Name=v.Name,Description=v.Description,Duration=v.Duration,Cost=v.Cost,Locked=worlds<v.World,RequiredWorld=v.World,
			Reward=math.min(self.Config.MaximumCurrency,(v.Reward+self:Passive(d,now,true)*v.IncomeSeconds)*multiplier)}
	end
	for _,kind in ipairs({"Achievements","Daily"}) do
		for i,v in ipairs(self.P[kind]) do
			local progress=math.max(0,self:Metric(d,v.Metric)-(kind=="Daily" and (d.Daily.Baseline[v.Metric] or 0) or 0))
			local claimed=kind=="Daily" and d.Daily.Claimed[v.Id]==true or kind=="Achievements" and d.ClaimedAchievements[v.Id]==true
			local ready=not claimed and progress>=v.Goal
			if ready then s.Claimable+=1 end
			s[kind][i]={Id=v.Id,Name=v.Name,Progress=math.min(progress,v.Goal),Goal=v.Goal,Claimed=claimed,Ready=ready,
				Energy=(v.Energy or 0)+self:Passive(d,now,true)*(v.IncomeSeconds or 0),Stars=v.Stars or 0}
		end
	end
	local first=self.Catalog[1]; local second=self.Catalog[2]
	if (d.Upgrades[first.Id] or 0)==0 then s.Objective="First goal: buy "..((self.Config.UpgradePresentation[first.Id] or {}).Name or first.Id)
	elseif second and (d.Upgrades[second.Id] or 0)==0 then s.Objective="Next: automate with "..((self.Config.UpgradePresentation[second.Id] or {}).Name or second.Id)
	elseif s.Claimable>0 then s.Objective="Journal: "..s.Claimable.." rewards ready to collect"
	elseif not d.Expedition then s.Objective="Send an expedition for extra income"
	else s.Objective="Keep growing. A new world is within reach." end
	return s
end
return Economy
]====])
setSource("StarterPlayer.StarterPlayerScripts.ClickerClient","LocalScript",[====[
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
]====])
setSource("StarterPlayer.StarterPlayerScripts.Effects","ModuleScript",[====[
-- Bounded client-only animation. Rewards and timers remain authoritative on the server.
local RunService=game:GetService("RunService")
local TweenService=game:GetService("TweenService")
local Debris=game:GetService("Debris")
local Kit=game:GetService("ReplicatedStorage"):WaitForChild("ClickerKit")
local Config=require(Kit.ThemeConfig)
local Art=require(Kit.Art)
local UI=require(Kit.UIBuilder)
local T=Config.Theme
local Effects={}; Effects.__index=Effects
local function circle(parent,name,color,size)
	local o=Instance.new("Frame"); o.Name=name; o.BorderSizePixel=0; o.BackgroundColor3=color; o.Size=UDim2.fromOffset(size,size); o.AnchorPoint=Vector2.new(.5,.5)
	local corner=Instance.new("UICorner"); corner.CornerRadius=UDim.new(1,0); corner.Parent=o; o.Parent=parent; return o
end
function Effects.new(view)
	local self=setmetatable({View=view,Spring=1,Velocity=0,Tilt=0,Hover=false,Time=0,Accumulator=0,Display=0,Particles=0,Collectors={},PassiveClock=0,Clouds={},CachedArt=nil},Effects)
	view.Animated=true
	view.Target.MouseEnter:Connect(function() self.Hover=true end)
	view.Target.MouseLeave:Connect(function() self.Hover=false end)
	self.Connection=RunService.RenderStepped:Connect(function(dt)
		self.Accumulator+=dt
		if self.Accumulator>=1/30 then local elapsed=self.Accumulator; self.Accumulator=0; self:Step(math.min(elapsed,.05)) end
	end)
	view.Gui.Destroying:Once(function() self:Destroy() end)
	return self
end
function Effects:Track(object,life)
	self.Particles+=1
	object.Destroying:Once(function() self.Particles=math.max(0,self.Particles-1) end)
	Debris:AddItem(object,life+.2)
end
function Effects:Pop(message,color,x,y,big)
	if self.Particles>=70 then return end
	local v=self.View
	local o=Instance.new("TextLabel"); o.Name="RewardPop"; o.BackgroundTransparency=1; o.Font=Enum.Font.GothamBold; o.Text=message
	o.TextColor3=color or T.Accent; o.TextSize=big and 25 or 18; o.Size=UDim2.fromOffset(180,34); o.AnchorPoint=Vector2.new(.5,.5)
	o.Position=UDim2.fromOffset(x or v.Target.Position.X.Offset,y or v.Target.Position.Y.Offset-50); o.ZIndex=10; o.Parent=v.Particles
	self:Track(o,.8)
	TweenService:Create(o,TweenInfo.new(.75,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Position=o.Position-UDim2.fromOffset(0,v.ReducedMotion and 8 or 48),TextTransparency=1}):Play()
end
function Effects:Press()
	local v=self.View
	self.Spring=v.ReducedMotion and .98 or .91; self.Velocity=-.4; self.Tilt=math.random(-2,2)
	if v.ReducedMotion or self.Particles>=60 then return end
	local d=v.Diameter or 250; local p=v.Target.Position
	local ring=circle(v.Particles,"ClickRipple",T.Accent,d*.87); ring.BackgroundTransparency=1; ring.Position=p; ring.ZIndex=8
	local line=Instance.new("UIStroke"); line.Color=T.Accent; line.Transparency=.4; line.Thickness=2; line.Parent=ring
	self:Track(ring,.45)
	TweenService:Create(ring,TweenInfo.new(.4,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{Size=UDim2.fromOffset(d*1.25,d*1.25)}):Play()
	TweenService:Create(line,TweenInfo.new(.4),{Transparency=1}):Play()
	for i=1,3 do
		local a=math.random()*math.pi*2; local radius=d*.49; local x=p.X.Offset+math.cos(a)*radius; local y=p.Y.Offset+math.sin(a)*radius
		local dot=circle(v.Particles,"ClickSpark",i==1 and T.Accent or T.Text,math.random(3,6)); dot.Position=UDim2.fromOffset(x,y)
		self:Track(dot,.45)
		TweenService:Create(dot,TweenInfo.new(.4),{Position=UDim2.fromOffset(x+math.cos(a)*25,y+math.sin(a)*25),BackgroundTransparency=1,Size=UDim2.fromOffset(1,1)}):Play()
	end
end
function Effects:Celebrate(strength)
	local v=self.View
	if v.ReducedMotion then return end
	for i=1,math.min(strength or 14,24) do
		if self.Particles>=70 then break end
		local a=i/(strength or 14)*math.pi*2; local r=(v.Diameter or 250)*.55
		local x,y=v.Target.Position.X.Offset,v.Target.Position.Y.Offset
		local dot=circle(v.Particles,"Celebration",i%2==0 and T.Accent or T.AccentAlt,math.random(5,9)); dot.Position=UDim2.fromOffset(x,y); dot.Rotation=i*20
		self:Track(dot,1)
		TweenService:Create(dot,TweenInfo.new(.9,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Position=UDim2.fromOffset(x+math.cos(a)*r,y+math.sin(a)*r),BackgroundTransparency=1,Rotation=dot.Rotation+100}):Play()
	end
end
function Effects:Update(previous,state)
	local v=self.View
	if not previous then self.Display=state.Currency end
	if previous and state.Currency<previous.Currency then self.Display=state.Currency end
	if previous and state.TotalClicks>previous.TotalClicks then
		self:Pop("+"..Art.Number(state.LastClickGain or state.ClickPower),T.Accent,v.Target.Position.X.Offset+math.random(-40,40),v.Target.Position.Y.Offset-45,true)
	end
	if previous then
		for id,item in pairs(state.Upgrades) do
			if item.Owned>((previous.Upgrades[id] or {}).Owned or 0) then
				local row=v.Rows[id]; local tile=row and row.Frame:FindFirstChild("IconTile")
				if tile then
					local scale=tile:FindFirstChild("Pulse") or Instance.new("UIScale"); scale.Name="Pulse"; scale.Parent=tile; scale.Scale=v.ReducedMotion and .98 or .8
					TweenService:Create(scale,TweenInfo.new(.35,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Scale=1}):Play()
				end
			end
		end
		if state.CurrentZone~=previous.CurrentZone or state.Prestiges>previous.Prestiges then self:Celebrate(20) end
		if state.BurstEndsAt>previous.BurstEndsAt then self:Celebrate(12) end
	end
	local count=0
	for _,def in ipairs(require(Kit.UpgradeCatalog)) do if def.PassivePerSecond>0 then count+=((state.Upgrades[def.Id] or {}).Owned or 0) end end
	count=math.min(4,count)
	for i=#self.Collectors+1,count do
		local o=Instance.new("Frame"); o.Name="ActiveCollector"..i; o.BackgroundTransparency=1; o.Size=UDim2.fromOffset(48,48); o.AnchorPoint=Vector2.new(.5,.5); o.Parent=v.CollectorLayer
		local scale=Instance.new("UIScale"); scale.Scale=.62; scale.Parent=o
		if T.CollectorStyle=="Cookie" then
			local cookie=circle(o,"Cookie",T.Accent,32); cookie.Position=UDim2.fromOffset(24,24)
			for _,p in ipairs({{17,18},{28,28},{17,30}}) do local chip=circle(o,"Chip",Color3.fromRGB(79,47,37),5); chip.Position=UDim2.fromOffset(p[1],p[2]) end
		else Art.Icon(o,"Drone",T.AccentAlt) end
		table.insert(self.Collectors,o)
	end
	for i=#self.Collectors,count+1,-1 do self.Collectors[i]:Destroy(); table.remove(self.Collectors,i) end
end
function Effects:Step(dt)
	local v=self.View; if not v.Gui.Parent then self:Destroy(); return end
	self.Time+=dt
	local now=workspace:GetServerTimeNow(); local s=v.State; local reduced=v.ReducedMotion
	local desired=1+(self.Hover and not reduced and .025 or 0)
	self.Velocity+=((desired-self.Spring)*240-self.Velocity*23)*dt; self.Spring=math.clamp(self.Spring+self.Velocity*dt,.85,1.08)
	v.Bounce.Scale=self.Spring; self.Tilt*=math.exp(-8*dt)
	if v.Art~=self.CachedArt then
		self.CachedArt=v.Art; self.Clouds={}
		for _,o in ipairs(v.Art:GetChildren()) do if o.Name=="Cloud" then table.insert(self.Clouds,{Object=o,Position=o.Position}) end end
	end
	v.Art.Rotation=reduced and 0 or math.sin(self.Time*.45)*1.2+self.Tilt
	v.Art.Position=UDim2.new(.5,0,.5,reduced and 0 or math.sin(self.Time*.8)*3)
	local angle=reduced and .8 or self.Time*.6
	v.OrbitDot.Position=UDim2.fromScale(.5+math.cos(angle)*.49,.5+math.sin(angle)*.49)
	for i,star in ipairs(v.Stars) do star.Object.BackgroundTransparency=reduced and star.Alpha or math.clamp(star.Alpha+math.sin(self.Time*.7+star.Phase)*.15,.1,.92) end
	for i,cloud in ipairs(self.Clouds) do cloud.Object.Position=cloud.Position+UDim2.fromOffset(reduced and 0 or math.sin(self.Time*.3+i)*2,0) end
	for i,o in ipairs(self.Collectors) do
		local a=(reduced and 0 or self.Time*.45)+i*math.pi/2
		o.Position=UDim2.fromOffset(v.Target.Position.X.Offset+math.cos(a)*(v.Diameter or 250)*.64,v.Target.Position.Y.Offset+math.sin(a)*(v.Diameter or 250)*.35)
		o.Rotation=reduced and 0 or math.sin(a)*9
	end
	if not s then return end
	local active=(s.BurstEndsAt or 0)>now
	local rate=(s.BasePassiveRate or s.PassiveRate or 0)*(active and (s.BurstMultiplier or 3) or 1)
	local estimate=math.min(Config.MaximumCurrency,s.Currency+rate*math.clamp(now-(s.ServerTime or now),0,1.1))
	self.Display+=(estimate-self.Display)*(1-math.exp(-12*dt)); if math.abs(estimate-self.Display)<.01 then self.Display=estimate end
	v.Currency.Text=Art.Number(self.Display)
	local fraction=active and math.clamp((s.BurstEndsAt-now)/(s.BurstDuration or 6),0,1) or (s.BurstCharge or 0)/(s.BurstNeeded or 20)
	v.BurstFill.Size=UDim2.new(fraction,0,1,0)
	v.BurstTitle.Text=(T.BurstName or "BOOST")..(active and " / x"..(s.BurstMultiplier or 3) or " CHARGE")
	v.BurstCount.Text=active and string.format("%.1fs",s.BurstEndsAt-now) or (s.BurstCharge or 0).." / "..(s.BurstNeeded or 20)
	v.BurstNote.Text=active and "All clicks and producers earn x3!" or "20 clicks unlock a short x3 production boost"
	local halo=v.Art:FindFirstChild("Atmosphere"); if halo and halo:FindFirstChild("Outline") then halo.Outline.Transparency=active and (reduced and .35 or .35+math.sin(self.Time*5)*.1) or .75 end
	v.Comet.Visible=(s.EventEndsAt or 0)>now
	if v.Comet.Visible then
		v.Comet.Position=UDim2.fromOffset(v.Compact and 80 or 388,(v.Landscape and 50 or 75)+(reduced and 0 or math.sin(self.Time*2)*7))
		v.Comet.Rotation=reduced and 0 or math.sin(self.Time*2)*4; v.CometTimer.Text=math.ceil(s.EventEndsAt-now).."s / TAP TO COLLECT"
	end
	self.PassiveClock+=dt
	if rate>0 and self.PassiveClock>=1.2 and v.Scene.Visible then
		self.PassiveClock=0; local o=self.Collectors[1]
		if o then self:Pop("+"..Art.Number(rate).." / sec",T.AccentAlt,o.Position.X.Offset,o.Position.Y.Offset-15,false) end
	end
	local trip=s.Expedition
	for _,r in pairs(v.Cards.Expeditions) do
		if trip and trip.Id==r.Id then
			local remaining=math.max(0,trip.EndsAt-now); local duration=r.Definition.Duration
			r.Button.Text=remaining<=0 and "COLLECT" or UI.Time(remaining); r.Button.BackgroundColor3=remaining<=0 and T.Accent or T.Panel; r.Button.TextColor3=remaining<=0 and T.Background or T.MutedText
			r.Fill.Size=UDim2.new(1-math.clamp(remaining/duration,0,1),0,1,0)
			v.Ship.Position=UDim2.fromScale(.08+.84*(1-math.clamp(remaining/duration,0,1)),.5)
			v.RouteLabel.Text=remaining<=0 and "Cargo arrived! Collect your reward below." or r.Definition.Name.." / "..UI.Time(remaining).." remaining"
		elseif trip then r.Button.Text="CREW BUSY"; r.Fill.Size=UDim2.fromScale(0,1)
		else r.Fill.Size=UDim2.fromScale(0,1) end
	end
	if not trip then v.Ship.Position=UDim2.fromScale(.08,.5); v.RouteLabel.Text="Choose an expedition below" end
end
function Effects:Destroy()
	if self.Connection then self.Connection:Disconnect(); self.Connection=nil end
end
return Effects
]====])
game:GetService("Players").CharacterAutoLoads=false
game:GetService("StarterGui").ScreenOrientation=Enum.ScreenOrientation.Sensor
local world=workspace:FindFirstChild("ClickerWorld");if world then world:Destroy() end
local worldBuilder=shared:FindFirstChild("WorldBuilder");if worldBuilder then worldBuilder:Destroy() end
for _,name in ipairs({"ClickerAtmosphere","ClickerBloom"})do local item=game.Lighting:FindFirstChild(name);if item then item:Destroy() end end
local modules=shared:Clone();modules.Name="ClickerPreviewModules";modules.Parent=game:GetService("ReplicatedStorage")
local ok,result=pcall(function()
 local view=require(modules.UIBuilder).Build(game:GetService("StarterGui"))
 view.Gui:SetAttribute("Preview",true);view:Layout(workspace.CurrentCamera.ViewportSize)
end)
modules:Destroy();assert(ok,result)
print("ORBIT installed as the standalone Space game. Press Play.")
