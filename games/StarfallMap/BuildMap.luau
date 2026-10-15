-- Run in Studio Edit mode. All authored geometry lives in Workspace.StarfallMap.
local C = Color3.fromRGB
local V = Vector3.new
local root = Instance.new('Model')
root.Name = 'StarfallMap'
assert(not workspace:FindFirstChild(root.Name), 'StarfallMap already exists; preserve the current build before reinstalling')
local backup = Instance.new('Folder')
backup.Name = 'StarfallOriginalScene'
backup.Parent = game.ServerStorage
for _,name in {'Baseplate','SpawnLocation'} do
 local old = workspace:FindFirstChild(name)
 if old then old.Parent = backup end
end
local steel=C(28,38,58)
local silver=C(104,127,151)
local dark=C(13,20,34)
local cyan=C(70,225,255)
local gold=C(255,183,75)
local function group(name,parent)
 local m=Instance.new('Model');m.Name=name;m.Parent=parent;return m
end
local function part(parent,name,size,cf,color,material,shape)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or steel
 p.Material=material or Enum.Material.Metal;p.Anchored=true;p.TopSurface=Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth
 if shape then p.Shape=shape end
 p.Parent=parent;return p
end
local function decor(p)
 p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;return p
end
local function ball(parent,name,pos,size,color,material,alpha)
 local p=part(parent,name,V(size,size,size),CFrame.new(pos),color,material,Enum.PartType.Ball)
 p.Transparency=alpha or 0;return decor(p)
end
local function disk(parent,name,pos,r,height,color,material)
 return part(parent,name,V(height,r*2,r*2),CFrame.new(pos)*CFrame.Angles(0,0,math.pi/2),color,material,Enum.PartType.Cylinder)
end
local function ring(parent,name,pos,r,thickness,color,tilt,segments)
 local m=group(name,parent);segments=segments or 48
 local base=CFrame.new(pos)*(tilt or CFrame.new())
 for i=1,segments do
  local a=(i-1)*math.pi*2/segments
  local p=part(m,'Arc',V(thickness,thickness,2*math.pi*r/segments*1.02),base*CFrame.new(math.cos(a)*r,0,math.sin(a)*r)*CFrame.Angles(0,-a,0),color,Enum.Material.Neon)
  decor(p)
 end
 return m
end
local function line(parent,name,a,b,width,color)
 local p=part(parent,name,V(width,width,(b-a).Magnitude),CFrame.lookAt((a+b)/2,b),color,Enum.Material.Neon)
 return decor(p)
end
local function sign(parent,name,text,pos,size,color)
 local anchor=part(parent,name,V(size.X,size.Y,0.4),CFrame.new(pos),dark)
 decor(anchor)
 local gui=Instance.new('SurfaceGui');gui.Face=Enum.NormalId.Front;gui.PixelsPerStud=30;gui.LightInfluence=0;gui.Parent=anchor
 local label=Instance.new('TextLabel');label.Size=UDim2.fromScale(1,1);label.BackgroundTransparency=1;label.Text=text
 label.TextColor3=color or cyan;label.Font=Enum.Font.GothamBold;label.TextScaled=true;label.Parent=gui
 return anchor
end
local function billboard(parent,text,pos,color)
 local a=part(parent,'SectorLabel',V(1,1,1),CFrame.new(pos),color);a.Transparency=1;decor(a)
 local g=Instance.new('BillboardGui');g.Size=UDim2.fromOffset(230,46);g.StudsOffset=V(0,2,0);g.MaxDistance=1300;g.AlwaysOnTop=false;g.Parent=a
 local t=Instance.new('TextLabel');t.Size=UDim2.fromScale(1,1);t.BackgroundTransparency=1;t.Text=text;t.TextColor3=color;t.TextStrokeTransparency=.45;t.Font=Enum.Font.GothamBold;t.TextSize=19;t.Parent=g
end
local random=Random.new(814)
local function rock(parent,pos,scale,color)
 local p=part(parent,'Asteroid',V(scale,scale*.73,scale*.86),CFrame.new(pos)*CFrame.Angles(random:NextNumber(),random:NextNumber()*4,random:NextNumber()),color,Enum.Material.Slate)
 decor(p)
 for j=1,2 do
  local n=part(parent,'RockFacet',V(scale*.65,scale*.5,scale*.55),p.CFrame*CFrame.new(scale*.25,scale*.2,0)*CFrame.Angles(j,.6,j*.8),color:Lerp(silver,.1*j),Enum.Material.Slate)
  decor(n)
 end
