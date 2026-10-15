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
