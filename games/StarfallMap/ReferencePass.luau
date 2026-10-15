-- Art direction from the user's studded purple / charcoal / glowing-energy reference.
-- Run after ToyStyle. Previous authored props are preserved in ServerStorage.
local C=Color3.fromRGB
local V=Vector3.new
local CF=CFrame.new
local root=workspace:WaitForChild('StarfallMap')
assert(not root:FindFirstChild('ReferenceArt'),'Reference pass already exists')
local backup=Instance.new('Folder');backup.Name='StarfallBeforeReference';backup.Parent=game.ServerStorage
local hub=root.Hub
local P={rock=C(43,40,57),dark=C(30,27,44),frame=C(103,95,121),edge=C(137,124,157),floor=C(147,50,179),floor2=C(126,43,158),purple=C(155,65,214),pink=C(241,71,255),gold=C(255,203,66),cyan=C(91,231,255),white=C(220,211,239)}
local function model(name,parent)local m=Instance.new('Model');m.Name=name;m.Parent=parent;return m end
local function part(parent,name,size,cf,color,class,studs)
 local p=Instance.new(class or 'Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or P.rock;p.Material=Enum.Material.Plastic;p.Anchored=true;p.TopSurface=studs and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function deco(p)p.CanCollide=false;p.CanTouch=false;return p end
local function beam(parent,name,a,b,w,color,glow)
 local p=deco(part(parent,name,V(w,w,(b-a).Magnitude),CFrame.lookAt((a+b)*.5,b),color));if glow then p.Material=Enum.Material.Neon end;return p
end
local function cylinder(parent,name,pos,r,height,color)
 local p=part(parent,name,V(height,r*2,r*2),CF(pos)*CFrame.Angles(0,0,math.pi/2),color);p.Shape=Enum.PartType.Cylinder;return p
end
local function glow(parent,name,size,cf,color)
 local p=deco(part(parent,name,size,cf,color));p.Material=Enum.Material.Neon;p.CastShadow=false;return p
end
local function sign(parent,name,text,pos,size,color)
 local base=deco(part(parent,name,V(size.X,size.Y,.45),CF(pos),P.dark))
 local gui=Instance.new('SurfaceGui');gui.Face=Enum.NormalId.Back;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=12;gui.LightInfluence=0;gui.Parent=base
 local label=Instance.new('TextLabel');label.Name='Title';label.Size=UDim2.fromScale(.94,.88);label.Position=UDim2.fromScale(.03,.06);label.BackgroundTransparency=1;label.Text=text;label.TextScaled=true;label.Font=Enum.Font.FredokaOne;label.TextColor3=color or P.white;label.TextStrokeColor3=P.dark;label.TextStrokeTransparency=.4;label.Parent=gui
 return base
end
local function arc(parent,name,center,r,from,to,steps,color,width,tilt)
 local previous=nil
 local basis=CF(center)*(tilt or CFrame.new())
 for i=0,steps do
  local a=from+(to-from)*i/steps;local q=(basis*CF(math.cos(a)*r,0,math.sin(a)*r)).Position
  if previous then beam(parent,name,previous,q,width,color,true)end;previous=q
 end
end
local function crate(parent,pos,size,color)
 local m=model('CargoCrate',parent);part(m,'StuddedBox',size,CF(pos),color or P.frame,nil,true)
 for _,x in {-size.X*.3,size.X*.3}do part(m,'Strap',V(.45,size.Y+.15,size.Z+.2),CF(pos+V(x,0,0)),P.dark)end
 return m
end
local function shard(parent,pos,height,color,angle)
 local m=model('EnergyCrystal',parent)
 local cf=CF(pos)*CFrame.Angles(.12,angle or 0,.12)
 part(m,'CrystalBody',V(height*.24,height*.55,height*.24),cf*CF(0,height*.275,0),color)
 local tip=part(m,'CrystalTip',V(height*.24,height*.45,height*.24),cf*CF(0,height*.775,0),color,'WedgePart');tip.Material=Enum.Material.Neon
 local facet=part(m,'CrystalFacet',V(height*.12,height*.55,height*.24),cf*CF(-height*.06,height*.275,0),color:Lerp(P.white,.2));facet.Material=Enum.Material.Neon
 for _,o in m:GetChildren()do if o:IsA('BasePart')then o.CanCollide=false end end
 return m
end
local art=model('ReferenceArt',nil)
-- Keep the landmarks loaded, and use a real sky instead of distant renderable walls.
root.ModelStreamingMode=Enum.ModelStreamingMode.Persistent
local enclosure=root:FindFirstChild('SpaceBackdrop');if enclosure then enclosure.Parent=backup end
-- Purple Nebula Space Skybox by Zalthen, Creator Store model 83555979203508.
local sky=game.Lighting.StarfallSky
for face,id in {SkyboxBk=129876530632297,SkyboxDn=108406529909981,SkyboxFt=104400530594543,SkyboxLf=73372229972523,SkyboxRt=87408857415924,SkyboxUp=137817405681365}do sky[face]='rbxassetid://'..id end
sky.CelestialBodiesShown=false;sky.StarCount=0
game:GetService('ContentProvider'):PreloadAsync({sky})
local clouds=root.Backdrop:FindFirstChild('ToyNebulaClouds');if clouds then clouds.Parent=backup end
for _,p in root.Backdrop:GetDescendants()do if p:IsA('MeshPart')then p.Color=P.rock end end
root.Backdrop.DistantPlanet.Color=C(35,24,69)

-- Restrained common palette; studs sit on surfaces designed to read as play space.
for _,o in hub:GetDescendants()do
 if o:IsA('BasePart')and not o:IsA('MeshPart')then
  if o.Material==Enum.Material.Glass then o.Material=Enum.Material.Plastic;o.Color=C(57,89,123);o.Transparency=.22
  elseif o.Material==Enum.Material.Neon then o.Color=o.Name=='DirectionArrow'and P.gold or P.cyan
  else o.Color=P.rock end
  o.Reflectance=0
 elseif o:IsA('PointLight')then o.Brightness=.35;o.Color=P.cyan
 end
end
local deck=hub.StationStructure
deck.DeckSurface.Color=P.floor;deck.DeckSurface.TopSurface=Enum.SurfaceType.Studs
deck.MainDeck.Color=P.dark;deck.LowerHull.Color=P.dark
for _,p in deck:GetChildren()do
 if p.Name=='PortWing'or p.Name=='StarboardWing'then p.Color=P.floor2;p.TopSurface=Enum.SurfaceType.Studs end
 if p.Name=='SideArmor'then p.Color=P.frame end
end
for _,p in hub.WalkingPaths:GetChildren()do
 p.Color=p.Name=='DirectionArrow'and P.gold or C(153,108,180)
 if p.Name=='DirectionArrow'then p.Size*=V(1.8,1,1.25)end
end
for _,p in hub.Railings:GetChildren()do p.Color=p.Name=='RailTop'and P.edge or P.rock end
local hangar=hub.Hangar
for _,p in hangar:GetChildren()do if p:IsA('BasePart')then
 if p.Name=='Floor'then p.Color=C(65,43,87);p.TopSurface=Enum.SurfaceType.Studs
 elseif p.Name=='DoorColumn'or p.Name=='DoorChamfer'then p.Color=P.frame
 elseif p.Name=='Roof'then p.Color=P.frame;p.TopSurface=Enum.SurfaceType.Studs
 elseif p.Name=='DoorLight'then p.Color=P.pink
 elseif p.Name=='WallRib'or p.Name=='RoofRib'then p.Color=C(67,62,86)
 end
end end
for _,n in {'StationName','HangarNumber'}do local old=hangar:FindFirstChild(n);if old then old.Parent=backup end end
sign(art,'StarfallSign','STARFALL',V(0,68,-15.5),Vector2.new(47,7),P.gold)
sign(art,'SalvagersSign','S A L V A G E R S',V(0,60,-15.5),Vector2.new(35,2.8),P.white)
for _,side in {-1,1}do
 part(art,'PortalButtress',V(10,6,13),CF(side*48,33,-18),P.frame,nil,true)
 glow(art,'PortalEnergy',V(.7,25,.55),CF(side*44,47,-15.5),P.pink)
 part(art,'LintelTrim',V(13,2,9),CF(side*41,64,-20)*CFrame.Angles(0,0,side*.65),P.edge,nil,true)
end
for _,p in hub.ObservationDeck:GetChildren()do if p:IsA('BasePart')then
 if p.Name=='RoomRoof'then p.Color=P.frame;p.TopSurface=Enum.SurfaceType.Studs
 elseif p.Name=='WindowFrame'or p.Name=='WindowMullion'then p.Color=P.edge
 end
end end
for _,t in hub.ObservationDeck:GetDescendants()do if t:IsA('TextLabel')then t.Text='OBSERVATORY';t.TextColor3=P.cyan end end
for _,p in hub.ObservationStairs:GetChildren()do if p:IsA('BasePart')then
 p.Color=p.Name=='StepNosing'and P.gold or P.frame
 if p.Name=='Step'then p.TopSurface=Enum.SurfaceType.Studs end
end end
for _,p in hub.Machinery:GetChildren()do if p:IsA('BasePart')then
 if p.Name=='CraneBeam'or p.Name=='Hook'then p.Color=P.gold else if p.Material~=Enum.Material.Neon then p.Color=P.frame end end
end end
for _,p in hub.CargoBays:GetChildren()do if p:IsA('BasePart')then p.Color=p.Name=='ContainerBand'and P.dark or P.purple end end

-- A layered irregular rock skirt replaces the thin floating tray silhouette.
local foundation=model('RockFoundation',nil)
local rand=Random.new(1317)
for i=1,18 do
 local a=i*math.pi*2/18;local pos=V(math.cos(a)*87,16+rand:NextNumber(-3,2),-5+math.sin(a)*72)
 local rock=part(foundation,'FacetedHullRock',V(rand:NextNumber(20,34),rand:NextNumber(20,31),rand:NextNumber(18,28)),CF(pos)*CFrame.Angles(.15,a,rand:NextNumber(-.18,.18)),i%3==0 and C(58,52,72)or P.rock,'WedgePart',true);rock.CanCollide=false
end
for i=1,9 do local a=i*math.pi*2/9;part(foundation,'LowerFragment',V(23,19,24),CF(math.cos(a)*49,4,-9+math.sin(a)*44)*CFrame.Angles(.4,a,.3),P.dark,'CornerWedgePart').CanCollide=false end
-- Bound rotated decorations below the deck; their unrotated height is insufficient.
for _,p in foundation:GetChildren()do if p:IsA('BasePart')then
 local cf=p.CFrame;local s=p.Size*.5
 local extent=math.abs(cf.RightVector.Y)*s.X+math.abs(cf.UpVector.Y)*s.Y+math.abs(cf.LookVector.Y)*s.Z
 local top=p.Position.Y+extent
 if top>25 then p.CFrame-=V(0,top-25,0)end
end end
foundation.Parent=art;task.wait()

-- Hand-built craft: broad studded wings, wedge noses, inset cockpits, compact engines.
for _,name in {'DockedFleet','StuddedShipArmor','LandingPads','SALVAGE','SHIP UPGRADES'}do local old=hub:FindFirstChild(name);if old then old.Parent=backup end end
local fleet=model('DockedFleet',nil)
local function ship(parent,name,pos,yaw,scale,accent)
 local m=model(name,parent);local cf=CF(pos)*CFrame.Angles(0,yaw,0)
 local function p(n,s,offset,color,class,rot,studs)
  local o=part(m,n,s*scale,cf*CF(offset*scale)*(rot or CFrame.new()),color,class,studs);o.CanCollide=false;return o
 end
 p('Hull',V(8,4,20),V(0,4,0),P.frame,nil,nil,true)
 p('Nose',V(8,4,8),V(0,4,14),P.frame,'WedgePart',CFrame.Angles(0,math.pi,0),true)
 p('CockpitFrame',V(6,3,9),V(0,7,4),P.dark,'WedgePart',CFrame.Angles(0,math.pi,0))
 p('CockpitGlass',V(4.8,.4,5.5),V(0,7.75,5),C(71,174,200),nil,CFrame.Angles(.3,0,0))
 p('Spine',V(3,1,12),V(0,6.5,-6),accent,nil,nil,true)
 for _,side in {-1,1}do
  p('Wing',V(10,1.7,13),V(side*8,3.5,-1),P.rock,nil,CFrame.Angles(0,side*.13,side*.07),true)
  p('WingPanel',V(6,.6,8),V(side*9,4.7,-1),accent,nil,CFrame.Angles(0,side*.13,side*.07),true)
  p('TailFin',V(1.4,6,6),V(side*6,6,-9),P.frame,'WedgePart',nil,true)
  p('EngineHousing',V(5,4,9),V(side*7,3.5,-10),P.dark,nil,nil,true)
  local e=p('Engine',V(1,3,3),V(side*7,3.5,-15),P.gold,nil,CFrame.Angles(0,math.pi/2,0));e.Shape=Enum.PartType.Cylinder;e.Material=Enum.Material.Neon
  p('LandingGear',V(1.3,3,1.3),V(side*5,1.5,3),P.dark)
  p('Foot',V(3,.5,4),V(side*5,.3,3),P.edge)
 end
 p('NoseGear',V(1.2,3,1.2),V(0,1.5,10),P.dark)
 return m
end
ship(fleet,'SalvageShuttle',V(-49,32,53),-.18,1,P.purple)
ship(fleet,'SurveySkiff',V(49,32,53),.22,.9,C(69,137,162))
ship(fleet,'HangarShip',V(-5,31,-58),0,1.25,P.purple)
fleet.Parent=hub
local pads=model('LandingPads',nil)
for i,x in {-49,49}do
 part(pads,'PadFoundation',V(39,1.8,37),CF(x,30.9,53),P.dark,nil,true)
 part(pads,'PadSurface',V(35,.5,33),CF(x,32,53),C(64,48,86),nil,true)
 for _,side in {-1,1}do
  glow(pads,'LandingGuide',V(.5,.18,25),CF(x+side*17,32.4,53),i==1 and P.pink or P.cyan)
  part(pads,'CornerBumper',V(3,1.8,3),CF(x+side*18,33,37),P.edge,nil,true)
 end
 sign(pads,'PadNumber','0'..i,V(x,33.8,72),Vector2.new(6,3),P.gold)
end
pads.Parent=hub;task.wait()

-- Real booths create a little salvage market, with legible silhouettes and stocked shelves.
local market=model('Market',nil)
for side=-1,1,2 do
 local x=side*72;local booth=model(side<0 and 'SalvageShop'or 'UpgradeShop',market)
 part(booth,'Base',V(24,1,22),CF(x,31,3),P.dark,nil,true)
 part(booth,'BackWall',V(24,13,2),CF(x,38,-7),P.frame,nil,true)
 for _,dx in {-10,10}do part(booth,'Pillar',V(2.4,17,2.4),CF(x+dx,39,11),P.frame,nil,true)end
 part(booth,'Canopy',V(28,3,25),CF(x,48,3),P.rock,nil,true)
 for i=-2,2 do part(booth,'AwningStripe',V(2.8,.45,25.3),CF(x+i*5,49.75,3),i%2==0 and P.purple or P.frame,nil,true)end
 part(booth,'Counter',V(23,6,6),CF(x,34,10),P.rock,nil,true)
 part(booth,'CounterTop',V(25,1,7),CF(x,37.5,10),P.edge,nil,true)
 sign(booth,'ShopSign',side<0 and 'SELL SALVAGE'or 'UPGRADES',V(x,45,16),Vector2.new(25,4.4),side<0 and P.gold or P.cyan)
 part(booth,'Shelf',V(19,.7,4),CF(x,39,-4),P.dark,nil,true)
 if side<0 then
  crate(booth,V(x-6,34,-2),V(7,5,7),P.purple);crate(booth,V(x+5,34,-2),V(6,5,6),P.frame)
  shard(booth,V(x,38,10),5,P.pink,.4)
 else
  for i=-1,1 do local c=cylinder(booth,'EngineUpgrade',V(x+i*6,41,-4),1.8,3,P.frame);glow(booth,'CoreIndicator',V(1.5,.2,1.5),CF(x+i*6,42.6,-4),P.cyan)end
  crate(booth,V(x-4,34,-1),V(9,5,6),P.frame)
 end
end
market.Parent=hub
-- Move the chart to the plaza center and give it one distinctive orbital sculpture.
local console=hub.NavigationConsole
for _,o in console:GetDescendants()do if o:IsA('BasePart')then o.CFrame+=V(-28,0,-3)end end
for _,p in console:GetChildren()do if p:IsA('BasePart')then
 if p.Name=='Base'then p.Color=P.dark
 elseif p.Name=='MapTable'then p.Color=P.frame;p.TopSurface=Enum.SurfaceType.Studs
 elseif p.Name=='Hologram'then p.Color=P.purple;p.Transparency=.35
 end
end end
local old=console:FindFirstChild('NavigationLabel');if old then old.Parent=backup end
sign(console,'NavigationLabel','STAR CHART',V(0,34,14),Vector2.new(15,2.8),P.gold)
local orb=glow(console,'ChartOrb',V(4.5,4.5,4.5),CF(0,42,5),P.cyan);orb.Shape=Enum.PartType.Ball
arc(console,'OrbitSculpture',V(0,42,5),4,0,math.pi*2,28,P.gold,.25,CFrame.Angles(.5,0,.4))
-- Small props intentionally hug the edges and leave the central lane clear.
for _,d in {{V(-92,34,48),P.purple},{V(-86,34,57),P.frame},{V(87,34,43),P.frame},{V(90,39,44),P.purple},{V(-35,34,-9),P.frame}}do crate(art,d[1],V(6,6,6),d[2])end
for _,side in {-1,1}do
 part(art,'BenchSeat',V(13,1,4),CF(side*29,33.3,22),P.frame,nil,true)
 for _,dx in {-4,4}do part(art,'BenchLeg',V(1.5,2.6,3),CF(side*29+dx,31.8,22),P.dark)end
 local pole=part(art,'PlazaLamp',V(1.5,10,1.5),CF(side*24,35.5,4),P.frame)
 glow(art,'LampLantern',V(3,2,3),CF(side*24,41,4),P.gold)
end
-- Asymmetry: a compact antenna and solar panel silhouette on one side of the roof.
part(art,'AntennaBase',V(10,4,10),CF(-31,76,-48),P.rock,nil,true)
part(art,'AntennaMast',V(2,19,2),CF(-31,87,-48),P.edge,nil,true)
local dish=cylinder(art,'Dish',V(-31,96,-48),6,1.3,P.frame);dish.CFrame*=CFrame.Angles(.45,0,0)
glow(art,'AntennaBeacon',V(1.5,1.5,1.5),CF(-31,99,-48),P.pink)
for i=1,3 do part(art,'SolarPanel',V(15,.8,7),CF(-40,80,-57-i*9)*CFrame.Angles(0,0,.18),C(50,45,88),nil,true)end
art.Parent=root;task.wait()

-- Recompose the surrounding scenery. The carrier becomes distant scenery, not a toy over the roof.
for _,sector in root.Sectors:GetChildren()do
 for _,p in sector:GetDescendants()do if p:IsA('MeshPart')then p.Color=P.rock;p.Material=Enum.Material.Plastic;p.TextureID='' end end
end
local derelict=root.Sectors.DerelictField
local oldCarrier=derelict:FindFirstChild('BrokenCarrier');if oldCarrier then oldCarrier.Parent=backup end
local wreck=model('BrokenCarrier',nil)
local wr=ship(wreck,'ForwardHull',V(65,102,-410),-.2,4.8,P.frame)
derelict:SetAttribute('LandmarkCenter',V(65,120,-410))
-- Separate two blocky engine modules and surround them with dark floating shards.
for side=-1,1,2 do
 part(wreck,'BrokenEngineModule',V(20,18,40),CF(65+side*36,108,-455)*CFrame.Angles(.14,side*.17,side*.2),P.frame,nil,true)
 glow(wreck,'EngineCore',V(11,9,.6),CF(65+side*36,108,-433)*CFrame.Angles(0,side*.17,0),P.pink)
end
wreck.Parent=derelict
for _,p in derelict:GetChildren()do if p.Name=='ExposedHullRib'then p.Transparency=1 end end
-- Ice: jagged angular ridges and studded ledges, with an uneven skyline.
local ice=root.Sectors.IceGraveyard
for _,m in ice:GetChildren()do if m.Name=='ShatteredMoon'or m.Name=='FrozenFragment'then m.Parent=backup end end
local glacier=model('ShatteredMoon',nil);local ip=V(-300,98,-260)
ice:SetAttribute('LandmarkCenter',V(-300,120,-260))
part(glacier,'FrozenShelf',V(87,4,65),CF(ip),C(94,162,192),nil,true).CanCollide=false
for i=1,9 do
 local h=({31,42,30,58,47,70,43,54,27})[i];local x=(i-5)*9
 part(glacier,'IceCliff',V(12,h,30),CF(ip+V(x,h*.5,-14))*CFrame.Angles(0,(i%3-1)*.1,(i%2==0 and -.06 or .06)),i%2==0 and C(139,203,224)or C(74,140,177),'WedgePart',true).CanCollide=false
end
for i=1,5 do shard(glacier,ip+V(-33+i*12,3,12+i%2*8),12+i%3*7,P.cyan,i*.9)end
glacier.Parent=ice;task.wait()
-- Ruins: heavy dark uprights, a broken golden energy arch, and magenta crystal growths.
local ruins=root.Sectors.AncientRuins
local oldGate=ruins:FindFirstChild('AncientGateway');if oldGate then oldGate.Parent=backup end
local gate=model('AncientGateway',nil);local gp=V(280,110,195)
for side=-1,1,2 do
 for i=1,5 do
  part(gate,'StuddedMonolith',V(14,13,17),CF(gp+V(side*(36-i),i*12-6,-3))*CFrame.Angles(0,side*.06,side*.035),i%2==0 and P.frame or P.rock,nil,true).CanCollide=false
 end
 part(gate,'BrokenCrown',V(28,12,18),CF(gp+V(side*23,66,-3))*CFrame.Angles(0,0,side*.2),P.frame,'WedgePart',true).CanCollide=false
 glow(gate,'Rune',V(1.1,35,.6),CF(gp+V(side*31,34,6)),P.pink)
end
arc(gate,'GoldenPortal',gp+V(0,31,5),28,-.28,math.pi*.87,32,P.gold,1.7,CFrame.Angles(math.pi/2,0,0))
arc(gate,'GoldenPortal',gp+V(0,31,5),28,math.pi*1.1,math.pi*1.87,27,P.gold,1.7,CFrame.Angles(math.pi/2,0,0))
for i=1,7 do shard(gate,gp+V((i-4)*13,-14,14+i%2*12),12+i%4*5,P.pink,i*.6)end
gate.Parent=ruins
local temple=ruins.TempleFragment;temple:ScaleTo(temple:GetScale()*.8)
for _,p in ruins:GetDescendants()do if p.Name=='RelicShard'then p.Color=P.pink end end
-- Salvage crane gets a studded working ledge, cargo, and visible ore.
local scrap=root.Sectors.ScrapBelt;local sp=V(-215,96,65)
local rig=scrap.SalvageRig
for _,p in rig:GetChildren()do if p:IsA('BasePart')then p.Color=(p.Name=='CraneTower'or p.Name=='CraneArm')and P.gold or P.frame;p.TopSurface=Enum.SurfaceType.Studs end end
for i=1,4 do shard(scrap,sp+V(-35+i*13,-5,21+i%2*5),7+i%3*4,P.gold,i)end
for _,p in root.Sectors.NebulaCurrent:GetChildren()do
 if p.Name=='IonFilament'then p.Color=p.Color.G>p.Color.R and P.cyan or P.pink;p.Transparency=.2;p.Size=V(1.8,1.8,p.Size.Z)
 elseif p.Name=='Pulsar'then p.Color=P.gold end
end
for _,p in root.Sectors.SingularityEdge:GetChildren()do if p.Name=='AccretionStream'then p.Color=P.gold;p.Transparency=math.min(p.Transparency,.35);p.Size=V(1.8,1.8,p.Size.Z)end end
-- Sparse close fragments add depth below the deck without blocking the skyline.
local nearby=model('NearbyDebris',nil)
for i=1,10 do
 local a=i*math.pi*2/10;local r=rand:NextNumber(125,180)
 local p=part(nearby,'FloatingFragment',V(rand:NextNumber(8,17),rand:NextNumber(8,15),rand:NextNumber(10,19)),CF(math.cos(a)*r,rand:NextNumber(-18,8),math.sin(a)*r)*CFrame.Angles(.4,a,.2),P.rock,'WedgePart',true);p.CanCollide=false
end
nearby.Parent=art
-- Soft particle clouds supply faint purple depth without overlapping solid mesh bubbles.
local haze=model('DistantHaze',art)
for i,pos in {V(-260,230,-610),V(220,260,-680),V(-580,190,40)}do
 local anchor=deco(part(haze,'CloudAnchor',V(1,1,1),CF(pos),P.dark));anchor.Transparency=1
 local cloud=Instance.new('ParticleEmitter');cloud.Name='NebulaMist';cloud.Texture='rbxasset://textures/particles/smoke_main.dds';cloud.Color=ColorSequence.new(C(71,27,119));cloud.Size=NumberSequence.new(290);cloud.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.25,.965),NumberSequenceKeypoint.new(.75,.965),NumberSequenceKeypoint.new(1,1)});cloud.Lifetime=NumberRange.new(30);cloud.Rate=.15;cloud.Speed=NumberRange.new(0);cloud.Rotation=NumberRange.new(-180,180);cloud.RotSpeed=NumberRange.new(-1,1);cloud.LightEmission=.7;cloud.LightInfluence=0;cloud.LockedToPart=true;cloud.Parent=anchor
end
local L=game.Lighting;L.ClockTime=14;L.Brightness=2;L.Ambient=C(167,149,185);L.OutdoorAmbient=C(167,149,185);L.ExposureCompensation=.15
L.StarfallColor.Contrast=.08;L.StarfallColor.Saturation=.09
L.StarfallBloom.Intensity=.45;L.StarfallBloom.Size=32;L.StarfallBloom.Threshold=1.1
workspace.CurrentCamera.CFrame=CFrame.lookAt(V(120,100,155),V(0,46,-15))
return {ArtDirection='Purple studs, charcoal silhouettes, gold and magenta energy',Parts=#art:GetDescendants(),Backup=backup:GetFullName()}