end
local hub=group('Hub',root)
disk(hub,'StationUnderbody',V(0,22,0),65,10,dark)
disk(hub,'StationDeck',V(0,28,0),72,4,steel)
disk(hub,'InnerDeck',V(0,30.1,0),46,.2,C(43,56,75))
ring(hub,'DeckEdge',V(0,30.3,0),70,1.3,cyan,nil,64)
ring(hub,'InnerWayfinding',V(0,30.4,0),42,.55,gold,nil,48)
-- Radial docking arms and perimeter supports.
for i=1,8 do
 local a=i*math.pi/4
 local cf=CFrame.new(math.cos(a)*75,27,math.sin(a)*75)*CFrame.Angles(0,-a,0)
 part(hub,'DockArm',V(28,5,17),cf,steel)
 part(hub,'DockPlate',V(27,.4,13),cf*CFrame.new(0,2.7,0),silver)
 decor(part(hub,'DockStripe',V(25,.25,.7),cf*CFrame.new(0,3,5),gold,Enum.Material.Neon))
 decor(part(hub,'DockStripe',V(25,.25,.7),cf*CFrame.new(0,3,-5),cyan,Enum.Material.Neon))
 part(hub,'Support',V(5,20,5),CFrame.new(math.cos(a)*60,16,math.sin(a)*60),silver)
 -- Separated rail panels leave docks open.
 local railcf=CFrame.new(math.cos(a+.2)*66,34,math.sin(a+.2)*66)*CFrame.Angles(0,-a-.2,0)
 local glass=part(hub,'SafetyScreen',V(1,6,24),railcf,C(91,192,230),Enum.Material.Glass);glass.Transparency=.55
end
local tower=group('CommsTower',hub)
disk(tower,'TowerFoot',V(0,33,16),12,6,silver)
disk(tower,'TowerCore',V(0,44,16),7,19,dark)
ring(tower,'TowerBand',V(0,48,16),7.3,.8,cyan)
disk(tower,'ObservationDeck',V(0,55,16),11,3,steel)
part(tower,'Antenna',V(2,22,2),CFrame.new(0,67,16),silver)
ball(tower,'Beacon',V(0,79,16),3,gold,Enum.Material.Neon)
local console=group('NavigationConsole',hub)
disk(console,'Base',V(0,32,-12),9,4,dark)
disk(console,'HologramTable',V(0,35,-12),11,2,silver)
ring(console,'TableGlow',V(0,36.2,-12),10,.65,cyan)
local holo=disk(console,'HologramSurface',V(0,37,-12),9,.25,cyan,Enum.Material.Neon);holo.Transparency=.7;decor(holo)
ball(console,'HolographicStar',V(0,41,-12),2,gold,Enum.Material.Neon)
ring(console,'HolographicOrbit',V(0,41,-12),5,.14,cyan,CFrame.Angles(.3,0,.15),28)
local prompt=Instance.new('ProximityPrompt');prompt.Name='OpenStarChart';prompt.ActionText='Open star chart';prompt.ObjectText='Navigation';prompt.HoldDuration=0;prompt.MaxActivationDistance=18;prompt.RequiresLineOfSight=false;prompt.Parent=console.Base
sign(hub,'Title','STARFALL  /  SALVAGERS',V(0,68,16),V(40,4,1),gold)
sign(console,'ConsoleTitle','NAVIGATION',V(0,38,-22),V(18,2,1),cyan)
-- Future gameplay stations are clear physical landmarks.
for _,s in {{'SALVAGE',-36,8,gold},{'SHIP UPGRADES',36,8,cyan}} do
 local m=group(s[1],hub)
 part(m,'Desk',V(17,5,8),CFrame.new(s[2],33,s[3]),dark)
 part(m,'Worktop',V(19,1,10),CFrame.new(s[2],36,s[3]),silver)
 sign(m,'Sign',s[1],V(s[2],43,s[3]+4),V(20,3,1),s[4])
 for k=-1,1 do ball(m,'Cargo',V(s[2]+k*5,38,s[3]),2,s[4],Enum.Material.Neon) end
end
local spawn=Instance.new('SpawnLocation');spawn.Name='StationSpawn';spawn.Size=V(10,1,10);spawn.CFrame=CFrame.new(0,31,48);spawn.Anchored=true;spawn.Neutral=true;spawn.Duration=0;spawn.Transparency=1;spawn.Parent=hub
local routes=group('Routes',root)
local sectors=group('Sectors',root)
local defs={
 {'ScrapBelt','SCRAP BELT',V(-165,36,90),gold,'01  /  LOW RISK'},
 {'IceGraveyard','ICE GRAVEYARD',V(-255,53,-125),C(114,226,255),'02  /  MODERATE'},
 {'DerelictField','DERELICT FIELD',V(35,48,-285),C(108,158,255),'03  /  MODERATE'},
 {'NebulaCurrent','NEBULA CURRENT',V(-210,65,285),C(164,108,255),'04  /  HIGH RISK'},
 {'AncientRuins','ANCIENT RUINS',V(270,48,210),C(209,121,255),'05  /  HIGH RISK'},
 {'SingularityEdge','SINGULARITY EDGE',V(310,95,-200),C(255,65,125),'06  /  EXTREME'},
}
root.Parent=workspace;task.wait()
for idx,d in defs do
 local m=group(d[1],nil);m:SetAttribute('SectorId',d[1]);local pos=d[3];local color=d[4]
 local dir=V(pos.X,0,pos.Z).Unit
 local a=dir*90+V(0,28,0);local b=pos-dir*48
 local mid=(a+b)/2+V(0,-10,0)
 line(routes,d[1]..'RouteA',a,mid,.65,color)
 line(routes,d[1]..'RouteB',mid,b,.65,color)
 ball(routes,'RouteBeacon',mid,3,color,Enum.Material.Neon)
 ring(m,'SectorBoundary',pos+V(0,-6,0),51,.5,color,nil,40)
 for i=1,10 do
  local ang=i*math.pi*2/10
  rock(m,pos+V(math.cos(ang)*random:NextNumber(28,48),random:NextNumber(-14,5),math.sin(ang)*random:NextNumber(28,48)),random:NextNumber(6,13),C(52,57,75))
 end
 if idx==1 then
  rock(m,pos,34,C(95,77,62))
  for j=1,8 do
   local off=V(random:NextNumber(-20,20),random:NextNumber(9,21),random:NextNumber(-20,20))
   local crate=part(m,'SalvageContainer',V(8,5,6),CFrame.new(pos+off)*CFrame.Angles(0,j*.4,0),C(108,91,70));decor(crate)
   line(m,'ContainerStripe',pos+off+V(-3,3,0),pos+off+V(3,3,0),.4,gold)
  end
 elseif idx==2 then
  ball(m,'FrozenMoon',pos+V(0,16,0),50,C(137,198,226),Enum.Material.Glacier)
  for j=1,16 do
   local a=j*math.pi*2/16;local p=Instance.new('WedgePart');p.Name='IceSpire';p.Size=V(10,random:NextNumber(17,36),12);p.CFrame=CFrame.new(pos+V(math.cos(a)*25,5,math.sin(a)*25))*CFrame.Angles(.2,a,.2);p.Color=color;p.Material=Enum.Material.Ice;p.Anchored=true;p.Parent=m;decor(p)
  end
 elseif idx==3 then
  local cf=CFrame.new(pos+V(0,12,0))*CFrame.Angles(.1,-.4,.25)
  part(m,'WreckedHull',V(24,15,65),cf,silver,Enum.Material.CorrodedMetal)
  for j=-1,1,2 do
   part(m,'BrokenWing',V(30,3,25),cf*CFrame.new(j*25,-2,9)*CFrame.Angles(0,0,j*.3),steel)
   part(m,'Engine',V(9,9,15),cf*CFrame.new(j*8,-1,37),dark)
   ball(m,'ColdEngineCore',(cf*CFrame.new(j*8,-1,44)).Position,6,color,Enum.Material.Neon)
  end
  part(m,'Bridge',V(12,10,16),cf*CFrame.new(0,12,-7),dark)
  decor(part(m,'BridgeWindow',V(11,3,.4),cf*CFrame.new(0,12,-15.3),color,Enum.Material.Neon))
 elseif idx==4 then
  ball(m,'NebulaCore',pos+V(0,15,0),16,C(230,199,255),Enum.Material.Neon)
  for j=1,8 do
   local a=j*math.pi/4
   ball(m,'IonCloud',pos+V(math.cos(a)*20,math.sin(a*2)*12+15,math.sin(a)*20),32,j%2==0 and cyan or color,Enum.Material.Neon,.92)
  end
  ring(m,'CurrentRing',pos+V(0,15,0),33,.65,color,CFrame.Angles(.5,0,.35))
  ring(m,'CurrentRing',pos+V(0,15,0),40,.4,cyan,CFrame.Angles(-.5,0,-.2))
 elseif idx==5 then
  rock(m,pos,57,C(67,56,89))
  disk(m,'TempleFoundation',pos+V(0,13,0),26,3,C(90,81,119),Enum.Material.Slate)
  for j=1,6 do
   local a=j*math.pi/3;local at=pos+V(math.cos(a)*20,28,math.sin(a)*20)
   part(m,'AncientPillar',V(5,27,5),CFrame.new(at),C(115,104,145),Enum.Material.Slate)
   part(m,'PillarCap',V(9,3,9),CFrame.new(at+V(0,14,0)),silver,Enum.Material.Slate)
   decor(part(m,'AlienGlyph',V(.35,14,.35),CFrame.new(at+V(-2.6,0,-2.6)),color,Enum.Material.Neon))
  end
  ball(m,'Relic',pos+V(0,25,0),7,color,Enum.Material.Neon)
  ring(m,'RelicHalo',pos+V(0,25,0),10,.6,color,CFrame.Angles(math.pi/2,0,0),32)
 elseif idx==6 then
  ball(m,'EventHorizon',pos+V(0,25,0),52,C(2,0,6),Enum.Material.SmoothPlastic)
  ring(m,'AccretionInner',pos+V(0,25,0),28,1.6,C(255,217,231),CFrame.Angles(.4,0,.3),64)
  ring(m,'AccretionOuter',pos+V(0,25,0),36,2.2,color,CFrame.Angles(.4,0,.3),64)
  ring(m,'AccretionOrbit',pos+V(0,25,0),45,.5,color,CFrame.Angles(.4,0,.3),64)
  for j=1,9 do rock(m,pos+V(random:NextNumber(-55,55),random:NextNumber(-30,60),random:NextNumber(-55,55)),random:NextNumber(5,12),C(61,22,44)) end
 end
 billboard(m,d[2]..'\n'..d[5],pos+V(0,65,0),color)
 m.Parent=sectors;task.wait()
end
local backdrop=group('Backdrop',nil)
ball(backdrop,'DistantGasGiant',V(-540,190,-600),230,C(69,75,137),Enum.Material.SmoothPlastic)
ring(backdrop,'PlanetRings',V(-540,190,-600),150,4,C(113,125,184),CFrame.Angles(.3,0,-.3),80)
ball(backdrop,'DistantMoon',V(500,190,540),85,C(79,88,115),Enum.Material.Slate)
for i=1,130 do
 local a=random:NextNumber(0,math.pi*2);local h=random:NextNumber(-70,580);local radius=random:NextNumber(750,1100)
 ball(backdrop,'Star',V(math.cos(a)*radius,h,math.sin(a)*radius),random:NextNumber(.8,2.5),i%5==0 and C(155,184,255) or C(234,241,255),Enum.Material.Neon)
end
backdrop.Parent=root
local L=game.Lighting
L.ClockTime=0;L.Brightness=2;L.Ambient=C(65,76,111);L.OutdoorAmbient=C(75,86,121);L.ExposureCompensation=.15;L.FogColor=C(7,10,24);L.FogStart=1800;L.FogEnd=5000
local bloom=Instance.new('BloomEffect');bloom.Name='StarfallBloom';bloom.Intensity=.3;bloom.Size=20;bloom.Threshold=1.5;bloom.Parent=L
local correction=Instance.new('ColorCorrectionEffect');correction.Name='StarfallColor';correction.Contrast=.1;correction.Saturation=.12;correction.Parent=L
local sky=Instance.new('Sky');sky.Name='StarfallSky';sky.CelestialBodiesShown=false;sky.StarCount=3000;sky.Parent=L
game.Players.CharacterAutoLoads=true
workspace.CurrentCamera.CFrame=CFrame.lookAt(V(650,680,800),V(20,30,0))
return {Parts=#root:GetDescendants(),Sectors=#sectors:GetChildren(),Spawn=spawn.Position}
