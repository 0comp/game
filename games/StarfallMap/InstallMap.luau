-- Starfall Salvagers local map installer. Run in Studio Command Bar while stopped.
-- Refuses to overwrite an existing Workspace.StarfallMap.
local function buildMap()
assert(not workspace:FindFirstChild('StarfallMap'),'Preserve the existing StarfallMap before reinstalling')
local root=Instance.new('Model');root.Name='StarfallMap';root.Parent=workspace
local backup=game.ServerStorage:FindFirstChild('StarfallOriginalScene')or Instance.new('Folder');backup.Name='StarfallOriginalScene';backup.Parent=game.ServerStorage
for _,name in {'Baseplate','SpawnLocation'}do local p=workspace:FindFirstChild(name);if p then p.Parent=backup end end
local lighting=Instance.new('Folder');lighting.Name='Lighting';lighting.Parent=backup
for _,e in game.Lighting:GetChildren()do e.Parent=lighting end
local bloom=Instance.new('BloomEffect');bloom.Name='StarfallBloom';bloom.Parent=game.Lighting
local color=Instance.new('ColorCorrectionEffect');color.Name='StarfallColor';color.Parent=game.Lighting
local sky=Instance.new('Sky');sky.Name='StarfallSky';sky.CelestialBodiesShown=false;sky.Parent=game.Lighting
local box=Instance.new('Model');box.Name='SpaceBackdrop';box.Parent=root
for _,d in {{Vector3.new(1000,400,0),Vector3.new(2,2048,2048)},{Vector3.new(-1000,400,0),Vector3.new(2,2048,2048)},{Vector3.new(0,1400,0),Vector3.new(2048,2,2048)},{Vector3.new(0,-600,0),Vector3.new(2048,2,2048)},{Vector3.new(0,400,1000),Vector3.new(2048,2048,2)},{Vector3.new(0,400,-1000),Vector3.new(2048,2048,2)}}do
 local p=Instance.new('Part');p.Name='Space';p.Position=d[1];p.Size=d[2];p.Color=Color3.new();p.Material=Enum.Material.Neon;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=box
end
game.Players.CharacterAutoLoads=true
return root

end
buildMap()
local function polishMap()
-- Generated model assets owned by this map's authoring session.
local specs={Asteroid=109161846061376,Derelict=71697835508122,AlienGate=113296818406753,IceMoon=125222352024053}
local kit=game.ServerStorage:FindFirstChild('StarfallMeshKit') or Instance.new('Folder')
kit.Name='StarfallMeshKit';kit.Parent=game.ServerStorage
for name,id in specs do
 if not kit:FindFirstChild(name)then
  local loaded=game:GetService('InsertService'):LoadAsset(id)
  loaded.Name=name;loaded.Parent=kit
  for _,p in loaded:GetDescendants()do if p:IsA('BasePart')then p.Anchored=true end end
  task.wait()
 end
end
return kit

end
polishMap()
local function detailMap()
-- Version 2 station rebuild. Preserve the previous authored scene before replacing it.
local C=Color3.fromRGB
local V=Vector3.new
local root=workspace:WaitForChild('StarfallMap')
local archive=Instance.new('Folder');archive.Name='StarfallV1Archive';archive.Parent=game.ServerStorage
for _,name in {'Hub','Sectors','Routes','Backdrop'} do local old=root:FindFirstChild(name);if old then old.Parent=archive end end
local navy=C(29,43,57);local steel=C(99,119,133);local armor=C(166,183,191);local dark=C(12,22,32)
local cyan=C(101,214,228);local orange=C(227,148,66);local white=C(221,231,231)
local function model(name,parent)local m=Instance.new('Model');m.Name=name;m.Parent=parent;return m end
local function p(parent,name,size,cf,color,material,class)
 local o=Instance.new(class or 'Part');o.Name=name;o.Size=size;o.CFrame=cf;o.Color=color or navy;o.Material=material or Enum.Material.SmoothPlastic;o.Anchored=true;o.TopSurface=Enum.SurfaceType.Smooth;o.BottomSurface=Enum.SurfaceType.Smooth;o.Parent=parent;return o
end
local function deco(o)o.CanCollide=false;o.CanTouch=false;o.CastShadow=false;return o end
local function cyl(parent,name,pos,r,length,color,cf,mat)
 local o=p(parent,name,V(length,r*2,r*2),CFrame.new(pos)*(cf or CFrame.Angles(0,0,math.pi/2)),color,mat);o.Shape=Enum.PartType.Cylinder;return o
end
local function beam(parent,name,a,b,w,color,mat)
 return p(parent,name,V(w,w,(b-a).Magnitude),CFrame.lookAt((a+b)*.5,b),color,mat)
end
local function glow(parent,name,size,cf,color)
 return deco(p(parent,name,size,cf,color,Enum.Material.Neon))
end
local function sign(parent,name,text,cf,size,color)
 local base=deco(p(parent,name,V(size.X,size.Y,.3),cf,dark))
 for _,face in {Enum.NormalId.Front,Enum.NormalId.Back} do
  local g=Instance.new('SurfaceGui');g.Face=face;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=35;g.LightInfluence=0;g.Parent=base
  local t=Instance.new('TextLabel');t.BackgroundTransparency=1;t.Size=UDim2.fromScale(.94,.8);t.Position=UDim2.fromScale(.03,.1);t.Text=text;t.Font=Enum.Font.GothamBold;t.TextScaled=true;t.TextColor3=color or white;t.Parent=g
 end
end
local function lamp(parent,pos,color,range,brightness)
 local o=glow(parent,'LightFixture',V(4,.25,1.2),CFrame.new(pos),color)
 local l=Instance.new('PointLight');l.Color=color;l.Range=range;l.Brightness=brightness;l.Shadows=false;l.Parent=o
end
local hub=model('Hub',nil)
local deck=model('StationStructure',hub)
p(deck,'MainDeck',V(156,5,174),CFrame.new(0,27.5,-4),navy)
p(deck,'PortWing',V(26,5,130),CFrame.new(-90,27.5,-4),navy)
p(deck,'StarboardWing',V(26,5,130),CFrame.new(90,27.5,-4),navy)
p(deck,'LowerHull',V(142,12,150),CFrame.new(0,19,-9),dark)
p(deck,'DeckSurface',V(152,.4,170),CFrame.new(0,30.2,-4),steel)
-- Armored skirts and structural diagonal braces give the station a thick silhouette.
for _,side in {-1,1} do
 p(deck,'SideArmor',V(9,15,126),CFrame.new(side*83,20,-5)*CFrame.Angles(0,0,side*.2),armor)
 for i=1,6 do
  local z=-74+i*23
  beam(deck,'HullBrace',V(side*64,11,z-7),V(side*91,27,z+7),3.2,steel)
  glow(deck,'HullMarker',V(.4,1.3,5),CFrame.new(side*88,23,z),cyan)
 end
end
-- Paint markings stay flat on the walking surface.
local paths=model('WalkingPaths',hub)
for z=-17,73,9 do
 for _,x in {-9,9} do deco(p(paths,'PathEdge',V(.65,.08,6),CFrame.new(x,30.5,z),white)) end
end
for x=-68,68,9 do for _,z in {-1,11} do deco(p(paths,'CrossPath',V(6,.08,.6),CFrame.new(x,30.5,z),white))end end
for z=14,65,17 do
 local a=deco(p(paths,'DirectionArrow',V(.6,.08,4),CFrame.new(-1.3,30.55,z)*CFrame.Angles(0,-.55,0),orange))
 deco(p(paths,'DirectionArrow',V(.6,.08,4),CFrame.new(1.3,30.55,z)*CFrame.Angles(0,.55,0),orange))
end
-- Open-front hangar with a broad opening, roof ribs, interior bays and angled lintels.
local hangar=model('Hangar',hub)
p(hangar,'Floor',V(104,.5,72),CFrame.new(0,30.55,-56),C(60,76,88))
p(hangar,'RearWall',V(106,39,4),CFrame.new(0,50,-91),navy)
p(hangar,'Roof',V(112,4,76),CFrame.new(0,70,-56),armor)
for _,side in {-1,1} do
 p(hangar,'HangarSideWall',V(4,39,72),CFrame.new(side*54,50,-56),navy)
 p(hangar,'DoorColumn',V(7,34,8),CFrame.new(side*48,47,-20),armor)
 p(hangar,'DoorChamfer',V(12,10,8),CFrame.new(side*41,63,-20)*CFrame.Angles(0,0,side*.65),armor)
 glow(hangar,'DoorLight',V(.3,22,.5),CFrame.new(side*44,48,-15.8),cyan)
 p(hangar,'DoorFooter',V(10,5,10),CFrame.new(side*48,33,-19),dark)
 for j=1,4 do
  local z=-22-j*15
  p(hangar,'WallRib',V(5,37,2),CFrame.new(side*51.4,50,z),steel)
  p(hangar,'RoofRib',V(50,2,2),CFrame.new(side*26,67,z)*CFrame.Angles(0,0,-side*.06),steel)
 end
end
p(hangar,'DoorHeader',V(81,8,8),CFrame.new(0,67,-20),navy)
sign(hangar,'StationName','STARFALL  /  SALVAGE OPERATIONS',CFrame.new(0,67,-15.7),Vector2.new(70,4),white)
sign(hangar,'HangarNumber','HANGAR  01',CFrame.new(-36,40,-16),Vector2.new(15,3),orange)
for _,x in {-37,0,37} do lamp(hangar,V(x,65,-47),C(243,203,150),43,.65) end
for _,x in {-44,44} do lamp(hangar,V(x,43,-84),cyan,23,.4) end
-- Observation room above the hangar. Clear glazing is framed by repeated mullions.
local observation=model('ObservationDeck',hub)
p(observation,'MezzanineFloor',V(124,3,25),CFrame.new(0,73,-84),steel)
p(observation,'RoomBack',V(78,19,2),CFrame.new(0,84,-95),navy)
p(observation,'RoomRoof',V(84,3,26),CFrame.new(0,94,-83),armor)
for i=-3,3 do
 local x=i*11
 local pane=p(observation,'ObservationWindow',V(10.3,14,.3),CFrame.new(x,83,-70.3),C(99,180,201),Enum.Material.Glass);pane.Transparency=.66
 p(observation,'WindowMullion',V(.7,17,1),CFrame.new(x-5.4,83,-70),steel)
end
for _,y in {75,91} do p(observation,'WindowFrame',V(78,1.3,1),CFrame.new(0,y,-70),steel) end
p(observation,'RoomSide',V(2,19,23),CFrame.new(-40,84,-83),navy)
p(observation,'DoorSideRear',V(2,19,7),CFrame.new(40,84,-91.5),navy)
p(observation,'DoorSideFront',V(2,19,7),CFrame.new(40,84,-74.5),navy)
p(observation,'DoorLintel',V(2,5,10),CFrame.new(40,91,-83),navy)
sign(observation,'ControlLabel','FLIGHT CONTROL',CFrame.new(0,92,-69.2),Vector2.new(38,2.3),cyan)
for i=-2,2 do
 p(observation,'ControlDesk',V(8,3,5),CFrame.new(i*12,77,-76),dark)
 glow(observation,'ControlDisplay',V(6,.25,3),CFrame.new(i*12,79,-76)*CFrame.Angles(-.2,0,0),cyan)
end
-- Walkable stairs, a landing, and rails connect the main deck to observation.
local stairs=model('ObservationStairs',hub)
for i=1,32 do
 local rise=44.5/32
 p(stairs,'Step',V(12,rise+.02,2.4),CFrame.new(64,30+i*rise-rise*.5,-17-i*2.25),steel)
 deco(p(stairs,'StepNosing',V(11,.12,.5),CFrame.new(64,30+i*rise+.1,-15.8-i*2.25),orange))
end
p(stairs,'UpperLanding',V(22,3,8),CFrame.new(58,73,-93),steel)
for _,x in {57,71} do beam(stairs,'StairRail',V(x,35,-22),V(x,79,-89),.7,armor) end
-- Industrial work cells, overhead lifting crane, pipes and reactors.
local machinery=model('Machinery',hub)
p(machinery,'CraneBeam',V(87,3,4),CFrame.new(0,60,-57),orange)
p(machinery,'CraneCarriage',V(9,6,8),CFrame.new(-15,57,-57),dark)
beam(machinery,'HoistCable',V(-15,54,-57),V(-15,43,-57),.35,steel)
p(machinery,'Hook',V(3,.7,2),CFrame.new(-14,42,-57),orange)
for _,side in {-1,1} do
 for i=1,3 do
  local z=-35-i*14
  p(machinery,'WorkCell',V(12,7,8),CFrame.new(side*40,34,z),dark)
  glow(machinery,'StatusPanel',V(3,1,.2),CFrame.new(side*40,36,z+4.1),i%2==0 and cyan or orange)
  cyl(machinery,'CoolantPipe',V(side*47,44,z),1,11,steel,CFrame.Angles(0,math.pi/2,0))
 end
 cyl(machinery,'ReactorPod',V(side*67,36,-63),5,15,steel)
 cyl(machinery,'ReactorCap',V(side*67,44,-63),5.5,2,navy)
 glow(machinery,'ReactorIndicator',V(1,8,.25),CFrame.new(side*67,36,-57.8),cyan)
end
-- Broad painted landing pads replace the small docking arms.
local pads=model('LandingPads',hub)
for i,x in {-49,49} do
 cyl(pads,'PadBase',V(x,31,53),23,.8,navy)
 for j=1,12 do
  local a=j*math.pi/6
  deco(p(pads,'PadPaint',V(.5,.1,8),CFrame.new(x+math.cos(a)*20,31.5,53+math.sin(a)*20)*CFrame.Angles(0,-a,0),orange))
 end
 deco(p(pads,'PadCenter',V(7,.1,1),CFrame.new(x,31.5,53),white))
 deco(p(pads,'PadCenter',V(1,.1,7),CFrame.new(x,31.5,53),white))
 for _,z in {31,75} do lamp(pads,V(x,32,z),cyan,14,.25) end
 sign(pads,'PadNumber','0'..i,CFrame.new(x,34,79),Vector2.new(5,3),orange)
end
-- Physical station signage and service counters.
for _,s in {{'SALVAGE',-62,9,orange},{'SHIP UPGRADES',62,9,cyan}} do
 local service=model(s[1],hub)
 p(service,'ServiceCounter',V(19,5,9),CFrame.new(s[2],33,s[3]),navy)
 p(service,'CounterSurface',V(20,.6,10),CFrame.new(s[2],36,s[3]),armor)
 sign(service,'ServiceLabel',s[1],CFrame.new(s[2],41,s[3]-2),Vector2.new(20,3),s[4])
 glow(service,'Terminal',V(6,.3,4),CFrame.new(s[2],36.6,s[3]),s[4])
end
-- Keep the client controller's stable navigation-console path.
local console=model('NavigationConsole',hub)
cyl(console,'Base',V(28,33,8),5,5,navy)
cyl(console,'MapTable',V(28,36,8),7,1,armor)
local glass=cyl(console,'Hologram',V(28,37,8),5.7,.2,cyan,nil,Enum.Material.Neon);glass.Transparency=.8;deco(glass)
for i=1,6 do local a=i*math.pi/3;glow(console,'SectorDot',V(.7,.7,.7),CFrame.new(28+math.cos(a)*4,38,8+math.sin(a)*4),cyan) end
sign(console,'NavigationLabel','NAVIGATION',CFrame.new(28,39,1),Vector2.new(12,2),cyan)
local prompt=Instance.new('ProximityPrompt');prompt.Name='OpenStarChart';prompt.ObjectText='Navigation console';prompt.ActionText='Open star chart';prompt.MaxActivationDistance=16;prompt.HoldDuration=0;prompt.RequiresLineOfSight=false;prompt.Parent=console.Base
-- Cargo stacks arranged in bays leave the marked paths clear.
local cargo=model('CargoBays',hub)
for side=-1,1,2 do for row=1,3 do for stack=1,2 do
 local x=side*(82+(stack-1)*7);local z=-15-row*10
 p(cargo,'Container',V(6,5,8),CFrame.new(x,33,z),row%2==0 and orange or navy)
 for _,dx in {-2,2} do p(cargo,'ContainerBand',V(.3,5.2,8.2),CFrame.new(x+dx,33,z),steel) end
end end end
-- Perimeter railings protect the main deck without boxing in the view.
local rails=model('Railings',hub)
for side=-1,1,2 do
 for z=-70,70,14 do
  p(rails,'RailPost',V(.8,4,.8),CFrame.new(side*101,32.5,z),steel)
  p(rails,'RailTop',V(.8,.6,14),CFrame.new(side*101,34.5,z+7),armor)
 end
end
for x=-70,70,14 do
 p(rails,'RailPost',V(.8,4,.8),CFrame.new(x,32.5,81),steel)
 p(rails,'RailTop',V(14,.6,.8),CFrame.new(x+7,34.5,81),armor)
end
local spawn=Instance.new('SpawnLocation');spawn.Name='StationSpawn';spawn.Size=V(8,1,8);spawn.CFrame=CFrame.new(0,31,58);spawn.Anchored=true;spawn.Transparency=1;spawn.Neutral=true;spawn.Duration=0;spawn.Parent=hub
hub.Parent=root
local L=game.Lighting;L.ClockTime=14;L.Brightness=2;L.Ambient=C(83,98,118);L.OutdoorAmbient=C(90,106,128);L.ExposureCompensation=.1
L.StarfallBloom.Intensity=.17;L.StarfallBloom.Threshold=1.8
L.StarfallColor.Contrast=.06;L.StarfallColor.Saturation=-.04
workspace.CurrentCamera.CFrame=CFrame.lookAt(V(155,135,190),V(0,48,-18))
return {StationInstances=#hub:GetDescendants(),Archive=archive:GetFullName()}

end
detailMap()
local function landmarkMap()
local C=Color3.fromRGB;local V=Vector3.new
local root=workspace.StarfallMap;local kit=game.ServerStorage.StarfallMeshKit
if not kit:FindFirstChild('IceMoon') then
 local ice=game.CollectionService:GetTagged('Assistant-09f6ffe9-3ec9-4e30-8018-d54e46c176b2')[1];assert(ice,'Ice mesh is required');ice.Name='IceMoon';ice.Parent=kit
end
local function model(name,parent)local m=Instance.new('Model');m.Name=name;m.Parent=parent;return m end
local function p(parent,name,size,cf,color,mat)
 local o=Instance.new('Part');o.Name=name;o.Size=size;o.CFrame=cf;o.Color=color;o.Material=mat or Enum.Material.SmoothPlastic;o.Anchored=true;o.CanCollide=false;o.CanTouch=false;o.CastShadow=false;o.Parent=parent;return o
end
local function line(parent,name,a,b,w,color,alpha)
 local o=p(parent,name,V(w,w,(b-a).Magnitude),CFrame.lookAt((a+b)*.5,b),color,Enum.Material.Neon);o.Transparency=alpha or 0;return o
end
local function asset(key,parent,name,pos,maxSize,rotation)
 local m=kit[key]:Clone();m.Name=name
 local cf,size=m:GetBoundingBox();m.WorldPivot=cf;m:ScaleTo(maxSize/math.max(size.X,size.Y,size.Z));m:PivotTo(CFrame.new(pos)*(rotation or CFrame.new()))
 for _,o in m:GetDescendants()do if o:IsA('BasePart')then o.Anchored=true;o.CanCollide=false;o.CanTouch=false end end
 m.Parent=parent;return m
end
local sectors=model('Sectors',root);local routes=model('Routes',root)
local rand=Random.new(483)
local centers={ScrapBelt=V(-215,60,65),IceGraveyard=V(-305,135,-225),DerelictField=V(80,150,-340),NebulaCurrent=V(-235,150,300),AncientRuins=V(280,70,195),SingularityEdge=V(385,200,-120)}
local colors={ScrapBelt=C(216,155,88),IceGraveyard=C(108,204,226),DerelictField=C(113,156,197),NebulaCurrent=C(131,100,196),AncientRuins=C(164,108,207),SingularityEdge=C(215,92,146)}
for id,center in centers do
 local m=model(id,nil);m:SetAttribute('SectorId',id);m:SetAttribute('LandmarkCenter',center)
 local color=colors[id]
 -- Debris follows an uneven arc instead of identical circular pedestals.
 for i=1,12 do
  local a=i*.48;local r=rand:NextNumber(45,90)
  asset('Asteroid',m,'Debris',center+V(math.cos(a)*r,rand:NextNumber(-30,18),math.sin(a)*r),rand:NextNumber(8,22),CFrame.Angles(rand:NextNumber(),a,rand:NextNumber()))
 end
 if id=='ScrapBelt' then
  asset('Asteroid',m,'SalvageAsteroid',center,86,CFrame.Angles(.25,.5,-.2))
  local rig=model('SalvageRig',m)
  p(rig,'Platform',V(38,3,27),CFrame.new(center+V(0,35,0)),C(64,78,87))
  for _,x in {-14,14}do p(rig,'CraneTower',V(3,35,4),CFrame.new(center+V(x,53,-7)),C(201,139,71))end
  p(rig,'CraneArm',V(47,4,4),CFrame.new(center+V(4,70,-7))*CFrame.Angles(0,0,-.12),C(201,139,71))
  line(rig,'Cable',center+V(23,69,-7),center+V(23,42,-7),.35,C(96,116,128),.2)
  for i=1,5 do p(rig,'Cargo',V(6,5,8),CFrame.new(center+V(-12+i*5,39,5)),i%2==0 and color or C(56,68,79))end
 elseif id=='IceGraveyard' then
  asset('IceMoon',m,'ShatteredMoon',center+V(0,25,0),135,CFrame.Angles(.6,.4,-.25))
  for i=1,4 do asset('IceMoon',m,'FrozenFragment',center+V(-65+i*32,-45-i*5,55+i*8),rand:NextNumber(15,32),CFrame.Angles(i,.2*i,.4*i))end
 elseif id=='DerelictField' then
  local wreck=asset('Derelict',m,'BrokenCarrier',center+V(0,28,0),200,CFrame.Angles(.13,-.3,.16))
  local pivot=wreck:GetPivot()
  for _,piece in wreck:GetDescendants()do if piece:IsA('BasePart')then
   local rel=pivot:ToObjectSpace(piece.CFrame);local offset=rel.Position
   piece.Size=piece.Size*V(1,1,1.5);piece.CFrame=pivot*CFrame.new(offset*V(1,1,1.5))*rel.Rotation
   if string.find(piece.Name,'engines')then piece.CFrame=piece.CFrame*pivot.Rotation:Inverse()*CFrame.new(0,8,38)*pivot.Rotation*CFrame.Angles(.08,0,.13)end
   if string.find(piece.Name,'wings')then piece.CFrame=piece.CFrame*CFrame.new(0,14,7)*CFrame.Angles(0,-.08,.12)end
  end end
  for i=1,6 do line(m,'ExposedHullRib',center+V(-22,10,-15+i*9),center+V(22,20,-15+i*9),1.3,C(78,90,101),.4)end
 elseif id=='AncientRuins' then
  asset('Asteroid',m,'TempleFragment',center,125,CFrame.Angles(.1,.5,.08))
  asset('AlienGate',m,'AncientGateway',center+V(0,89,0),145,CFrame.Angles(0,-.4,0))
  for i=1,4 do
   local theta=i*math.pi*.5
   local pos=center+V(math.cos(theta)*53,12,math.sin(theta)*53)
   asset('Asteroid',m,'FloatingSanctum',pos,24,CFrame.Angles(i,.4*i,.2))
   local light=p(m,'RelicShard',V(1.8,13,1.8),CFrame.new(pos+V(0,17,0))*CFrame.Angles(0,.5,.2),color,Enum.Material.Neon);light.Transparency=.35
  end
 elseif id=='NebulaCurrent' then
  local core=p(m,'Pulsar',V(8,8,8),CFrame.new(center),C(189,207,255),Enum.Material.Neon);core.Shape=Enum.PartType.Ball
  for arm=1,3 do
   local previous=nil
   for i=0,36 do
    local a=arm*math.pi*2/3+i*.16;local r=12+i*2.3
    local pos=center+V(math.cos(a)*r,math.sin(a*1.5)*12,math.sin(a)*r*.65)
    if previous then line(m,'IonFilament',previous,pos,1.2+i*.04,arm==2 and C(89,151,201)or color,.45+i*.008)end
    previous=pos
   end
  end
 elseif id=='SingularityEdge' then
  local hole=p(m,'EventHorizon',V(88,88,88),CFrame.new(center),C(0,0,0),Enum.Material.Neon);hole.Shape=Enum.PartType.Ball
  local tilt=CFrame.new(center)*CFrame.Angles(.35,0,.2)
  for ring=1,4 do
   local r=45+ring*8;local previous=nil
   for i=0,80 do
    local a=i*math.pi*2/80;local pos=(tilt*CFrame.new(math.cos(a)*r,math.sin(a*3)*.5,math.sin(a)*r)).Position
    if previous then line(m,'AccretionStream',previous,pos,ring==1 and 1.7 or .8,ring==1 and C(246,204,221)or color,ring==1 and .13 or .65)end
    previous=pos
   end
  end
 end
 local direction=V(center.X,0,center.Z).Unit
 local start=direction*120+V(0,25,0);local finish=center-direction*100
 line(routes,'SubtleRoute_'..id,start,finish,.18,color,.86)
 m.Parent=sectors;task.wait()
end
-- Reuse the sculpted ship kit at believable landing-pad and hangar scale.
local fleet=model('DockedFleet',root.Hub)
for i,d in {{V(-49,38,53),43,.2},{V(49,37,53),33,-.35},{V(-10,40,-57),50,.05}}do asset('Derelict',fleet,i==3 and 'HangarSurveyShip' or 'SalvageShuttle',d[1],d[2],CFrame.Angles(0,d[3],0))end
local backdrop=model('Backdrop',nil)
local planet=p(backdrop,'DistantPlanet',V(260,260,260),CFrame.new(-620,230,-770),C(48,64,94));planet.Shape=Enum.PartType.Ball
local moon=asset('Asteroid',backdrop,'DistantBrokenMoon',V(600,250,600),130,CFrame.Angles(.2,.6,0))
for i=1,180 do
 local a=rand:NextNumber(0,math.pi*2);local r=rand:NextNumber(720,940)
 local star=p(backdrop,'Star',V(1,1,1),CFrame.new(math.cos(a)*r,rand:NextNumber(-200,650),math.sin(a)*r),C(168,184,214),Enum.Material.Neon)
 local b=Instance.new('BillboardGui');b.Size=UDim2.fromOffset(i%11==0 and 3 or 1.5,i%11==0 and 3 or 1.5);b.MaxDistance=3000;b.Parent=star
 local dot=Instance.new('Frame');dot.Size=UDim2.fromScale(1,1);dot.BorderSizePixel=0;dot.BackgroundColor3=star.Color;dot.BackgroundTransparency=.2;dot.Parent=b
end
-- Sparse layered nebula sprites give depth without covering the player's foreground.
for i,d in {{V(-460,270,-700),500,C(53,57,102)},{V(480,190,-770),650,C(74,42,85)},{V(-600,320,580),460,C(32,67,90)}}do
 local a=p(backdrop,'NebulaAnchor',V(1,1,1),CFrame.new(d[1]),C(0,0,0));a.Transparency=1
 local b=Instance.new('BillboardGui');b.Size=UDim2.new(d[2],0,d[2]*.7,0);b.MaxDistance=3000;b.LightInfluence=0;b.Parent=a
 local img=Instance.new('ImageLabel');img.Size=UDim2.fromScale(1,1);img.BackgroundTransparency=1;img.Image='rbxasset://textures/particles/smoke_main.dds';img.ImageColor3=d[3];img.ImageTransparency=.35;img.Rotation=i*31;img.Parent=b
end
backdrop.Parent=root
return {Sectors=#sectors:GetChildren(),Meshes=#root:GetDescendants()}

end
landmarkMap()
local function toyStyle()
-- User art direction: chunky, colorful Roblox plastic with exposed studs.
local C=Color3.fromRGB;local V=Vector3.new
local root=workspace.StarfallMap
local palette={
 {C(29,43,57),C(45,91,169)}, {C(99,119,133),C(141,167,194)},
 {C(166,183,191),C(237,243,250)}, {C(12,22,32),C(27,46,83)},
 {C(227,148,66),C(255,190,54)}, {C(101,214,228),C(88,221,255)},
 {C(221,231,231),C(249,250,255)}, {C(60,76,88),C(111,140,179)},
}
for _,o in root.Hub:GetDescendants()do
 if o:IsA('BasePart')and not o:IsA('MeshPart')then
  if o.Material~=Enum.Material.Neon and o.Material~=Enum.Material.Glass then o.Material=Enum.Material.Plastic;o.Reflectance=0 end
  for _,pair in palette do if (o.Color.R-pair[1].R)^2+(o.Color.G-pair[1].G)^2+(o.Color.B-pair[1].B)^2<.0001 then o.Color=pair[2];break end end
  if o.Size.X>=4 and o.Size.Z>=4 and o.CFrame.UpVector.Y>.95 and o.Material==Enum.Material.Plastic then o.TopSurface=Enum.SurfaceType.Studs end
  if o.Name=='DoorColumn'or o.Name=='DoorChamfer'then o.Color=C(242,246,255)end
 elseif o:IsA('TextLabel')then o.Font=Enum.Font.FredokaOne
 elseif o:IsA('PointLight')then o.Brightness=math.min(o.Brightness,.5)end
end
local function paintMesh(p,color)
 p.TextureID='';p.Color=color;p.Material=Enum.Material.Plastic;p.Reflectance=0;p.CastShadow=true
 for _,s in p:GetChildren()do if s:IsA('SurfaceAppearance')then s:Destroy()end end
end
for _,o in root:GetDescendants()do if o:IsA('MeshPart')then
 local color=C(112,126,153)
 if o:IsDescendantOf(root.Hub)or (o:IsDescendantOf(root.Sectors.DerelictField)and (string.find(o.Name,'hull')or string.find(o.Name,'wings')or string.find(o.Name,'engines')))then
  color=string.find(o.Name,'engines')and C(255,174,55)or string.find(o.Name,'wings')and C(55,127,218)or C(239,245,255)
 elseif o:IsDescendantOf(root.Sectors.IceGraveyard)then color=C(133,226,255)
 elseif o:IsDescendantOf(root.Sectors.AncientRuins)then color=o.Name=='body_geom'and C(106,90,151)or C(146,101,215)
 elseif o:IsDescendantOf(root.Sectors.ScrapBelt)then color=C(143,130,158)
 elseif o:IsDescendantOf(root.Sectors.NebulaCurrent)then color=C(116,101,170)
 end
 paintMesh(o,color)
end end
-- Small studded armor plates tie the sculpted craft to the building kit.
local armor=Instance.new('Model');armor.Name='StuddedShipArmor';armor.Parent=root.Hub
for _,ship in root.Hub.DockedFleet:GetChildren()do
 local cf,size=ship:GetBoundingBox();local top=cf.Position.Y+size.Y*.5
 for _,side in {-1,1}do
  local plate=Instance.new('Part');plate.Name='WingArmor';plate.Size=V(size.X*.23,.55,size.Z*.17);plate.CFrame=CFrame.new(cf.Position.X+side*size.X*.28,top-2,cf.Position.Z);plate.Color=C(59,132,222);plate.Material=Enum.Material.Plastic;plate.TopSurface=Enum.SurfaceType.Studs;plate.Anchored=true;plate.CanCollide=false;plate.Parent=armor
 end
end
-- Give the landings bright, studded play surfaces instead of metal plates.
for _,p in root.Hub.LandingPads:GetChildren()do
 if p:IsA('BasePart')and p.Name=='PadBase'then p.Color=C(50,100,181);p.Material=Enum.Material.Plastic;p.TopSurface=Enum.SurfaceType.Studs end
end
-- A smooth invisible collision ramp makes the visible studded stairs walkable.
local stairs=root.Hub.ObservationStairs
for _,p in stairs:GetChildren()do if p:IsA('BasePart')and(p.Name=='Step'or p.Name=='StepNosing')then p.CanCollide=false end end
local ramp=Instance.new('WedgePart');ramp.Name='StairCollisionRamp';ramp.Size=V(12,44.5,72);ramp.CFrame=CFrame.new(64,52.25,-53);ramp.Transparency=1;ramp.Anchored=true;ramp.Parent=stairs
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={ramp}
local near=workspace:Raycast(V(64,120,-20),V(0,-130,0),params)
local far=workspace:Raycast(V(64,120,-86),V(0,-130,0),params)
if near and far and near.Position.Y>far.Position.Y then ramp.CFrame*=CFrame.Angles(0,math.pi,0)end
-- Remove the cloud diagnostics; use actual faceted meshes for a toy nebula backdrop.
for _,a in root.Backdrop:GetChildren()do if a.Name=='NebulaAnchor'then a:Destroy()end end
local clouds=Instance.new('Model');clouds.Name='ToyNebulaClouds';clouds.Parent=root.Backdrop
local kit=game.ServerStorage.StarfallMeshKit
for band,d in {{V(-480,270,-710),C(100,80,176)},{V(480,230,-760),C(155,80,173)},{V(-620,280,520),C(62,126,184)}}do
 for i=1,5 do
  local m=kit.Asteroid:Clone();m.Name='CloudPuff';local cf,size=m:GetBoundingBox();m.WorldPivot=cf;m:ScaleTo((155+i*10)/math.max(size.X,size.Y,size.Z));m:PivotTo(CFrame.new(d[1]+V((i-3)*65,math.sin(i)*30,math.cos(i)*20))*CFrame.Angles(i*.3,i*.5,i*.1))
  for _,p in m:GetDescendants()do if p:IsA('MeshPart')then paintMesh(p,d[2]);p.Material=Enum.Material.Neon;p.Transparency=.91;p.Anchored=true;p.CanCollide=false;p.CastShadow=false end end
  m.Parent=clouds
 end
end
local L=game.Lighting;L.Ambient=C(144,158,185);L.OutdoorAmbient=C(144,158,185);L.Brightness=2;L.ExposureCompensation=.05
L.StarfallColor.Contrast=.04;L.StarfallColor.Saturation=.12
L.StarfallBloom.Intensity=.12;L.StarfallBloom.Threshold=2
return {Style='Studded Roblox plastic',StairRamp=ramp.CFrame.Position,MeshTexturesRemoved=true}

end
toyStyle()
local function referencePass()
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

end
referencePass()
local function homeIsland()
-- Six avatar-scale plots around a public launch plaza, following the user's sketch.
local C=Color3.fromRGB;local V=Vector3.new;local CF=CFrame.new
local root=workspace:WaitForChild('StarfallMap')
assert(not root:GetAttribute('SixPlotHome'),'Archive the previous home before rebuilding')
local archive=Instance.new('Folder');archive.Name='StarfallBeforeSixPlotHome';archive.Parent=game.ServerStorage
for _,name in {'Hub','ReferenceArt'}do local old=root:FindFirstChild(name);if old then old.Parent=archive end end
local P={grass=C(105,174,58),garden=C(115,186,66),leaf=C(35,129,74),leaf2=C(58,151,75),path=C(213,176,120),rock=C(75,79,88),rock2=C(57,62,74),wood=C(132,84,53),wood2=C(164,107,65),turquoise=C(49,174,174),orange=C(236,137,57),blue=C(62,123,181),dark=C(39,53,68),white=C(225,229,216),gold=C(255,212,87),cyan=C(95,218,245)}
local Y=30
local function model(name,parent)local m=Instance.new('Model');m.Name=name;m.Parent=parent;return m end
local function part(parent,name,size,cf,color,studs,class)
 local p=Instance.new(class or 'Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color or P.rock;p.Material=Enum.Material.Plastic;p.TopSurface=studs and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Anchored=true;p.Parent=parent;return p
end
local function deco(p)p.CanCollide=false;p.CanTouch=false;return p end
local function glow(parent,name,size,cf,color)
 local p=deco(part(parent,name,size,cf,color));p.Material=Enum.Material.Neon;p.CastShadow=false;return p
end
local function sign(parent,name,text,cf,w,h,color)
 local p=deco(part(parent,name,V(w,h,.25),cf,P.dark))
 local gui=Instance.new('SurfaceGui');gui.Name='Surface';gui.Face=Enum.NormalId.Front;gui.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;gui.PixelsPerStud=16;gui.LightInfluence=0;gui.Parent=p
 local label=Instance.new('TextLabel');label.Name='OwnerTitle';label.Size=UDim2.fromScale(.94,.86);label.Position=UDim2.fromScale(.03,.07);label.BackgroundTransparency=1;label.Text=text;label.TextScaled=true;label.Font=Enum.Font.Arcade;label.TextColor3=color or P.white;label.TextStrokeColor3=P.dark;label.TextStrokeTransparency=.45;label.Parent=gui
 return p
end
local function underside(parent,cf,w,d)
 part(parent,'Cliff',V(w-1,11,d-1),cf*CF(0,Y-6.5,0),P.rock,true)
 part(parent,'LowerLayer',V(w*.81,6,d*.79),cf*CF(0,Y-14,0),P.rock2)
 for _,side in {-1,1}do
  local p=deco(part(parent,'CliffFragment',V(w*.3,10,d*.4),cf*CF(side*w*.22,Y-20,side*d*.13)*CFrame.Angles(.14,side*.45,side*.12),P.rock2,false,'WedgePart'))
  -- Rotated AABB bound, not unrotated height. All pointed scenery stays below the lawn.
  local half=p.Size*.5;local c=p.CFrame
  local extent=math.abs(c.RightVector.Y)*half.X+math.abs(c.UpVector.Y)*half.Y+math.abs(c.LookVector.Y)*half.Z
  local top=p.Position.Y+extent;if top>Y-4 then p.CFrame-=V(0,top-(Y-4),0)end
 end
end
local function tree(parent,cf,height)
 local t=model('Tree',parent)
 part(t,'Trunk',V(1.7,height*.52,1.7),cf*CF(0,height*.26,0),P.wood,true)
 part(t,'Leaves',V(height*.48,height*.35,height*.48),cf*CF(0,height*.7,0),P.leaf,true)
 part(t,'Crown',V(height*.34,height*.3,height*.34),cf*CF(.25,height*.9,0),P.leaf2,true)
 return t
end
local function flowers(parent,cf)
 for i=1,3 do
  local q=cf*CF((i-2)*1.2,0,(i%2)*.7)
  deco(part(parent,'FlowerStem',V(.16,.75,.16),q*CF(0,.4,0),P.leaf))
  deco(part(parent,'Flower',V(.85,.22,.85),q*CF(0,.85,0),i==2 and C(185,114,216)or P.gold))
 end
end
local function fence(parent,cf,width,depth)
 local function rail(x,z,l,yaw)
  for _,h in {1.15,2.25}do part(parent,'FenceRail',V(l,.42,.55),cf*CF(x,Y+h,z)*CFrame.Angles(0,yaw,0),P.wood2,true)end
 end
 rail(0,depth*.5,width,0)
 rail(-width*.25-3,-depth*.5,width*.5-6,0);rail(width*.25+3,-depth*.5,width*.5-6,0)
 rail(-width*.5,0,depth,math.pi*.5);rail(width*.5,0,depth,math.pi*.5)
 for _,q in {V(-width*.5,0,-depth*.5),V(width*.5,0,-depth*.5),V(-width*.5,0,depth*.5),V(width*.5,0,depth*.5),V(-6,0,-depth*.5),V(6,0,-depth*.5)}do
  part(parent,'FencePost',V(.85,3.3,.85),cf*CF(q+V(0,Y+1.65,0)),P.wood,true)
 end
end
local function ship(parent,cf,accent)
 local s=model('StarterShip',parent);s:SetAttribute('DisplayOnly',true)
 local function p(n,size,offset,color,class,rot)
  return part(s,n,size,cf*CF(offset)*(rot or CFrame.new()),color,true,class)
 end
 local hull=p('Hull',V(5,2.4,12),V(0,2.7,0),P.white);s.PrimaryPart=hull
 p('Nose',V(5,2.4,5),V(0,2.7,-8.5),P.white,'WedgePart')
 p('Cockpit',V(4,2.2,5),V(0,4.5,-2),P.dark,'WedgePart')
 p('Window',V(3.2,.3,3.5),V(0,5.1,-2),P.blue,nil,CFrame.Angles(-.25,0,0))
 p('Spine',V(2.5,.7,6),V(0,4.25,3),accent)
 for _,side in {-1,1}do
  p('Wing',V(4.5,.8,7),V(side*4,2,1),accent)
  p('EngineHousing',V(2.8,2.7,6),V(side*4.3,2.9,4.2),P.dark)
  p('EngineArmor',V(2.9,.5,3.5),V(side*4.3,4.5,4),accent)
  local engine=glow(s,'EngineCore',V(.35,1.8,1.8),cf*CF(side*4.3,2.9,7.3)*CFrame.Angles(0,math.pi*.5,0),P.cyan);engine.Shape=Enum.PartType.Cylinder
  p('LandingLeg',V(.8,1.3,.8),V(side*2,1,1),P.dark)
  p('LandingFoot',V(1.8,.35,2.2),V(side*2,.35,1),P.rock)
 end
 p('CargoRack',V(3,.5,4),V(0,4.6,4),P.orange)
 for name,offset in {EngineLeft=V(-4.3,0,4.2),EngineRight=V(4.3,0,4.2),Shield=V(0,2,0),Weapon=V(0,0,-6),Cargo=V(0,2,4)}do
  local a=Instance.new('Attachment');a.Name=name..'Socket';a.Position=offset;a.Parent=hull
 end
 return s
end
local function robot(parent,cf,accent)
 local r=model('RobotShopkeeper',parent)
 part(r,'Body',V(2.1,2.1,1.4),cf*CF(0,2.6,0),accent,true)
 part(r,'Head',V(2.5,1.7,1.8),cf*CF(0,4.45,0),P.white,true)
 part(r,'Face',V(1.9,1,.12),cf*CF(0,4.45,-.96),P.dark)
 for _,side in {-1,1}do
  glow(r,'Eye',V(.32,.35,.14),cf*CF(side*.48,4.55,-1.04),P.cyan)
  part(r,'Leg',V(.65,1.5,.65),cf*CF(side*.6,.8,0),P.dark,true)
  part(r,'Arm',V(.65,1.8,.65),cf*CF(side*1.5,2.7,0),P.rock,true)
 end
 part(r,'Antenna',V(.2,.7,.2),cf*CF(0,5.6,0),P.dark)
 return r
end
local hub=model('Hub',nil);hub:SetAttribute('PlotCapacity',6)
local ground=model('Ground',nil)
part(ground,'CentralLawn',V(80,1,72),CF(0,Y-.5,0),P.grass,true)
underside(ground,CFrame.new(),80,72)
ground.Parent=hub;task.wait()

local public=model('PublicArea',nil)
local path=model('WalkingPaths',hub)
part(path,'MarketWalk',V(72,.12,18),CF(0,Y+.06,18),P.path,true).CanCollide=false
local launch=model('LaunchPad',public)
part(launch,'PadBorder',V(27,.22,29),CF(0,Y+.11,-7),P.dark,true).CanCollide=false
part(launch,'PadSurface',V(24,.16,26),CF(0,Y+.3,-7),C(123,148,161),true).CanCollide=false
for _,side in {-1,1}do
 part(launch,'PaintStripe',V(.6,.06,21),CF(side*11,Y+.42,-7),P.gold).CanCollide=false
 part(launch,'Bumper',V(1.5,1.2,1.5),CF(side*12,Y+.6,6),P.orange,true)
end
local anchor=Instance.new('Attachment');anchor.Name='LaunchAnchor';anchor.CFrame=CF(0,.4,0);anchor.Parent=launch.PadSurface
ship(launch,CF(0,Y+.205,-7),P.orange)
sign(launch,'LaunchSign','LAUNCH',CF(0,Y+1.4,9)*CFrame.Angles(0,math.pi,0),9,2,P.gold)
local shops=model('Shops',public)
for i,d in {{-30,'PET EXCHANGE',P.turquoise},{30,'SHIP UPGRADES',P.orange}}do
 local x=d[1];local s=model(i==1 and 'PetShop'or 'ShipShop',shops)
 part(s,'Floor',V(16,.16,14),CF(x,Y+.08,-1),P.path,true).CanCollide=false
 part(s,'BackWall',V(14,8,1),CF(x,Y+4,-6.5),P.white,true)
 for _,side in {-1,1}do part(s,'Post',V(.9,10,.9),CF(x+side*6.7,Y+5,4),P.wood,true)end
 part(s,'Canopy',V(16,1.2,15),CF(x,Y+10.3,-1),d[3],true)
 for j=-2,2 do part(s,'AwningStripe',V(1.3,.2,15.2),CF(x+j*3,Y+11,-1),P.white,true).CanCollide=false end
 part(s,'Counter',V(14,2.8,3.4),CF(x,Y+1.4,4.5),P.wood,true)
 part(s,'CounterTop',V(14.5,.35,3.8),CF(x,Y+2.97,4.5),P.white,true)
 sign(s,'ShopTitle',d[2],CF(x,Y+8.8,6.1)*CFrame.Angles(0,math.pi,0),14,2.1,P.white)
 robot(s,CF(x,Y,-1)*CFrame.Angles(0,math.pi,0),d[3])
 if i==1 then
  for j=-1,1 do
   local egg=deco(part(s,'DisplayEgg',V(1.3,1.8,1.3),CF(x+j*3,Y+3.9,4.5),j==0 and P.gold or P.turquoise));egg.Shape=Enum.PartType.Ball
  end
 else
  for j=-1,1 do part(s,'ModuleDisplay',V(1.8,1.3,2),CF(x+j*3,Y+3.7,4.5),j==0 and P.orange or P.blue,true)end
 end
end
public.Parent=hub
local title=sign(public,'SpaceportTitle','STARFALL SPACEPORT',CF(0,Y+8,32)*CFrame.Angles(0,math.pi,0),25,2.6,P.white)
for _,x in {-13,13}do part(public,'SignPost',V(.8,8,.8),CF(x,Y+4,32),P.wood,true)end
local common=Instance.new('SpawnLocation');common.Name='PublicSpawn';common.Size=V(4,1,4);common.CFrame=CF(10,Y+.5,27);common.Transparency=1;common.CanCollide=false;common.Anchored=true;common.Neutral=true;common.Duration=0;common.Parent=hub
task.wait()

local plots=Instance.new('Folder');plots.Name='Plots';plots.Parent=hub
local accents={P.orange,P.turquoise,P.blue,C(151,101,190),C(148,175,65),C(203,108,94)}
for index=1,6 do
 local angle=-math.pi*.5+(index-1)*math.pi/3
 local dir=V(math.cos(angle),0,math.sin(angle));local center=dir*76
 local cf=CFrame.lookAt(center,center-dir)
 local plot=model(string.format('Plot%02d',index),nil);plot:SetAttribute('PlotIndex',index);plot:SetAttribute('OwnerUserId',0)
 local floor=model('Terrain',plot)
 part(floor,'Lawn',V(46,1,46),cf*CF(0,Y-.5,0),P.grass,true)
 underside(floor,cf,46,46)
 local exit=math.min(math.abs(dir.X)>.001 and 40/math.abs(dir.X)or math.huge,math.abs(dir.Z)>.001 and 36/math.abs(dir.Z)or math.huge)
 local endRadius=53;local length=endRadius-exit
 local bridgeCf=CFrame.lookAt(dir*(exit+length*.5),dir*(exit+length*.5)-dir)
 -- A small overlap closes floating-point seams; lower the link surface to avoid z-fighting.
 part(floor,'LinkGround',V(12,1,length+.7),bridgeCf*CF(0,Y-.52,0),P.grass,true)
 part(floor,'LinkFoundation',V(11,7,length+.7),bridgeCf*CF(0,Y-4.5,0),P.rock)
 local entryPathCf=CFrame.lookAt(dir*43,dir*43-dir)
 part(path,'PlotApproach'..index,V(8,.12,34),entryPathCf*CF(0,Y+.06,0),P.path,true).CanCollide=false
 part(plot,'EntrancePath',V(8,.12,20),cf*CF(0,Y+.06,-13),P.path,true).CanCollide=false
 local fences=model('Fences',plot);fence(fences,cf,44,44)
 local pad=model('ShipPad',plot)
 part(pad,'PadBorder',V(17,.12,24),cf*CF(-11,Y+.06,1),P.rock,true).CanCollide=false
 part(pad,'PadTop',V(15.5,.12,22),cf*CF(-11,Y+.18,1),C(137,156,153),true).CanCollide=false
 ship(pad,cf*CF(-11,Y+.065,1),accents[index])
 local garden=model('PetGarden',plot)
 part(garden,'GardenGrass',V(17,.12,26),cf*CF(11,Y+.06,1),P.garden,true).CanCollide=false
 local slots=Instance.new('Folder');slots.Name='PlacementAnchors';slots.Parent=garden
 for n=1,6 do
  local sx=n%2==1 and 7 or 15;local sz=-7+math.floor((n-1)/2)*8
  local tile=deco(part(garden,'PetDisplayTile',V(4,.12,4),cf*CF(sx,Y+.17,sz),C(164,188,125),true))
  -- Scene markers do not set the eventual gameplay pet capacity.
  local marker=deco(part(slots,string.format('PetAnchor%02d',n),V(.2,.2,.2),tile.CFrame*CF(0,.1,0),P.grass));marker.Transparency=1
 end
 local nameplate=sign(plot,'Nameplate',string.format('PLOT %02d\nAVAILABLE',index),cf*CF(12,Y+4,-22),12,2.6,P.white)
 for _,x in {7,17}do part(plot,'NameplatePost',V(.55,3,.55),cf*CF(x,Y+1.5,-22),P.wood,true)end
 local spawn=Instance.new('SpawnLocation');spawn.Name='PlotSpawn';spawn.Size=V(4,1,4);spawn.CFrame=cf*CF(0,Y+.5,-17);spawn.Transparency=1;spawn.CanCollide=false;spawn.Anchored=true;spawn.Neutral=true;spawn.Duration=0;spawn.Parent=plot
 tree(plot,cf*CF(-16,Y,17),11+(index%2)*2)
 tree(plot,cf*CF(17,Y,18),10)
 flowers(plot,cf*CF(15,Y,-17))
 local flag=part(plot,'PlotFlag',V(2.8,3,.18),cf*CF(-7,Y+5.5,-22),accents[index],true);deco(flag)
 part(plot,'FlagPost',V(.45,7,.45),cf*CF(-8.5,Y+3.5,-22),P.wood,true)
 plot.Parent=plots;task.wait()
end

local decorations=model('Decorations',nil)
for _,q in {V(-36,Y,27),V(36,Y,27),V(-35,Y,-28),V(35,Y,-28)}do tree(decorations,CF(q),12)end
for _,x in {-17,17}do
 part(decorations,'Bench',V(6.5,.55,2.2),CF(x,Y+1.7,28),P.wood2,true)
 for _,dx in {-2,2}do part(decorations,'BenchLeg',V(.7,1.4,1.5),CF(x+dx,Y+.7,28),P.wood)end
end
decorations.Parent=hub
hub.Parent=root;root:SetAttribute('SixPlotHome',true);root:SetAttribute('PlotCapacity',6)
local L=game.Lighting;L.ClockTime=14;L.Brightness=2;L.Ambient=C(168,165,179);L.OutdoorAmbient=C(168,165,179);L.ExposureCompensation=.1
L.StarfallBloom.Intensity=.18;L.StarfallBloom.Threshold=1.8;L.StarfallColor.Contrast=.03;L.StarfallColor.Saturation=.03
game.StarterPlayer.CameraMinZoomDistance=5;game.StarterPlayer.CameraMaxZoomDistance=96
workspace.CurrentCamera.CFrame=CFrame.lookAt(V(128,132,154),V(0,Y,0))
return {Plots=#plots:GetChildren(),Capacity=6,GroundHeight=Y,Archive=archive:GetFullName()}

end
homeIsland()
local function polishHome()
-- Landscape and set-dressing pass. All six plots retain the same usable layout.
local C=Color3.fromRGB;local V=Vector3.new;local CF=CFrame.new
local hub=workspace.StarfallMap.Hub;local Y=30
assert(not hub:FindFirstChild('WorldPolish'),'Home is already polished')
local backup=Instance.new('Folder');backup.Name='StarfallBeforeHomePolish';backup.Parent=game.ServerStorage
hub:Clone().Parent=backup
local P={grass=C(105,174,58),leaf=C(33,118,67),leaf2=C(56,146,73),leaf3=C(83,164,74),wood=C(130,83,50),trim=C(166,112,68),rock=C(92,101,109),dark=C(42,59,69),cream=C(231,226,204),gold=C(247,198,82),cyan=C(84,207,224),orange=C(228,132,52),turquoise=C(48,159,158)}
local function model(n,parent)local m=Instance.new('Model');m.Name=n;m.Parent=parent;return m end
local function p(parent,n,size,cf,color,studs,class)
 local o=Instance.new(class or 'Part');o.Name=n;o.Size=size;o.CFrame=cf;o.Color=color;o.Material=Enum.Material.Plastic;o.Anchored=true;o.CanCollide=false;o.CanTouch=false;o.TopSurface=studs and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth;o.BottomSurface=Enum.SurfaceType.Smooth;o.Parent=parent;return o
end
local function sign(parent,n,text,cf,w,h,color)
 local b=p(parent,n,V(w,h,.25),cf,P.dark)
 for _,face in {Enum.NormalId.Front,Enum.NormalId.Back}do
  local g=Instance.new('SurfaceGui');g.Face=face;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=16;g.LightInfluence=0;g.Parent=b
  local t=Instance.new('TextLabel');t.BackgroundTransparency=1;t.Size=UDim2.fromScale(.94,.86);t.Position=UDim2.fromScale(.03,.07);t.Text=text;t.Font=Enum.Font.Arcade;t.TextScaled=true;t.TextColor3=color or P.cream;t.TextStrokeTransparency=.45;t.Parent=g
 end
end
local function beam(parent,n,a,b,w,color)
 return p(parent,n,V(w,w,(b-a).Magnitude),CFrame.lookAt((a+b)*.5,b),color,true)
end
local function crate(parent,cf,size,color)
 local m=model('Crate',parent);p(m,'Box',size,cf,color or P.trim,true)
 for _,x in {-size.X*.32,size.X*.32}do p(m,'Band',V(.25,size.Y+.1,size.Z+.1),cf*CF(x,0,0),P.wood)end
 return m
end
local function planter(parent,cf,w,d)
 local m=model('Planter',parent)
 p(m,'Soil',V(w,.25,d),cf*CF(0,.3,0),C(104,80,54),true)
 for _,side in {-1,1}do p(m,'Timber',V(w+.3,.7,.35),cf*CF(0,.35,side*d*.5),P.wood,true);p(m,'Timber',V(.35,.7,d),cf*CF(side*w*.5,.35,0),P.wood,true)end
 for i=1,math.floor(w/1.3)do
  local x=-w*.5+.8+(i-1)*1.3;local z=i%2==0 and -.4 or .4
  p(m,'LeafTuft',V(.9,1,.6),cf*CF(x,.9,z)*CFrame.Angles(0,i*.4,.2),P.leaf2,true)
  local c=({P.gold,C(208,124,192),P.cream})[(i%3)+1]
  p(m,'Flower',V(.7,.3,.7),cf*CF(x,1.5,z),c,true)
 end
end
local function lantern(parent,cf)
 p(parent,'LanternCap',V(1,.2,1),cf*CF(0,.55,0),P.dark,true)
 local glass=p(parent,'LanternGlass',V(.72,.9,.72),cf,P.gold)
 local light=Instance.new('PointLight');light.Color=P.gold;light.Brightness=.35;light.Range=9;light.Shadows=false;light.Parent=glass
 p(parent,'LanternBase',V(.9,.2,.9),cf*CF(0,-.55,0),P.dark)
end
local polish=model('WorldPolish',hub)

-- Replace two-block canopies with varied crowns while retaining their trunks and scale.
local trees={};for _,o in hub:GetDescendants()do if o:IsA('Model')and o.Name=='Tree'then table.insert(trees,o)end end
for index,t in trees do
 if t.Parent==hub.Decorations then
  local pos=t.Trunk.Position
  t:PivotTo(t:GetPivot()+V(math.sign(pos.X)*35-pos.X,0,math.sign(pos.Z)*32-pos.Z))
 end
 local trunk=t:FindFirstChild('Trunk');local old=t:FindFirstChild('Crown')
 if trunk and old then
  local h=old.Position.Y+old.Size.Y*.5-Y
  local cf=trunk.CFrame*CF(0,-trunk.Size.Y*.5,0)
  t.Leaves:Destroy();old:Destroy()
  if index%3==0 then
   for i,w in {8,6.8,5.5,4.1,2.6}do
    p(t,'PineTier',V(w,1.8,w),cf*CF(0,h*.42+(i-1)*1.7,0)*CFrame.Angles(0,i*.13,0),i%2==0 and P.leaf2 or P.leaf,true)
   end
  else
   p(t,'CrownMass',V(6.6,3.7,5.8),cf*CF(0,h*.68,0)*CFrame.Angles(0,index*.2,0),P.leaf,true)
   for i,q in {V(-2.8,.7,-.4),V(2.6,.3,.6),V(.3,2.8,0)}do
    p(t,'LeafCluster',V(i==3 and 4.6 or 3.7,2.8,3.8),cf*CF(q+V(0,h*.66,0))*CFrame.Angles(0,i*.27,0),i==3 and P.leaf3 or P.leaf2,true)
   end
   beam(t,'Branch',(cf*CF(0,h*.3,0)).Position,(cf*CF(2,h*.62,0)).Position,.6,P.wood)
  end
 end
end

-- Rich cliff layering is contained below the lawn, with no rotated points above it.
local function cliffDetails(parent,cf,w,d,seed)
 local rand=Random.new(seed)
 for side=-1,1,2 do
  for i=1,5 do
   local z=-d*.4+(i-1)*d*.2;local h=rand:NextNumber(3,6)
   p(parent,'RockPlate',V(1.1,h,rand:NextNumber(5,8)),cf*CF(side*w*.5,Y-2.5-h*.5,z),i%2==0 and P.rock or C(70,81,91),true)
  end
  for i=1,5 do
   local x=-w*.4+(i-1)*w*.2
   p(parent,'RockPlate',V(rand:NextNumber(5,8),4.5,1.1),cf*CF(x,Y-5,side*d*.5),i%2==0 and P.rock or C(70,81,91),true)
  end
  p(parent,'GrassLip',V(w,.5,1.2),cf*CF(0,Y-.7,side*d*.5),C(91,145,54),true)
 end
end
cliffDetails(polish,CFrame.new(),79,71,81)

for index=1,6 do
 local plot=hub.Plots[string.format('Plot%02d',index)]
 local cf=plot.Terrain.Lawn.CFrame*CF(0,-(Y-.5),0)
 local detail=model('PlotDetail'..index,nil)
 cliffDetails(detail,cf,45,45,90+index)
 -- Low edging and planted corners make the garden feel tended; anchors stay open.
 planter(detail,cf*CF(9,Y,17),7,3.2)
 planter(detail,cf*CF(-17,Y,-16),5,2.8)
 for _,side in {-1,1}do
  p(detail,'GatePost',V(1.1,6.8,1.1),cf*CF(side*5.4,Y+3.4,-22),P.wood,true)
  lantern(detail,cf*CF(side*5.4,Y+5.1,-21.1))
 end
 p(detail,'GateHeader',V(12,1,1.3),cf*CF(0,Y+7,-22),P.trim,true)
 sign(detail,'PlotNumber',string.format('%02d',index),cf*CF(0,Y+7.15,-22.82),3,1.6,P.cream)
 for _,q in {V(-11,0,22),V(0,0,22),V(11,0,22),V(-22,0,-11),V(-22,0,0),V(-22,0,11),V(22,0,-11),V(22,0,0),V(22,0,11)}do
  p(detail,'FenceStanchion',V(.7,3,.7),cf*CF(q+V(0,Y+1.5,0)),P.wood,true)
 end
 for _,x in {-16.5,-5.5,5.5,16.5}do
  beam(detail,'FenceBrace',(cf*CF(x-4.8,Y+.75,21.85)).Position,(cf*CF(x+4.8,Y+2.6,21.85)).Position,.3,P.trim)
 end
 -- Integrated pet-care corner and ship service props, outside walking/placement lanes.
 p(detail,'GardenBed',V(4.5,.8,3),cf*CF(16,Y+.4,16),C(195,153,107),true)
 p(detail,'BedCushion',V(3.8,.5,2.4),cf*CF(16,Y+1.05,16),C(113,178,164),true)
 p(detail,'FoodBowl',V(1.7,.4,1.7),cf*CF(19,Y+.2,12.5),P.turquoise)
 p(detail,'BowlInset',V(1.2,.12,1.2),cf*CF(19,Y+.43,12.5),C(156,205,224))
 local pump=cf*CF(-20,Y,-6)
 p(detail,'ServicePump',V(1.7,3.2,2),pump*CF(0,1.6,0),P.turquoise,true)
 p(detail,'PumpDisplay',V(1.2,.7,.12),pump*CF(0,2.3,1.06),P.dark)
 beam(detail,'FuelHose',(pump*CF(.5,1.5,1)).Position,(pump*CF(2,1,2)).Position,.18,P.dark)
 crate(detail,cf*CF(-19,Y+1.05,11.5),V(2.2,2.1,2.4))
 crate(detail,cf*CF(-18,Y+.8,14.2)*CFrame.Angles(0,.2,0),V(2,1.6,2),P.rock)
 -- Pad inset corners and numbered labels are paint, not glow.
 for _,side in {-1,1}do p(detail,'PadTrim',V(.35,.08,19),cf*CF(-11+side*7.1,Y+.29,1),C(210,202,161))end
 sign(detail,'GardenLabel','PETS',cf*CF(11,Y+2.8,-13),5,1.3,P.cream)
 p(detail,'GardenLabelPost',V(.4,2.6,.4),cf*CF(11,Y+1.3,-13),P.wood)
 for _,tile in plot.PetGarden:GetChildren()do if tile.Name=='PetDisplayTile'then tile.Color=C(147,171,112);tile.Size=V(3.4,.08,3.4)end end
 detail.Parent=polish;task.wait()
end

-- Launch pad has a readable industrial toy silhouette and small purpose-built details.
local launch=model('LaunchDetail',nil)
for _,side in {-1,1}do
 p(launch,'GantryFoot',V(3,1.3,4),CF(side*16,Y+.65,-20),P.dark,true)
 p(launch,'GantryUpright',V(1.5,12,1.7),CF(side*16,Y+6,-20),P.orange,true)
 p(launch,'GantryInset',V(.65,7,.18),CF(side*16,Y+6,-19.05),P.cream,true)
 for i=1,5 do p(launch,'PadHazard',V(.7,.08,1.8),CF(side*12,Y+.5,-17+i*4)*CFrame.Angles(0,.6,0),P.gold)end
 p(launch,'PadSide',V(.7,.6,27),CF(side*13.7,Y+.3,-7),P.rock,true)
 p(launch,'ServicingCabinet',V(2.2,3,3),CF(side*16,Y+1.5,-9),side<0 and P.turquoise or P.orange,true)
end
p(launch,'GantryHeader',V(33,1.2,2),CF(0,Y+12.6,-20),P.orange,true)
sign(launch,'ReadySign','DEPARTURES',CF(0,Y+12.6,-18.8),15,2.2,P.cream)
for _,x in {-18,18}do
 p(launch,'WindsockPole',V(.45,8,.45),CF(x,Y+4,-22),P.wood,true)
 local cloth=model('SwayFlag',launch)
 for i=1,4 do p(cloth,'ClothSegment',V(.9,.6-i*.08,1),CF(x+i*.8,Y+7.8,-22),i%2==0 and P.cream or P.orange)end
end
launch.Parent=polish;task.wait()

-- Shop frontage: cladding, framed windows, cargo, a repair trolley, and an original pet mascot.
local shops=model('ShopDetail',nil)
for i,shop in {hub.PublicArea.Shops.PetShop,hub.PublicArea.Shops.ShipShop}do
 local x=shop.BackWall.Position.X;local color=i==1 and P.turquoise or P.orange
 for _,side in {-1,1}do
  p(shops,'WindowFrame',V(3.7,2.7,.18),CF(x+side*4.2,Y+5.6,-5.88),color,true)
  p(shops,'Window',V(3.1,2.1,.12),CF(x+side*4.2,Y+5.6,-5.75),P.dark)
  p(shops,'WindowCross',V(.18,2,.14),CF(x+side*4.2,Y+5.6,-5.65),P.cream)
  crate(shops,CF(x+side*5.3,Y+.75,8.3),V(2.4,1.5,2.2),side<0 and P.trim or color)
 end
 p(shops,'ShopSkirting',V(14.2,.6,.2),CF(x,Y+.4,6.3),color,true)
 for j=-2,2 do p(shops,'AwningValance',V(2.7,.55,.6),CF(x+j*2.8,Y+10.3,6.7),j%2==0 and P.cream or color,true)end
 local robot=shop.RobotShopkeeper
 p(robot,'Badge',V(.6,.5,.15),robot.Body.CFrame*CF(.45,.25,-.78),P.gold)
 for _,eye in robot:GetChildren()do if eye.Name=='Eye'then eye:SetAttribute('HomeBlink',true)end end
end
local cart=model('RepairTrolley',shops)
p(cart,'Cabinet',V(2.5,2.2,3),CF(38,Y+1.3,10),P.turquoise,true)
p(cart,'Worktop',V(2.8,.3,3.3),CF(38,Y+2.55,10),P.cream,true)
for _,z in {9,11}do local wheel=p(cart,'Wheel',V(.35,1,1),CF(36.65,Y+.55,z),P.dark);wheel.Shape=Enum.PartType.Cylinder end
p(cart,'Tool',V(.2,.2,1.6),CF(38,Y+2.8,10)*CFrame.Angles(0,.4,0),P.rock)
crate(shops,CF(-20.5,Y+1,-2),V(3.8,2,3.5),P.trim)
local pup=model('MascotPet',shops);pup:SetAttribute('DisplayOnly',true)
local pc=CF(-20.5,Y+2,-2)
p(pup,'Body',V(2,1.4,1.8),pc*CF(0,1,0),P.cream,true)
p(pup,'Head',V(1.8,1.5,1.4),pc*CF(0,1.7,.65),P.cream,true)
for _,side in {-1,1}do
 p(pup,'Ear',V(.6,1,.6),pc*CF(side*.9,2.1,.55),P.orange,true,'WedgePart')
 p(pup,'Foot',V(.55,.4,.65),pc*CF(side*.65,.25,.4),P.dark)
 local eye=p(pup,'PetEye',V(.22,.3,.12),pc*CF(side*.4,1.85,1.4),P.dark);eye:SetAttribute('HomeBlink',true)
end
p(pup,'Nose',V(.22,.18,.16),pc*CF(0,1.55,1.43),P.dark)
p(pup,'Cheek',V(.25,.25,.12),pc*CF(.7,1.5,1.4),P.turquoise)
p(pup,'Tail',V(.4,.7,.5),pc*CF(0,1.2,-1)*CFrame.Angles(.35,0,0),P.orange,true)
shops.Parent=polish

local ships={};for _,o in hub:GetDescendants()do if o:IsA('Model')and o.Name=='StarterShip'then table.insert(ships,o)end end
for _,s in ships do
 local hull=s.Hull;local accent=s.Spine.Color
 for _,side in {-1,1}do p(s,'TailFin',V(.5,2.4,3.7),hull.CFrame*CF(side*4.3,2.2,3.8),accent,true,'WedgePart')end
 for _,engine in s:GetChildren()do if engine.Name=='EngineCore'then
  for _,side in {-1,1}do
   p(s,'NozzleRim',V(.15,.22,2.6),engine.CFrame*CF(-.2,side*1.15,0),P.cream)
   p(s,'NozzleRim',V(.15,2.6,.22),engine.CFrame*CF(-.2,0,side*1.15),P.cream)
  end
 end end
 local rack=s:FindFirstChild('CargoRack')
 if rack then for _,side in {-1,1}do p(s,'CargoBrace',V(.3,.8,3.9),rack.CFrame*CF(side*1.35,.55,0),P.dark,true)end end
end

local landscaping=model('PlazaLandscaping',nil)
planter(landscaping,CF(-20,Y,32),9,3)
planter(landscaping,CF(20,Y,32),9,3)
planter(landscaping,CF(-33,Y,-28),8,4)
planter(landscaping,CF(33,Y,-28),8,4)
-- Six approach lantern pairs establish a rhythm around the public center.
for index=1,6 do
 local a=-math.pi*.5+(index-1)*math.pi/3;local dir=V(math.cos(a),0,math.sin(a));local cf=CFrame.lookAt(dir*34,dir*33)
 for _,side in {-1,1}do
  local lc=cf*CF(side*5.4,Y+3.8,0)
  p(landscaping,'PathLampPost',V(.55,4,.55),lc*CF(0,-1.8,0),P.wood,true)
  lantern(landscaping,lc)
 end
end
landscaping.Parent=polish
local L=game.Lighting;L.ClockTime=13.8;L.Brightness=2.2;L.Ambient=C(163,169,162);L.OutdoorAmbient=C(163,169,162);L.ExposureCompensation=.08
L.StarfallColor.TintColor=C(255,248,232);L.StarfallColor.Contrast=.04;L.StarfallColor.Saturation=.04
L.StarfallBloom.Intensity=.16;L.StarfallBloom.Threshold=1.8
return {DetailInstances=#polish:GetDescendants(),Plots=#hub.Plots:GetChildren(),Backup=backup:GetFullName()}

end
polishHome()
local function finishHome()
-- Clean ground joins and finish both market stalls on every visible side.
local C=Color3.fromRGB;local V=Vector3.new;local CF=CFrame.new
local hub=workspace.StarfallMap.Hub;local Y=30
assert(not hub:GetAttribute('SurfaceFinish'),'Home finish already applied')
local backup=Instance.new('Folder');backup.Name='StarfallBeforeSurfaceFinish';backup.Parent=game.ServerStorage
hub:Clone().Parent=backup
local P={path=C(213,176,120),wood=C(130,83,50),cream=C(231,226,204),dark=C(42,59,69),glass=C(72,119,143),gold=C(247,198,82)}
local function part(parent,name,size,cf,color,studs)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=Enum.Material.Plastic
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.TopSurface=studs and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function model(name,parent)local m=Instance.new('Model');m.Name=name;m.Parent=parent;return m end
local function sign(parent,text,cf,w,h,color)
 local p=part(parent,'Sign',V(w,h,.22),cf,P.dark)
 for _,face in {Enum.NormalId.Front,Enum.NormalId.Back}do
  local g=Instance.new('SurfaceGui');g.Face=face;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=20;g.LightInfluence=0;g.Parent=p
  local t=Instance.new('TextLabel');t.Size=UDim2.fromScale(.94,.86);t.Position=UDim2.fromScale(.03,.07);t.BackgroundTransparency=1
  t.Font=Enum.Font.Arcade;t.Text=text;t.TextScaled=true;t.TextColor3=color;t.Parent=g
 end
end
local function beam(parent,a,b,w,color)
 part(parent,'TimberBrace',V(w,w,(b-a).Magnitude),CFrame.lookAt((a+b)*.5,b),color,true)
end

-- Each plot gets one continuous path. The plaza and angled paths share cut
-- boundaries; small smooth junction aprons prevent doubled rotated stud patterns.
local paths=model('FinishedWalkingPaths',hub)
local market=part(paths,'MarketWalk',V(72,.4,18),CF(0,Y+.2,18),P.path,true);market.CanCollide=true
for index=1,6 do
 local a=-math.pi*.5+(index-1)*math.pi/3;local dir=V(math.cos(a),0,math.sin(a))
 local inner=index==4 and 27 or 26
 if index==3 or index==5 then
  local outside=(36+4*math.abs(dir.Z))/math.abs(dir.X)
  local head=part(paths,'JunctionSource',V(8,.4,outside-inner),CFrame.lookAt(dir*((outside+inner)*.5),dir*((outside+inner)*.5)-dir)*CF(0,Y+.2,0),P.path)
  local cutter=part(paths,'JunctionCutter',V(72,4,18),CF(0,Y,18),P.path)
  local apron=head:SubtractAsync({cutter},Enum.CollisionFidelity.PreciseConvexDecomposition,Enum.RenderFidelity.Precise)
  apron.Name='JunctionApron'..index;apron.Anchored=true;apron.UsePartColor=true;apron.Color=P.path;apron.Material=Enum.Material.Plastic
  apron.CanCollide=true;apron.CanTouch=false;apron.Parent=paths;head:Destroy();cutter:Destroy()
  inner=outside
 end
 local outer=73
 local frame=CFrame.lookAt(dir*((inner+outer)*.5),dir*((inner+outer)*.5)-dir)
 part(paths,'PlotApproach'..index,V(8,.4,outer-inner),frame*CF(0,Y+.2,0),P.path,true).CanCollide=true
end
hub.WalkingPaths.Parent=backup;paths.Name='WalkingPaths'

for index=1,6 do
 local plot=hub.Plots[string.format('Plot%02d',index)]
 local cf=plot.Terrain.Lawn.CFrame*CF(0,-29.5,0)
 plot.EntrancePath.Parent=backup
 -- Borders finish outside the eight-stud lane rather than underneath it.
 local pad=plot.ShipPad
 pad.PadBorder.Size=V(13.5,.4,24);pad.PadBorder.CFrame=cf*CF(-11,Y+.2,1)
 pad.PadTop.Size=V(12.5,.3,22);pad.PadTop.CFrame=cf*CF(-11,Y+.55,1);pad.PadTop.TopSurface=Enum.SurfaceType.Smooth
 pad.StarterShip:PivotTo(pad.StarterShip:GetPivot()+V(0,.46,0))
 local grass=plot.PetGarden.GardenGrass;grass.Size=V(15,.4,26);grass.CFrame=cf*CF(12,Y+.2,1)
 for _,tile in plot.PetGarden:GetChildren()do if tile.Name=='PetDisplayTile'then
  tile.CFrame+=V(0,30.66-tile.Position.Y,0)
 end end
 for _,anchor in plot.PetGarden.PlacementAnchors:GetChildren()do anchor.CFrame+=V(0,30.8-anchor.Position.Y,0)end
 local trimCount=0
 for _,o in hub.WorldPolish['PlotDetail'..index]:GetChildren()do
  if o.Name=='PadTrim'then
   trimCount+=1;local side=trimCount==1 and -1 or 1;o.CFrame=cf*CF(-11+side*6,Y+.74,1)
  elseif o.Name=='FoodBowl' or o.Name=='BowlInset'then o.CFrame+=cf:VectorToWorldSpace(V(-.6,.4,0))end
 end
 -- Underlying lawn studs remain below the raised walk instead of bleeding through it.
 local link=plot.Terrain.LinkGround;link.CFrame+=V(0,-.28,0)
 task.wait()
end

local launch=hub.PublicArea.LaunchPad
launch.PadBorder.Size=V(27,.4,29);launch.PadBorder.CFrame=CF(0,Y+.2,-7)
launch.PadSurface.Size=V(24,.3,26);launch.PadSurface.CFrame=CF(0,Y+.55,-7);launch.PadSurface.TopSurface=Enum.SurfaceType.Smooth
launch.StarterShip:PivotTo(launch.StarterShip:GetPivot()+V(0,.32,0))
for _,o in launch:GetChildren()do
 if o.Name=='PaintStripe'then o.CFrame+=V(0,.32,0)
 elseif o.Name=='Bumper'then o.CFrame+=V(0,.4,0)end
end
launch.PadSurface.LaunchAnchor.CFrame=CF(0,.15,0)
for _,o in hub.WorldPolish.LaunchDetail:GetChildren()do
 if o.Name=='PadHazard'then o.CFrame+=V(0,.28,0)
 elseif o.Name=='PadSide'then o.CFrame+=V(0,.25,0)end
end

local wraps=model('ShopWrap',hub.WorldPolish)
for index,shop in {hub.PublicArea.Shops.PetShop,hub.PublicArea.Shops.ShipShop}do
 local x=shop.BackWall.Position.X;local accent=shop.Canopy.Color
 local detail=model(shop.Name..'Exterior',nil)
 shop.Floor.Size=V(16,.4,14);shop.Floor.CFrame=CF(x,Y+.2,-1)
 -- Low side walls leave the stall welcoming and keep the shopkeeper visible.
 for _,side in {-1,1}do
  local sx=x+side*6.7
  part(detail,'RearCornerPost',V(.9,10,.9),CF(sx,Y+5,-6),P.wood,true).CanCollide=true
  part(detail,'SideWall',V(.45,2.8,10),CF(sx,Y+1.4,-1),P.cream,true).CanCollide=true
  part(detail,'SidePanel',V(.16,1.4,8.7),CF(sx+side*.32,Y+1.2,-1),accent,true)
  part(detail,'SideRail',V(.7,.35,10.3),CF(sx,Y+2.95,-1),P.wood,true)
  beam(detail,V(sx,Y+9.7,-5.6),V(sx,Y+7.2,-3.3),.4,P.wood)
  beam(detail,V(sx,Y+9.7,3.6),V(sx,Y+7.2,1.3),.4,P.wood)
  for _,z in {-2.7,.7}do part(detail,'SideSignSupport',V(.28,3,.28),CF(sx+side*.22,Y+4.5,z),P.wood,true)end
  sign(detail,index==1 and 'PETS' or 'SHIP WORKS',CF(sx+side*.4,Y+5.6,-1)*CFrame.Angles(0,side*math.pi*.5,0),5.5,1.7,P.cream)
  -- Framed rear windows have layered depths so their faces never share a plane.
  local wx=x+side*4.5
  part(detail,'RearWindowFrame',V(3.5,2.8,.2),CF(wx,Y+4.8,-7.12),accent,true)
  part(detail,'RearWindowGlass',V(2.9,2.2,.12),CF(wx,Y+4.8,-7.3),P.glass)
  part(detail,'WindowMullion',V(.2,2.2,.1),CF(wx,Y+4.8,-7.42),P.cream)
  part(detail,'WindowMullion',V(2.9,.2,.1),CF(wx,Y+4.8,-7.42),P.cream)
  part(detail,'WindowSill',V(3.8,.3,.65),CF(wx,Y+3.3,-7.3),P.wood,true)
  part(detail,'RearWainscot',V(5,1.5,.18),CF(wx,Y+.85,-7.15),accent,true)
 end
 part(detail,'DoorFrame',V(3.3,6.2,.22),CF(x,Y+3.1,-7.12),P.wood,true)
 part(detail,'ServiceDoor',V(2.7,5.6,.16),CF(x,Y+3,-7.33),accent,true)
 part(detail,'DoorWindow',V(1.9,1.3,.12),CF(x,Y+4.6,-7.5),P.dark)
 part(detail,'DoorHandle',V(.25,.5,.23),CF(x+.85,Y+2.7,-7.5),P.gold)
 sign(detail,index==1 and 'PET EXCHANGE' or 'SHIP WORKS',CF(x,Y+7.2,-7.28),12,1.1,P.cream)
 -- Fascia wraps the roof, hiding raw stripe ends from rear and side views.
 for _,z in {-8.65,6.65}do part(detail,'RoofFascia',V(16.4,.65,.35),CF(x,Y+10.7,z),accent,true)end
 for _,side in {-1,1}do part(detail,'RoofFascia',V(.35,.65,15.6),CF(x+side*8.05,Y+10.7,-1),accent,true)end
 part(detail,'RoofVent',V(2.6,.65,2.2),CF(x+3.8,Y+11.45,-4),P.dark,true)
 for j=1,4 do part(detail,'VentSlat',V(2,.1,.18),CF(x+3.8,Y+11.83,-4.75+j*.3),P.cream)end
 local lamp=part(detail,'RearLantern',V(.7,.9,.7),CF(x+5.8,Y+6.7,-7.7),P.gold)
 part(detail,'LanternHood',V(1,.2,1),CF(x+5.8,Y+7.25,-7.7),P.dark,true)
 local light=Instance.new('PointLight');light.Color=P.gold;light.Brightness=.3;light.Range=7;light.Parent=lamp
 detail.Parent=wraps;task.wait()
end
hub:SetAttribute('SurfaceFinish',true)
return {Plots=#hub.Plots:GetChildren(),Paths=#paths:GetChildren(),ShopExteriors=#wraps:GetChildren(),Backup=backup:GetFullName()}

end
finishHome()
local function refineSpaceport()
-- Open market kiosks, compact modular ships, and a clearer departure area.
local C=Color3.fromRGB;local V=Vector3.new;local CF=CFrame.new
local root=workspace.StarfallMap;local hub=root.Hub;local Y=30
assert(hub:GetAttribute('SurfaceFinish'),'Apply HomeFinish first')
assert(not hub:GetAttribute('SpaceportRefinement'),'Spaceport refinement already applied')
local backup=Instance.new('Folder');backup.Name='StarfallBeforeSpaceportRefinement';backup.Parent=game.ServerStorage
hub:Clone().Parent=backup
local P={cream=C(231,229,211),white=C(249,244,225),dark=C(42,58,70),wood=C(132,84,53),path=C(213,176,120),turquoise=C(49,174,174),orange=C(236,137,57),blue=C(76,151,181),cyan=C(111,224,239),gold=C(248,205,86),rock=C(92,98,107)}
local function model(name,parent)local m=Instance.new('Model');m.Name=name;m.Parent=parent;return m end
local function p(parent,name,size,cf,color,studs,class,solid)
 local o=Instance.new(class or 'Part');o.Name=name;o.Size=size;o.CFrame=cf;o.Color=color;o.Material=Enum.Material.Plastic
 o.Anchored=true;o.CanCollide=solid==true;o.CanTouch=false;o.TopSurface=studs and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth
 o.BottomSurface=Enum.SurfaceType.Smooth;o.Parent=parent;return o
end
local function sign(parent,name,text,cf,w,h,color)
 local b=p(parent,name,V(w,h,.22),cf,P.dark)
 for _,face in {Enum.NormalId.Front,Enum.NormalId.Back}do
  local g=Instance.new('SurfaceGui');g.Face=face;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=20;g.LightInfluence=0;g.Parent=b
  local t=Instance.new('TextLabel');t.Size=UDim2.fromScale(.94,.86);t.Position=UDim2.fromScale(.03,.07);t.BackgroundTransparency=1
  t.Font=Enum.Font.Arcade;t.Text=text;t.TextScaled=true;t.TextColor3=color or P.cream;t.Parent=g
 end
 return b
end
local function crate(parent,cf,size,accent)
 local m=model('CargoCrate',parent);p(m,'Box',size,cf,accent or P.wood,true)
 for _,side in {-1,1}do p(m,'Strap',V(.17,size.Y+.06,size.Z+.06),cf*CF(side*size.X*.3,0,0),P.dark)end
 return m
end
local function disc(parent,name,cf,diameter,thickness,color)
 local d=p(parent,name,V(thickness,diameter,diameter),cf*CFrame.Angles(0,math.pi*.5,0),color);d.Shape=Enum.PartType.Cylinder;return d
end

local function buildShip(parent,cf,accent,showcase)
 local s=model('StarterShip',nil);s:SetAttribute('DisplayOnly',true);s:SetAttribute('VisualTier',showcase and 2 or 0)
 local function q(name,size,offset,color,class,solid,rotation)
  return p(s,name,size,cf*CF(offset)*(rotation or CFrame.new()),color,true,class,solid)
 end
 local hull=q('Hull',V(5.6,2.8,9.6),V(0,3.2,0),P.cream,nil,true);s.PrimaryPart=hull
 q('LowerHull',V(4.8,1,10.5),V(0,2,0),P.dark,nil,true)
 q('Nose',V(5.6,2.8,3.4),V(0,3.2,-6.5),P.cream,'WedgePart',true)
 q('NoseStripe',V(2.2,.1,2.6),V(0,3.59,-6.15),accent,nil,false,CFrame.Angles(-math.atan(2.8/3.4),0,0))
 q('Cockpit',V(4.2,2.1,3.7),V(0,5.05,-2.2),P.dark,'WedgePart',true)
 q('Window',V(3.6,.22,2.9),V(0,5.55,-2.25),P.blue,nil,false,CFrame.Angles(-.25,0,0)).TopSurface=Enum.SurfaceType.Smooth
 q('Spine',V(2.5,.5,1),V(0,4.85,.75),accent)
 for _,side in {-1,1}do
  q('HullStripe',V(.22,1.1,6.8),V(side*2.9,3.4,0),accent)
  q('Wing',V(2.7,.65,5.6),V(side*3.75,2.4,.7),accent,nil,true)
  q('EngineHousing',V(2.8,3,6.8),V(side*4.4,3.2,2.5),P.dark,nil,true)
  q('EngineArmor',V(2.9,.55,5.4),V(side*4.4,4.95,2.1),accent)
  q('BoosterNose',V(2.8,2.6,2),V(side*4.4,3.4,-1.9),P.cream,'WedgePart',true)
  q('TailFin',V(.5,2.8,3.4),V(side*4.4,5.7,3.5),accent,'WedgePart')
  disc(s,'NozzleFrame',cf*CF(side*4.4,3.2,6.1),2.6,.35,P.cream)
  local engine=disc(s,'EngineCore',cf*CF(side*4.4,3.2,6.32),1.8,.12,P.cyan)
  engine.Material=Enum.Material.Neon;engine.CastShadow=false
  if showcase then
   q('UpgradeArmor',V(.35,2.1,4.3),V(side*5.95,3.45,2.3),accent)
   q('UpgradeIntake',V(1.9,.4,2),V(side*4.4,5.45,1),P.cream)
  end
  for _,z in {-3,3}do
   q('LandingLeg',V(.65,1.2,.65),V(side*2,.9,z),P.dark,nil,true)
   q('LandingFoot',V(1.5,.4,1.7),V(side*2,.2,z),P.rock,nil,true)
  end
 end
 q('CargoRack',V(3.5,.35,3.5),V(0,4.775,3.1),P.dark)
 crate(s,cf*CF(0,5.575,3.1),V(2.7,1.25,2.6),accent)
 if showcase then crate(s,cf*CF(0,6.7,3.1),V(2.3,1,2.2),P.cream)end
 q('ShieldMount',V(1.4,.3,1.4),V(0,4.75,.1),P.blue)
 disc(s,'WeaponMount',cf*CF(0,3.1,-8.25),1,.18,P.dark)
 for name,offset in {EngineLeft=V(-4.4,3.2,2.5),EngineRight=V(4.4,3.2,2.5),Shield=V(0,5,.1),Weapon=V(0,3.1,-8.25),Cargo=V(0,5.02,3.1)}do
  local a=Instance.new('Attachment');a.Name=name..'Socket';a.Position=V(offset.X,offset.Y-3.2,offset.Z);a.Parent=hull
 end
 s.Parent=parent;return s
end
for index=1,6 do
 local pad=hub.Plots[string.format('Plot%02d',index)].ShipPad;local old=pad.StarterShip;local accent=old.Spine.Color
 pad.PadBorder.CanCollide=true;pad.PadTop.CanCollide=true
 local garden=pad.Parent.PetGarden;garden.GardenGrass.CanCollide=true
 for _,tile in garden:GetChildren()do if tile.Name=='PetDisplayTile'then
  tile.Size=V(3.4,.3,3.4);tile.CFrame+=V(0,30.55-tile.Position.Y,0);tile.CanCollide=true
 end end
 local cf=old.Hull.CFrame*CF(0,-2.7,0);cf+=V(0,30.7-cf.Position.Y,0)
 old.Parent=backup;buildShip(pad,cf,accent,false);task.wait()
end
local launch=hub.PublicArea.LaunchPad
launch.PadBorder.CanCollide=true;launch.PadSurface.CanCollide=true
launch.StarterShip.Parent=backup
local showShip=buildShip(launch,CF(0,Y+.7,-7),P.orange,true)

-- Compact central counters leave an unobstructed loop on every side.
local oldShops=hub.PublicArea.Shops;local oldDetail=hub.WorldPolish.ShopDetail
local mascot=oldDetail.MascotPet:Clone();mascot:PivotTo(mascot:GetPivot()+V(-13.5,0,9))
local trolley=oldDetail.RepairTrolley:Clone();trolley:PivotTo(trolley:GetPivot()+V(-3,0,-3.3))
local shops=model('OpenShops',nil)
for index,old in {oldShops.PetShop,oldShops.ShipShop}do
 local x=index==1 and -27 or 27;local accent=index==1 and P.turquoise or P.orange
 local shop=model(old.Name,nil);shop:SetAttribute('ApproachSides',4)
 p(shop,'Floor',V(14,.4,14),CF(x,Y+.2,-2),P.path,true,nil,true)
 for _,side in {-1,1}do for _,z in {-8.2,4.2}do
  p(shop,'CornerFoot',V(1.1,.45,1.1),CF(x+side*6.2,Y+.625,z),P.dark,true)
  p(shop,'Post',V(.7,9.3,.7),CF(x+side*6.2,Y+5.05,z),P.wood,true,nil,true)
  local lamp=p(shop,'Lantern',V(.55,.75,.55),CF(x+side*6.2,Y+6.3,z+(z<0 and -.5 or .5)),P.gold)
  p(shop,'LanternCap',V(.8,.15,.8),lamp.CFrame*CF(0,.45,0),P.dark,true)
 end end
 p(shop,'Canopy',V(15,1,15),CF(x,Y+10.2,-2),accent,true,nil,true)
 for j=-2,2 do p(shop,'RoofStripe',V(1.35,.3,15),CF(x+j*3,Y+10.85,-2),P.cream,true)end
 for _,z in {-9.6,5.6}do p(shop,'Fascia',V(15.5,.6,.35),CF(x,Y+10.45,z),accent,true)end
 for _,side in {-1,1}do p(shop,'Fascia',V(.35,.6,15.5),CF(x+side*7.6,Y+10.45,-2),accent,true)end
 for _,z in {-8.3,4.3}do p(shop,'Header',V(13,.7,.55),CF(x,Y+8.5,z),P.wood,true)end
 for _,side in {-1,1}do p(shop,'Header',V(.55,.7,13),CF(x+side*6.3,Y+8.5,-2),P.wood,true)end
 local fullTitle=index==1 and 'PET EXCHANGE' or 'SHIP UPGRADES'
 for _,z in {-8.65,4.65}do sign(shop,'ShopTitle',fullTitle,CF(x,Y+8.35,z),11.5,1.6)end
 for _,side in {-1,1}do sign(shop,'SideTitle',index==1 and 'PETS' or 'UPGRADES',CF(x+side*6.65,Y+8.35,-2)*CFrame.Angles(0,math.pi*.5,0),9,1.6)end
 -- Four counter rails meet at their corners without doubled top faces.
 for _,z in {-2.8,2.8}do
  p(shop,'Counter',V(6.8,2.5,1.2),CF(x,Y+1.65,-2+z),accent,true,nil,true)
  p(shop,'CounterTop',V(6.8,.3,1.3),CF(x,Y+3.05,-2+z),P.cream,true)
 end
 for _,side in {-1,1}do
  p(shop,'Counter',V(1.2,2.5,4.4),CF(x+side*2.8,Y+1.65,-2),accent,true,nil,true)
  p(shop,'CounterTop',V(1.3,.3,4.3),CF(x+side*2.8,Y+3.05,-2),P.cream,true)
 end
 local robot=old.RobotShopkeeper:Clone();robot.PrimaryPart=robot.Body
 robot:PivotTo(robot:GetPivot()+V(x-old.BackWall.Position.X,.4,-1));robot:SetAttribute('TrackVisitor',true);robot.Parent=shop
 for _,q in {V(0,2.5,4.8),V(0,2.5,-4.8),V(-4.8,2.5,0),V(4.8,2.5,0)}do
  local a=Instance.new('Attachment');a.Name='ServiceApproach';a.Parent=shop.Floor;a.WorldCFrame=CF(x,Y,-2)*CF(q)
 end
 if index==1 then
  for n,q in {V(-2.7,0,2.7),V(2.7,0,-2.7),V(2.7,0,2.7)}do
   local egg=p(shop,'DisplayEgg',V(1.05,1.45,1.05),CF(x+q.X,Y+3.95,-2+q.Z),n==1 and P.gold or P.turquoise);egg.Shape=Enum.PartType.Ball
  end
  p(shop,'IncubatorBase',V(1.7,.3,1.7),CF(x-2.7,Y+3.4,-4.7),P.dark,true)
  local dome=p(shop,'IncubatorGlass',V(1.55,2.2,1.55),CF(x-2.7,Y+4.6,-4.7),P.cyan);dome.Transparency=.7
  local egg=p(shop,'IncubatorEgg',V(.95,1.3,.95),CF(x-2.7,Y+4.2,-4.7),P.cream);egg.Shape=Enum.PartType.Ball
 else
  for n,q in {V(-2.7,0,-2.7),V(2.7,0,-2.7),V(-2.7,0,2.7),V(2.7,0,2.7)}do
   local color=({P.turquoise,P.blue,P.orange,P.dark})[n]
   p(shop,'ModuleDisplay',V(1.3,1.1,1.3),CF(x+q.X,Y+3.8,-2+q.Z),color,true)
   if n<=2 then disc(shop,'EngineDisplay',CF(x+q.X,Y+3.8,-1.3+q.Z),.7,.15,P.cyan)end
  end
 end
 shop.Parent=shops;task.wait()
end
oldShops.Parent=backup;shops.Name='Shops';shops.Parent=hub.PublicArea
oldDetail.Parent=backup;hub.WorldPolish.ShopWrap.Parent=backup
local stock=model('ShopStock',hub.WorldPolish);mascot.Parent=stock;trolley.Parent=stock
crate(stock,CF(-34,Y+1,7),V(3.8,2,3.5),P.wood)
for _,x in {-27,27}do p(hub.WalkingPaths,'ShopApproach',V(6,.4,4),CF(x,Y+.2,7),P.path,true,nil,true)end

local details=model('DepartureDetails',nil)
launch.LaunchSign.Parent=backup;launch.PadBorder.TopSurface=Enum.SurfaceType.Smooth
for _,side in {-1,1}do for _,z in {-18,4}do
 p(details,'LandingCorner',V(2.2,.06,.35),CF(side*9.6,Y+.76,z),P.cream)
 p(details,'LandingCorner',V(.35,.06,2.2),CF(side*10.525,Y+.76,z+(z<0 and 1.275 or -1.275)),P.cream)
end end
p(details,'BoardingStep',V(8,.15,1.5),CF(0,Y+.475,8.05),P.rock,true,nil,true)
p(details,'BoardingStep',V(8,.15,1.3),CF(0,Y+.625,6.65),P.cream,true,nil,true)
for _,x in {-3,3}do p(details,'BoardingStripe',V(.6,.04,1.4),CF(x,Y+.57,8.05),P.gold)end
local loader=model('CargoLoader',details)
p(loader,'Cart',V(2.5,.4,3.5),CF(9,Y+.95,1.5),P.orange,true)
for _,side in {-1,1}do for _,z in {.3,2.7}do
 local wheel=p(loader,'Wheel',V(.35,.9,.9),CF(9+side*1.3,Y+.5,z),P.dark);wheel.Shape=Enum.PartType.Cylinder
end end
crate(loader,CF(9,Y+1.8,1.5),V(1.8,1.3,2.2),P.cream)
p(loader,'Handle',V(2,.2,.2),CF(9,Y+2,3.6),P.dark)
for _,side in {-1,1}do p(loader,'HandlePost',V(.2,1.2,.2),CF(9+side*.9,Y+1.5,3.6),P.dark)end
for _,o in hub.WorldPolish.LaunchDetail:GetChildren()do if o.Name=='ServicingCabinet'then o.CFrame=CF(math.sign(o.Position.X)*12,Y+1.5,-25)end end
sign(details,'ShipShowcase','UPGRADED SHIP',CF(9.5,Y+2.2,-9)*CFrame.Angles(0,math.pi*.5,0),5.3,1.4,P.gold)
p(details,'DisplayPlaqueStand',V(.35,2,.35),CF(9.5,Y+1,-9),P.dark)
local board=p(details,'DepartureSignal',V(5,1.4,.35),CF(0,Y+9.8,-18.7),P.dark,true)
for i,color in {C(115,63,51),C(132,117,58),C(113,202,109)}do
 local lamp=p(details,'SignalLamp',V(.75,.75,.15),board.CFrame*CF((i-2)*1.35,0,.25),color)
 if i==3 then lamp.Material=Enum.Material.Neon;lamp.CastShadow=false end
end
details.Parent=hub.WorldPolish

-- Small stepped bands improve the floating-island silhouette below the lawn.
local cliffs=model('CliffBands',nil)
p(cliffs,'CentralRockBand',V(81.5,1.2,73.5),CF(0,Y-2,0),C(103,106,105),true)
p(cliffs,'CentralLowerBand',V(74,1.7,66),CF(0,Y-13.8,0),C(63,74,83),true)
for index=1,6 do
 local cf=hub.Plots[string.format('Plot%02d',index)].Terrain.Lawn.CFrame*CF(0,-29.5,0)
 p(cliffs,'PlotRockBand',V(47.2,1.1,47.2),cf*CF(0,Y-2,0),C(99,106,103),true)
 p(cliffs,'PlotLowerBand',V(39,1.4,38),cf*CF(0,Y-13.7,0),C(63,74,83),true)
end
cliffs.Parent=hub.WorldPolish
hub:SetAttribute('SpaceportRefinement',true)
return {Plots=#hub.Plots:GetChildren(),Shops=#shops:GetChildren(),Ships=7,Backup=backup:GetFullName()}

end
refineSpaceport()
local function planetVista()
-- Readable toy planet silhouettes replace the scattered first-pass dioramas.
local C=Color3.fromRGB;local V=Vector3.new;local CF=CFrame.new
local root=workspace.StarfallMap
assert(not root:GetAttribute('PlanetVista'),'Planet vista already applied')
local backup=Instance.new('Folder');backup.Name='StarfallBeforePlanetVista';backup.Parent=game.ServerStorage
for _,name in {'Sectors','Routes','Backdrop'}do local o=root:FindFirstChild(name);if o then o.Parent=backup end end
local function part(parent,name,size,cf,color,studs)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=Enum.Material.Plastic
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.TopSurface=studs and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local sectors=Instance.new('Model');sectors.Name='Sectors';sectors.Parent=root
local definitions={
 {'ScrapBelt',V(-270,110,-190),40,C(67,151,171),C(128,191,78),C(213,165,95)},
 {'IceGraveyard',V(-510,180,120),53,C(91,175,208),C(220,240,230),C(146,217,226)},
 {'DerelictField',V(310,140,-310),48,C(187,113,66),C(219,155,89),C(112,82,85)},
 {'NebulaCurrent',V(80,230,-650),58,C(128,91,183),C(99,173,181),C(180,138,207)},
 {'AncientRuins',V(550,160,190),62,C(147,157,94),C(205,190,126),C(116,139,133)},
 {'SingularityEdge',V(-80,260,700),57,C(49,43,82),C(102,69,132),C(169,112,174)},
}
for index,d in definitions do
 local m=Instance.new('Model');m.Name=d[1];m:SetAttribute('VistaOnly',true);m.Parent=sectors
 local center,r=d[2],d[3];local body=part(m,'Planet',V(r*2,r*2,r*2),CF(center),d[4]);body.Shape=Enum.PartType.Ball
 local facing=CFrame.lookAt(center,V(0,35,0))
 for group,offset in {Vector2.new(0,0),Vector2.new(1.8,.3),Vector2.new(-1.8,-.35)}do
  for n,cell in {Vector2.new(0,0),Vector2.new(-1,0),Vector2.new(1,0),Vector2.new(0,-1),Vector2.new(0,1),Vector2.new(1,1),Vector2.new(-1,-1)}do
   local latitude=offset.Y+cell.Y*.21;local longitude=offset.X+cell.X*.21
   local localDir=V(math.sin(longitude)*math.cos(latitude),math.sin(latitude),-math.cos(longitude)*math.cos(latitude))
   local dir=facing:VectorToWorldSpace(localDir);local pos=center+dir*(r-.7)
   local cf=CFrame.lookAt(pos,pos+dir)*CFrame.Angles(-math.pi*.5,0,0)
   part(m,'ContinentPlate',V(r*.24,2.5,r*.24),cf,group==2 and d[6]or d[5],true)
  end
 end
 if index==2 or index==6 then
  local plane=CF(center)*CFrame.Angles(.2,0,index==2 and -.4 or .45)
  local outer=part(m,'RingSource',V(1.2,r*3.15,r*3.15),plane*CFrame.Angles(0,0,math.pi*.5),index==2 and C(184,214,219)or C(181,125,180));outer.Shape=Enum.PartType.Cylinder
  local inner=part(m,'RingCutter',V(6,r*2.8,r*2.8),outer.CFrame,d[4]);inner.Shape=Enum.PartType.Cylinder
  local ring=outer:SubtractAsync({inner},Enum.CollisionFidelity.Box,Enum.RenderFidelity.Precise)
  ring.Name='OrbitRing';ring.UsePartColor=true;ring.Color=outer.Color;ring.Anchored=true;ring.CanCollide=false;ring.CanTouch=false;ring.Parent=m
  outer:Destroy();inner:Destroy()
 end
 if index==3 then
  for n=1,7 do
   local a=n*math.pi*2/7;local pos=center+V(math.cos(a)*r*1.6,math.sin(a*2)*14,math.sin(a)*r*1.6)
   part(m,'SmallAsteroid',V(7+n%3,6+n%2,8),CF(pos)*CFrame.Angles(n*.3,n*.7,.2),C(74,79,89),true)
  end
 end
 task.wait()
end
local routes=Instance.new('Model');routes.Name='Routes';routes.Parent=root
local courier=Instance.new('Model');courier.Name='CourierShuttle';courier:SetAttribute('DisplayOnly',true);courier.Parent=routes
local base=CF(-160,70,-120)
local hull=part(courier,'Hull',V(2.5,1.5,6),base,C(229,227,207),true);courier.PrimaryPart=hull
part(courier,'Cockpit',V(2,1,2),base*CF(0,1,-1.5),C(52,84,112))
part(courier,'Wing',V(6,.4,2.5),base*CF(0,-.3,1),C(236,137,57),true)
for _,x in {-2,2}do
 part(courier,'Engine',V(1.2,1.2,3),base*CF(x,0,1),C(42,58,70),true)
 local glow=part(courier,'Exhaust',V(.8,.8,.2),base*CF(x,0,2.7),C(111,224,239));glow.Material=Enum.Material.Neon;glow.CastShadow=false
end
root:SetAttribute('PlanetVista',true)
return {PlanetVistas=#sectors:GetChildren(),Archived=backup:GetFullName()}

end
planetVista()
local function planetIslands()
-- Six playable biome islands. Egg templates have fixed appearances, no rarity data.
local C=Color3.fromRGB;local V=Vector3.new;local CF=CFrame.new
local root=workspace.StarfallMap
assert(not root:FindFirstChild('PlanetIslands'),'Planet islands already exist')
local backup=Instance.new('Folder');backup.Name='StarfallBeforePlanetIslands';backup.Parent=game.ServerStorage
local previousTemplates=game.ServerStorage:FindFirstChild('StarfallEggTemplates')
if previousTemplates then previousTemplates.Parent=backup end
local planets=root:FindFirstChild('Planets')or root:FindFirstChild('Sectors')
assert(planets,'Build orbital planet models first')
planets:Clone().Parent=backup;planets.Name='Planets'
local definitions={
 {Id='ScrapBelt',Name='Sprout Moon',Center=V(-280,42,-220),Size=V(96,0,88),Ground=C(112,183,70),Accent=C(239,194,91),Rock=C(110,103,90),Egg=C(234,229,199),EggAccent=C(113,183,71)},
 {Id='DerelictField',Name='Rust Crater',Center=V(340,48,-350),Size=V(92,0,100),Ground=C(206,143,79),Accent=C(229,175,103),Rock=C(89,79,78),Egg=C(225,159,77),EggAccent=C(94,105,113),Terrace=4.5},
 {Id='IceGraveyard',Name='Frost Cove',Center=V(-520,56,150),Size=V(104,0,88),Ground=C(129,205,218),Accent=C(231,243,233),Rock=C(81,123,157),Egg=C(194,233,235),EggAccent=C(80,171,202)},
 {Id='NebulaCurrent',Name='Violet Wilds',Center=V(80,64,-700),Size=V(96,0,96),Ground=C(151,103,190),Accent=C(159,205,92),Rock=C(91,75,125),Egg=C(177,120,210),EggAccent=C(172,217,91)},
 {Id='AncientRuins',Name='Relic Grove',Center=V(600,60,230),Size=V(104,0,88),Ground=C(130,169,92),Accent=C(221,198,122),Rock=C(99,111,103),Egg=C(218,204,151),EggAccent=C(91,159,145),Terrace=6},
 {Id='SingularityEdge',Name='Storm Reach',Center=V(-100,82,780),Size=V(100,0,92),Ground=C(90,116,154),Accent=C(128,199,218),Rock=C(61,75,101),Egg=C(131,161,201),EggAccent=C(237,203,93),Terrace=4.5},
}
local function model(name,parent)local m=Instance.new('Model');m.Name=name;m.Parent=parent;return m end
local function p(parent,name,size,cf,color,studs,solid,class)
 local o=Instance.new(class or 'Part');o.Name=name;o.Size=size;o.CFrame=cf;o.Color=color;o.Material=Enum.Material.Plastic
 o.Anchored=true;o.CanCollide=solid==true;o.CanTouch=false;o.TopSurface=studs and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth
 o.BottomSurface=Enum.SurfaceType.Smooth;o.Parent=parent;return o
end
local function sign(parent,text,cf,w,h)
 local b=p(parent,'IslandSign',V(w,h,.25),cf,C(42,58,70))
 for _,face in {Enum.NormalId.Front,Enum.NormalId.Back}do
  local g=Instance.new('SurfaceGui');g.Face=face;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=18;g.LightInfluence=0;g.Parent=b
  local t=Instance.new('TextLabel');t.BackgroundTransparency=1;t.Size=UDim2.fromScale(.94,.86);t.Position=UDim2.fromScale(.03,.07)
  t.Font=Enum.Font.Arcade;t.Text=text;t.TextScaled=true;t.TextColor3=C(239,230,207);t.Parent=g
 end
end
local function tree(parent,cf,height,leaves,trunk)
 local t=model('BlockTree',parent)
 p(t,'Trunk',V(1.6,height*.55,1.6),cf*CF(0,height*.275,0),trunk or C(128,85,53),true,true)
 p(t,'Crown',V(6,3.4,5.5),cf*CF(0,height*.72,0),leaves,true)
 for _,q in {V(-2,.4,0),V(2,1,.5),V(0,2.6,0)}do p(t,'LeafCluster',V(3.5,2.7,3.5),cf*CF(q+V(0,height*.7,0)),leaves:Lerp(C(203,223,132),.15),true)end
end
local function crystal(parent,cf,height,color)
 local m=model('CrystalCluster',parent)
 for i,q in {V(-1.5,0,0),V(0,0,.5),V(1.4,0,-.2)}do
  local h=height*(i==2 and 1 or .65)
  p(m,'Crystal',V(1.9,h,1.9),cf*CF(q+V(0,h*.5,0))*CFrame.Angles(0,i*.35,0),color,true,true)
  p(m,'CrystalTip',V(1.9,2,1.9),cf*CF(q+V(0,h+1,0))*CFrame.Angles(0,i*.35,0),color:Lerp(C(237,242,226),.18),false,false,'WedgePart')
 end
end
local function mushroom(parent,cf,height,color)
 local m=model('BlockMushroom',parent)
 p(m,'Stem',V(1.7,height,1.7),cf*CF(0,height*.5,0),C(221,212,198),true,true)
 p(m,'Cap',V(6.2,1.4,6.2),cf*CF(0,height,0),color,true)
 p(m,'CapTop',V(4.4,1.1,4.4),cf*CF(0,height+1.25,0),color:Lerp(C(224,172,231),.15),true)
 for _,q in {V(-1.7,0,-1.4),V(1.5,0,.6),V(-.3,0,1.6)}do p(m,'Spot',V(.8,.18,.8),cf*CF(q+V(0,height+.8,0)),C(239,225,199))end
end
local islands=model('PlanetIslands',root)
local templates=Instance.new('Folder');templates.Name='StarfallEggTemplates';templates.Parent=game.ServerStorage
for index,d in definitions do
 local island=model(d.Id,nil);island:SetAttribute('DisplayName',d.Name);island:SetAttribute('SurfaceY',d.Center.Y)
 island:SetAttribute('EggTargetCount',8);island:SetAttribute('EggLifetimeSeconds',180);island:SetAttribute('EggRefillSeconds',6)
 -- Surface scenes are outside the orbital map. Future flight arrival uses the links below.
 local surfaceCenter=V(10000+((index-1)%3)*5000,0,math.floor((index-1)/3)*5000)
 local center=surfaceCenter;local base=CF(center);local Y=d.Center.Y
 island:SetAttribute('PlanetId',d.Id);island:SetAttribute('SurfaceScene',true)
 local terrain=model('Terrain',island);local props=model('Props',island)
 local function q(parent,name,size,offset,color,studs,solid,class,rotation)
  return p(parent,name,size,base*CF(offset)*(rotation or CFrame.new()),color,studs,solid,class)
 end
 local function ground(name,w,depth,x,z)
  local surface=q(terrain,name,V(w,1,depth),V(x,Y-.5,z),d.Ground,true,true);surface:SetAttribute('EggGround',true)
  q(terrain,'Cliff',V(w-1,9,depth-1),V(x,Y-5.5,z),d.Rock,true,true)
  q(terrain,'LowerRock',V(w*.8,5,depth*.78),V(x,Y-12.5,z),d.Rock:Lerp(C(38,48,65),.3),false,true)
  q(terrain,'RockBand',V(w+.8,.9,depth+.8),V(x,Y-2.1,z),d.Rock:Lerp(d.Accent,.12),true)
  for _,side in {-1,1}do q(terrain,'RockPoint',V(w*.23,8,depth*.34),V(x+side*w*.2,Y-19,z+side*depth*.12),d.Rock:Lerp(C(38,48,65),.35),false,false,'WedgePart',CFrame.Angles(0,side*.35,0))end
  return surface
 end
 island.PrimaryPart=ground('MainLawn',d.Size.X,d.Size.Z,0,0)
 local wing=index==2 and 26 or index==4 and 24 or 18
 ground('WestWing',wing,index==4 and 52 or 64,-d.Size.X*.5-wing*.5,index==4 and 12 or 0)
 ground('EastWing',index==6 and 24 or 18,index==2 and 72 or 60,d.Size.X*.5+(index==6 and 12 or 9),index==4 and -8 or 0)
 ground('FrontLip',64,16,0,-d.Size.Z*.5-8)
 ground('RearLip',index==5 and 80 or 64,index==5 and 24 or 16,0,d.Size.Z*.5+(index==5 and 12 or 8))
 local pad=model('LandingPad',island)
 q(pad,'PadBorder',V(27,.4,24),V(0,Y+.2,-42),C(62,79,94),true,true)
 local top=q(pad,'PadSurface',V(24,.35,21),V(0,Y+.575,-42),d.Accent,false,true)
 local anchor=Instance.new('Attachment');anchor.Name='LandingAnchor';anchor.CFrame=CF(0,.175,0);anchor.Parent=top
 local entry=q(pad,'ArrivalAnchor',V(1,1,1),V(0,Y+3,-27),d.Ground);entry.Transparency=1;entry.CanQuery=false
 for _,side in {-1,1}do
  q(pad,'PadMark',V(.4,.06,15),V(side*10,Y+.8,-42),C(241,235,216))
  q(pad,'FlagPost',V(.45,7,.45),V(side*16,Y+3.5,-43),C(132,84,53),true,true)
  q(pad,'Flag',V(2.6,1.8,.18),V(side*16+1.3,Y+6,-43),d.Accent,true)
 end
 sign(pad,d.Name:upper(),base*CF(0,Y+3.2,-55),19,2)
 for _,x in {-8,8}do q(pad,'SignPost',V(.5,3,.5),V(x,Y+1.5,-55),C(132,84,53),true,true)end
 local walk=q(terrain,'MainPath',V(8,.4,52),V(0,Y+.2,-4),d.Accent,true,true);walk:SetAttribute('EggGround',true)
 for _,side in {-1,1}do local branch=q(terrain,'BranchPath',V(32,.4,8),V(side*20,Y+.2,4),d.Accent,true,true);branch:SetAttribute('EggGround',true)end
 if d.Terrace then
  local w=index==5 and 76 or index==6 and 80 or 64
  local depth=index==5 and 36 or 28;local front=21
  local t=q(terrain,'UpperTerrace',V(w,d.Terrace,depth),V(0,Y+d.Terrace*.5,front+depth*.5),d.Ground:Lerp(d.Accent,.12),true,true);t:SetAttribute('EggGround',true)
  local steps=math.floor(d.Terrace/.75);local start=front-steps*2
  for n=1,steps do local stair=q(terrain,'TerraceStep',V(10,n*.75,2),V(0,Y+n*.375,start+(n-.5)*2),d.Accent,true,true);stair:SetAttribute('EggGround',true)end
 end
 if index==1 then
  for n,pt in {V(-46,0,-26),V(46,0,-22),V(-47,0,30),V(47,0,31),V(-21,0,41),V(24,0,42)}do tree(props,base*CF(pt+V(0,Y,0)),10+n%3,C(46,137,77))end
  local clearing=q(terrain,'NestingClearing',V(18,.4,14),V(-34,Y+.2,16),C(213,176,120),true,true);clearing:SetAttribute('EggGround',true)
  for n=1,9 do local a=n*math.pi*2/9;local x,z=-34+math.cos(a)*10,16+math.sin(a)*8
   q(props,'FlowerStem',V(.2,1,.2),V(x,Y+.5,z),C(68,136,66),false)
   q(props,'FlowerHead',V(1.2,.3,1.2),V(x,Y+1.15,z),n%2==0 and C(225,143,179)or d.Accent,true)
  end
 elseif index==2 then
  for n,pt in {V(-43,0,-25),V(45,0,-18),V(-52,0,26),V(51,0,29)}do
   q(props,'OreRock',V(6+n%2,4+n%3,6),pt+V(0,Y+2,0),d.Rock,true,true,'WedgePart',CFrame.Angles(0,n*.6,0))
  end
  local wreck=model('CrashedEngine',props);local h=d.Terrace
  q(wreck,'Hull',V(10,4,8),V(0,Y+h+2,37),C(87,100,112),true,true)
  q(wreck,'Armor',V(10.5,1,5),V(0,Y+h+4.5,37),C(223,134,65),true)
  for _,side in {-1,1}do q(wreck,'BrokenFin',V(2.3,4,6),V(side*6,Y+h+2,36),C(185,109,67),true,true,'WedgePart')end
  for n=1,3 do q(props,'CargoBox',V(3,2.5,3),V(-50+(n-1)*4,Y+1.25,-7),C(156,106,63),true,true)end
 elseif index==3 then
  for n,pt in {V(-45,0,-25),V(44,0,-23),V(-48,0,28),V(48,0,25),V(-10,0,39),V(10,0,39)}do crystal(props,base*CF(pt+V(0,Y,0)),n>4 and 10 or 5+n%3,C(73,161,204))end
  for _,side in {-1,1}do local bank=q(terrain,'SnowBank',V(18,.7,12),V(side*41,Y+.35,30),d.Accent,true,true);bank:SetAttribute('EggGround',true)end
 elseif index==4 then
  for n,pt in {V(-45,0,-23),V(43,0,-22),V(-48,0,30),V(46,0,29),V(-13,0,40),V(14,0,42)}do mushroom(props,base*CF(pt+V(0,Y,0)),n>4 and 9 or 5+n%3,n%2==0 and C(183,96,187)or C(114,92,178))end
  for _,pt in {V(-58,0,10),V(52,0,8)}do tree(props,base*CF(pt+V(0,Y,0)),11,d.Accent,C(100,70,124))end
 elseif index==5 then
  for _,side in {-1,1}do
   tree(props,base*CF(side*46,Y,-24),12,C(72,134,99))
   q(props,'RuinPillar',V(2.6,10,3),V(side*8,Y+11,38),d.Accent,true,true)
   q(props,'RuinCap',V(4,.9,4),V(side*8,Y+16.45,38),C(183,173,124),true)
   q(props,'BrokenColumn',V(3,4,3),V(side*48,Y+2,25),d.Rock,true,true)
  end
  q(props,'RuinLintel',V(20,2,4),V(0,Y+17.2,38),d.Accent,true,true)
  q(props,'RuinInlay',V(6,1,.2),V(0,Y+17.2,35.85),C(86,172,157),true)
  for n=1,3 do q(props,'StoneSlab',V(5,.6,3),V(-29+(n-1)*6,Y+.3,38),d.Rock,true,true)end
 elseif index==6 then
  for _,side in {-1,1}do
   local mast=model('StormMast',props);local y=Y+4.5
   q(mast,'Base',V(4,1,4),V(side*34,y+.5,35),C(58,77,101),true,true)
   q(mast,'Mast',V(1.2,8,1.2),V(side*34,y+5,35),d.Accent,true,true)
   q(mast,'Collector',V(5,1,3),V(side*34,y+9,35),C(231,199,92),true)
   for _,z in {-1,1}do q(mast,'Fin',V(2,3,.45),V(side*34,y+7,35+z*2),d.Accent,true,false,'WedgePart')end
  end
  for n,pt in {V(-44,0,-26),V(45,0,-24),V(-53,0,10),V(51,0,10)}do crystal(props,base*CF(pt+V(0,Y,0)),5+n%2,C(131,158,196))end
 end
 -- Keep searching areas open while making the perimeter feel like a biome.
 for n,pt in {V(-42,0,-6),V(42,0,9),V(-33,0,-35),V(32,0,-34),V(-37,0,38),V(37,0,39),V(-57,0,15),V(53,0,-10)}do
  if index==1 then tree(props,base*CF(pt+V(0,Y,0)),9+n%3,C(47,132,73))
  elseif index==4 then mushroom(props,base*CF(pt+V(0,Y,0)),4+n%4,n%2==0 and C(168,86,177)or C(115,80,160))
  elseif index==5 then
   if n%2==1 then tree(props,base*CF(pt+V(0,Y,0)),9+n%3,C(66,126,91))
   else q(props,'WeatheredStone',V(3.4,3+n%3,3.2),pt+V(0,Y+(3+n%3)*.5,0),d.Rock,true,true)end
  else
   local pile=model('BoulderPile',props)
   for k,delta in {V(-1.5,0,0),V(1,0,.7),V(0,1.3,-.8)}do
    local height=k==3 and 2.8 or 2.2
    q(pile,'Boulder',V(k==3 and 3 or 4,height,3.2),pt+delta+V(0,Y+height*.5,0),index==3 and C(103,187,211)or d.Rock,true,true)
   end
   if index==2 then q(pile,'OrePlate',V(1.6,.35,1.8),pt+V(0,Y+4.275,-.8),C(223,153,68),true)end
  end
 end
 local scatter=model('EdgeDetails',props)
 for n=1,30 do
  local a=n*math.pi*2/30;local x=math.cos(a)*(d.Size.X*.5-6);local z=math.sin(a)*(d.Size.Z*.5-5)
  if not (z<-25 and math.abs(x)<21)then
   local stoneColor=index==3 and C(201,230,233)or d.Rock:Lerp(d.Accent,.2)
   q(scatter,'SmallStone',V(1.8,.65,1.4),V(x,Y+.325,z),stoneColor,true)
   if index==1 or index==4 or index==5 then
    q(scatter,'PlantStem',V(.2,1.2,.2),V(x+1.5,Y+.6,z-.7),index==4 and C(103,73,135)or C(64,127,64))
    q(scatter,'PlantCrown',V(1.1,.4,1.1),V(x+1.5,Y+1.4,z-.7),n%3==0 and d.Accent or index==4 and C(158,206,90)or C(77,151,73),true)
   elseif index==3 then q(scatter,'IceShard',V(.65,1.5,.65),V(x+1.3,Y+.75,z-.6),C(82,162,197),false,false,'WedgePart')
   elseif index==6 then q(scatter,'StormShoot',V(.55,1.6,.55),V(x+1.2,Y+.8,z-.6),d.Accent,true)
   end
  end
 end
 if index==2 then
  local wreck=props.CrashedEngine
  local nozzle=q(wreck,'DeadNozzle',V(.45,3.4,3.4),V(0,Y+7,41.3),C(43,57,70),false,false,nil,CFrame.Angles(0,math.pi*.5,0));nozzle.Shape=Enum.PartType.Cylinder
 elseif index==5 then
  for n=1,5 do q(props,'RuinVine',V(1.2,.65,.3),V(-7+n*2.3,Y+16.5,35.9),C(66,130,91),true)end
 end
 -- Organic biomes use one trail; industrial biomes retain short service branches.
 for _,branch in terrain:GetChildren()do if branch.Name=='BranchPath'then
  if index==3 or index==4 or (index==1 and branch.Position:Dot(base.RightVector)>center:Dot(base.RightVector))then branch:Destroy()
  elseif index==2 or index==6 then
   local localPos=base:PointToObjectSpace(branch.Position);local side=math.sign(localPos.X)
   branch.Size=V(20,.4,8);branch.CFrame=base*CF(side*14,Y+.2,4)
  end
 end end
 local zones=Instance.new('Folder');zones.Name='EggSpawnZones';zones.Parent=island
 for n,pt in {V(-25,0,-15),V(25,0,-15),V(-27,0,23),V(27,0,23),V(-47,0,0),V(47,0,0),V(0,0,35)}do
  local zone=q(zones,string.format('Zone%02d',n),V(18,1,18),pt+V(0,Y+12,0),d.Egg);zone.Transparency=1;zone.CanQuery=false
 end
 local active=Instance.new('Folder');active.Name='ActiveEggs';active.Parent=island
 island:ScaleTo(.8);island:SetAttribute('SurfaceY',island.PrimaryPart.Position.Y+island.PrimaryPart.Size.Y*.5)
 island.Parent=islands
 local template=model(d.Id,nil);template:SetAttribute('PlanetId',d.Id)
 local shell=p(template,'Shell',V(2.2,2.8,2.2),CF(0,1.55,0),d.Egg);shell.Shape=Enum.PartType.Ball;shell.PivotOffset=CF(0,-1.55,0);template.PrimaryPart=shell
 p(template,'Nest',V(2.8,.15,2.8),CF(0,.075,0),d.Accent,true)
 for _,side in {-1,1}do
  local spot=p(template,'Mark',V(.65,.65,.25),CF(side*.7,1.6,-.9),d.EggAccent);spot.Shape=Enum.PartType.Ball
 end
 if index==1 then
  for _,side in {-1,1}do p(template,'LeafPlate',V(.8,.55,.5),CF(side*.4,2.9,0)*CFrame.Angles(0,0,side*.25),d.EggAccent,true,false,'WedgePart')end
 elseif index==2 then
  p(template,'ArmorBand',V(1.6,.35,.2),CF(0,1.1,-1.04),d.EggAccent,true)
  p(template,'ArmorPlate',V(.65,.65,.15),CF(0,2,-.98),d.EggAccent,true)
 elseif index==3 then
  for _,side in {-1,1}do p(template,'IceTip',V(.5,.8,.5),CF(side*.65,2.7,0),d.EggAccent,false,false,'WedgePart')end
 elseif index==4 then
  for _,side in {-1,1}do
   p(template,'Antenna',V(.16,.6,.16),CF(side*.4,3.1,0),d.EggAccent)
   local tip=p(template,'AntennaTip',V(.4,.4,.4),CF(side*.4,3.5,0),d.EggAccent);tip.Shape=Enum.PartType.Ball
  end
 elseif index==5 then
  p(template,'Rune',V(.2,1,.15),CF(0,1.8,-1.1),d.EggAccent)
  for _,side in {-1,1}do p(template,'Rune',V(.6,.2,.15),CF(side*.2,1.8+side*.35,-1.1),d.EggAccent)end
 else
  for n=1,3 do p(template,'StormStripe',V(.7,.22,.15),CF((n%2)*.3-.15,1.1+n*.4,-1.08)*CFrame.Angles(0,0,.35),d.EggAccent)end
 end
 -- A supported nest clears the terrain's visible studs without floating plates.
 for _,o in template:GetChildren()do if o:IsA('BasePart')then
  if o.Name=='Nest'then o.Size=V(2.8,.4,2.8);o.CFrame=CF(0,.2,0)else o.CFrame+=V(0,.25,0)end
 end end
 shell.PivotOffset=CF(0,-1.8,0)
 template.Parent=templates
 local planet=planets:FindFirstChild(d.Id)
 if planet and planet:FindFirstChild('Planet')then
  local desired=V(d.Center.X,Y+95,d.Center.Z);planet:PivotTo(planet:GetPivot()+desired-planet.Planet.Position)
  planet.PrimaryPart=planet.Planet;planet:SetAttribute('VistaOnly',nil);planet:SetAttribute('DestinationPlanet',true)
  planet:SetAttribute('DisplayName',d.Name);planet:SetAttribute('PlanetId',d.Id);planet:SetAttribute('SurfaceIslandId',d.Id)
  planet:SetAttribute('ArrivalRadius',planet.Planet.Size.X*.5+18)
  local link=Instance.new('ObjectValue');link.Name='SurfaceIsland';link.Value=island;link.Parent=planet
  local arrival=Instance.new('ObjectValue');arrival.Name='ArrivalAnchor';arrival.Value=entry;arrival.Parent=planet
  local orbit=Instance.new('ObjectValue');orbit.Name='OrbitPlanet';orbit.Value=planet;orbit.Parent=island
 end
 task.wait()
end
return {Islands=#islands:GetChildren(),EggTemplates=#templates:GetChildren(),SpawnZones=42,Backup=backup:GetFullName()}

end
planetIslands()
local function expandPlanetIslands()
-- Broader surface landscapes; never scales ships, eggs, trees, or character-sized props.
local V=Vector3.new;local CF=CFrame.new;local C=Color3.fromRGB
local root=workspace.StarfallMap
local islands=root.PlanetIslands
local backup=Instance.new('Folder');backup.Name='StarfallBeforeIslandExpansion';backup.Parent=game.ServerStorage
local palettes={
 ScrapBelt={C(112,183,70),C(110,103,90),C(239,194,91)},
 DerelictField={C(206,143,79),C(89,79,78),C(229,175,103)},
 IceGraveyard={C(129,205,218),C(81,123,157),C(231,243,233)},
 NebulaCurrent={C(151,103,190),C(91,75,125),C(159,205,92)},
 AncientRuins={C(130,169,92),C(99,111,103),C(221,198,122)},
 SingularityEdge={C(90,116,154),C(61,75,101),C(128,199,218)},
}
local order={'ScrapBelt','DerelictField','IceGraveyard','NebulaCurrent','AncientRuins','SingularityEdge'}
local results={}
local function part(parent,name,size,cf,color,solid)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
 p.Anchored=true;p.CanCollide=solid==true;p.CanTouch=false;p.Material=Enum.Material.Plastic
 p.TopSurface=Enum.SurfaceType.Studs;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
for biome,id in order do
 local island=islands:FindFirstChild(id);assert(island and not island:GetAttribute('ExpandedSurface'),'Surface missing or already expanded: '..id)
 island:Clone().Parent=backup
 local origin=island.PrimaryPart.Position;local Y=island:GetAttribute('SurfaceY')
 local ground,rock,accent=table.unpack(palettes[id])
 local cells={};local CELL=16
 local function key(i,j)return i..':'..j end
 local function height(i,j)
  if j<=-3 then return 0 end -- Uninterrupted arrival meadow for all six ships.
  if biome==1 then
   return math.max(i<=-3 and math.clamp(j+1,0,3)*2 or 0,i>=3 and math.clamp(j-1,0,4)*2 or 0)
  elseif biome==2 then
   if math.abs(i)<=2 and j<=4 then return 0 end
   return math.min(8,math.max(0,j+2)*2,math.max(2,math.abs(i)-1)*2)
  elseif biome==3 then
   return math.max(0,math.floor((j+1)/2))*2+(i<=-4 and j>=1 and 2 or 0)
  elseif biome==4 then
   return math.max(i<=-2 and math.clamp(j+2,0,4)*2 or 0,i>=3 and math.clamp(j,0,5)*2 or 0)
  elseif biome==5 then return math.clamp(j+1,0,5)*2
  else
   return math.max(0,math.clamp(j,0,4)*2)+(math.abs(i)>=3 and math.clamp(j+2,0,3)*2 or 0)
  end
 end
 for j=-8,8 do for i=-7,7 do
  local included=(i/7.7)^2+(j/9)^2<1
  if j<=-3 then included=math.abs(i)<=6 end
  if j==-8 then included=math.abs(i)<=4 end -- Clip the meadow's front corners.
  if included then cells[key(i,j)]={I=i,J=j,H=height(i,j)}end
 end end
 local function cellAt(x,z)return cells[key(math.floor(x/CELL+.5),math.floor(z/CELL+.5))]end
 local function elevation(x,z)local c=cellAt(x,z);return c and c.H end
 local terrain=Instance.new('Model');terrain.Name='ExpandedTerrainDraft';terrain.Parent=island
 local floorCount,stepCount=0,0
 for j=-8,8 do
  local row=Instance.new('Model');row.Name='TerrainRow'..j
  for i=-7,7 do local c=cells[key(i,j)];if c then
   local tint=ground:Lerp(accent,math.min(c.H/90,.18))
   local tile=part(row,'GroundCell',V(CELL,1,CELL),CF(origin.X+i*CELL,Y+c.H-.5,origin.Z+j*CELL),tint,true)
   part(row,'RockCell',V(CELL,11+c.H,CELL),CF(origin.X+i*CELL,Y+(c.H-13)*.5,origin.Z+j*CELL),rock,true)
   tile:SetAttribute('EggGround',true);tile:SetAttribute('TerrainHeight',c.H);floorCount+=1
   if i==0 and j==0 then island.PrimaryPart=tile end
   if not cells[key(i-1,j)]or not cells[key(i+1,j)]or not cells[key(i,j-1)]or not cells[key(i,j+1)]then
    -- Side detailing stays completely below the walkable floor.
    part(row,'CliffFoot',V(14,6,14),CF(origin.X+i*CELL,Y-15,origin.Z+j*CELL),rock,true)
    part(row,'CliffFace',V(16.08,.9,16.08),CF(origin.X+i*CELL,Y-5,origin.Z+j*CELL),rock:Lerp(accent,.12),false)
    if (i+j)%3==0 then
     local point=Instance.new('WedgePart');point.Name='HangingRock';point.Size=V(10,10,12)
     point.CFrame=CF(origin.X+i*CELL,Y-23,origin.Z+j*CELL)*CFrame.Angles(0,math.pi*((i+j)%4)/2,0)
     point.Color=rock;point.Material=Enum.Material.Plastic;point.Anchored=true;point.CanCollide=false;point.Parent=row
    end
   end
  end end
  row.Parent=terrain;task.wait()
 end
 local stairs=Instance.new('Model');stairs.Name='TerrainStairs';stairs.Parent=terrain
 local function connect(a,b)
  if not a or not b or a.H==b.H then return end
  local low,high=a,b;if low.H>high.H then low,high=high,low end
  local dx,dz=high.I-low.I,high.J-low.J;local rise=high.H-low.H
  local count=math.ceil(rise/.5);local tread=math.min(1.4,14/count)
  local boundary=V((low.I+high.I)*8,0,(low.J+high.J)*8)
  for n=1,count do
   local h=n*rise/count;local p2=boundary-V(dx,0,dz)*((count-n+.5)*tread)
   local size=dx~=0 and V(tread,h,7)or V(7,h,tread)
   local step=part(stairs,'HalfStudStep',size,CF(origin.X+p2.X,Y+low.H+h*.5,origin.Z+p2.Z),accent,true)
   step:SetAttribute('EggGround',true);stepCount+=1
  end
 end
 -- Three north/south routes and cross-links make the upper ground reachable on foot.
 for _,i in {-4,0,4}do for j=-3,7 do connect(cells[key(i,j)],cells[key(i,j+1)])end end
 for _,j in {-1,2,5}do for i=-7,6 do connect(cells[key(i,j)],cells[key(i+1,j)])end end
 -- Preserve the gate's internal spacing when spreading the wider landscape.
 if biome==5 then
  local gate=Instance.new('Model');gate.Name='RuinGate';gate.Parent=island.Props
  for _,item in island.Props:GetChildren()do
   if item.Name=='RuinPillar'or item.Name=='RuinCap'or item.Name=='RuinLintel'or item.Name=='RuinInlay'or item.Name=='RuinVine'then item.Parent=gate end
  end
 end
 -- Move each complete prop as a unit; its physical size remains unchanged.
 local function moveProp(item,scatter)
  local cf=item:IsA('Model')and item:GetPivot()or item.CFrame
  local offset=cf.Position-V(origin.X,Y,origin.Z)
  local x,z=offset.X*2.15,math.max(-27,offset.Z*2.3+16)
  local h=elevation(x,z)
  if h==nil then x*=.85;z*=.85;h=elevation(x,z)or 0 end
  local oldH=0
  if not scatter and (biome==2 or biome==5 or biome==6)then
   if offset.Z>=16.8 and math.abs(offset.X)<(biome==2 and 25.6 or biome==5 and 30.4 or 32)then oldH=biome==5 and 4.8 or 3.6 end
  end
  local delta=V(x-offset.X,h-oldH,z-offset.Z)
  if item:IsA('Model')then item:PivotTo(cf+delta)else item.CFrame=cf+delta end
 end
 for _,item in island.Props:GetChildren()do
  if item.Name=='EdgeDetails'then for _,detail in item:GetChildren()do moveProp(detail,true)end else moveProp(item)end
 end
 -- Bring every prop's base to the new terrain without stretching trees or ruins.
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={terrain}
 for _,item in island.Props:GetChildren()do if item.Name~='EdgeDetails'then
  local cf,size
  if item:IsA('Model')then cf,size=item:GetBoundingBox()else cf,size=item.CFrame,item.Size end
  -- Keep small props wholly on one terrace, including their rotated footprint.
  local radius=math.max(size.X,size.Z)*.75
  if radius<7 then
   local x,z=cf.X-origin.X,cf.Z-origin.Z;local cell=cellAt(x,z)
   if cell then
    local margin=8-radius-.2
    local nx=cell.I*16+math.clamp(x-cell.I*16,-margin,margin)
    local nz=cell.J*16+math.clamp(z-cell.J*16,-margin,margin)
    local shift=V(nx-x,0,nz-z)
    if item:IsA('Model')then item:PivotTo(item:GetPivot()+shift)else item.CFrame+=shift end
    cf+=shift
   end
  end
  local hit=workspace:Raycast(V(cf.X,Y+50,cf.Z),V(0,-100,0),ray)
  if hit then
   local shift=V(0,hit.Position.Y-(cf.Y-size.Y*.5),0)
   if item:IsA('Model')then item:PivotTo(item:GetPivot()+shift)else item.CFrame+=shift end
  end
 end end
 local landscape=Instance.new('Model');landscape.Name='ExpandedLandscape';landscape.Parent=island.Props
 local function landscapeCluster(x,z,n)
  local cell=cellAt(x,z);if not cell then return end
  -- A six-stud crown fits inside a 16-stud cell with this four-stud margin.
  x=cell.I*16+math.clamp(x-cell.I*16,-4,4)
  z=cell.J*16+math.clamp(z-cell.J*16,-4,4)
  local h=cell.H
  local cluster=Instance.new('Model');cluster.Name='Cluster'..n;cluster.Parent=landscape
  local base=CF(origin.X+x,Y+h,origin.Z+z)
  if biome==1 or biome==4 or biome==5 then
   local trunk=biome==4 and C(217,205,188)or C(125,83,54)
   local leaves=biome==4 and C(161,205,91)or biome==5 and C(65,132,91)or C(48,140,75)
   local ht=biome==4 and 4+n%3 or 6+n%4
   part(cluster,'Stem',V(1.3,ht,1.3),base*CF(0,ht*.5,0),trunk,true)
   part(cluster,biome==4 and 'MushroomCap'or 'TreeCrown',V(5.6,biome==4 and 1.4 or 3.4,5.6),base*CF(0,ht,0),leaves,false)
   part(cluster,'CrownTop',V(3.8,1.8,3.8),base*CF(0,ht+1.7,0),leaves:Lerp(accent,.16),false)
  else
   local color=biome==3 and C(94,180,206)or rock
   part(cluster,'LowBoulder',V(4,2.2,3.5),base*CF(0,1.1,0),color,true)
   part(cluster,biome==2 and 'Ore'or 'Crystal',V(1.7,3+n%3,1.7),base*CF(1.4,(3+n%3)*.5,-.6),accent,true)
  end
 end
 for n=1,28 do
  local side=n%2==0 and 1 or -1;local x=side*(38+(n*13)%63);local z=-16+(n*19)%131
  landscapeCluster(x,z,n)
 end
 for n,pt in {V(-24,0,5),V(26,0,22),V(-24,0,52),V(25,0,76),V(-36,0,-104),V(36,0,-92),V(-100,0,-80),V(100,0,-80)}do
  landscapeCluster(pt.X,pt.Z,n+28)
 end
 local groundDetails=Instance.new('Model');groundDetails.Name='MeadowDetails';groundDetails.Parent=island.Props
 for n,pt in {V(-48,0,-128),V(0,0,-128),V(48,0,-128),V(-100,0,-112),V(100,0,-112),V(-36,0,-60),V(36,0,-60)}do
  local color=biome==1 and C(82,150,67)or ground:Lerp(accent,.35)
  for k=-1,1 do
   part(groundDetails,'SmallGroundDetail',V(1.3,.6,1.3),CF(origin.X+pt.X+k*1.5,Y+.3,origin.Z+pt.Z+(k%2)*1.5),color,false)
  end
 end
 -- Only authoring markers: the meadow itself has no parking-pad geometry.
 local pad=island.LandingPad;local anchor=pad.ArrivalAnchor
 for _,item in pad:GetChildren()do if item~=anchor then item:Destroy()end end
 local padSurface=part(pad,'PadSurface',V(208,.2,88),CF(origin.X,Y-.2,origin.Z-84),ground,false)
 padSurface.Transparency=1;padSurface.CanQuery=false
 local landingAnchor=Instance.new('Attachment');landingAnchor.Name='LandingAnchor';landingAnchor.Parent=padSurface;landingAnchor.Position=V(0,.2,0)
 anchor.CFrame=CF(origin.X,Y+3,origin.Z-78)
 local clearances=Instance.new('Folder');clearances.Name='ShipClearances';clearances.Parent=pad
 for row=1,2 do for col=1,3 do
  local x=(col-2)*72;local z=row==1 and -102 or -58
  local area=part(clearances,'ShipClearance'..((row-1)*3+col),V(40,1,32),CF(origin.X+x,Y+.5,origin.Z+z),accent,false)
  area.Transparency=1;area.CanQuery=false;area:SetAttribute('ShipSlot',(row-1)*3+col)
  local slot=Instance.new('Attachment');slot.Name='ShipAnchor';slot.Position=V(0,-.5,0);slot.Parent=area
 end end
 -- A pair of small perimeter flags identifies the arrival meadow from higher ground.
 for _,side in {-1,1}do
  part(pad,'MeadowFlagPole',V(.5,7,.5),CF(origin.X+side*101,Y+3.5,origin.Z-40),rock,true)
  part(pad,'MeadowFlag',V(3,1.8,.2),CF(origin.X+side*101+1.5,Y+6,origin.Z-40),accent,false)
 end
 local zones=island.EggSpawnZones;zones:ClearAllChildren()
 local zoneCount=0
 for j=-1,6,2 do for i=-5,5,2 do
  local h=elevation(i*16,j*16);if h~=nil then
   zoneCount+=1;local zone=part(zones,'Zone'..zoneCount,V(13,1,13),CF(origin.X+i*16,Y+h+12,origin.Z+j*16),ground,false)
   zone.Transparency=1;zone.CanQuery=false
  end
 end end
 island.Terrain:Destroy();terrain.Name='Terrain'
 island:SetAttribute('ExpandedSurface',true);island:SetAttribute('ShipCapacity',6)
 island:SetAttribute('SurfaceWidth',240);island:SetAttribute('SurfaceDepth',272)
 table.insert(results,{Id=id,GroundCells=floorCount,StairSteps=stepCount,ShipClearances=6,EggZones=zoneCount})
 task.wait()
end
return results

end
expandPlanetIslands()
local function shapeOrganicIslands()
-- Contoured floating islands replacing the square terrain grid.
local V=Vector3.new;local CF=CFrame.new;local C=Color3.fromRGB
local root=workspace.StarfallMap
local order={'ScrapBelt','DerelictField','IceGraveyard','NebulaCurrent','AncientRuins','SingularityEdge'}
local hills={
 ScrapBelt={{-85,45,46,3},{75,90,48,1},{-20,124,40,2}},
 DerelictField={{-90,35,48,2},{85,55,52,3},{0,116,56,1}},
 IceGraveyard={{-95,45,52,1},{70,90,54,3},{-25,122,42,2}},
 NebulaCurrent={{-88,62,52,2},{86,52,50,1},{0,126,44,3}},
 AncientRuins={{-85,48,45,1},{80,66,48,1},{0,116,54,3}},
 SingularityEdge={{-85,50,54,3},{86,55,52,2},{-8,126,42,1}},
}
local outlines={
 ScrapBelt={{0,0,320,320},{-112,2,112,174},{115,24,102,142},{0,-91,222,154},{-18,110,190,136}},
 DerelictField={{0,0,320,300},{-120,20,132,174},{112,18,126,152},{0,-92,230,160},{-20,100,200,140}},
 IceGraveyard={{0,0,320,310},{-118,10,128,140},{120,38,120,160},{0,-92,226,160},{12,110,190,142}},
 NebulaCurrent={{0,0,310,320},{-112,5,124,172},{116,30,124,150},{0,-92,228,160},{-18,112,204,142}},
 AncientRuins={{0,0,320,310},{-110,-2,126,150},{118,22,108,144},{0,-90,226,164},{0,112,190,144}},
 SingularityEdge={{0,0,320,320},{-116,0,110,182},{120,22,120,166},{0,-90,230,160},{12,110,170,142}},
}
local bays={DerelictField={-165,35,90,85},IceGraveyard={163,0,72,76},NebulaCurrent={-166,42,78,72},AncientRuins={166,0,70,70},SingularityEdge={0,170,80,75}}
local backup=game.ServerStorage:FindFirstChild('StarfallBeforeOrganicIslands')or Instance.new('Folder')
backup.Name='StarfallBeforeOrganicIslands';backup.Parent=game.ServerStorage
local results={}
local function basePart(parent,name,size,cf,role,solid,studs)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true
 p.CanCollide=solid==true;p.CanTouch=false;p.Material=Enum.Material.Plastic
 p.Color=C(112,183,70);p:SetAttribute('PaletteRole',role)
 p.TopSurface=studs and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
for _,id in order do
 local island=root.PlanetIslands[id];assert(not island:GetAttribute('OrganicIsland'),'Already reshaped: '..id)
 local Y=island:GetAttribute('SurfaceY');local center=island.PrimaryPart.Position
 local origin=V(center.X,Y,center.Z)
 local oldTerrain=island.Terrain;local oldProps=island.Props
 local saved=Instance.new('Folder');saved.Name=id;saved.Parent=backup
 island.EggSpawnZones:Clone().Parent=saved
 local terrain=Instance.new('Model');terrain.Name='OrganicTerrainDraft';terrain.Parent=island
 local function unionDiscs(name,shapes,top,height,role,ground)
  local parts={}
  for _,s in shapes do
   local p=basePart(terrain,'ContourSource',V(height,s[3],s[4]),CF(origin.X+s[1],top-height*.5,origin.Z+s[2])*CFrame.Angles(0,0,math.pi*.5),role,true,false)
   p.Shape=Enum.PartType.Cylinder;table.insert(parts,p)
  end
  local result
  if #parts==1 then result=parts[1]else
   local others={};for n=2,#parts do table.insert(others,parts[n])end
   result=parts[1]:UnionAsync(others,Enum.CollisionFidelity.PreciseConvexDecomposition,Enum.RenderFidelity.Precise)
   result.Parent=terrain;for _,p in parts do p:Destroy()end
  end
  local bay=bays[id]
  if bay then
   local cutter=basePart(terrain,'CoveCutter',V(height+6,bay[3],bay[4]),CF(origin.X+bay[1],top-height*.5,origin.Z+bay[2])*CFrame.Angles(0,0,math.pi*.5),role,false,false)
   cutter.Shape=Enum.PartType.Cylinder
   local cut=result:SubtractAsync({cutter},Enum.CollisionFidelity.PreciseConvexDecomposition,Enum.RenderFidelity.Precise)
   cut.Parent=terrain;result:Destroy();cutter:Destroy();result=cut
  end
  result.Name=name;result.Anchored=true;result.CanCollide=true;result.CanTouch=false
  result.Material=Enum.Material.Plastic;result:SetAttribute('PaletteRole',role)
  if result:IsA('UnionOperation')then result.UsePartColor=true end
  if ground then
   result:SetAttribute('EggGround',true)
   for _,face in {'TopSurface','BottomSurface','LeftSurface','RightSurface','FrontSurface','BackSurface'}do result[face]=Enum.SurfaceType.Studs end
  end
  task.wait();return result
 end
 local shape=outlines[id]
 local ground=unionDiscs('IslandSurface',shape,Y,1.4,'Ground',true)
 island.PrimaryPart=ground
 local function cliffLayer(scale,height,top,role,name)
  local p=ground:Clone();p.Name=name;p:SetAttribute('EggGround',nil);p:SetAttribute('PaletteRole',role)
  local texture=p:FindFirstChild('ClassicStuds');if texture then texture:Destroy()end
  local s=ground.Size;local r=ground.CFrame
  local sx=math.abs(r.RightVector.Y)>.9;local sy=math.abs(r.UpVector.Y)>.9
  p.Size=V(sx and height or s.X*scale,sy and height or s.Y*scale,(not sx and not sy)and height or s.Z*scale)
  p.CFrame=r+V(0,top-height*.5-r.Position.Y,0)
  for _,face in {'TopSurface','BottomSurface','LeftSurface','RightSurface','FrontSurface','BackSurface'}do p[face]=Enum.SurfaceType.Smooth end
  p.Parent=terrain;return p
 end
 cliffLayer(1,13,Y-1.4,'Rock','UpperCliff')
 cliffLayer(.89,12,Y-14.4,'Deep','LowerCliff')
 cliffLayer(.68,13,Y-26.4,'Rock','IslandCore')
 local moundParts={}
 for level=1,3 do
  local shapes={}
  for _,h in hills[id]do if level<=h[4]then
   local r=h[3]-(level-1)*14
   table.insert(shapes,{h[1]+(level-1)*3,h[2]+(level-1)*2,r*2,r*1.8})
  end end
  moundParts[level]=unionDiscs('HillContour'..level,shapes,Y+level*4,4,level==3 and 'High'or 'Ground',true)
 end
 -- Short access paths climb each hill from its southern shoulder.
 local stairs=Instance.new('Model');stairs.Name='HillsidePaths';stairs.Parent=terrain
 for _,h in hills[id]do for level=1,h[4]do
  local radius=(h[3]-(level-1)*14)*.9
  for n=1,7 do
   local rise=n*.5;local z=h[2]+(level-1)*2-radius-(7.5-n)*1.4
   local p=basePart(stairs,'HillStep',V(8,rise,1.4),CF(origin.X+h[1]+(level-1)*3,Y+(level-1)*4+rise*.5,origin.Z+z),'Path',true,true)
   p:SetAttribute('EggGround',true)
  end
 end end
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={terrain}
 local function floorAt(x,z)
  local hit=workspace:Raycast(V(origin.X+x,Y+65,origin.Z+z),V(0,-120,0),ray)
  if hit and hit.Normal.Y>.99 and hit.Instance:GetAttribute('EggGround')then return hit.Position.Y end
 end
 -- The central valley remains open. Trail pieces are fused into one clean surface.
 local trail={}
 for n=0,40 do local z=-32+n*2;local x=math.sin(n*.115)*13
  if math.abs((floorAt(x,z)or -1000)-Y)<.1 then table.insert(trail,{x,z,12,12})end
 end
 if #trail>0 then unionDiscs('CurvedTrail',trail,Y+.42,.4,'Path',true)end
 local props=Instance.new('Model');props.Name='OrganicPropsDraft';props.Parent=island
 local function asset(name)
  for _,p in oldProps:GetDescendants()do if p:IsA('Model')and p.Name==name then return p end end
 end
 local templates={
  ScrapBelt=asset('BlockTree'),DerelictField=asset('BoulderPile'),IceGraveyard=asset('CrystalCluster'),
  NebulaCurrent=asset('BlockMushroom'),AncientRuins=asset('BlockTree'),SingularityEdge=asset('CrystalCluster'),
 }
 local function place(template,x,z,yaw,parent)
  if not template then return end
  local p=template:Clone();local box,size=p:GetBoundingBox()
  local half=math.min(math.max(size.X,size.Z)*.55,10)
  local targetY
  for _,shift in {V(0,0,0),V(6,0,0),V(-6,0,0),V(0,0,6),V(0,0,-6)}do
   local nx,nz=x+shift.X,z+shift.Z
   if nz<-34 and math.abs(nx)<96 then continue end
   local y=floorAt(nx,nz);local flat=y~=nil
   if flat then for _,q in {V(-half,0,-half),V(half,0,-half),V(-half,0,half),V(half,0,half)}do
    local edge=floorAt(nx+q.X,nz+q.Z);if not edge or math.abs(edge-y)>.15 then flat=false;break end
   end end
   if flat then x,z,targetY=nx,nz,y;break end
  end
  if not targetY then p:Destroy();return end
  p:PivotTo(CF(origin.X+x,targetY,origin.Z+z)*CFrame.Angles(0,yaw or 0,0))
  local cf,s=p:GetBoundingBox();p:PivotTo(p:GetPivot()+V(0,targetY-(cf.Y-s.Y*.5),0))
  p.Parent=parent or props;return p
 end
 local groves={{-115,-7},{112,6},{-104,77},{92,94},{-29,139},{-43,22}}
 local placed=0
 for g,pt in groves do
  local grove=Instance.new('Model');grove.Name='SceneryGrove'..g
  for n=1,9 do local a=n*2.4+g*.7;local radius=6+math.sqrt(n)*5
   if place(templates[id],pt[1]+math.cos(a)*radius,pt[2]+math.sin(a)*radius,a,grove)then placed+=1 end
  end
  grove.Parent=props;task.wait()
 end
 -- Preserve each biome's landmark; cluster it as one complete object.
 if id=='ScrapBelt'then
  unionDiscs('NestingClearing',{{-40,-12,18,16}},Y+.42,.4,'Path',true)
  local flowers=Instance.new('Model');flowers.Name='NestingFlowers';flowers.Parent=props
  for n=1,12 do local a=n*math.pi/6;local x,z=-40+math.cos(a)*11,-12+math.sin(a)*10
   local y=floorAt(x,z)
   if y then
    basePart(flowers,'FlowerStem',V(.25,1.2,.25),CF(origin.X+x,y+.6,origin.Z+z),'Leaf',false,false)
    basePart(flowers,'FlowerHead',V(1.4,.4,1.4),CF(origin.X+x,y+1.4,origin.Z+z),'Accent',false,true)
   end
  end
 elseif id=='DerelictField'then place(asset('CrashedEngine'),85,55,.45)
 elseif id=='AncientRuins'then place(asset('RuinGate'),0,116,0)
 elseif id=='SingularityEdge'then place(asset('StormMast'),-85,50,0);place(asset('StormMast'),86,55,0)end
 local details=Instance.new('Model');details.Name='ShoreDetails';details.Parent=props
 for n=1,44 do
  local a=n*math.pi*2/44;local x=math.cos(a)*(128+8*math.sin(a*3));local z=math.sin(a)*(139+6*math.cos(a*2))
  if z>-34 or math.abs(x)>102 then
   local y=floorAt(x,z)
   if y then
    local p=basePart(details,'ShoreStone',V(2.2,1.1,2),CF(origin.X+x,y+.55,origin.Z+z)*CFrame.Angles(0,a,0),'Rock',false,true)
    if id=='ScrapBelt'or id=='NebulaCurrent'or id=='AncientRuins'then
     basePart(details,'PlantStem',V(.3,1.1,.3),CF(origin.X+x+2,y+.55,origin.Z+z),'Stem',false,false)
     basePart(details,'PlantCrown',V(1.4,.6,1.4),CF(origin.X+x+2,y+1.3,origin.Z+z),'LeafLight',false,true)
    end
   end
  end
 end
 -- Tapered underside rock points follow the perimeter rather than a square grid.
 for n=1,12 do
  local a=n*math.pi/6;local x,z=math.cos(a)*113,math.sin(a)*115
  local p=Instance.new('WedgePart');p.Name='UndersideRock';p.Size=V(20,12+n%3*3,24)
  p.CFrame=CF(origin.X+x,Y-37,origin.Z+z)*CFrame.Angles(0,-a,math.pi)
  p.Material=Enum.Material.Plastic;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p:SetAttribute('PaletteRole','Deep');p.Parent=terrain
 end
 oldTerrain.Parent=saved;oldProps.Parent=saved
 terrain.Name='Terrain';props.Name='Props'
 local zones=island.EggSpawnZones;zones:ClearAllChildren();local count=0
 for _,z in {-12,24,66,110}do for _,x in {-108,-58,0,58,108}do
  local y=floorAt(x,z)
  if y then
   count+=1;local p=basePart(zones,'OrganicZone'..count,V(18,1,18),CF(origin.X+x,y+12,origin.Z+z),'Ground',false,false)
   p.Transparency=1;p.CanQuery=false
  end
 end end
 island:SetAttribute('OrganicIsland',true);island:SetAttribute('SurfaceWidth',340);island:SetAttribute('SurfaceDepth',350)
 table.insert(results,{Id=id,Groves=6,Scenery=placed,EggZones=count,ShipCapacity=6})
 task.wait()
end
return results

end
shapeOrganicIslands()
local function addWorldLandmarks()
-- Distinct, deliberately oversized focal scenery among ordinary avatar-scale props.
local V=Vector3.new;local CF=CFrame.new
local root=workspace.StarfallMap
local order={'ScrapBelt','DerelictField','IceGraveyard','NebulaCurrent','AncientRuins','SingularityEdge'}
local anchors={ScrapBelt=V(-17,0,126),DerelictField=V(0,0,116),IceGraveyard=V(-22,0,124),NebulaCurrent=V(6,0,130),AncientRuins=V(6,0,120),SingularityEdge=V(-8,0,116)}
local names={ScrapBelt='HollowHeartTree',DerelictField='CrashedScout',IceGraveyard='FrostArch',NebulaCurrent='MushroomFamily',AncientRuins='TempleGate',SingularityEdge='StormBeacon'}
local backup=Instance.new('Folder');backup.Name='StarfallBeforeWorldLandmarks';backup.Parent=game.ServerStorage
local results={}
for _,id in order do
 local island=root.PlanetIslands[id];assert(not island:GetAttribute('WorldLandmark'),'Landmark already authored')
 local arrival=island.LandingPad.ArrivalAnchor.Position
 local origin=V(arrival.X,island:GetAttribute('SurfaceY'),arrival.Z+78)
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={island.Terrain}
 local function floor(x,z)
  local hit=workspace:Raycast(V(origin.X+x,origin.Y+80,origin.Z+z),V(0,-140,0),ray)
  assert(hit and hit.Normal.Y>.99,'Unsupported landmark site: '..id)
  return hit.Position.Y
 end
 local point=anchors[id];local y=floor(point.X,point.Z)
 local base=CF(origin.X+point.X,y,origin.Z+point.Z)
 local hero=Instance.new('Model');hero.Name=names[id];hero:SetAttribute('SceneryOnly',true)
 local function p(parent,name,size,offset,role,solid,rotation,class)
  local o=Instance.new(class or 'Part');o.Name=name;o.Size=size;o.CFrame=base*CF(offset)*(rotation or CF())
  o.Anchored=true;o.CanCollide=solid==true;o.CanTouch=false;o.Material=Enum.Material.Plastic
  o.TopSurface=Enum.SurfaceType.Studs;o.BottomSurface=Enum.SurfaceType.Smooth;o:SetAttribute('PaletteRole',role);o.Parent=parent;return o
 end
 local function beam(parent,name,a,b,width,role,solid)
  return p(parent,name,V(width,(b-a).Magnitude,width),(a+b)*.5,role,solid,CFrame.lookAt(V(),b-a)*CFrame.Angles(math.pi*.5,0,0))
 end
 local function disc(parent,name,diam,height,pos,role)
  local o=p(parent,name,V(height,diam,diam),pos,role,false,CFrame.Angles(0,0,math.pi*.5))
  o.Shape=Enum.PartType.Cylinder;o.TopSurface=Enum.SurfaceType.Smooth;o.RightSurface=Enum.SurfaceType.Studs;return o
 end
 if id=='ScrapBelt'then
  for _,side in {-1,1}do
   p(hero,'Trunk',V(3.5,21,5),V(side*5.3,10.5,0),'Stem',true)
   p(hero,'Root',V(5,4,11),V(side*7,2,1),'Stem',true,CFrame.Angles(0,side*.2,0),'WedgePart')
   beam(hero,'Branch',V(side*4,19,0),V(side*13,25,1),2.4,'Stem',false)
  end
  p(hero,'TrunkBridge',V(14,5,5),V(0,20,0),'Stem',true)
  for n,d in {{V(0,28,0),V(22,9,20)},{V(-11,26,2),V(14,9,14)},{V(11,28,-1),V(14,9,16)},{V(1,35,1),V(16,7,14)}}do
   p(hero,'Canopy'..n,d[2],d[1],n%2==0 and 'LeafLight'or 'Leaf',false)
  end
  p(hero,'HeartLeaf',V(3,3,.6),V(0,20,-2.9),'Highlight',false,CFrame.Angles(0,0,.7))
 elseif id=='DerelictField'then
  p(hero,'Hull',V(18,6,30),V(0,5,0),'High',true)
  p(hero,'BrokenNose',V(18,6,10),V(0,5,-18),'Rock',true,nil,'WedgePart')
  p(hero,'Cabin',V(9,5,10),V(0,10,-4),'Deep',true)
  p(hero,'CanopyWindow',V(7,3,.3),V(0,10,-9.2),'Highlight',false)
  p(hero,'RoofArmor',V(10,1.1,9),V(0,13,-3),'Accent',false)
  for _,side in {-1,1}do
   p(hero,'BrokenWing',V(13,2,11),V(side*14,3.8,4),'High',true,CFrame.Angles(0,side*.25,side*.12),'WedgePart')
   p(hero,'Gear',V(2.5,3,4),V(side*6,1.5,-7),'Deep',true)
   local engine=p(hero,'DeadEngine',V(7,5.5,5.5),V(side*6,5,18),'Rock',true,CFrame.Angles(0,math.pi*.5,0));engine.Shape=Enum.PartType.Cylinder
   local nozzle=p(hero,'EngineNozzle',V(.6,4,4),V(side*6,5,21.7),'Deep',false,CFrame.Angles(0,math.pi*.5,0));nozzle.Shape=Enum.PartType.Cylinder
  end
  p(hero,'SalvagePanel',V(7,.5,5),V(-19,.25,-10),'Highlight',true,CFrame.Angles(0,.35,0))
 elseif id=='IceGraveyard'then
  for _,side in {-1,1}do
   p(hero,'IceFoot',V(8,2,12),V(side*13,1,0),'High',true)
   p(hero,'IcePillar',V(6,17,8),V(side*13,10.5,0),'High',true)
   p(hero,'IceRidge',V(3,14,1),V(side*13,10,-4.6),'Highlight',false)
   p(hero,'CrownShard',V(6,8,8),V(side*13,27,0),'Highlight',false,nil,'WedgePart')
  end
  p(hero,'IceBridge',V(32,5,8),V(0,21,0),'High',true)
  p(hero,'BridgeGlint',V(12,1,.35),V(0,21,-4.3),'Highlight',false)
  p(hero,'CenterCrystal',V(5,6,6),V(0,26.5,0),'Accent',false,nil,'WedgePart')
 elseif id=='NebulaCurrent'then
  for n,d in {{V(0,0,0),20,24},{V(-10,0,6),12,14},{V(10,0,5),15,15}}do
   local pos,height,diam=d[1],d[2],d[3]
   p(hero,'MushroomStem',V(3,height,3),pos+V(0,height*.5,0),'Stem',true)
   disc(hero,'MushroomCap',diam,2.2,pos+V(0,height,0),n==1 and 'LeafLight'or 'Leaf')
   p(hero,'CapCrown',V(diam*.65,2.8,diam*.65),pos+V(0,height+2.5,0),'High',false)
   for k=1,5 do local a=k*math.pi*2/5
    p(hero,'CapSpot',V(1.8,.35,1.8),pos+V(math.cos(a)*diam*.2,height+4.45,math.sin(a)*diam*.2),'Highlight',false)
   end
  end
 elseif id=='AncientRuins'then
  for _,side in {-1,1}do
   p(hero,'TempleFoot',V(8,2,10),V(side*12,1,0),'Rock',true)
   p(hero,'TemplePillar',V(5,19,7),V(side*12,11.5,0),'Highlight',true)
   p(hero,'PillarBand',V(5.5,1.2,7.5),V(side*12,7,0),'Leaf',false)
   p(hero,'TempleCap',V(8,2,10),V(side*12,22,0),'High',true)
   p(hero,'MossBlock',V(3,1.1,3),V(side*14,23.4,1),'Leaf',false)
  end
  p(hero,'TempleLintel',V(34,4,9),V(0,25,0),'Highlight',true)
  p(hero,'TempleCrown',V(17,3,10),V(0,28.5,0),'High',true)
  p(hero,'RuneStem',V(.8,2.8,.3),V(0,25,-4.7),'Accent',false)
  for _,side in {-1,1}do p(hero,'RuneArm',V(3,.7,.3),V(side*.9,25+side*.85,-4.7),'Accent',false)end
 elseif id=='SingularityEdge'then
  p(hero,'BeaconBase',V(11,2,11),V(0,1,0),'Rock',true)
  p(hero,'BeaconMast',V(3,16,3),V(0,10,0),'Deep',true)
  for _,side in {-1,1}do
   beam(hero,'BeaconFork',V(0,16,0),V(side*9,24,0),2.5,'High',false)
   p(hero,'CollectorCap',V(5,3,7),V(side*9,25,0),'Highlight',false)
  end
  p(hero,'CrossAntenna',V(25,1.3,2),V(0,28,0),'Rock',false)
  p(hero,'AntennaCore',V(7,3,5),V(0,29,0),'High',false)
  local vent=p(hero,'BeaconVent',V(2.5,2,.2),V(0,14,-1.7),'Accent',false);vent.Material=Enum.Material.Neon
 end
 -- Replace small duplicate landmarks without changing surrounding groves.
 local saved=Instance.new('Folder');saved.Name=id;saved.Parent=backup
 local clearRadius=id=='DerelictField'and 30 or id=='SingularityEdge'and 16 or 23
 for _,grove in island.Props:GetChildren()do if grove.Name:match('^SceneryGrove')then
  for _,plant in grove:GetChildren()do if plant:IsA('Model')then
   local at=plant:GetPivot().Position
   if (V(at.X,0,at.Z)-V(base.X,0,base.Z)).Magnitude<clearRadius then plant.Parent=saved end
  end end
 end end
 for _,o in island.Props:GetChildren()do if o.Name=='RuinGate'or o.Name=='CrashedEngine'or o.Name=='StormMast'then o.Parent=saved end end
 hero.Parent=island.Props
 local meadow=Instance.new('Model');meadow.Name='ArrivalPlanting';meadow.Parent=island.Props
 for n,point2 in {V(-36,0,-100),V(36,0,-100),V(-36,0,-60),V(36,0,-60),V(-104,0,-82),V(104,0,-82)}do
  local groundY=floor(point2.X,point2.Z)
  local previousBase=base;base=CF(origin.X+point2.X,groundY,origin.Z+point2.Z)
  p(meadow,'GroundStone',V(2.4,.9,2),V(0,.45,0),'Rock',false)
  for _,side in {-1,1}do
   p(meadow,'PlantStem',V(.3,1.6,.3),V(side*1.8,.8,.3),'Stem',false)
   p(meadow,'PlantCrown',V(1.8,.6,1.8),V(side*1.8,1.9,.3),n%2==0 and 'Accent'or 'LeafLight',false)
  end
  base=previousBase
 end
 island:SetAttribute('WorldLandmark',hero.Name)
 table.insert(results,{Id=id,Landmark=hero.Name,Height=y-origin.Y})
 task.wait()
end
return results

end
addWorldLandmarks()
local function applyIslandStudSkin()
-- Native studs on thin, merged top strips; the underlying CSG supplies the curved silhouette.
local V=Vector3.new;local CF=CFrame.new
local results={}
for _,island in workspace.StarfallMap.PlanetIslands:GetChildren()do
 assert(island:GetAttribute('OrganicIsland')and not island:GetAttribute('NativeStudSkin'),'Organic island required, skin must be applied once')
 local anchor=island.LandingPad.ArrivalAnchor
 local origin=V(anchor.Position.X,island:GetAttribute('SurfaceY'),anchor.Position.Z+78)
 local surfaces={}
 for _,p in island.Terrain:GetDescendants()do
  if p:IsA('BasePart')and p:GetAttribute('EggGround')and p.Name~='HillStep'then table.insert(surfaces,p)end
  local texture=p:FindFirstChild('ClassicStuds');if texture then texture:Destroy()end
 end
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances=surfaces
 local function sample(x,z)
  local hit=workspace:Raycast(V(origin.X+x,origin.Y+55,origin.Z+z),V(0,-95,0),ray)
  if hit and hit.Normal.Y>.99 then return hit.Position.Y,hit.Instance:GetAttribute('PaletteRole')or 'Ground'end
 end
 local skin=Instance.new('Model');skin.Name='NativeStudSurfaces';skin.Parent=island.Terrain
 local count=0
 for z=-188,188,4 do
  local row=Instance.new('Model');row.Name='StudRow'..z
  local start,finish,level,role
  local function flush()
   if start then
    local p=Instance.new('Part');p.Name='StudSurface';p.Size=V(finish-start+4,.05,4)
    p.CFrame=CF(origin.X+(start+finish)*.5,level+.025,origin.Z+z);p.CastShadow=false
    p.Anchored=true;p.CanCollide=true;p.CanTouch=false;p.Material=Enum.Material.Plastic
    p.TopSurface=Enum.SurfaceType.Studs;p.BottomSurface=Enum.SurfaceType.Smooth
    p:SetAttribute('EggGround',true);p:SetAttribute('PaletteRole',role);p.Parent=row;count+=1
   end
   start,finish,level,role=nil,nil,nil,nil
  end
  for x=-188,188,4 do
   local y,r=sample(x,z);local flat=y~=nil
   if flat then for _,q in {V(-2.02,0,-2.02),V(2.02,0,-2.02),V(-2.02,0,2.02),V(2.02,0,2.02)}do
    local edge=sample(x+q.X,z+q.Z);if not edge or math.abs(edge-y)>.04 then flat=false;break end
   end end
   if flat then
    if start and (math.abs(level-y)>.04 or role~=r)then flush()end
    if not start then start,level,role=x,y,r end
    finish=x
   else flush()end
  end
  flush();row.Parent=skin;task.wait()
 end
 for _,step in island.Terrain.HillsidePaths:GetChildren()do if step:IsA('BasePart')then step.CFrame+=V(0,.05,0)end end
 island.Props:PivotTo(island.Props:GetPivot()+V(0,.05,0))
 island.LandingPad:PivotTo(island.LandingPad:GetPivot()+V(0,.05,0))
 for _,zone in island.EggSpawnZones:GetChildren()do zone.CFrame+=V(0,.05,0)end
 island:SetAttribute('SurfaceY',origin.Y+.05);island:SetAttribute('NativeStudSkin',true)
 table.insert(results,{Id=island.Name,StudStrips=count})
end
return results

end
applyIslandStudSkin()
local function dressExplorationAreas()
-- Fuller exploration landscapes. Never moves or rebuilds LandingPad or its six ship spaces.
local V=Vector3.new;local CF=CFrame.new
local root=workspace.StarfallMap
local order={'ScrapBelt','DerelictField','IceGraveyard','NebulaCurrent','AncientRuins','SingularityEdge'}
local definitions={
 ScrapBelt={Names={'Flower Clearing','Dense Woodland','Hollow Tree Grove'},Template='BlockTree',Tall=72,North=V(-20,0,77),Left=V(-85,0,-8),Right=V(75,0,34)},
 DerelictField={Names={'Scrap Canyon','Cargo Yard','Wreck Site'},Template='BoulderPile',Tall=44,North=V(0,0,53),Left=V(-90,0,-21),Right=V(85,0,-3)},
 IceGraveyard={Names={'Crystal Forest','Frozen Basin','Ice Arch Passage'},Template='CrystalCluster',Tall=56,North=V(-25,0,72),Left=V(-95,0,-15),Right=V(70,0,30)},
 NebulaCurrent={Names={'Spore Garden','Alien Thicket','Mushroom Canopy'},Template='BlockMushroom',Tall=70,North=V(0,0,74),Left=V(-88,0,3),Right=V(86,0,-5)},
 AncientRuins={Names={'Overgrown Columns','Ruined Courtyard','Temple Approach'},Template='BlockTree',Tall=56,North=V(0,0,55),Left=V(-85,0,-4),Right=V(80,0,11)},
 SingularityEdge={Names={'Crystal Valley','Machinery Camp','Beacon Ridge'},Template='CrystalCluster',Tall=52,North=V(-8,0,76),Left=V(-85,0,-11),Right=V(86,0,-3)},
}
local backup=game.ServerStorage:FindFirstChild('StarfallBeforeExplorationDressing')or Instance.new('Folder')
backup.Name='StarfallBeforeExplorationDressing';backup.Parent=game.ServerStorage
local results={}
local function distanceSegment(p,a,b)
 local delta=b-a;local t=delta:Dot(delta)>0 and math.clamp((p-a):Dot(delta)/delta:Dot(delta),0,1)or 0
 return (p-(a+delta*t)).Magnitude
end
for _,id in order do
 local island=root.PlanetIslands[id];assert(not island:GetAttribute('ExplorationDressed'),'Already dressed: '..id)
 local d=definitions[id];local a=island.LandingPad.ArrivalAnchor.Position
 local origin=V(a.X,island:GetAttribute('SurfaceY'),a.Z+78)
 local saved=Instance.new('Folder');saved.Name=id;saved.Parent=backup
 local surfaces={}
 for _,p in island.Terrain:GetDescendants()do if p:IsA('BasePart')and p:GetAttribute('EggGround')then table.insert(surfaces,p)end end
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances=surfaces
 local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={island.Props}
 local function floorAt(x,z)
  local h=workspace:Raycast(V(origin.X+x,origin.Y+65,origin.Z+z),V(0,-115,0),ray)
  if h and h.Normal.Y>.99 then return h.Position.Y,h.Instance end
 end
 local function flat(x,z,radius)
  local y=floorAt(x,z);if not y then return end
  for _,p in {V(-radius,0,-radius),V(radius,0,-radius),V(-radius,0,radius),V(radius,0,radius)}do
   local edge=floorAt(x+p.X,z+p.Z);if not edge or math.abs(edge-y)>.1 then return end
  end
  return y
 end
 local routes={
  {V(0,0,-24),V(-24,0,-18),V(-55,0,-8),d.Left},
  {V(2,0,-22),V(32,0,-7),V(65,0,5),d.Right},
  {V(-13,0,48),V(-22,0,59),d.North},
  {V(-55,0,-8),V(-29,0,12),V(0,0,24),V(33,0,22),V(65,0,5)},
 }
 local oldTrail={};for n=0,20 do table.insert(oldTrail,V(math.sin(n*.23)*13,0,-32+n*4))end
 local function smooth(nodes)
  local points={}
  for n=1,#nodes-1 do
   local p0,p1,p2,p3=nodes[math.max(1,n-1)],nodes[n],nodes[n+1],nodes[math.min(#nodes,n+2)]
   local count=math.max(1,math.ceil((p2-p1).Magnitude/3))
   for step=0,count-1 do local t=step/count
    table.insert(points,(p1*2+(p2-p0)*t+(p0*2-p1*5+p2*4-p3)*t*t+(-p0+p1*3-p2*3+p3)*t*t*t)*.5)
   end
  end
  table.insert(points,nodes[#nodes]);return points
 end
 for n,route in routes do routes[n]=smooth(route)end
 local allRoutes=table.clone(routes);table.insert(allRoutes,oldTrail)
 local stairCenters={}
 for _,step in island.Terrain.HillsidePaths:GetChildren()do if step:IsA('BasePart')then table.insert(stairCenters,V(step.Position.X-origin.X,0,step.Position.Z-origin.Z))end end
 local function routeDistance(x,z)
  local p=V(x,0,z);local closest=math.huge
  for _,route in allRoutes do for n=1,#route-1 do closest=math.min(closest,distanceSegment(p,route[n],route[n+1]))end end
  for _,center in stairCenters do closest=math.min(closest,(p-center).Magnitude)end
  return closest
 end
 local template
 for _,o in island.Props:GetDescendants()do if o:IsA('Model')and o.Name==d.Template then template=o;break end end
 assert(template,'Missing biome scenery: '..id)
 local hero=island.Props[island:GetAttribute('WorldLandmark')]
 local heroCF=hero:GetBoundingBox();local heroPoint=V(heroCF.X-origin.X,0,heroCF.Z-origin.Z)
 -- Clear trunks/solid props along the approaches; foliage farther away can frame them.
 for _,grove in island.Props:GetChildren()do if grove.Name:match('^SceneryGrove')then
  for _,plant in grove:GetChildren()do if plant:IsA('Model')then
   local p=plant:GetPivot().Position
   if routeDistance(p.X-origin.X,p.Z-origin.Z)<9 then plant:SetAttribute('OriginalExplorationGrove',grove.Name);plant.Parent=saved end
  end end
 end end
 local areaCenters={V(-55,0,-8),V(65,0,5),d.North+V(15,0,13)}
 -- Reserve the thematic scenery first, so open egg pockets do not consume its space.
 local featureSites={{},{}}
 local featureRadius=id=='ScrapBelt'and 5.2 or 4.5
 for area=1,2 do local center=areaCenters[area]
  for n=1,180 do local angle=n*2.399+area;local radius=18+math.floor((n-1)/24)*6
   local x,z=center.X+math.cos(angle)*radius,center.Z+math.sin(angle)*radius
   if z<-28 or routeDistance(x,z)<7+featureRadius or (V(x,0,z)-heroPoint).Magnitude<25+featureRadius then continue end
   local clear=true
   for _,sites in featureSites do for _,p in sites do if (V(x,0,z)-V(p.X,0,p.Z)).Magnitude<featureRadius*2+2 then clear=false end end end
   if not clear then continue end
   local y=flat(x,z,featureRadius);if not y then continue end
   if #workspace:GetPartBoundsInBox(CF(origin.X+x,y+2.7,origin.Z+z),V(featureRadius*2,5.4,featureRadius*2),overlap)>0 then continue end
   table.insert(featureSites[area],{X=x,Z=z,Y=y,Angle=angle})
   if #featureSites[area]==6 then break end
  end
  assert(#featureSites[area]>=3,'Not enough thematic scenery sites: '..id..' / '..d.Names[area])
 end
 local pockets={}
 local function removableGrovePlant(part)
  local parent=part.Parent
  while parent and parent~=island.Props do
   if parent:IsA('Model')and parent.Parent and parent.Parent.Name:match('^SceneryGrove')then return parent end
   parent=parent.Parent
  end
 end
 for area,center in areaCenters do
  local found=0
  for n=1,200 do
   local angle=n*2.39996+area;local r=13+math.floor((n-1)/20)*6
   local x,z=center.X+math.cos(angle)*r,center.Z+math.sin(angle)*r
   if z<-28 or routeDistance(x,z)<10 or (V(x,0,z)-heroPoint).Magnitude<25 then continue end
   local separated=true;for _,p in pockets do if (V(x,0,z)-V(p.X,0,p.Z)).Magnitude<18 then separated=false;break end end
   for _,sites in featureSites do for _,p in sites do if (V(x,0,z)-V(p.X,0,p.Z)).Magnitude<featureRadius+11 then separated=false end end end
   if not separated then continue end
   local y=flat(x,z,9);if not y then continue end
   local blocked=false;local remove={}
   for _,hit in workspace:GetPartBoundsInBox(CF(origin.X+x,y+2.3,origin.Z+z),V(15,4.6,15),overlap)do
    local plant=removableGrovePlant(hit)
    if plant then remove[plant]=true else blocked=true;break end
   end
   if blocked then continue end
   for plant in remove do plant:SetAttribute('OriginalExplorationGrove',plant.Parent.Name);plant.Parent=saved end
   table.insert(pockets,{X=x,Z=z,Y=y,Area=area});found+=1;if found==4 then break end
  end
  assert(found>=2,'Not enough clear egg pockets for '..id..' / '..d.Names[area]..': '..found)
 end
 local function pocketDistance(x,z)
  local dist=math.huge;for _,p in pockets do dist=math.min(dist,(V(x,0,z)-V(p.X,0,p.Z)).Magnitude)end;return dist
 end
 local dressing=Instance.new('Model');dressing.Name='ExplorationDressing';dressing.Parent=island.Props
 for n,name in d.Names do local area=Instance.new('Model');area.Name=name;area:SetAttribute('Subarea',name);area.Parent=dressing end
 local function part(parent,name,size,cf,role,solid,class)
  local p=Instance.new(class or 'Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true
  p.CanCollide=solid==true;p.CanTouch=false;p.Material=Enum.Material.Plastic;p.TopSurface=Enum.SurfaceType.Studs
  p.BottomSurface=Enum.SurfaceType.Smooth;p:SetAttribute('PaletteRole',role);p.Parent=parent;return p
 end
 -- Fuse all new trail segments at a given elevation, avoiding coplanar overlapping pieces.
 local grouped={}
 for _,route in routes do for n=1,#route-1 do local delta=route[n+1]-route[n];local steps=math.max(1,math.ceil(delta.Magnitude/3))
  for step=0,steps do local p=route[n]+delta*(step/steps);local y,hit=floorAt(p.X,p.Z)
   if y and p.Z>=-30 and hit.Name~='HillStep'and hit:GetAttribute('PaletteRole')~='Path'then
    local level=math.round((y-origin.Y)/4);local elevation=origin.Y+level*4
    if math.abs(y-elevation)<.12 then grouped[level]=grouped[level]or {};table.insert(grouped[level],V(p.X,elevation,p.Z))end
   end
  end
 end end
 local network=Instance.new('Model');network.Name='ExplorationRoutes';network.Parent=island.Terrain
 local trailCount=0
 for level,points in grouped do
  local pieces={}
  for _,p in points do
   local source=part(network,'TrailSource',V(.26,10,10),CF(origin.X+p.X,p.Y+.13,origin.Z+p.Z)*CFrame.Angles(0,0,math.pi*.5),'Path',true)
   source.Shape=Enum.PartType.Cylinder;table.insert(pieces,source)
  end
  if #pieces>0 then
   local first=table.remove(pieces,1);local union=first
   if #pieces>0 then union=first:UnionAsync(pieces,Enum.CollisionFidelity.PreciseConvexDecomposition,Enum.RenderFidelity.Precise);union.Parent=network;first:Destroy();for _,p in pieces do p:Destroy()end end
   union.Name='WindingTrail'..level;union.Anchored=true;union.CanCollide=true;union.CanTouch=false
   union.Material=Enum.Material.Plastic;if union:IsA('UnionOperation')then union.UsePartColor=true end
   union:SetAttribute('EggGround',true);union:SetAttribute('PaletteRole','Path');trailCount+=1
   -- Native studs clipped to this route's actual collision footprint.
   local trailRay=RaycastParams.new();trailRay.FilterType=Enum.RaycastFilterType.Include;trailRay.FilterDescendantsInstances={union}
   local minX,maxX,minZ,maxZ=math.huge,-math.huge,math.huge,-math.huge
   for _,p in points do minX=math.min(minX,p.X-6);maxX=math.max(maxX,p.X+6);minZ=math.min(minZ,p.Z-6);maxZ=math.max(maxZ,p.Z+6)end
   local top=points[1].Y+.26
   for z=math.floor(minZ/2)*2,maxZ,2 do local start,finish
    local function flush()
     if start then local p=part(network,'TrailStuds',V(finish-start+2,.05,2),CF(origin.X+(start+finish)*.5,top+.025,origin.Z+z),'Path',true);p.CastShadow=false;p:SetAttribute('EggGround',true)end
     start,finish=nil,nil
    end
    for x=math.floor(minX/2)*2,maxX,2 do local supported=true
     for _,q in {V(-1.01,0,-1.01),V(1.01,0,-1.01),V(-1.01,0,1.01),V(1.01,0,1.01)}do
      local h=workspace:Raycast(V(origin.X+x+q.X,top+4,origin.Z+z+q.Z),V(0,-8,0),trailRay)
      if not h or h.Normal.Y<.99 then supported=false;break end
     end
     if supported then if not start then start=x end;finish=x else flush()end
    end
    flush()
   end
  end
  task.wait()
 end
 local occupied={};local tall=0;local low=0
 local function available(x,z,r)
  if z<-28 or routeDistance(x,z)<7+r or pocketDistance(x,z)<10+r or (V(x,0,z)-heroPoint).Magnitude<25+r then return end
  for _,p in occupied do if (V(x,0,z)-V(p.X,0,p.Z)).Magnitude<r+p.R then return end end
  local y=flat(x,z,r);if not y then return end
  if #workspace:GetPartBoundsInBox(CF(origin.X+x,y+2.7,origin.Z+z),V(r*2,5.4,r*2),overlap)>0 then return end
  return y
 end
 local function worldBottom(model)
  local bottom=math.huge
  for _,p in model:GetDescendants()do if p:IsA('BasePart')then
   local extent=math.abs(p.CFrame.RightVector.Y)*p.Size.X*.5+math.abs(p.CFrame.UpVector.Y)*p.Size.Y*.5+math.abs(p.CFrame.LookVector.Y)*p.Size.Z*.5
   bottom=math.min(bottom,p.Position.Y-extent)
  end end
  return bottom
 end
 -- Reserve the recognizable area props before filling their surroundings with plants.
 for area=1,2 do local container=dressing[d.Names[area]]
  for n,site in featureSites[area]do
   local angle,x,z,y=site.Angle,site.X,site.Z,site.Y
   local footprint=featureRadius
   local at=CF(origin.X+x,y,origin.Z+z)*CFrame.Angles(0,angle,0)
   if id=='DerelictField'and area==1 then
    local height=3+n%3
    part(container,'ScrapRidge',V(7,height,6),at*CF(0,height*.5,0),'Rock',true,'WedgePart')
    part(container,'OreFragment',V(2,1.2,.2),at*CF(0,height*.72,3.1),'High',false)
   elseif id=='DerelictField'then
    part(container,'CargoCrate',V(4,3.5,4),at*CF(0,1.75,0),'High',true)
    part(container,'CrateBand',V(4.2,.4,4.2),at*CF(0,2.4,0),'Deep',false)
    if n%3==0 then part(container,'StackedCrate',V(3.5,3,3.5),at*CF(0,5,0),'Rock',true)end
   elseif id=='AncientRuins'and area==2 then
    part(container,'CourtyardSlab',V(6,.4,6),at*CF(0,.2,0),'Highlight',true)
    part(container,'BrokenWall',V(6,3,1.5),at*CF(0,1.9,2),'High',true)
    part(container,'WallMoss',V(3,.5,2),at*CF(0,3.6,2),'Leaf',false)
   elseif id=='AncientRuins'then
    local height=3+n%4;part(container,'BrokenColumn',V(3,height,3),at*CF(0,height*.5,0),'Highlight',true)
    part(container,'MossCap',V(3.5,.6,3.5),at*CF(0,height+.3,0),'Leaf',false)
   elseif id=='SingularityEdge'and area==1 then
    for _,side in {-1,1}do part(container,'ShelteredCrystal',V(1.8,4+n%3,1.8),at*CF(side*1.5,(4+n%3)*.5,0),'High',true,'WedgePart')end
   elseif id=='SingularityEdge'then
    part(container,'DamagedGenerator',V(5,3,4),at*CF(0,1.5,0),'Rock',true)
    part(container,'GeneratorPanel',V(3,1,.2),at*CF(0,1.8,-2.2),'Accent',false)
    part(container,'Vent',V(2,.4,3),at*CF(0,3.2,0),'High',false)
   elseif id=='ScrapBelt'and area==1 then
    for _,side in {-1,1}do
     part(container,'FlowerStem',V(.3,1.6,.3),at*CF(side*1.4,.8,0),'Stem',false)
     part(container,'FlowerHead',V(1.7,.4,1.7),at*CF(side*1.4,1.8,0),'Accent',false)
    end
   elseif id=='ScrapBelt'then
    part(container,'FallenLog',V(2,2,9),at*CF(0,1,0),'Stem',true)
    part(container,'LogMoss',V(1.6,.4,5),at*CF(0,2.2,0),'Leaf',false)
   elseif id=='IceGraveyard'and area==1 then
    part(container,'CrystalSpire',V(2,7,2),at*CF(0,3.5,0),'High',true,'WedgePart')
    part(container,'CrystalFoot',V(5,1,4),at*CF(0,.5,0),'Highlight',true)
   elseif id=='IceGraveyard'then
    part(container,'IceShelfFragment',V(6,2.3,5),at*CF(0,1.15,0),'Highlight',true)
    part(container,'IceRidge',V(2,3,3),at*CF(1,3.8,0),'High',false,'WedgePart')
   else
    local h=area==1 and 3 or 7
    part(container,'AlienStalk',V(1,h,1),at*CF(0,h*.5,0),'Stem',true)
    part(container,'SporeHead',V(4,1.5,4),at*CF(0,h+.3,0),'LeafLight',false)
   end
   table.insert(occupied,{X=x,Z=z,R=footprint})
  end
 end
 local tallModel=Instance.new('Model');tallModel.Name='MiddleAndBackground';tallModel.Parent=dressing
 for z=-20,156,14 do for x=-140,140,14 do
  if tall>=d.Tall then break end
  local nx=x+math.sin(x*.21+z)*4;local nz=z+math.cos(z*.17-x)*4
  local y=available(nx,nz,4.2)
  if y then
   local m=template:Clone();m:PivotTo(CF(origin.X+nx,y,origin.Z+nz)*CFrame.Angles(0,nx*.11+nz*.07,0)*m:GetPivot().Rotation)
   m:PivotTo(m:GetPivot()+V(0,y-worldBottom(m),0));m.Parent=tallModel
   table.insert(occupied,{X=nx,Z=nz,R=4.2});tall+=1
  end
 end;task.wait()end
 local understory=Instance.new('Model');understory.Name='ForegroundGroundCover';understory.Parent=dressing
 for z=-24,154,11 do for x=-140,140,11 do
  if low>=160 then break end
  local nx=x+math.cos(z*.7+x)*2.3;local nz=z+math.sin(x*.5-z)*2.3;local y=available(nx,nz,1.6)
  if y then
   local at=CF(origin.X+nx,y,origin.Z+nz);local m=Instance.new('Model');m.Name='GroundCluster'
   if id=='ScrapBelt'or id=='NebulaCurrent'or id=='AncientRuins'then
    for _,side in {-1,1}do
     part(m,'PlantStem',V(.3,1.3,.3),at*CF(side*.8,.65,0),'Stem',false)
     part(m,id=='NebulaCurrent'and 'SporeCap'or 'PlantCrown',V(1.1,.5,1.1),at*CF(side*.8,1.45,0),(low%3==0)and 'Accent'or 'LeafLight',false)
    end
   else
    part(m,'GroundStone',V(2.4,.9,2),at*CF(0,.45,0),'Rock',false)
    part(m,id=='DerelictField'and 'ScrapPlate'or 'SmallShard',V(.7,1.7,.8),at*CF(.9,.85,.3),'High',false,'WedgePart')
   end
   m.Parent=understory;table.insert(occupied,{X=nx,Z=nz,R=1.6});low+=1
  end
 end;task.wait()end
 island.EggSpawnZones.Parent=saved
 local zones=Instance.new('Folder');zones.Name='EggSpawnZones';zones.Parent=island
 for n,p in pockets do
  local zone=part(zones,'Pocket'..n,V(12,1,12),CF(origin.X+p.X,p.Y+12,origin.Z+p.Z),'Ground',false)
  zone.Transparency=1;zone.CanQuery=false;zone:SetAttribute('Subarea',d.Names[p.Area])
 end
 island:SetAttribute('ExplorationDressed',true);island:SetAttribute('Subareas',table.concat(d.Names,' / '))
 table.insert(results,{Id=id,TallScenery=tall,GroundClusters=low,EggPockets=#pockets,ThemedSites=#featureSites[1]+#featureSites[2],RouteUnions=trailCount})
 task.wait()
end
return results

end
dressExplorationAreas()
local function applyWorldPalettes()
-- One user-supplied palette per destination; exact swatches, no blended colors.
local root=workspace.StarfallMap
local definitions={
 {Id='ScrapBelt',Image=5,Name='Forest Greens',Hex={'5BBA6F','3FA34D','2A9134','137547','0C6038','054A29'},Ground=1,High=2,Rock=4,Deep=6,Leaf=3,LeafLight=2,Stem=5,Accent=1,Highlight=1,Path=3,Shell=1},
 {Id='DerelictField',Image=3,Name='Muted Quarry',Hex={'CFCFEA','A89B9D','816C61','575A4B','2A2C24'},Ground=2,High=3,Rock=4,Deep=5,Leaf=4,LeafLight=1,Stem=5,Accent=1,Highlight=1,Path=1,Shell=2},
 {Id='IceGraveyard',Image=2,Name='Aqua Frost',Hex={'363732','53D8FB','66C3FF','DCE1E9','D4AFB9'},Ground=2,High=3,Rock=1,Deep=1,Leaf=3,LeafLight=4,Stem=1,Accent=5,Highlight=4,Path=4,Shell=4},
 {Id='NebulaCurrent',Image=1,Name='Orchid Violet',Hex={'420039','932F6D','E07BE0','DCCCFF','F6F2FF'},Ground=3,High=4,Rock=2,Deep=1,Leaf=2,LeafLight=4,Stem=1,Accent=5,Highlight=5,Path=4,Shell=4},
 {Id='AncientRuins',Image=4,Name='Teal Relics',Hex={'0E7C7B','17BEBB','D4F4DD','D62246','4B1D3F'},Ground=1,High=2,Rock=5,Deep=5,Leaf=2,LeafLight=3,Stem=5,Accent=4,Highlight=3,Path=3,Shell=3},
 {Id='SingularityEdge',Image=6,Name='Electric Candy',Hex={'0091AD','6AFEFF','FFF4E4','FFED9C','FF57BB'},Ground=1,High=2,Rock=3,Deep=1,Leaf=4,LeafLight=5,Stem=1,Accent=5,Highlight=4,Path=3,Shell=3},
}
local function fromHex(hex)return Color3.fromRGB(tonumber(hex:sub(1,2),16),tonumber(hex:sub(3,4),16),tonumber(hex:sub(5,6),16))end
local function setColor(part,color)
 if part:GetAttribute('PrePaletteColor')==nil then part:SetAttribute('PrePaletteColor',part.Color)end
 part.Color=color
 if part:IsA('UnionOperation')then part.UsePartColor=true end
end
local results={}
for _,d in definitions do
 local colors={};for _,hex in d.Hex do table.insert(colors,fromHex(hex))end
 local function color(role)return colors[d[role]]end
 local function metadata(model)
  model:SetAttribute('PaletteName',d.Name);model:SetAttribute('PaletteImageIndex',d.Image)
  model:SetAttribute('PaletteHex',table.concat(d.Hex,','))
 end
 local island=root.PlanetIslands[d.Id];local planet=root.Planets[d.Id]
 metadata(island);metadata(planet)
 local count=0
 for _,part in island:GetDescendants()do if part:IsA('BasePart')then
  local name=part.Name;local role='Rock'
  if part:GetAttribute('PaletteRole')then role=part:GetAttribute('PaletteRole')
  elseif name=='GroundCell'then
   local h=part:GetAttribute('TerrainHeight')or 0
   role=h>=8 and 'Highlight'or h>0 and 'High'or 'Ground'
   -- Green and purple landscapes retain their colored upper ground.
   if d.Id=='ScrapBelt'or d.Id=='NebulaCurrent'or d.Id=='DerelictField'then role=h>0 and 'High'or 'Ground'end
  elseif name=='RockCell'or name=='CliffFoot'then role='Rock'
  elseif name=='CliffFace'then role='High'
  elseif name=='HangingRock'then role='Deep'
  elseif name=='HalfStudStep'or name=='StoneSlab'then role='Path'
  elseif name=='Trunk'or name=='Stem'or name=='PlantStem'or name=='FlowerStem'or name=='MeadowFlagPole'then role='Stem'
  elseif name=='Crown'or name=='TreeCrown'or name=='Cap'or name=='MushroomCap'or name=='PlantCrown'or name=='RuinVine'then role='Leaf'
  elseif name=='LeafCluster'or name=='CrownTop'or name=='CapTop'then role='LeafLight'
  elseif name=='Crystal'or name=='IceShard'or name=='StormShoot'then role='High'
  elseif name=='CrystalTip'or name=='Spot'then role='Highlight'
  elseif name=='FlowerHead'or name=='MeadowFlag'or name=='Ore'or name=='OrePlate'or name=='Collector'or name=='Armor'then role='Accent'
  elseif name=='RuinPillar'or name=='RuinCap'or name=='RuinLintel'then role='Highlight'
  elseif name=='RuinInlay'then role='Accent'
  elseif name=='Hull'or name=='CargoBox'or name=='BrokenFin'then role='High'
  elseif name=='DeadNozzle'or name=='Mast'or name=='Base'then role='Deep'
  elseif name=='SmallGroundDetail'then role='LeafLight'
  end
  setColor(part,color(role));count+=1
 end end
 local plate=0
 for _,part in planet:GetDescendants()do if part:IsA('BasePart')then
  local role='Rock'
  if part.Name=='Planet'then role='Ground'
  elseif part.Name=='ContinentPlate'then plate+=1;role=plate%3==0 and 'Highlight'or 'High'
  elseif part.Name=='OrbitRing'then role='Accent'end
  setColor(part,color(role))
 end end
 local template=game.ServerStorage.StarfallEggTemplates[d.Id];metadata(template)
 for _,part in template:GetDescendants()do if part:IsA('BasePart')then
  local role=part.Name=='Shell'and 'Shell'or part.Name=='Nest'and 'Ground'or 'Accent'
  if part.Name=='LeafPlate'then role='Leaf'
  elseif part.Name=='IceTip'or part.Name=='AntennaTip'then role='High'end
  setColor(part,color(role))
 end end
 table.insert(results,{Id=d.Id,Palette=d.Name,Image=d.Image,ColoredParts=count})
 task.wait()
end
return results

end
applyWorldPalettes()
local function addIslandLife()
-- Decorative details only; no rewards, hazards or rarity rolls.
local root=workspace.StarfallMap
local V,CF=Vector3.new,CFrame.new
local order={'ScrapBelt','DerelictField','IceGraveyard','NebulaCurrent','AncientRuins','SingularityEdge'}
local results={}
for _,id in order do
 local island=root.PlanetIslands[id]
 assert(not island.Props:FindFirstChild('IslandLife'),'IslandLife already exists: '..id)
 local folder=Instance.new('Model');folder.Name='IslandLife';folder.Parent=island.Props
 local colors={};for h in island:GetAttribute('PaletteHex'):gmatch('[^,]+')do table.insert(colors,Color3.fromHex(h))end
 local dark,light,accent=colors[#colors],colors[1],colors[3]
 if id=='IceGraveyard'then dark,light,accent=colors[1],colors[4],colors[2]
 elseif id=='AncientRuins'then dark,light,accent=colors[5],colors[3],colors[4]
 elseif id=='NebulaCurrent'then dark,light,accent=colors[1],colors[5],colors[3]
 elseif id=='SingularityEdge'then dark,light,accent=colors[1],colors[3],colors[5]end
 local count=0
 local function p(parent,name,size,at,color,glow)
  local q=Instance.new('Part');q.Name=name;q.Size=size;q.CFrame=at;q.Color=color
  q.Anchored=true;q.CanCollide=false;q.CanTouch=false;q.CanQuery=false
  q.Material=glow and Enum.Material.Neon or Enum.Material.Plastic
  q.TopSurface=glow and Enum.SurfaceType.Smooth or Enum.SurfaceType.Studs;q.BottomSurface=Enum.SurfaceType.Smooth
  q.CastShadow=not glow;q.Parent=parent;count+=1;return q
 end
 local function motion(model,kind,radius)
  model:SetAttribute('IslandMotion',kind);model:SetAttribute('MotionRadius',radius or 0)
  model:SetAttribute('MotionPhase',count*.73);model:SetAttribute('RestPivot',model:GetPivot())
 end
 local function motes(at,kind,n)
  local m=Instance.new('Model');m.Name=kind;m.Parent=folder
  for j=1,n do
   local q=p(m,'Mote',V(.22,.22,.22),at*CF(math.cos(j*2.4)*1.8,j*.7,math.sin(j*2.4)*1.8),light,false)
   q:SetAttribute('MoteIndex',j)
  end
  motion(m,kind,2)
 end
 local function visitor(at,index)
  local m=Instance.new('Model');m.Name=(id=='ScrapBelt' or id=='NebulaCurrent')and 'FlutterBug' or 'SurveyDrone';m.Parent=folder
  local bug=m.Name=='FlutterBug'
  p(m,'Body',bug and V(.8,.65,1.2)or V(2,1.1,1.5),at,accent)
  p(m,'Face',bug and V(.65,.4,.12)or V(1.6,.65,.12),at*CF(0,.1,-(bug and .65 or .81)),dark)
  for _,s in {-1,1}do
   p(m,'Eye',V(.17,.17,.12),at*CF(s*(bug and .18 or .45),.15,-(bug and .74 or .9)),light)
   local wing=p(m,'Wing',bug and V(1.1,.12,1)or V(.65,.22,1.8),at*CF(s*(bug and .8 or 1.3),.2,0),light)
   wing:SetAttribute('WingSide',s)
   if not bug then p(m,'Thruster',V(.4,.22,.4),at*CF(s*1.3,-.23,.3),accent,true)end
  end
  if not bug then p(m,'Antenna',V(.14,.7,.14),at*CF(.6,.85,.1),dark)end
  motion(m,bug and 'Flutter' or 'Survey',bug and 2.5 or 3)
 end
 local sources=island.Props.ExplorationDressing:GetDescendants()
 local visitors=0
 for _,s in sources do if s:IsA('BasePart')then
  local at=s.CFrame;local top=at*CF(0,s.Size.Y*.5,0)
  if s.Name=='FallenLog'then
   for _,side in {-1,1}do
    p(folder,'LogEnd',V(1.65,1.65,.08),at*CF(0,0,side*(s.Size.Z*.5+.045)),light)
    p(folder,'Heartwood',V(.75,.75,.1),at*CF(0,0,side*(s.Size.Z*.5+.1)),accent)
   end
   for j=1,3 do p(folder,'TinyFungus',V(.65,.35,.65),top*CF(.35,.25,j-2),light)end
  elseif s.Name=='FlowerHead'then
   p(folder,'FlowerCenter',V(.55,.2,.55),top*CF(0,.1,0),dark)
   for j=1,4 do local a=j*math.pi*.5;p(folder,'Petal',V(.65,.2,.65),top*CF(math.cos(a)*.68,.08,math.sin(a)*.68),light)end
  elseif s.Name=='CargoCrate'then
   for _,x in {-1.6,1.6}do for _,y in {-1.25,1.25}do
    p(folder,'CrateRivet',V(.22,.22,.13),at*CF(x,y,-2.08),light)
   end end
   p(folder,'CargoLabel',V(1.3,.65,.12),at*CF(0,.15,-2.08),dark)
   p(folder,'LabelStripe',V(.8,.16,.13),at*CF(0,.15,-2.15),light)
   p(folder,'CrateHandle',V(.8,.2,.35),top*CF(0,.15,0),dark)
  elseif s.Name=='OreFragment'then motes(top*CF(0,.3,0),'Sparks',3)
  elseif s.Name=='IceShelfFragment'then
   for j=1,3 do p(folder,'IceFissure',V(.1,.03,1.6),top*CF(j-2,.025,0)*CFrame.Angles(0,j*.7,0),accent)end
   motes(top*CF(0,1,0),'Snow',4)
  elseif s.Name=='CrystalSpire'then
   p(folder,'CrystalGlint',V(.15,.65,.15),top*CF(0,.4,0),light,true)
   motes(top,'Shimmer',3)
  elseif s.Name=='SporeHead'then
   for j=1,4 do p(folder,'MushroomSpot',V(.6,.12,.6),top*CF(math.cos(j*2.4),.07,math.sin(j*2.4)),accent)end
   motes(top*CF(0,.3,0),'Spores',4)
   -- Animate only the cap and its spots together, keeping the rooted stalk still.
   local cap=Instance.new('Model');cap.Name='BreathingCap';cap.Parent=folder
   local copy=s:Clone();copy.CanCollide=false;copy.CanTouch=false;copy.CanQuery=false;copy.Parent=cap
   s.Transparency=1
   for _,q in folder:GetChildren()do if q:IsA('BasePart')and q.Name=='MushroomSpot'and(q.Position-s.Position).Magnitude<4 then q.Parent=cap end end
   motion(cap,'Breathe',0)
  elseif s.Name=='BrokenColumn'then
   p(folder,'RunePlaque',V(1.5,1.4,.12),at*CF(0,0,-1.57),dark)
   for j=1,3 do p(folder,'RuneStroke',V(.16,.7,.12),at*CF((j-2)*.37,0,-1.66)*CFrame.Angles(0,0,j*.3),accent)end
   motes(top*CF(0,1.4,0),'Runes',3)
  elseif s.Name=='CourtyardSlab'then
   for j=1,3 do p(folder,'CourtyardInlay',V(.2,.04,2.3),top*CF(j-2,.035,-.4),accent)end
  elseif s.Name=='DamagedGenerator'then
   for _,side in {-1,1}do
    p(folder,'GeneratorFoot',V(.65,.4,3),at*CF(side*1.8,-1.3,0),dark)
    p(folder,'Gauge',V(.6,.6,.15),at*CF(side*1.5,.45,-2.08),light)
    local lamp=p(folder,'StatusLamp',V(.3,.3,.15),at*CF(side*1.5,.45,-2.18),accent,true)
    lamp:SetAttribute('IslandPulse',true);lamp:SetAttribute('PulsePhase',count*.4)
   end
   motes(top*CF(0,.5,0),'Sparks',4)
  end
  if visitors<6 and (s.Name=='FallenLog'or s.Name=='CargoCrate'or s.Name=='IceShelfFragment'or s.Name=='SporeHead'or s.Name=='BrokenColumn'or s.Name=='DamagedGenerator')then
   visitors+=1;visitor(top*CF(0,3.5,0),visitors)
  end
 end end
 island:SetAttribute('IslandLifeDetailed',true)
 table.insert(results,{Id=id,DetailParts=count,AmbientVisitors=visitors})
 task.wait()
end
return results

end
addIslandLife()
local function landscapeArrivals()
-- One shared surface landing anchor for future client-side ships; natural arrival landscape.
local root=workspace.StarfallMap
local V,CF=Vector3.new,CFrame.new
local order={'ScrapBelt','DerelictField','IceGraveyard','NebulaCurrent','AncientRuins','SingularityEdge'}
-- Composition is authored per destination. Each uses different routes, terrain and planting regions.
local designs={
 ScrapBelt={Name='Woodland and open flower meadow',
  Roads={{{0,-62},{-9,-42},{0,-31}},{{-28,-84},{-54,-81},{-82,-108},{-54,-139},{10,-145},{57,-121},{72,-61},{90,-15}}},
  Hills={{-67,-48,15,10,3,'Oval',-.2},{48,-94,13,9,2,'Oval',.35}},
  Groves={{-101,-66,28,40,48},{-58,-120,30,19,40},{84,-67,30,36,40},{12,-143,38,14,25}},
  Sites={{-47,-45},{67,-103},{-83,-104}},Style='Wood'},
 DerelictField={Name='Broken salvage ridges and wreck scatter',
  Roads={{{0,-62},{9,-43},{0,-31}},{{-28,-84},{-64,-93},{-80,-68},{-105,-46},{-88,-15}},{{28,-84},{65,-111},{53,-137},{-8,-145}}},
  Hills={{-62,-51,20,8,4,'Ledge',-.45},{65,-55,12,9,2,'Ledge',.3},{-48,-121,22,7,3,'Ledge',.2}},
  Groves={{-104,-90,35,39,35},{47,-139,43,15,38},{93,-48,30,30,32},{-44,-57,20,18,22}},
  Sites={{66,-122},{-60,-117},{-102,-51},{57,-49}},Style='Scrap'},
 IceGraveyard={Name='Long ice shelves and blue crystal pockets',
  Roads={{{0,-62},{-8,-45},{0,-31}},{{-28,-84},{-64,-104},{-100,-79},{-111,-38},{-88,-15}},{{28,-84},{58,-62},{94,-79},{80,-109},{43,-124},{0,-130}}},
  Hills={{-62,-49,26,10,2,'Shelf',-.18},{57,-119,25,12,3,'Shelf',.45}},
  Groves={{-95,-80,25,38,38},{69,-48,42,20,46},{-35,-137,43,17,36},{104,-100,19,30,24}},
  Sites={{-68,-121},{57,-46},{24,-132}},Style='Ice'},
 NebulaCurrent={Name='Asymmetric mushroom thickets and spore gardens',
  Roads={{{0,-62},{10,-47},{0,-31}},{{28,-84},{61,-87},{100,-55},{90,-15}},{{-28,-84},{-57,-67},{-95,-87},{-76,-125},{-14,-140},{39,-126},{61,-87}}},
  Hills={{-61,-112,17,12,3,'Oval',.65},{69,-48,11,15,4,'Oval',-.3},{14,-137,12,8,1,'Oval',.2}},
  Groves={{-95,-54,29,28,36},{-61,-115,36,25,55},{72,-109,36,31,42},{74,-41,27,17,28}},
  Sites={{-63,-49},{51,-122},{-94,-109}},Style='Spore'},
 AncientRuins={Name='Interrupted processional courts and overgrown walls',
  Roads={{{0,-62},{-3,-43},{0,-31}},{{-28,-84},{-63,-82},{-79,-55},{-88,-15}},{{28,-84},{62,-84},{75,-118},{32,-138},{-27,-134},{-63,-82}}},
  Hills={{-53,-48,12,9,1,'Court',0},{-63,-113,12,10,1,'Court',.28}},
  Groves={{-107,-63,25,40,40},{-50,-132,35,19,38},{92,-68,24,42,42},{24,-146,38,12,22}},
  Sites={{-65,-46},{58,-119},{-69,-111},{68,-43}},Style='Ruins'},
 SingularityEdge={Name='Diagonal crystal ridges and isolated machinery',
  Roads={{{0,-62},{7,-46},{0,-31}},{{-28,-84},{-54,-110},{-91,-100},{-121,-60},{-88,-15}},{{28,-84},{62,-61},{100,-70},{94,-101},{55,-120}}},
  Hills={{-67,-52,26,8,4,'Ledge',.7},{56,-125,24,7,3,'Ledge',-.55}},
  Groves={{-94,-84,30,40,42},{-25,-142,41,15,34},{79,-48,33,23,40},{92,-112,21,31,34}},
  Sites={{-62,-121},{57,-44},{87,-101}},Style='Storm'},
}
local results={}
for _,id in order do
 local island=root.PlanetIslands[id]
 assert(not island.Props:FindFirstChild('ArrivalLandscape'),'Arrival landscape already built: '..id)
 local land=island.LandingPad.PadSurface.Position
 local origin=V(land.X,island:GetAttribute('SurfaceY'),land.Z+84)
 local archive=game.ServerStorage:FindFirstChild('StarfallBeforeSharedLanding')or Instance.new('Folder')
 archive.Name='StarfallBeforeSharedLanding';archive.Parent=game.ServerStorage
 local saved=Instance.new('Folder');saved.Name=id;saved.Parent=archive
 island.LandingPad:Clone().Parent=saved
 local keep=island.LandingPad.ShipClearances:FindFirstChild('ShipClearance1')
 for _,s in island.LandingPad.ShipClearances:GetChildren()do if s~=keep then s.Parent=saved end end
 keep.CFrame=CF(origin.X,keep.Position.Y,origin.Z-84)
 island.LandingPad.PadSurface.Size=V(56,.2,44)
 island:SetAttribute('LandingMode','SharedClientShip');island:SetAttribute('SurfaceLandingSlots',1)
 local colors={};for h in island:GetAttribute('PaletteHex'):gmatch('[^,]+')do table.insert(colors,Color3.fromHex(h))end
 local ground,high,rock,accent,path=colors[1],colors[2],colors[#colors],colors[3],colors[3]
 if id=='DerelictField'then ground,high,rock,accent,path=colors[2],colors[3],colors[5],colors[1],colors[1]
 elseif id=='IceGraveyard'then ground,high,rock,accent,path=colors[2],colors[3],colors[1],colors[5],colors[4]
 elseif id=='NebulaCurrent'then ground,high,rock,accent,path=colors[3],colors[4],colors[1],colors[5],colors[4]
 elseif id=='AncientRuins'then ground,high,rock,accent,path=colors[1],colors[2],colors[5],colors[4],colors[3]
 elseif id=='SingularityEdge'then ground,high,rock,accent,path=colors[1],colors[2],colors[3],colors[5],colors[3]end
 local props=Instance.new('Model');props.Name='ArrivalLandscape';props.Parent=island.Props
 local terrain=Instance.new('Model');terrain.Name='ArrivalContours';terrain.Parent=island.Terrain
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={island.Terrain}
 local occupied={};local trees,low,mounds=0,0,0
 local design=designs[id]
 local function p(parent,name,size,at,color,solid,studs)
  local q=Instance.new('Part');q.Name=name;q.Size=size;q.CFrame=at;q.Color=color;q.Anchored=true
  q.CanCollide=solid==true;q.CanTouch=false;q.CanQuery=solid==true or id=='AncientRuins'
  q.TopSurface=studs and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth;q.BottomSurface=Enum.SurfaceType.Smooth
  q.Material=Enum.Material.Plastic;q.Parent=parent;return q
 end
 local function floor(x,z)
  local hit=workspace:Raycast(V(origin.X+x,origin.Y+40,origin.Z+z),V(0,-90,0),ray)
  return hit and hit.Normal.Y>.99 and hit.Instance:GetAttribute('EggGround')and hit.Position.Y or nil
 end
 local function flat(x,z,r)
  local y=floor(x,z);if not y then return end
  for _,q in {V(r,0,r),V(-r,0,r),V(r,0,-r),V(-r,0,-r)}do local h=floor(x+q.X,z+q.Z);if not h or math.abs(h-y)>.12 then return end end
  return y
 end
 local function shipClear(x,z,r)
  for _,s in island.LandingPad.ShipClearances:GetChildren()do
   local q=s.CFrame:PointToObjectSpace(V(origin.X+x,s.Position.Y,origin.Z+z))
   if math.abs(q.X)<s.Size.X*.5+r+2 and math.abs(q.Z)<s.Size.Z*.5+r+2 then return false end
  end
  return true
 end
 local routePoints={}
 local function curve(points)
  for n=1,#points-1 do
   local a,b,c,d=points[math.max(1,n-1)],points[n],points[n+1],points[math.min(#points,n+2)]
   for step=0,40 do
    local t=step/40;local t2,t3=t*t,t*t*t
    local q=(b*2+(c-a)*t+(a*2-b*5+c*4-d)*t2+(-a+b*3-c*3+d)*t3)*.5
    table.insert(routePoints,{q.X,q.Z})
   end
  end
 end
 for _,route in design.Roads do local points={}for _,q in route do table.insert(points,V(q[1],0,q[2]))end;curve(points)end
 local function roadDistance(x,z)
  local best=math.huge
  for _,q in routePoints do best=math.min(best,math.sqrt((q[1]-x)^2+(q[2]-z)^2))end
  return best
 end
 local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={island.Props}
 local function available(x,z,r)
  if z> -25 or not shipClear(x,z,r)or roadDistance(x,z)<r+3.5 then return end
  for _,a in occupied do if (V(x,0,z)-V(a.X,0,a.Z)).Magnitude<r+a.R+1.5 then return end end
  local y=flat(x,z,r);if not y then return end
  -- Exact support plus visual spacing around pre-existing arrival plants.
  if #workspace:GetPartBoundsInBox(CF(origin.X+x,y+5,origin.Z+z),V(r*2,10,r*2),overlap)>0 then return end
  return y
 end
 -- Small walkable contour gardens at the shore; never alter a ship's flat ground.
 for _,s in design.Hills do
  local x,z,rx,rz,levels,style,angle=table.unpack(s)
  local r=math.max(rx,rz)
  if style~='Oval'then
   r=math.max(math.abs(math.cos(angle))*rx+math.abs(math.sin(angle))*rz,math.abs(math.sin(angle))*rx+math.abs(math.cos(angle))*rz)
  end
  r+=(levels-1)*.4+.1
  local y=available(x,z,r)
  if not y then for attempt=1,60 do
   local a=attempt*2.399;local shift=3+attempt*.3
   local nx,nz=x+math.cos(a)*shift,z+math.sin(a)*shift
   local h=available(nx,nz,r)
   if h then x,z,y=nx,nz,h;break end
  end end
  -- Hills can be wider than ordinary prop footprints; their support is checked at all corners.
  if y then
   for level=1,levels do
    local sx,sz=math.max(3,rx-(level-1)*1.5),math.max(3,rz-(level-1)*1.5)
    local top=y+level*.5
    local at=CF(origin.X+x+(level-1)*.4,top-.25,origin.Z+z)*CFrame.Angles(0,angle,0)
    local color=(style=='Shelf'or style=='Court')and high or ground
    if style=='Oval'then
     local q=p(terrain,'WoodlandKnoll',V(.5,sx*2,sz*2),at*CFrame.Angles(0,0,math.pi*.5),color,true,false)
     q.Shape=Enum.PartType.Cylinder;q:SetAttribute('EggGround',true)
     for dx=-sx+1,sx-1,2 do
      local width=sz*math.sqrt(math.max(0,1-((math.abs(dx)+1)/sx)^2))*2
      if width>=2 then local skin=p(terrain,'KnollStuds',V(2,.05,math.floor(width/2)*2),at*CF(dx,.275,0),color,true,true);skin.CastShadow=false;skin:SetAttribute('EggGround',true)end
     end
    else
     local q=p(terrain,style=='Court'and 'BrokenCourt'or style=='Shelf'and 'IceShelf'or 'RidgeLedge',V(sx*2,.5,sz*2),at,color,true,true)
     q:SetAttribute('EggGround',true)
    end
   end
   mounds+=1
  end
 end
 -- One fused path surface avoids overlapping path plates at intersections.
 local routeParts={}
 for _,point in routePoints do
  local x,z=point[1],point[2]
  local y=flat(x,z,2.8)
  if not y and id~='IceGraveyard'and id~='SingularityEdge'then for inset=1,10 do
   local nx,nz=x*(1-inset*.01),z*(1-inset*.01)
   local h=flat(nx,nz,2.8)
   if h and math.abs(h-origin.Y)<.12 then x,z,y=nx,nz,h;break end
  end end
  if y and math.abs(y-origin.Y)<.12 then
   local q=p(terrain,'RouteDraft',V(.16,5.5,5.5),CF(origin.X+x,origin.Y+.08,origin.Z+z)*CFrame.Angles(0,0,math.pi*.5),path,true,false)
   q.Shape=Enum.PartType.Cylinder;q.CanCollide=false;q.CanQuery=false;table.insert(routeParts,q)
  end
 end
 local rest={}for n=2,#routeParts do table.insert(rest,routeParts[n])end
 local road=routeParts[1]:UnionAsync(rest,Enum.CollisionFidelity.PreciseConvexDecomposition)
 road.Name='ArrivalWalkways';road.CanCollide=true;road.CanQuery=true;road.UsePartColor=true;road.Color=path;road:SetAttribute('EggGround',true);road.Parent=terrain
 for _,q in routeParts do q:Destroy()end
 local roadRay=RaycastParams.new();roadRay.FilterType=Enum.RaycastFilterType.Include;roadRay.FilterDescendantsInstances={road}
 for x=-150,150,2 do
  local run=nil
  local function flush(z)
   if run then local length=z-run
    local skin=p(terrain,'WalkwayStuds',V(2,.05,length),CF(origin.X+x,origin.Y+.185,origin.Z+(run+z)*.5-1),path,true,true)
    skin.CastShadow=false;skin:SetAttribute('EggGround',true);run=nil
   end
  end
  for z=-170,-20,2 do
   local inside=true
   for _,dx in {-1,1}do for _,dz in {-1,1}do
    if not workspace:Raycast(V(origin.X+x+dx,origin.Y+2,origin.Z+z+dz),V(0,-4,0),roadRay)then inside=false end
   end end
   if inside then run=run or z else flush(z)end
  end
  flush(-18)
 end
 -- Reserve authored scene fragments before planting; worlds use different prop families.
 local scenes=0
 for n,site in design.Sites do
  local x,z,y
  local footprint=design.Style=='Ruins'and 8.6 or 7.2
  for attempt=0,60 do
   local angle=attempt*2.399;local r=attempt==0 and 0 or 4+attempt*.2
   local nx,nz=site[1]+math.cos(angle)*r,site[2]+math.sin(angle)*r
   local h=available(nx,nz,footprint)
   if h then x,z,y=nx,nz,h;break end
  end
  if y then
   local m=Instance.new('Model');m.Name=design.Style..'Scene'..n
   local at=CF(origin.X+x,y,origin.Z+z)*CFrame.Angles(0,n*1.7,0)
   if design.Style=='Wood'then
    if n%2==1 then
     for j=1,3 do local h=1+j*.65
      p(m,'OldStump',V(2.5,h,2.5),at*CF((j-2)*3,h*.5,math.sin(j)*2),rock,true,true)
      p(m,'StumpHeart',V(1.5,.12,1.5),at*CF((j-2)*3,h+.06,math.sin(j)*2),high,false,true)
     end
    else
     p(m,'FallenBranch',V(9,1.5,1.8),at*CF(0,.75,0),rock,true,true)
     for j=1,7 do local a=j*2.4;local r=2+j*.35
      p(m,'MeadowFlower',V(1.2,.35,1.2),at*CF(math.cos(a)*r,.45,math.sin(a)*r),j%2==0 and high or accent,false,true)
     end
    end
   elseif design.Style=='Scrap'then
    p(m,'WreckFrame',V(8,1,4),at*CF(0,1.3,0)*CFrame.Angles(0,0,.17),rock,true,true)
    for j=1,3 do
     p(m,'BrokenRib',V(.65,2+(j+n)%3,4.5),at*CF((j-2)*2.7,2,0)*CFrame.Angles(0,0,(j-2)*.18+n*.04),high,true,true)
    end
    p(m,'DiscardedEngine',V(2.5,2.5,3),at*CF(3,1.25,3.6),accent,true,true)
    p(m,'LooseHullPanel',V(4,.3,2.8),at*CF(-3,.7,3.2)*CFrame.Angles(.25,.4,.13),high,false,true)
   elseif design.Style=='Ice'then
    for j=1,4 do local h=2+(j*3+n)%6
     local q=p(m,'SplitIceBlade',V(1.5,h,2.5),at*CF((j-2.5)*2,h*.5,math.sin(j)*2)*CFrame.Angles(0,j*.5,0),j%2==0 and high or path,true,true)
     q.Shape=Enum.PartType.Block
    end
    p(m,'FrozenPocket',V(6,.15,4),at*CF(0,.1,-3),accent,false,false)
   elseif design.Style=='Spore'then
    for j=1,3 do local h=2+j*1.7;local a=j*2.4;local center=at*CF(math.cos(a)*3,0,math.sin(a)*3)
     p(m,'BentStem',V(.8,h,.8),center*CF(0,h*.5,0)*CFrame.Angles(0,0,.12*(j-2)),rock,true,true)
     p(m,'SplitCap',V(3+j*.5,1,2+j*.6),center*CF((j-2)*.25,h,0)*CFrame.Angles(0,j*.7,.06),j%2==0 and high or accent,false,true)
     p(m,'CapSpot',V(.8,.16,.8),center*CF((j-2)*.25,h+.6,0),ground,false,true)
    end
   elseif design.Style=='Ruins'then
    local court=p(terrain,'CourtyardFoundation',V(12,.4,12),at*CF(0,.2,0),high,true,true);court:SetAttribute('EggGround',true)
    at=at*CF(0,.4,0)
    p(m,'BuriedLintel',V(9,1.8,2.5),at*CF(0,.9,1),high,true,true)
    for j=1,3 do local h=j==n%3+1 and 4.8 or 1.4
     p(m,'BrokenWallBlock',V(2.5,h,2.5),at*CF((j-2)*3,h*.5,-1.6),path,true,true)
    end
    p(m,'FallenColumn',V(2,2,6),at*CF(2,1,6)*CFrame.Angles(0,.6,0),path,true,true)
    p(m,'MossPatch',V(3,.3,2),at*CF(-2,1.95,1),ground,false,true)
   else
    p(m,'CoilPlinth',V(5,1,5),at*CF(0,.5,0),rock,true,true)
    p(m,'CoilStem',V(1.2,5,1.2),at*CF(0,3,0),ground,true,true)
    for j=1,3 do p(m,'ChargedFin',V(4,.5,1),at*CF(0,1+j,0)*CFrame.Angles(0,j*.85,0),high,false,true)end
    local core=p(m,'EnergyCore',V(1.2,1.2,1.2),at*CF(0,6,0),accent,false,false);core.Material=Enum.Material.Neon
    core:SetAttribute('IslandPulse',true);core:SetAttribute('PulsePhase',n)
    for j=1,3 do p(m,'BrokenConduit',V(1,.7,3),at*CF((j-2)*2,.4,4)*CFrame.Angles(0,j*.4,0),rock,false,true)end
   end
   m.Parent=props;scenes+=1;table.insert(occupied,{X=x,Z=z,R=footprint})
  end
 end
 -- Irregular groves, variable size and rotation; no repeated planting grid.
 local template=island.Props.ExplorationDressing.MiddleAndBackground:GetChildren()[1]
 assert(template and template:IsA('Model'),'Missing biome scenery template')
 local function bottom(m)
  local y=math.huge
  for _,q in m:GetDescendants()do if q:IsA('BasePart')then
   local c,s=q.CFrame,q.Size
   local half=math.abs(c.RightVector.Y)*s.X*.5+math.abs(c.UpVector.Y)*s.Y*.5+math.abs(c.LookVector.Y)*s.Z*.5
   y=math.min(y,q.Position.Y-half)
  end end return y
 end
 for region,g in design.Groves do for n=1,g[5]do
  local angle=n*2.399963+region*.7;local radius=math.sqrt(n/g[5])
  local nx=g[1]+math.cos(angle)*radius*g[3];local nz=g[2]+math.sin(angle)*radius*g[4]
  local m=template:Clone();local pivot=m:GetPivot()
  m:ScaleTo(m:GetScale()*(.72+(.5+.5*math.sin(n*3.71+region))*.48))
  m:PivotTo(CF(origin.X+nx,origin.Y,origin.Z+nz)*CFrame.Angles(0,n*1.3+region,0)*pivot.Rotation)
  local _,size=m:GetBoundingBox();local radius=math.max(size.X,size.Z)*.5+.5
  local y=available(nx,nz,radius)
  if y then
   m:PivotTo(m:GetPivot()+V(0,y-bottom(m),0));m.Parent=props;trees+=1
   table.insert(occupied,{X=nx,Z=nz,R=radius})
  else m:Destroy()end
 end;task.wait()end
 for n=1,900 do
  local nx=math.sin(n*1.618)*150;local nz=-96+math.sin(n*2.719)*67;local y=available(nx,nz,1.7)
  if y then
   local m=Instance.new('Model');m.Name='ShoreCluster';local at=CF(origin.X+nx,y,origin.Z+nz)
   if id=='ScrapBelt'or id=='AncientRuins'or id=='NebulaCurrent'then
    for j=1,1+n%3 do
     local h=.7+(n+j)%4*.3;local dx=math.cos(j*2.4)*.8;local dz=math.sin(j*2.4)*.8
     p(m,'PlantStem',V(.25,h,.25),at*CF(dx,h*.5,dz),rock,false)
     p(m,'PlantCrown',V(.6+j*.2,.35,.6+j*.2),at*CF(dx,h+.2,dz),low%3==0 and accent or high,false,true)
    end
   else
    local height=.5+n%3*.25
    p(m,'ShoreStone',V(1.2+n%3*.4,height,1.4),at*CF(0,height*.5,0)*CFrame.Angles(0,n*.7,0),rock,false,true)
    local shard=p(m,'ShoreShard',V(.6,1+n%4*.35,.8),at*CF(.7,(1+n%4*.35)*.5,.3),n%2==0 and accent or high,false,false)
    shard.Shape=Enum.PartType.Block
   end
   m.Parent=props;low+=1;table.insert(occupied,{X=nx,Z=nz,R=1.7})
  end
  if n%100==0 then task.wait()end
 end
 island:SetAttribute('ArrivalLandscaped',true)
 -- Reduce cloned silhouettes in older groves too, without enlarging their reserved footprints.
 local variation=0
 local groups={island.Props.ExplorationDressing.MiddleAndBackground}
 for _,g in island.Props:GetChildren()do if g.Name:match('^SceneryGrove')then table.insert(groups,g)end end
 for _,g in groups do for _,m in g:GetChildren()do if m:IsA('Model')and not m:GetAttribute('CompositionVaried')then
  variation+=1
  local before=m:GetPivot();local groundY=bottom(m)
  m:ScaleTo(m:GetScale()*(.78+(.5+.5*math.sin(variation*2.71))*.22))
  m:PivotTo(before)
  m:PivotTo(m:GetPivot()+V(0,groundY-bottom(m),0))
  m:SetAttribute('CompositionVaried',true)
 end end end
 island:SetAttribute('CompositionTheme',design.Name)
 table.insert(results,{Id=id,Scenery=trees,GroundClusters=low,Landforms=mounds,AuthoredScenes=scenes,Theme=design.Name})
 task.wait()
end
return results






end
landscapeArrivals()
local function directBiomeArt()
-- Final art pass: palette fields, legible paths, silhouette variants and authored cosmic scenes.
local root=workspace.StarfallMap
local V,CF=Vector3.new,CFrame.new
local order={'ScrapBelt','DerelictField','IceGraveyard','NebulaCurrent','AncientRuins','SingularityEdge'}
local config={
 ScrapBelt={Fields={1,2,3,4},Path=5,Stone=6,Accent=2,Water=5,Feature='WoodlandPond',Companion='ForkedGiantTree'},
 DerelictField={Fields={2,3,4},Path=5,Stone=5,Accent=1,Water=4,Feature='SalvageRidge',Companion='AbandonedDish'},
 IceGraveyard={Fields={2,3,4},Path=1,Stone=1,Accent=5,Water=3,Feature='FrozenBasin',Companion='SplitIceSpire'},
 NebulaCurrent={Fields={2,3,4},Path=1,Stone=1,Accent=4,Water=2,Feature='SporeMound',Companion='TwinCapMushroom'},
 AncientRuins={Fields={1,2},Path=3,Stone=5,Accent=4,Water=1,Feature='OvergrownCourt',Companion='BrokenRuneArch'},
 SingularityEdge={Fields={1,2},Path=3,Stone=3,Accent=5,Water=1,Feature='CrystalRift',Companion='CollectorPylon'},
}
local backup=game.ServerStorage:FindFirstChild('StarfallBeforeBiomeArt')or Instance.new('Folder')
backup.Name='StarfallBeforeBiomeArt';backup.Parent=game.ServerStorage
local results={}
for worldIndex,id in order do
 worldIndex=({ScrapBelt=1,DerelictField=2,IceGraveyard=3,NebulaCurrent=4,AncientRuins=5,SingularityEdge=6})[id]
 local island=root.PlanetIslands[id]
 assert(not island:GetAttribute('BiomeArtDirected'),'Art direction already applied: '..id)
 local d=config[id];local palette={}
 for h in island:GetAttribute('PaletteHex'):gmatch('[^,]+')do table.insert(palette,Color3.fromHex(h))end
 local origin=V(island.LandingPad.PadSurface.Position.X,island:GetAttribute('SurfaceY'),island.LandingPad.PadSurface.Position.Z+84)
 local saved=Instance.new('Folder');saved.Name=id;saved.Parent=backup
 local art=Instance.new('Model');art.Name='BiomeArt';art.Parent=island.Props
 local terrainArt=Instance.new('Model');terrainArt.Name='BiomeLandforms';terrainArt.Parent=island.Terrain
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={island.Terrain}
 local function p(parent,name,size,at,color,solid,studs)
  local q=Instance.new('Part');q.Name=name;q.Size=size;q.CFrame=at;q.Color=color;q.Anchored=true
  q.Material=Enum.Material.Plastic;q.CanCollide=solid==true;q.CanQuery=solid==true or id=='AncientRuins';q.CanTouch=false
  q.TopSurface=studs and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth;q.BottomSurface=Enum.SurfaceType.Smooth;q.Parent=parent
  return q
 end
 local function ground(x,z)
  local h=workspace:Raycast(V(origin.X+x,origin.Y+65,origin.Z+z),V(0,-110,0),ray)
  return h and h.Normal.Y>.99 and h.Instance:GetAttribute('EggGround')and h.Position.Y or nil
 end
 local function field(x,z,y)
  local n=math.noise(x*.018,z*.018,worldIndex*.43)+math.noise(x*.045,z*.045,3.4)*.18
  local t=math.clamp((n+.42)/.84,0,.999)
  local index=math.floor(t*#d.Fields)+1
  if y>origin.Y+3 then index=math.max(1,index-1)end
  return palette[d.Fields[index]]
 end
 -- Replace existing skin strips in place. Merge runs by color; no overlapping paint plates.
 local skins={}
 for _,q in island.Terrain.NativeStudSurfaces:GetDescendants()do if q:IsA('BasePart')and q.Name=='StudSurface'then table.insert(skins,q)end end
 local painted=0
 for n,q in skins do
  if q:GetAttribute('PaletteRole')=='Path'then q.Color=palette[d.Path]
  else
   local parent=q.Parent;local start=-q.Size.X*.5;local finish=q.Size.X*.5
   local runStart=start;local runColor=nil
   local function flush(edge)
    if runColor and edge>runStart then
     local copy=q:Clone();copy.Size=V(edge-runStart,q.Size.Y,q.Size.Z);copy.CFrame=q.CFrame*CF((runStart+edge)*.5,0,0)
     copy.Color=runColor;copy.Name='PaletteGround';copy:SetAttribute('PaletteRole',nil);copy.Parent=parent;painted+=1
    end
   end
   for x=start,finish-.01,4 do
    local center=q.CFrame:PointToWorldSpace(V(math.min(x+2,finish),0,0))
    local color=field(center.X-origin.X,center.Z-origin.Z,center.Y)
    if runColor and color~=runColor then flush(x);runStart=x end
    runColor=color
   end
   flush(finish);q.Parent=saved
  end
  if n%60==0 then task.wait()end
 end
 -- Underlying ground, exposed contours and raised walks use the same fields/contrasting path color.
 for _,q in island.Terrain:GetDescendants()do if q:IsA('BasePart')then
  local name=q.Name
  if name:find('Trail')or name:find('Walkway')or name=='HillStep'or q:GetAttribute('PaletteRole')=='Path'then
   q.Color=palette[d.Path];q.Material=Enum.Material.SmoothPlastic
   if q:IsA('UnionOperation')then q.UsePartColor=true end
  elseif name=='IslandSurface'or name:find('HillContour')or name=='WoodlandKnoll'or name=='KnollStuds'or name=='IceShelf'or name=='RidgeLedge'then
   q.Color=field(q.Position.X-origin.X,q.Position.Z-origin.Z,q.Position.Y)
   if q:IsA('UnionOperation')then q.UsePartColor=true end
  end
 end end
 local function protected(x,z,r)
  local slot=island.LandingPad.ShipClearances.ShipClearance1
  local localPoint=slot.CFrame:PointToObjectSpace(V(origin.X+x,slot.Position.Y,origin.Z+z))
  if math.abs(localPoint.X)<slot.Size.X*.5+r+3 and math.abs(localPoint.Z)<slot.Size.Z*.5+r+3 then return true end
  for _,zone in island.EggSpawnZones:GetChildren()do
   if (V(zone.Position.X,0,zone.Position.Z)-V(origin.X+x,0,origin.Z+z)).Magnitude<r+11 then return true end
  end
  return false
 end
 local walks={}
 for _,q in island.Terrain:GetDescendants()do if q:IsA('BasePart')and(q.Name:find('Trail')or q.Name:find('Walkway')or q.Name=='HillStep')then table.insert(walks,q)end end
 local walkRay=RaycastParams.new();walkRay.FilterType=Enum.RaycastFilterType.Include;walkRay.FilterDescendantsInstances=walks
 local function site(cx,cz,r)
  for n=0,100 do
   local a=n*2.399;local shift=n==0 and 0 or 4+n*.16
   local x,z=cx+math.cos(a)*shift,cz+math.sin(a)*shift
   if protected(x,z,r)or z> -29 then continue end
   local y=ground(x,z);if not y then continue end
   local supported=true
   for _,dx in {-r,r}do for _,dz in {-r,r}do
    local h=ground(x+dx,z+dz);if not h or math.abs(h-y)>.12 then supported=false end
   end end
   if supported then for dx=-r,r,4 do for dz=-r,r,4 do
    if workspace:Raycast(V(origin.X+x+dx,y+15,origin.Z+z+dz),V(0,-25,0),walkRay)then supported=false;break end
   end;if not supported then break end end end
   if not supported then continue end
   local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={island.Props}
   local hits=workspace:GetPartBoundsInBox(CF(origin.X+x,y+7,origin.Z+z),V(r*2,14,r*2),overlap)
   local removable={};local blocked=false
   for _,hit in hits do
    local m=hit
    while m.Parent and m.Parent~=island.Props.ArrivalLandscape and m.Parent~=island.Props.ArrivalPlanting and m.Parent~=island.Props do m=m.Parent end
    if m:IsA('Model')and(m.Parent==island.Props.ArrivalLandscape or m.Parent==island.Props.ArrivalPlanting)then removable[m]=true
    else blocked=true;break end
   end
   if not blocked then
    for m in removable do m.Parent=saved end
    return CF(origin.X+x,y,origin.Z+z),x,z
   end
  end
 end
 local features=0
 -- A broad biome-specific scene provides real height differences and a local landmark.
 local at=site(-58,-119,15)or site(78,-116,15)or site(45,-49,15)
 if at then
  local scene=Instance.new('Model');scene.Name=d.Feature;scene.Parent=art
  if id=='ScrapBelt'or id=='IceGraveyard'then
   local water=p(terrainArt,id=='ScrapBelt'and 'StillPond'or 'FrozenPool',V(20,.2,13),at*CF(0,.12,0),palette[d.Water],true,false)
   water.Material=id=='ScrapBelt'and Enum.Material.SmoothPlastic or Enum.Material.Ice;water.Transparency=.12
   -- Asymmetric stepped banks read as a shallow bowl, rather than concentric target rings.
   for _,b in {{-11,0,3,1,15},{10,2,4,1.5,11},{-3,-8,15,1,3},{3,7,13,.5,2}}do
    local q=p(terrainArt,'PondBank',V(b[3],b[4],b[5]),at*CF(b[1],b[4]*.5,b[2]),palette[d.Fields[2]],true,true);q:SetAttribute('EggGround',true)
   end
   for j=1,5 do
    local q=p(scene,id=='ScrapBelt'and 'ReedStem'or 'IceBlade',V(.5,2+j%3,.5),at*CF(-10+j*1.4,(2+j%3)*.5,5.7),palette[d.Accent],false,true)
    if id=='IceGraveyard'then q.Size=V(1.5,3+j%3,1.5);q.CFrame=at*CF(7-j*2,(3+j%3)*.5,-6)end
   end
  elseif id=='AncientRuins'then
   local floor=p(terrainArt,'OldCourtFloor',V(22,.35,16),at*CF(0,.175,0),palette[d.Stone],true,true);floor:SetAttribute('EggGround',true)
   for j=1,4 do
    local height=j==2 and 5 or 1.5+j*.5
    p(scene,'CourtyardWall',V(4,height,2),at*CF(-9+j*4.2,height*.5,-7),palette[3],true,true)
    p(scene,'OvergrownStone',V(2,.4,2),at*CF(-9+j*4.2,height+.2,-7),palette[2],false,true)
   end
   for j=1,3 do local height=j*.5;local q=p(terrainArt,'CourtSteps',V(9,height,2),at*CF(5,height*.5,6-j*2),palette[3],true,true);q:SetAttribute('EggGround',true)end
  else
   for level=1,4 do
    local q=p(terrainArt,'SteppedBiomeRidge',V(22-level*3,.5,11-level),at*CF(level*.7,level*.5-.25,level*.5)*CFrame.Angles(0,-.28,0),palette[d.Fields[math.min(level,#d.Fields)]],true,true)
    q:SetAttribute('EggGround',true)
   end
   for j=1,4 do
    local height=3+j*1.2
    local support=ground(at.X-origin.X-7+j*3,at.Z-origin.Z)
    local baseY=support and support-at.Y or 0
    if id=='NebulaCurrent'then
     p(scene,'SporeColumn',V(1,height,1),at*CF(-7+j*3,height*.5+baseY,0),palette[d.Stone],true,true)
     p(scene,'BroadSporeCap',V(3+j*.4,.7,3),at*CF(-7+j*3,height+baseY,0),palette[d.Accent],false,true)
    elseif id=='SingularityEdge'then
     p(scene,'RiftCrystal',V(1.5,height,1.5),at*CF(-7+j*3,height*.5+baseY,0)*CFrame.Angles(0,j*.7,0),palette[2],true,true)
    else
     p(scene,'ScrapFin',V(.6,height,5),at*CF(-7+j*3,height*.5+baseY,0)*CFrame.Angles(0,0,(j-2)*.08),palette[d.Stone],true,true)
    end
   end
  end
  features+=1
 end
 -- A second companion monument varies in silhouette and sits away from the hero/egg pockets.
 local companionAt=site(69,-49,9)
 if companionAt then
  local scene=Instance.new('Model');scene.Name=d.Companion;scene.Parent=art
  local at=companionAt
  if id=='ScrapBelt'then
   p(scene,'ForkedTrunk',V(2.5,10,2.5),at*CF(0,5,0),palette[d.Stone],true,true)
   for _,side in {-1,1}do
    p(scene,'Branch',V(1.4,5,1.4),at*CF(side*2,9,0)*CFrame.Angles(0,0,-side*.6),palette[d.Stone],true,true)
    p(scene,'BroadCrown',V(7,4,6),at*CF(side*3,13,0),palette[side==1 and 2 or 3],false,true)
   end
  elseif id=='AncientRuins'then
   for _,side in {-1,1}do
    p(scene,'OldPillar',V(2.5,7,3),at*CF(side*4,3.5,0),palette[3],true,true)
    p(scene,'PillarMoss',V(3,.6,3),at*CF(side*4,7.3,0),palette[2],false,true)
   end
   p(scene,'BrokenLintel',V(7,1.5,3),at*CF(-1,8,0),palette[3],true,true)
   local rune=p(scene,'Rune',V(.7,1.1,.15),at*CF(-1,8,-1.6),palette[4],false,false);rune.Material=Enum.Material.Neon
  elseif id=='NebulaCurrent'then
   for _,b in {{-3,9,7},{3,14,8}}do
    p(scene,'GiantStem',V(1.4,b[2],1.4),at*CF(b[1],b[2]*.5,0),palette[d.Stone],true,true)
    p(scene,'SplitMushroomCap',V(b[3],1.6,6),at*CF(b[1],b[2],0)*CFrame.Angles(0,b[1]*.2,0),palette[d.Accent],false,true)
   end
  elseif id=='IceGraveyard'then
   for _,side in {-1,1}do p(scene,'IceProng',V(2,11+side*2,3),at*CF(side*3,(11+side*2)*.5,0)*CFrame.Angles(0,.3*side,0),palette[side==1 and 3 or 4],true,true)end
   p(scene,'IceCrossbar',V(9,1,2),at*CF(0,5,0),palette[2],false,true)
  else
   p(scene,'EquipmentBase',V(6,1,6),at*CF(0,.5,0),palette[d.Stone],true,true)
   p(scene,'EquipmentMast',V(1.5,9,1.5),at*CF(0,5,0),palette[d.Stone],true,true)
   p(scene,'Receiver',V(9,1.5,5),at*CF(0,10,0)*CFrame.Angles(0,0,.2),palette[d.Accent],false,true)
   local core=p(scene,'Core',V(1.5,1.5,1.5),at*CF(0,8,-1.2),palette[d.Accent],false,false);core.Material=Enum.Material.Neon;core:SetAttribute('IslandPulse',true);core:SetAttribute('PulsePhase',worldIndex)
  end
  features+=1
 end
 -- Different small silhouettes replace a subset of existing trees/mushrooms/rock clusters.
 local varied=0
 local candidates=island.Props.ArrivalLandscape:GetChildren()
 for n,old in candidates do if old:IsA('Model')and table.find({'BlockTree','BlockMushroom','CrystalCluster','BoulderPile'},old.Name)and n%3==0 then
  local cf,size=old:GetBoundingBox();local bottom=cf.Position.Y-size.Y*.5
  local w=math.min(size.X,size.Z)*.65;local h=size.Y
  local at=CF(cf.Position.X,bottom,cf.Position.Z)
  local m=Instance.new('Model');m.Name='BiomeSilhouette'..(n%2+1)
  if old.Name=='BlockTree'then
   p(m,'TreeTrunk',V(w*.18,h*.62,w*.18),at*CF(0,h*.31,0),palette[d.Stone],true,true)
   if n%2==0 then
    for level=1,3 do local width=w*(1.1-level*.2)
     p(m,'PineTier',V(width,h*.18,width),at*CF(0,h*(.49+level*.14),0),palette[level%2==0 and d.Fields[1]or d.Fields[2]],false,true)
    end
   else
    for _,side in {-1,1}do p(m,'TwinCrown',V(w*.65,h*.28,w*.6),at*CF(side*w*.2,h*(side==1 and .78 or .66),0),palette[side==1 and d.Fields[2]or d.Fields[1]],false,true)end
   end
  elseif old.Name=='BlockMushroom'then
   for _,side in {-1,1}do
    local height=h*(side==1 and .8 or .53)
    p(m,'TwinStem',V(w*.16,height,w*.16),at*CF(side*w*.2,height*.5,0),palette[d.Stone],true,true)
    p(m,'WideCap',V(w*.7,h*.12,w*.7),at*CF(side*w*.2,height,0),palette[d.Accent],false,true)
   end
  else
   for j=1,3 do local height=h*(.4+j*.17)
    p(m,'SplitOutcrop',V(w*.32,height,w*.4),at*CF((j-2)*w*.25,height*.5,0)*CFrame.Angles(0,j*.7,0),palette[j%2==0 and d.Accent or d.Stone],true,true)
   end
  end
  m.Parent=island.Props.ArrivalLandscape;old.Parent=saved;varied+=1
 end end
 -- A few hovering stone fragments and motes, not a continuous glowing island outline.
 for n,point in {{-139,-45},{110,-112},{-42,-150}}do
  local y=ground(point[1],point[2]);if not y then continue end
  local m=Instance.new('Model');m.Name='OrbitingStoneCluster';m.Parent=art
  for j=1,3 do
   local q=p(m,'Mote',V(1+j*.45,.8+j*.3,1+j*.45),CF(origin.X+point[1]+math.cos(j*2.4)*2,y+5+j*1.4,origin.Z+point[2]+math.sin(j*2.4)*2),palette[d.Stone],false,true)
   q:SetAttribute('MoteIndex',j)
  end
  m:SetAttribute('IslandMotion','Shimmer');m:SetAttribute('MotionRadius',2);m:SetAttribute('MotionPhase',n*1.8);m:SetAttribute('RestPivot',m:GetPivot())
  local base=p(art,'CosmicSprout',V(.8,1.5,.8),CF(origin.X+point[1],y+.75,origin.Z+point[2]),palette[d.Accent],false,true)
  local tip=p(art,'CosmicTip',V(.5,.5,.5),base.CFrame*CF(0,1,0),palette[d.Accent],false,false);tip.Material=Enum.Material.Neon
  local dust=Instance.new('ParticleEmitter');dust.Name='SoftCosmicDust';dust.Texture='rbxasset://textures/particles/smoke_main.dds'
  dust.Color=ColorSequence.new(palette[d.Accent]);dust.Rate=1;dust.Lifetime=NumberRange.new(2,3);dust.Speed=NumberRange.new(.15,.4)
  dust.Size=NumberSequence.new({NumberSequenceKeypoint.new(0,.08),NumberSequenceKeypoint.new(.5,.3),NumberSequenceKeypoint.new(1,0)})
  dust.Transparency=NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(.3,.6),NumberSequenceKeypoint.new(1,1)})
  dust.LightEmission=.25;dust.SpreadAngle=Vector2.new(20,20);dust.Parent=tip
 end
 island:SetAttribute('BiomeArtDirected',true)
 table.insert(results,{Id=id,PaintedRuns=painted,CompanionScenes=features,SilhouetteVariants=varied})
 task.wait()
end
return results

end
directBiomeArt()
local function refinePropVariety()
-- Scenery-only refinement. Does not write terrain, landing geometry, egg zones, home or gameplay scripts.
local V,CF=Vector3.new,CFrame.new
local selectedIds={'ScrapBelt','DerelictField','IceGraveyard','NebulaCurrent','AncientRuins','SingularityEdge'}
local pilot=false
local definitions={
 ScrapBelt={Names={'BroadOak','LayeredPine','CrookedTree','ForkedSapling','LeafyShrub','LogAndStump'},Areas={'Pine Copse','Broadleaf Grove','Meadow Edge'},Dominants={{2,3,6},{1,4,5},{5,4,6}},Stem=6,Leaf=3,Light=1,Accent=2},
 DerelictField={Names={'WreckRibs','CargoStack','BuriedTank','FoldedPanel','SplitEngine','RubbleHeap'},Areas={'Cargo Yard','Rib Wreckage','Scrap Shore'},Dominants={{2,3,6},{1,5,4},{4,6,3}},Stem=5,Leaf=3,Light=1,Accent=4},
 IceGraveyard={Names={'SplitSpire','LeaningShard','CrystalFan','IceShelfChunk','SnowBoulders','FrostSprouts'},Areas={'Blade Grove','Fan Field','Snowbank'},Dominants={{1,2,6},{3,4,1},{5,6,4}},Stem=1,Leaf=3,Light=4,Accent=2},
 NebulaCurrent={Names={'UmbrellaCap','ForkedFungus','LayeredMushroom','CrookedFungus','PuffballPatch','SporeFan'},Areas={'Umbrella Thicket','Spore Forest','Sprout Beds'},Dominants={{1,2,5},{3,4,6},{5,6,2}},Stem=1,Leaf=2,Light=4,Accent=3},
 AncientRuins={Names={'BrokenColumn','LeaningColumn','JaggedWall','HalfArch','MossyMasonry','RootedTree'},Areas={'Column Walk','Collapsed Walls','Overgrown Approach'},Dominants={{1,2,5},{3,4,1},{5,6,2}},Stem=5,Leaf=1,Light=3,Accent=2},
 SingularityEdge={Names={'TwinPrisms','PrismFan','CoilPylon','BrokenReceiver','RockSpear','FragmentNest'},Areas={'Crystal Comb','Receiver Outcrop','Rift Shore'},Dominants={{1,2,5},{3,4,1},{5,6,2}},Stem=1,Leaf=2,Light=3,Accent=5},
}
local archive=game.ServerStorage:FindFirstChild('StarfallBeforePropVariety')or Instance.new('Folder')
archive.Name='StarfallBeforePropVariety';archive.Parent=game.ServerStorage
local kits=game.ServerStorage:FindFirstChild('StarfallSceneryKit')or Instance.new('Folder')
kits.Name='StarfallSceneryKit';kits.Parent=game.ServerStorage
local results={}
local function noise(x,z,seed)return(math.sin(x*12.9898+z*78.233+seed*17.71)*43758.5453)%1 end
local function bounds(m)
 local min,max=V(math.huge,math.huge,math.huge),V(-math.huge,-math.huge,-math.huge)
 for _,q in m:GetDescendants()do if q:IsA('BasePart')then
  local c,s=q.CFrame,q.Size*.5
  local e=V(math.abs(c.RightVector.X)*s.X+math.abs(c.UpVector.X)*s.Y+math.abs(c.LookVector.X)*s.Z,math.abs(c.RightVector.Y)*s.X+math.abs(c.UpVector.Y)*s.Y+math.abs(c.LookVector.Y)*s.Z,math.abs(c.RightVector.Z)*s.X+math.abs(c.UpVector.Z)*s.Y+math.abs(c.LookVector.Z)*s.Z)
  min=min:Min(q.Position-e);max=max:Max(q.Position+e)
 end end
 return min,max
end
for _,id in selectedIds do
 local index=({ScrapBelt=1,DerelictField=2,IceGraveyard=3,NebulaCurrent=4,AncientRuins=5,SingularityEdge=6})[id]
 local island=workspace.StarfallMap.PlanetIslands[id];assert(not island:GetAttribute('SceneryVaried'),'Scenery already refined: '..id)
 local d=definitions[id];local colors={};for h in island:GetAttribute('PaletteHex'):gmatch('[^,]+')do table.insert(colors,Color3.fromHex(h))end
 local origin=V(island.LandingPad.ArrivalAnchor.Position.X,island:GetAttribute('SurfaceY'),island.LandingPad.ArrivalAnchor.Position.Z+78)
 local saved=archive:FindFirstChild(id)or Instance.new('Folder');saved.Name=id;saved.Parent=archive
 local kit=kits:FindFirstChild(id)or Instance.new('Folder');kit.Name=id;kit.Parent=kits
 local function part(m,name,size,at,color,solid,studs,class)
  local p=Instance.new(class or 'Part');p.Name=name;p.Size=size;p.CFrame=at;p.Color=colors[color]
  p.Anchored=true;p.CanCollide=solid==true;p.CanTouch=false;p.CanQuery=true;p.Material=Enum.Material.Plastic
  p.TopSurface=studs and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=m;return p
 end
 local function beam(m,name,a,b,w,color)
  return part(m,name,V(w,(b-a).Magnitude,w),CF((a+b)*.5,b)*CFrame.Angles(math.pi*.5,0,0),color,true,false)
 end
 -- Six compact models per world; structural variety is built into the kit.
 for variant,name in d.Names do if not kit:FindFirstChild(name)then
  local m=Instance.new('Model');m.Name=name
  local function p(name,size,at,color,solid,studs,class)return part(m,name,size,at,color,solid,studs,class)end
  local stem,leaf,light,accent=d.Stem,d.Leaf,d.Light,d.Accent
  if id=='ScrapBelt'then
   if variant==1 then
    p('Trunk',V(1,6,1),CF(0,3,0),stem,true,false)
    p('BroadCrown',V(6,3.3,4.8),CF(0,6.4,0),leaf,false,false)
    p('CrownLobe',V(3.8,1.9,3.6),CF(.7,8.6,0),light,false,true)
   elseif variant==2 then
    p('Trunk',V(.8,9,.8),CF(0,4.5,0),stem,true,false)
    for j=1,3 do local w=7-j*1.4;p('PineTier',V(w,1.6,w),CF(0,4.6+j*1.5,0),j%2==0 and leaf or accent,false,j==3)end
   elseif variant==3 then
    beam(m,'LowerTrunk',V(0,0,0),V(.7,4,0),.9,stem);beam(m,'CrookedTrunk',V(.7,4,0),V(-.9,7,0),.8,stem)
    beam(m,'SideBranch',V(.6,4,0),V(2,6,0),.55,stem)
    p('LeaningCrown',V(4.2,2.5,3.7),CF(-.9,7.8,0),leaf,false,false)
    p('SideCrown',V(2.4,2.4,2.5),CF(2,6.6,0),light,false,true)
   elseif variant==4 then
    p('Trunk',V(.65,5,.65),CF(0,2.5,0),stem,true,false)
    for _,side in {-1,1}do beam(m,'Fork',V(0,4,0),V(side*1.6,6,0),.5,stem);p('ForkCrown',V(2.8,2.5,2.8),CF(side*1.6,6.9,0),side==1 and leaf or light,false,false)end
   elseif variant==5 then
    p('ShrubLobe',V(2.7,2.4,2.5),CF(-1,1.2,0),leaf,false,false)
    p('ShrubLobe',V(2.6,2.8,2.5),CF(1,1.4,0),accent,false,false)
    p('ShrubTop',V(2.3,1.4,2.2),CF(0,2.7,0),light,false,true)
   else
    p('FallenLog',V(6.8,1.6,1.8),CF(0,.8,0),stem,true,true)
    for _,side in {-1,1}do p('CutEnd',V(.12,1.35,1.55),CF(side*3.44,.8,0),light,false,false)end
    p('Stump',V(1.8,2.3,1.8),CF(-2,1.15,2),stem,true,false)
    p('StumpMoss',V(1.9,.3,1.9),CF(-2,2.45,2),leaf,false,true)
   end
  elseif id=='DerelictField'then
   if variant==1 then
    p('WreckFoot',V(6,.6,4),CF(0,.3,0),stem,true,true)
    for j=1,3 do local h=4+j*.8;p('BrokenRib',V(.5,h,3.5),CF((j-2)*2,h*.5+.6,0)*CFrame.Angles(0,0,(j-2)*.1),j==2 and light or leaf,true,false)end
   elseif variant==2 then
    p('LowerCrate',V(3.5,3,3.5),CF(-.7,1.5,0),leaf,true,true)
    p('UpperCrate',V(2.7,2.5,2.7),CF(-.3,4.25,0)*CFrame.Angles(0,.2,0),light,true,true)
    p('SideCrate',V(2,2,2),CF(2.2,1,1),accent,true,false)
   elseif variant==3 then
    p('TankFoot',V(4,.5,4),CF(0,.25,0),stem,true,false)
    local q=p('Tank',V(4.8,3.4,3.4),CF(0,2.8,0)*CFrame.Angles(0,0,math.pi*.5),leaf,true,false);q.Shape=Enum.PartType.Cylinder
    p('TankCap',V(3.5,.5,3.5),CF(0,5.45,0),light,false,true)
    p('Valve',V(.5,1.2,.5),CF(0,6.3,0),stem,false,false)
   elseif variant==4 then
    p('PanelFoot',V(4,.5,3),CF(0,.25,0),stem,true,false)
    p('BentPanel',V(3.6,3,.4),CF(-.8,1.7,0)*CFrame.Angles(0,0,.28),leaf,true,true)
    p('FoldedPanel',V(2.8,.4,2),CF(.9,2.7,.7)*CFrame.Angles(0,0,-.25),light,true,false)
   elseif variant==5 then
    for _,side in {-1,1}do local q=p('EngineHalf',V(2.5,2.4,2.4),CF(side*1.8,1.2,0),leaf,true,false);q.Shape=Enum.PartType.Cylinder;p('EngineSocket',V(.15,1.6,1.6),CF(side*3.1,1.2,0),stem,false,false)end
    p('BrokenPipe',V(1,.5,4),CF(0,.25,1.4),light,false,true)
   else
    for j=1,3 do p('Rubble',V(2+j*.3,1+j*.4,2),CF((j-2)*1.4,(1+j*.4)*.5,math.sin(j)),j==2 and light or accent,true,j==1)end
   end
  elseif id=='IceGraveyard'then
   if variant==1 or variant==2 then
    p('IceFoot',V(4,.7,3),CF(0,.35,0),light,true,false)
    if variant==1 then
     p('TallProng',V(1.5,8,2),CF(-1,4.7,0),leaf,true,false,'WedgePart');p('BrokenProng',V(1.7,5,2.4),CF(1.1,3.2,0),accent,true,false,'WedgePart')
    else p('LeaningIce',V(1.8,7,2.2),CF(.5,4.1,0)*CFrame.Angles(0,0,.24),leaf,true,false);p('IceTip',V(2,1.5,2.2),CF(1.35,7.3,0),light,false,false,'WedgePart')end
   elseif variant==3 then
    p('FanFoot',V(4.5,.7,3.5),CF(0,.35,0),accent,true,true)
    for j=1,3 do local h=3+j;p('FanBlade',V(.9,h,2.1),CF((j-2)*1.4,h*.5+.7,0)*CFrame.Angles(0,j*.7,0),j==2 and leaf or light,true,false,'WedgePart')end
   elseif variant==4 then
    p('ShelfBase',V(5.5,1.2,4.2),CF(0,.6,0),leaf,true,false)
    p('SplitShelf',V(3.8,.8,3.4),CF(-.6,1.6,0),light,true,true)
    p('ShelfRidge',V(1.2,2.4,2.8),CF(-1.7,3.2,0),accent,true,false,'WedgePart')
   elseif variant==5 then
    for j=1,3 do p('SnowBlock',V(2.5,1.5+j*.35,2.4),CF((j-2)*1.5,(1.5+j*.35)*.5,math.sin(j)),light,true,j==3)end
   else
    for j=1,4 do local h=1+j*.35;p('FrostSprout',V(.65,h,.9),CF(math.cos(j*2.4)*1.4,h*.5,math.sin(j*2.4)*1.4),j%2==0 and accent or light,false,j==2,'WedgePart')end
   end
  elseif id=='NebulaCurrent'then
   if variant<=4 then
    if variant==2 then
     for _,side in {-1,1}do local h=side==1 and 6.5 or 4.5;p('TwinStem',V(.65,h,.65),CF(side*1.3,h*.5,0),stem,true,false);p('TwinCap',V(3.1,.9,3.1),CF(side*1.3,h,0),side==1 and light or accent,false,true)end
    elseif variant==4 then
     beam(m,'CrookedStem',V(0,0,0),V(1.5,6,0),.8,stem);p('SlantedCap',V(4.4,1.3,3.8),CF(1.5,6.5,0)*CFrame.Angles(0,0,.18),leaf,false,false)
    else
     local h=variant==3 and 8 or 5;p('Stem',V(.8,h,.8),CF(0,h*.5,0),stem,true,false)
     p('WideCap',V(5.7,1.1,4.6),CF(0,h,0),leaf,false,false)
     p('CapCrown',V(3.8,.7,3.5),CF(.4,h+.9,0),light,false,true)
     if variant==3 then p('LowerCap',V(3.6,.8,3.4),CF(0,4.5,0),accent,false,false)end
    end
   elseif variant==5 then
    for j=1,3 do local q=p('Puffball',V(2.1,2.1,2.1),CF((j-2)*1.5,1.05,math.sin(j)),j==2 and accent or light,false,false);q.Shape=Enum.PartType.Ball end
   else
    for j=1,4 do local h=1+j*.6;p('SporeStem',V(.3,h,.3),CF((j-2.5)*.9,h*.5,0),stem,false,false);p('SporeFrond',V(1.1,.4,2),CF((j-2.5)*.9,h,0)*CFrame.Angles(0,j*.4,0),j%2==0 and leaf or accent,false,j==1)end
   end
  elseif id=='AncientRuins'then
   if variant==1 then
    p('ColumnFoot',V(3.4,.7,3.4),CF(0,.35,0),accent,true,true)
    p('ColumnShaft',V(1.8,6,1.8),CF(0,3.7,0),light,true,false)
    p('BrokenCapital',V(3,1.2,2.7),CF(.3,7.3,0)*CFrame.Angles(0,.2,0),light,true,true)
   elseif variant==2 then
    p('ColumnFoot',V(3.4,.6,3.4),CF(0,.3,0),accent,true,false)
    beam(m,'LeaningShaft',V(0,.6,0),V(1.7,6,0),1.5,light)
    p('BrokenCapital',V(2.4,1.4,2.4),CF(1.7,6.3,0),light,false,true)
   elseif variant==3 then
    for j=1,3 do local h=({4.8,2.7,6.2})[j];p('WallBlock',V(2.1,h,1.8),CF((j-2)*2,h*.5,0),j==2 and accent or light,true,j==2)end
    p('WallMoss',V(2.2,.3,1.9),CF(0,2.85,0),leaf,false,false)
   elseif variant==4 then
    p('IntactPost',V(1.8,6,2.4),CF(-2,3,0),light,true,false);p('BrokenPost',V(1.8,3.4,2.4),CF(2,1.7,0),light,true,false)
    p('HalfLintel',V(4,1.1,2.5),CF(-1,6.55,0),accent,true,true)
   elseif variant==5 then
    for j=1,3 do local h=1+j*.5;p('Masonry',V(2.4,h,2.2),CF((j-2)*1.6,h*.5,math.sin(j)),light,true,j==2)end
    p('Moss',V(2.5,.3,2.3),CF(0,2.15,math.sin(2)),leaf,false,false)
   else
    beam(m,'RootedTrunk',V(0,0,0),V(.8,5,0),1,stem)
    for _,side in {-1,1}do p('TealCrown',V(2.7,2.4,3),CF(side*1.1,5.6,0),side==1 and leaf or accent,false,false)end
   end
  else
   if variant==1 or variant==2 then
    p('CrystalFoot',V(4,.6,3),CF(0,.3,0),light,true,variant==2)
    for j=1,variant==1 and 2 or 3 do local h=3+j*1.7;p('Prism',V(1.1,h,1.5),CF((j-1.5)*1.5,h*.5+.6,0)*CFrame.Angles(0,j*.5,0),j==2 and accent or leaf,true,false,'WedgePart')end
   elseif variant==3 then
    p('PylonFoot',V(3.5,.7,3.5),CF(0,.35,0),light,true,true);p('PylonMast',V(.9,7,.9),CF(0,4.2,0),stem,true,false)
    for j=1,3 do p('CoilFin',V(4,.4,1.5),CF(0,2+j*1.5,0)*CFrame.Angles(0,j*.7,0),leaf,false,false)end
    p('Core',V(1,1,1),CF(0,7.9,0),accent,false,false)
   elseif variant==4 then
    p('ReceiverFoot',V(4,.6,4),CF(0,.3,0),light,true,false);beam(m,'BentMast',V(0,.6,0),V(1.3,4.5,0),.8,stem)
    p('BrokenDish',V(4.4,.9,3.2),CF(1.3,4.7,0)*CFrame.Angles(0,0,.3),leaf,false,true)
   elseif variant==5 then
    p('Outcrop',V(3,2.5,2.7),CF(0,1.25,0),light,true,false)
    p('RockSpear',V(1.4,6.5,1.6),CF(.3,4,0)*CFrame.Angles(0,.3,.14),leaf,true,false)
   else
    for j=1,4 do p('Fragment',V(1.4,1+j*.35,1.5),CF(math.cos(j*2.4)*1.6,(1+j*.35)*.5,math.sin(j*2.4)*1.6),j%2==0 and accent or light,true,j==1)end
   end
  end
  m:SetAttribute('PropKitVariant',variant);m:SetAttribute('VariantName',name);m.WorldPivot=CF(0,0,0);m.Parent=kit
 end end
 local output=island.Props:FindFirstChild('PropVariety')or Instance.new('Model');output.Name='PropVariety';output.Parent=island.Props
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={island.Terrain}
 local walks={};for _,q in island.Terrain:GetDescendants()do if q:IsA('BasePart')and(q.Name:find('Trail')or q.Name:find('Walkway')or q.Name=='HillStep'or q:GetAttribute('PaletteRole')=='Path')then table.insert(walks,q)end end
 local walkRay=RaycastParams.new();walkRay.FilterType=Enum.RaycastFilterType.Include;walkRay.FilterDescendantsInstances=walks
 local hero=island.Props:FindFirstChild(island:GetAttribute('WorldLandmark'));assert(hero,'Missing focal landmark')
 local heroCF,heroSize=hero:GetBoundingBox();local heroXZ=V(heroCF.X,0,heroCF.Z);local eyeXZ=V(origin.X,0,origin.Z-78)
 local function corridor(x,z)
  local point=V(x,0,z);local delta=heroXZ-eyeXZ;local t=math.clamp((point-eyeXZ):Dot(delta)/delta:Dot(delta),0,1)
  return(point-(eyeXZ+delta*t)).Magnitude
 end
 local function ground(x,z)
  local h=workspace:Raycast(V(x,origin.Y+75,z),V(0,-125,0),ray)
  return h and h.Normal.Y>.99 and h.Instance:GetAttribute('EggGround')and h.Position.Y or nil
 end
 local function region(x,z)
  if z-origin.Z< -28 then return 3 end
  return x-origin.X<0 and 1 or 2
 end
 local function clear(x,z,r)
  local slot=island.LandingPad.ShipClearances.ShipClearance1;local q=slot.CFrame:PointToObjectSpace(V(x,slot.Position.Y,z))
  if math.abs(q.X)<slot.Size.X*.5+r+2 and math.abs(q.Z)<slot.Size.Z*.5+r+2 then return end
  if corridor(x,z)<r+10 then return end
  if(V(x,0,z)-heroXZ).Magnitude<math.max(heroSize.X,heroSize.Z)*.5+r+4 then return end
  for _,zone in island.EggSpawnZones:GetChildren()do if(V(x,0,z)-V(zone.Position.X,0,zone.Position.Z)).Magnitude<r+10 then return end end
  local y=ground(x,z);if not y then return end
  for _,dx in {-r,0,r}do for _,dz in {-r,0,r}do local h=ground(x+dx,z+dz);if not h or math.abs(h-y)>.11 then return end end end
  for dx=-r,r,2 do for dz=-r,r,2 do if workspace:Raycast(V(x+dx,y+15,z+dz),V(0,-25,0),walkRay)then return end end end
  local overlaps=OverlapParams.new();overlaps.FilterType=Enum.RaycastFilterType.Include;overlaps.FilterDescendantsInstances={island.Props}
  if #workspace:GetPartBoundsInBox(CF(x,y+6,z),V(r*2,12,r*2),overlaps)>0 then return end
  return y
 end
 local candidates={}
 for _,m in island.Props:GetDescendants()do if m:IsA('Model')and table.find({'BlockTree','BlockMushroom','CrystalCluster','BoulderPile','BiomeSilhouette1','BiomeSilhouette2'},m.Name)and(not pilot or m.Parent.Name=='SceneryGrove1')then table.insert(candidates,m)end end
 table.sort(candidates,function(a,b)local ac=a:GetPivot().Position;local bc=b:GetPivot().Position;return ac.X==bc.X and ac.Z<bc.Z or ac.X<bc.X end)
 local replaced,cleared,shifted=0,0,0
 for n,old in candidates do
  local lo,hi=bounds(old);local center=(lo+hi)*.5;local x,z=center.X,center.Z
  if corridor(x,z)<10 then old:SetAttribute('OriginalParent',old.Parent:GetFullName());old.Parent=saved;cleared+=1;continue end
  local hash=noise(x-origin.X,z-origin.Z,index)
  if pilot or hash<.72 then
   local area=region(x,z);local weights=d.Dominants[area]
   local selection=noise(x-origin.X,z-origin.Z,index+4);local variant=selection<.68 and weights[1]or selection<.9 and weights[2]or weights[3]
   if pilot then variant=n%5==0 and 6 or n%3==0 and 3 or 2 end
   local m=kit[d.Names[variant]]:Clone();m.Name=d.Names[variant]
   local scale=.8+noise(x,z,index+8)*.28;m:ScaleTo(scale)
   local yaw=noise(x,z,index+12)*math.pi*2;m:PivotTo(CF(x,0,z)*CFrame.Angles(0,yaw,0))
   local a,b=bounds(m);local radius=math.max(math.abs(a.X-x),math.abs(b.X-x),math.abs(a.Z-z),math.abs(b.Z-z))+.35
   local cap=math.min(5.8,math.max(2.7,math.max(hi.X-lo.X,hi.Z-lo.Z)*.5*1.35))
   if radius>cap then m:ScaleTo(m:GetScale()*cap/radius);a,b=bounds(m);radius=cap end
   local originalParent=old.Parent;old:SetAttribute('OriginalParent',originalParent:GetFullName());old.Parent=saved
   local centers={V(origin.X-98,0,origin.Z+26),V(origin.X+88,0,origin.Z+70),V(origin.X-48,0,origin.Z-108)}
   local pull=(centers[area]-V(x,0,z))*.06;if pull.Magnitude>4 then pull=pull.Unit*4 end
   local options={V(x+pull.X,0,z+pull.Z),V(x+math.sin(n)*1.7,0,z+math.cos(n)*1.7),V(x,0,z)}
   local placed=false
   for _,point in options do
    local y=clear(point.X,point.Z,radius)
    if y then
     m:PivotTo(CF(point.X,0,point.Z)*CFrame.Angles(0,yaw,0));local min=bounds(m);m:PivotTo(m:GetPivot()+V(0,y-min.Y,0))
     m:SetAttribute('Area',d.Areas[area]);m:SetAttribute('OriginalSceneryPosition',V(x,lo.Y,z));m.Parent=output
     replaced+=1;if(V(point.X,0,point.Z)-V(x,0,z)).Magnitude>.2 then shifted+=1 end;placed=true;break
    end
   end
   if not placed then old.Parent=originalParent;m:Destroy()end
  end
  if n%25==0 then task.wait()end
 end
 if not pilot then island:SetAttribute('SceneryVaried',true);island:SetAttribute('SceneryAreas',table.concat(d.Areas,' / '))end
 local counts={};for _,m in output:GetChildren()do counts[m.Name]=(counts[m.Name]or 0)+1 end
 table.insert(results,{Id=id,Replaced=replaced,ViewCorridorCleared=cleared,Regrouped=shifted,Variants=counts,Pilot=pilot})
 task.wait()
end
return results

end
refinePropVariety()
local function buildDiscoveryScenes()
-- Eighteen local discovery scenes. Additive local relief; original terrain and gameplay remain intact.
local selectedIds={'ScrapBelt','DerelictField','IceGraveyard','NebulaCurrent','AncientRuins','SingularityEdge'}
local selectedScenes={1,2,3}
local V,C=Vector3.new,CFrame.new
local function relief(p,top,seed,mid,accent)
 local front=top==6 and -5 or top==4 and -7 or -12
 for level=1,top/2 do
  local zmin=level==1 and -12 or level==2 and -7 or -5
  local zmax=level==1 and 12 or level==2 and 10 or 9
  for z=zmin,zmax-1 do
   local half=level==1 and (math.abs(z)>8 and 10 or math.abs(z)>4 and 12 or 14)or level==2 and 11 or 10
   local shift=level==1 and ((math.floor((z+12)/4)+seed)%3-1)or 0
   local left,right=-half+shift,half+shift
   local function row(a,b)if b>a then p('ReliefShelf',V(b-a,2,1),(a+b)/2,level*2-1,z+.5,mid,nil,true,level==1)end end
   if z<front then row(left,-7);row(-1,right)else row(left,right)end
  end
 end
 for j=1,top do p('WalkableStep',V(6,j,1.3),-4,j/2,front-.65-(top-j)*1.3,accent,nil,true,true)end
end
local function finishing(m,p,id,s,top,dark,mid,light,accent)
 local function a(n,size,x,y,z,c)return p(n,size,x,top+y,z,c,nil,false,false)end
 if id=='DerelictField'then
  if s==1 then
   for _,x in {-3.8,3.8}do for _,z in {1,5}do a('EngineRib',V(3.8,.55,.55),x,4.8,z,dark)end;a('ServicePanel',V(2,.5,2),x,6.05,3,accent)end
  elseif s==2 then
   for _,x in {-6,6}do for j=1,2 do a('CargoStrap',V(.5,3.05,4.1),x,1.5+(j-1)*3,2+(j-1)*.3,dark);a('CrateLatch',V(1,.6,.15),x+1,1.5+(j-1)*3,-.08+(j-1)*.3,accent)end end
  else for j=1,3 do a('ToolPeg',V(.3,1,.3),j-2,3.4,5.7,dark)end end
 elseif id=='AncientRuins'then
  if s==3 then for _,x in {-6,6}do for _,offset in {-.55,.55}do a('StatueEye',V(.35,.45,.15),x+offset,6.1,2.79,dark)end;a('StatueBelt',V(2.4,.45,2.1),x,2.2,4,accent)end
  elseif s==1 then for j=1,3 do a('WeatheredRune',V(.6,.25,.12),-6,3+j,2.44,dark)end
  else for j=1,3 do a('WallMoss',V(.15,.7,1.3),7.44,1+j*.3,j*2-1,mid)end end
 elseif id=='NebulaCurrent'and s==1 then
  for _,v in {V(-6,12,4),V(5,10,6),V(7,7,-1)}do for _,x in {-2,2}do a('CapSpot',V(.65,.15,.65),v.X+x,v.Y+.78,v.Z,light)end end
 elseif id=='IceGraveyard'and s==3 then
  a('CabWindow',V(2.4,1.8,.15),-1,3.8,1.02,light)
 elseif id=='SingularityEdge'then
  if s==2 then for j=1,3 do a('GeneratorVent',V(.2,1,.15),j*.55-1.1,1, .42,light)end end
  if s==1 or s==3 then
   local fx=Instance.new('Model');fx.Name='ElectricalArc';fx:SetAttribute('IslandMotion','Sparks');fx:SetAttribute('MotionRadius',0);fx:SetAttribute('MotionPhase',s)
   local points={V(-2,top+5,3),V(-.6,top+5.7,3),V(.2,top+4.9,3),V(2,top+5.4,3)}
   for j=1,3 do local aa,bb=points[j],points[j+1];local q=p('ArcSegment',V(.09,(bb-aa).Magnitude,.09),0,0,0,accent,nil,false);q.CFrame=C((aa+bb)/2,bb)*CFrame.Angles(math.pi/2,0,0);q.Material=Enum.Material.Neon;q.Transparency=1;q:SetAttribute('MoteIndex',1);q.Parent=fx end
   fx.WorldPivot=C(0,top+5,3);fx.Parent=m
  end
 end
end
local defs={
 ScrapBelt={names={'Tangled Grove','Sheltered Pond Garden','Luminous Meadow'},colors={6,3,1,2}},
 DerelictField={names={'Split Drive Wreck','Cargo Passage','Abandoned Repair Camp'},colors={5,3,1,4}},
 IceGraveyard={names={'Fractured Pool','Leaning Ice Passage','Frozen Excavator'},colors={1,3,4,2}},
 NebulaCurrent={names={'Mushroom Canopy','Puffball Hollow','Spore Shelf Garden'},colors={1,2,4,3}},
 AncientRuins={names={'Collapsed Gateway','Sunken Garden Court','Forgotten Sentinels'},colors={5,1,3,2}},
 SingularityEdge={names={'Broken Antenna Array','Crystal Generator','Suspended Fractures'},colors={1,2,3,5}},
}
local backup=game.ServerStorage:FindFirstChild('StarfallBeforeDiscoveryScenes')or Instance.new('Folder');backup.Name='StarfallBeforeDiscoveryScenes';backup.Parent=game.ServerStorage
local results={}
for _,id in selectedIds do
 local island=workspace.StarfallMap.PlanetIslands[id];local d=defs[id]
 local origin=V(island.LandingPad.ArrivalAnchor.Position.X,island:GetAttribute('SurfaceY'),island.LandingPad.ArrivalAnchor.Position.Z+78)
 local pal={}for h in island:GetAttribute('PaletteHex'):gmatch('[^,]+')do table.insert(pal,Color3.fromHex(h))end
 local saved=backup:FindFirstChild(id)
 if not saved then saved=island.Props:Clone();saved.Name=id;saved.Parent=backup end
 local root=island.Props:FindFirstChild('DiscoveryScenes')or Instance.new('Model');root.Name='DiscoveryScenes';root.Parent=island.Props
 local allowed={GroundCluster=true,ShoreCluster=true,BlockTree=true,BlockMushroom=true,BoulderPile=true,CrystalCluster=true,BiomeSilhouette1=true,BiomeSilhouette2=true}
 for _,m in game.ServerStorage.StarfallSceneryKit[id]:GetChildren()do allowed[m.Name]=true end
 local function replaceable(p)
  if p:IsA('BasePart')and table.find({'PlantStem','PlantCrown','GroundStone','ShoreStone','FlowerHead','FlowerStem'},p.Name)then return p end
  while p and p~=island.Props do if p:IsA('Model')and allowed[p.Name]then return p end;p=p.Parent end
 end
 local tr=RaycastParams.new();tr.FilterType=Enum.RaycastFilterType.Include;tr.FilterDescendantsInstances={island.Terrain}
 local paths={}for _,p in island.Terrain:GetDescendants()do if p:IsA('BasePart')and(p.Name:find('Trail')or p.Name:find('Walkway')or p.Name=='HillStep'or p:GetAttribute('PaletteRole')=='Path')then table.insert(paths,p)end end
 local pr=RaycastParams.new();pr.FilterType=Enum.RaycastFilterType.Include;pr.FilterDescendantsInstances=paths
 local op=OverlapParams.new();op.FilterType=Enum.RaycastFilterType.Include;op.FilterDescendantsInstances={island.Props}
 local hero=island.Props:FindFirstChild(island:GetAttribute('WorldLandmark'));local hc,hs=hero:GetBoundingBox()
 local function height(x,z)local h=workspace:Raycast(V(x,origin.Y+70,z),V(0,-110,0),tr);return h and h.Normal.Y>.99 and h.Instance:GetAttribute('EggGround')and h.Position.Y end
 local function site(x,z)
  local y=height(x,z);if not y then return end
  local flat=V(x,0,z);local eye=V(origin.X,0,origin.Z-78);local delta=V(hc.X,0,hc.Z)-eye;local t=math.clamp((flat-eye):Dot(delta)/delta:Dot(delta),0,1)
  if(flat-eye-delta*t).Magnitude<27 or(flat-V(hc.X,0,hc.Z)).Magnitude<math.max(hs.X,hs.Z)*.5+24 then return end
  local slot=island.LandingPad.ShipClearances.ShipClearance1
  if math.abs(x-slot.Position.X)<slot.Size.X/2+19 and math.abs(z-slot.Position.Z)<slot.Size.Z/2+19 then return end
  for _,zone in island.EggSpawnZones:GetChildren()do if(flat-V(zone.Position.X,0,zone.Position.Z)).Magnitude<29 then return end end
  for _,m in root:GetChildren()do if(flat-V(m:GetPivot().X,0,m:GetPivot().Z)).Magnitude<48 then return end end
  for dx=-16,16,4 do for dz=-16,16,4 do
   local h=height(x+dx,z+dz);if not h or math.abs(h-y)>.12 then return end
   if workspace:Raycast(V(x+dx,y+20,z+dz),V(0,-24,0),pr)then return end
  end end
  local remove={}
  for _,p in workspace:GetPartBoundsInBox(C(x,y+10,z),V(35,22,35),op)do local m=replaceable(p);if not m then return end;remove[m]=true end
  return y,remove
 end
 for _,s in selectedScenes do
  local name=d.names[s];if root:FindFirstChild(name)then continue end
  local targets={V(-92,0,-80),V(94,0,18),V(-94,0,83)}
  local options={}for dx=-60,60,8 do for dz=-60,60,8 do local q=targets[s]+V(dx,0,dz);table.insert(options,{q=q,score=dx*dx+dz*dz})end end
  table.sort(options,function(a,b)return a.score==b.score and(a.q.X==b.q.X and a.q.Z<b.q.Z or a.q.X<b.q.X)or a.score<b.score end)
  local center,remove
  for n,o in options do local y,r=site(origin.X+o.q.X,origin.Z+o.q.Z);if y then center=V(origin.X+o.q.X,y,origin.Z+o.q.Z);remove=r;break end;if n%40==0 then task.wait()end end
  assert(center,'No clear discovery site for '..id..' / '..name)
  local m=Instance.new('Model');m.Name=name
  local dark,mid,light,accent=table.unpack(d.colors)
  local function p(n,size,x,y,z,color,rot,collide,studs)
   local q=Instance.new('Part');q.Name=n;q.Anchored=true;q.Size=size;q.CFrame=C(x,y,z)*(rot or C());q.Color=pal[color];q.Material=Enum.Material.Plastic;q.CanCollide=collide~=false;q.CanTouch=false;q.TopSurface=studs and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth;q.BottomSurface=Enum.SurfaceType.Smooth;q.Parent=m;return q
  end
  local function beam(n,a,b,w,color)local q=p(n,V(w,(b-a).Magnitude,w),0,0,0,color);q.CFrame=C((a+b)/2,b)*CFrame.Angles(math.pi/2,0,0);return q end
  local levels=({ScrapBelt={4,2,6},DerelictField={2,4,6},IceGraveyard={2,6,4},NebulaCurrent={4,2,6},AncientRuins={4,2,6},SingularityEdge={2,6,4}})[id];local top=levels[s]
  -- An irregular stepped outcrop with contiguous faces and one-stud risers.
  relief(p,top,s,mid,accent)
  local function at(n,size,x,y,z,c,rot,solid,studs)return p(n,size,x,top+y,z,c,rot,solid,studs)end
  local function kit(n,x,z,scale,yaw)
   local q=game.ServerStorage.StarfallSceneryKit[id][n]:Clone();q:ScaleTo(scale or 1);q:PivotTo(C(x,0,z)*CFrame.Angles(0,yaw or 0,0));local cf,sz=q:GetBoundingBox();q:PivotTo(q:GetPivot()+V(0,top-(cf.Y-sz.Y/2),0));q.Parent=m;return q
  end
  local function lamp(q,phase)q.Material=Enum.Material.Neon;q:SetAttribute('IslandPulse',true);q:SetAttribute('PulsePhase',phase or s)end
  local function motes(kind,x,y,z)
   local fx=Instance.new('Model');fx.Name=kind;fx:SetAttribute('IslandMotion',kind);fx:SetAttribute('MotionRadius',0);fx:SetAttribute('MotionPhase',s)
   for j=1,4 do local q=at('Mote',V(.13,.13,.13),x+math.sin(j*2)*2,y+j*.3,z+math.cos(j*2)*2,accent,nil,false);q.Material=Enum.Material.Neon;q:SetAttribute('MoteIndex',j);q.Parent=fx end
   fx.WorldPivot=C(x,top+y,z);fx.Parent=m
  end
  if id=='ScrapBelt'then
   if s==1 then
    kit('CrookedTree',-6,4,1.2,.5);kit('BroadOak',6,5,1.1,-.3);kit('ForkedSapling',7,-2,.8,1)
    kit('LogAndStump',1,1,1.1,.5);kit('LeafyShrub',-7,-2,.9);kit('LeafyShrub',4,-4,.65)
    beam('ExposedRoot',V(-6,top+.4,4),V(-2,top+.3,7),.55,dark)
   elseif s==2 then
    at('PoolBed',V(11,.3,8),1,.15,2,dark);local water=at('Pond',V(10,.15,7),1,.34,2,accent,nil,false);water.Transparency=.22
    for _,v in {V(-6,0,3),V(7,0,5),V(5,0,-3)}do at('BankRock',V(2.6,1.3,2),v.X,.65,v.Z,light,CFrame.Angles(0,v.X,0))end
    kit('CrookedTree',-8,6,1.1);kit('LeafyShrub',7,6,.8);kit('ForkedSapling',-7,-3,.8)
    for j=1,3 do at('LilyLeaf',V(1,.12,1),j*2-3,.49,2+math.sin(j),mid,nil,false)end
   else
    for _,v in {V(-6,0,5),V(6,0,6),V(7,0,-1),V(-7,0,1)}do kit('LeafyShrub',v.X,v.Z,.7+(v.X+7)*.02)end
    at('FlowerStone',V(3,2,3),1,1,3,dark,nil,true,true)
    for j=1,5 do local x=math.cos(j*2.4)*3;local z=3+math.sin(j*2.4)*2;at('PlantStem',V(.25,2+j*.25,.25),x,1+j*.125,z,dark,nil,false);local q=at('GlowBud',V(.8,.45,.8),x,2+j*.25,z,light,nil,false);lamp(q,j)end
    motes('Spores',1,3,3)
   end
  elseif id=='DerelictField'then
   if s==1 then
    at('EngineCradle',V(12,1,6),0,.5,3,dark,nil,true,true)
    for _,x in {-3.8,3.8}do local q=at('DriveShell',V(5,5,5),x,3.5,3,light);q.Shape=Enum.PartType.Cylinder;at('DarkSocket',V(.15,3.5,3.5),x+(x>0 and -2.55 or 2.55),3.5,3,dark)end
    for j=1,4 do at('SpilledCoil',V(.7,.7,1.5),j-2,.35,-1-j*.6,accent,CFrame.Angles(0,j*.7,0),true,true)end
    kit('FoldedPanel',-7,5,.7);motes('Sparks',0,3,3)
   elseif s==2 then
    for _,x in {-6,6}do for j=1,2 do at('CargoCrate',V(4,3,4),x,1.5+(j-1)*3,2+(j-1)*.3,j==1 and accent or light,nil,true,true)end end
    at('OpenCrateBase',V(4,.5,3),6,.25,-4,dark);at('CargoLid',V(3,.4,3),8,1,-4,light,CFrame.Angles(0,0,.6));kit('RubbleHeap',-7,7,.6)
   else
    for _,x in {-7,7}do at('CanopyPost',V(.7,7,.7),x,3.5,5,dark)end
    at('RepairAwning',V(15,.5,5),0,7.2,5,accent,CFrame.Angles(0,0,.035),false,true)
    at('Workbench',V(8,2.8,2.5),0,1.4,5,light,nil,true,true);kit('BuriedTank',7,0,.65)
    at('BrokenMotor',V(2,1.5,2),-1,3.55,5,dark);at('Tool',V(1.8,.2,.4),2,2.9,5,accent,nil,false);lamp(at('WorkLamp',V(.5,.5,.5),-6,6,5,light,nil,false))
   end
  elseif id=='IceGraveyard'then
   if s==1 then
    at('FrozenBed',V(15,.3,10),0,.15,2,dark)
    at('IceSheetLeft',V(6.8,.35,9.5),-4,.48,2,light);at('IceSheetRight',V(6.8,.35,9.5),4,.48,2,light)
    at('CrackBranch',V(.3,.05,6),-1,.68,3,accent,CFrame.Angles(0,.7,0),false)
    kit('SnowBoulders',-8,7,.7);kit('FrostSprouts',8,-2,.9)
   elseif s==2 then
    for _,x in {-6,6}do beam('LeaningIce',V(x,top,2),V(x*.7,top+10,3),2.5,accent);at('IceCrown',V(3,1.5,3),x*.7,10,3,light,nil,false)end
    kit('CrystalFan',-7,7,.8);kit('SnowBoulders',7,-3,.8)
   else
    at('FrozenMachineTrack',V(8,1.4,5),0,.7,3,dark,nil,true,true);at('MachineCab',V(4,4,3.8),-1,3.4,3,accent)
    beam('ExcavatorArm',V(1,top+4,3),V(6,top+6,3),.8,dark);at('BuriedBucket',V(2.5,2,2.5),6,5,3,dark)
    local ice=at('IceEncasement',V(10,7.5,7),0,3.75,3,light,nil,true);ice.Material=Enum.Material.Glass;ice.Transparency=.5
    kit('SplitSpire',-8,5,.7);kit('FrostSprouts',6,-3,.9)
   end
  elseif id=='NebulaCurrent'then
   if s==1 then
    for _,v in {V(-6,12,4),V(5,10,6),V(7,7,-1)}do at('CanopyStem',V(1,v.Y,1),v.X,v.Y/2,v.Z,dark);at('CanopyCap',V(7,1.4,6),v.X,v.Y,v.Z,accent,nil,false,true);at('CapCrown',V(4,.6,3.5),v.X,v.Y+1,v.Z,light,nil,false)end
    kit('PuffballPatch',-6,-2,.8);motes('Spores',0,4,3)
   elseif s==2 then
    for _,v in {V(-6,0,5),V(4,0,6),V(7,0,0),V(-7,0,-2)}do kit('PuffballPatch',v.X,v.Z,.75+(v.X+7)*.02)end
    at('HollowRock',V(4,3,4),0,1.5,4,dark);local sprouts=kit('SporeFan',0,4,.9);sprouts:PivotTo(sprouts:GetPivot()+V(0,3,0))
   else
    at('FungusRock',V(5,7,4),0,3.5,4,dark,nil,true,true)
    for j=1,4 do at('ShelfFungus',V(4,.7,3),j%2==0 and 2.5 or -2.5,j*1.5,3,accent,nil,false);at('ShelfLip',V(3,.2,2.6),j%2==0 and 2.5 or -2.5,j*1.5+.45,3,light,nil,false)end
    kit('ForkedFungus',-7,6,.8);kit('SporeFan',6,-1,.9);motes('Spores',0,5,3)
   end
  elseif id=='AncientRuins'then
   if s==1 then
    at('GatewayPost',V(2.5,9,3),-6,4.5,4,light,nil,true,true);at('BrokenPost',V(2.5,4,3),6,2,4,light)
    at('RemainingLintel',V(7,1.4,3),-3.5,9.7,4,accent);at('FallenLintel',V(6,1.4,3),3,.7,0,light,CFrame.Angles(0,.35,0),true,true)
    kit('MossyMasonry',-7,-2,.7)
   elseif s==2 then
    for _,x in {-8,8}do at('GardenWall',V(1,3,12),x,1.5,2,light,nil,true,true)end
    at('BrokenRearWall',V(9,2,1),-3,1,8,light);at('GardenBed',V(7,.4,6),0,.2,3,dark)
    kit('RootedTree',-5,6,.8);kit('MossyMasonry',6,5,.8)
    for j=1,4 do at('CourtyardFlower',V(.8,.5,.8),j*1.4-3,.65,3+math.sin(j),4,nil,false)end
   else
    for _,x in {-6,6}do at('StatuePlinth',V(4,1,4),x,.5,4,accent,nil,true,true);at('StatueBody',V(2.3,4,2),x,3,4,light);at('StatueHead',V(2.6,2,2.3),x,6,4,light);if x<0 then at('RemainingArm',V(1,3,1),x-1.6,3.5,4,light)else at('FallenHeadFragment',V(1.4,1,1.3),x-2,.5,1,light)end end
    at('CrackedMonument',V(2,5,2),0,2.5,6,dark);lamp(at('OldRune',V(.7,1.5,.12),0,3,4.94,accent,nil,false));kit('MossyMasonry',-5,-2,.7)
   end
  else
   if s==1 then
    for j=1,3 do local x=(j-2)*6;local h=({7,10,5})[j];beam('BentAntenna',V(x,top,4),V(x+1,top+h,4),.65,dark);at('ReceiverBar',V(4,.6,1),x+1,h,4,light,CFrame.Angles(0,0,j*.15),false);at('ReceiverFoot',V(3,.6,3),x,.3,4,light,nil,true,true)end
    at('FallenDish',V(4,.8,3),4,.4,-2,accent);motes('Sparks',0,6,4)
   elseif s==2 then
    at('GeneratorBase',V(7,2,5),0,1,3,dark,nil,true,true);at('GeneratorCore',V(3,3,3),0,3.5,3,light)
    kit('TwinPrisms',-5,3,1);kit('PrismFan',6,5,.8);kit('FragmentNest',5,-2,.7)
    lamp(at('ChargeWindow',V(2,1,.15),0,3,1.42,accent,nil,false))
   else
    at('FractureStone',V(5,3,4),0,1.5,3,dark,nil,true,true)
    local fx=Instance.new('Model');fx.Name='FloatingFragments';fx:SetAttribute('IslandMotion','Breathe');fx:SetAttribute('MotionRadius',0);fx:SetAttribute('MotionPhase',s)
    for j=1,3 do local q=at('SuspendedStone',V(2.1,1.8,2),math.cos(j*2)*3.3,5+j,3+math.sin(j*2)*2.5,light,CFrame.Angles(.2,j,.25),false,true);q.Parent=fx end
    fx.WorldPivot=C(0,top+7,3);fx.Parent=m;kit('PrismFan',-7,4,.8);motes('Sparks',0,5,3)
   end
  end
  finishing(m,p,id,s,top,dark,mid,light,accent)
  -- Keep all motion cosmetic and use the existing distance-capped client animator.
  m.WorldPivot=C();m:PivotTo(C(center));m:SetAttribute('DiscoveryScene',true);m:SetAttribute('ReliefHeight',top);m:SetAttribute('SceneIndex',s)
  for _,fx in m:GetDescendants()do if fx:IsA('Model')and fx:GetAttribute('IslandMotion')then fx:SetAttribute('RestPivot',fx:GetPivot());for _,q in fx:GetDescendants()do if q:IsA('BasePart')then q.CanCollide=false;q.CanTouch=false;q.CanQuery=false end end end end
  local replaced=0;for old in remove do old:Destroy();replaced+=1 end
  m.Parent=root;table.insert(results,{Id=id,Scene=name,Position=tostring(center),Height=top,Replaced=replaced,Parts=#m:GetDescendants()});task.wait()
 end
end
return results

end
buildDiscoveryScenes()
local resourceBackup = Instance.new('Folder')
resourceBackup.Name = 'PreviousStarfallScripts'
resourceBackup.Parent = game.ServerStorage
for _,old in game.ReplicatedStorage:GetChildren() do
 if old.Name == 'StarfallMap' then old.Parent = resourceBackup end
end
for _,old in game.StarterPlayer.StarterPlayerScripts:GetChildren() do
 if old.Name == 'StarfallMapClient' or old.Name == 'StarfallHomeAmbience' or old.Name == 'StarfallIslandLife' then old.Parent = resourceBackup end
end
local shared = Instance.new('Folder')
shared.Name = 'StarfallMap'
shared.Parent = game.ReplicatedStorage
local catalog = Instance.new('ModuleScript')
catalog.Name = 'SectorCatalog'
catalog.Source = [====[local C=Color3.fromRGB
local sectors={
 {Id='ScrapBelt',Name='Sprout Moon',Short='SPROUT MOON',Distance='0.4 AU',Risk='LOW',Theme='Leaf-patterned eggs · meadow family',Description='Emerald meadows and forest-green trees rise above deep green cliffs.',Color=C(91,186,111),MapPosition=Vector2.new(.15,.46),Status='AVAILABLE'},
 {Id='IceGraveyard',Name='Frost Cove',Short='FROST COVE',Distance='1.8 AU',Risk='MODERATE',Theme='Ice-tipped eggs · frost family',Description='Aqua ice, pale blue shelves and soft blossom details surround crystal formations.',Color=C(83,216,251),MapPosition=Vector2.new(.27,.17),Status='AVAILABLE'},
 {Id='DerelictField',Name='Rust Crater',Short='RUST CRATER',Distance='3.2 AU',Risk='MODERATE',Theme='Armored eggs · rust family',Description='Ash and taupe ground, charcoal rocks and pale lavender salvage accents.',Color=C(168,155,157),MapPosition=Vector2.new(.61,.14),Status='AVAILABLE'},
 {Id='NebulaCurrent',Name='Violet Wilds',Short='VIOLET WILDS',Distance='6.7 AU',Risk='HIGH',Theme='Antenna-patterned eggs · mushroom family',Description='Orchid and periwinkle terraces with berry mushrooms and midnight-violet cliffs.',Color=C(224,123,224),MapPosition=Vector2.new(.29,.72),Status='AVAILABLE'},
 {Id='AncientRuins',Name='Relic Grove',Short='RELIC GROVE',Distance='9.4 AU',Risk='HIGH',Theme='Rune-patterned eggs · relic family',Description='Teal terraces, mint ruins and raspberry markings above blackberry-colored cliffs.',Color=C(23,190,187),MapPosition=Vector2.new(.72,.72),Status='AVAILABLE'},
 {Id='SingularityEdge',Name='Storm Reach',Short='STORM REACH',Distance='14.2 AU',Risk='EXTREME',Theme='Storm-striped eggs · storm family',Description='Aqua ridges, cream cliffs and bright yellow and pink storm equipment.',Color=C(0,145,173),MapPosition=Vector2.new(.86,.43),Status='AVAILABLE'},
}
return sectors
]====]
catalog.Parent = shared
local ui = Instance.new('ModuleScript')
ui.Name = 'MapUI'
ui.Source = [====[local sectors=require(script.Parent.SectorCatalog)
local UI={}
local C=Color3.fromRGB
local bg=C(24,16,40)
local panel=C(44,30,64)
local muted=C(171,148,193)
local white=C(239,231,255)
local cyan=C(91,231,255)
local function make(class,parent,name,props)
 local o=Instance.new(class);o.Name=name
 for k,v in props or {} do o[k]=v end
 o.Parent=parent;return o
end
local function frame(parent,name,color)
 return make('Frame',parent,name,{BackgroundColor3=color or panel,BorderSizePixel=0})
end
local function corner(o,r) local c=o:FindFirstChildOfClass('UICorner') or make('UICorner',o,'Corner',{});c.CornerRadius=UDim.new(0,r or 12) end
local function stroke(o,c,t)
 return make('UIStroke',o,'Outline',{Color=c,Thickness=t or 1,Transparency=.35,ApplyStrokeMode=Enum.ApplyStrokeMode.Border})
end
local function label(parent,name,value,size,color,bold)
 return make('TextLabel',parent,name,{Text=value,Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham,TextSize=size,TextColor3=color or white,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true})
end
local function rect(o,x,y,w,h) o.Position=UDim2.fromOffset(x,y);o.Size=UDim2.fromOffset(w,h) end
local function button(parent,name,value,color)
 local b=make('TextButton',parent,name,{Text=value,TextColor3=white,TextSize=14,Font=Enum.Font.FredokaOne,BorderSizePixel=0,BackgroundColor3=color or panel,AutoButtonColor=true});corner(b,9);return b
end
function UI.Build(parent)
 local old=parent:FindFirstChild('StarfallMapGui');if old then old:Destroy() end
 local gui=make('ScreenGui',parent,'StarfallMapGui',{ResetOnSpawn=false,IgnoreGuiInset=false,DisplayOrder=20,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
 local open=button(gui,'OpenChart','M  /  STAR CHART',panel);open.AnchorPoint=Vector2.new(0,1);open.Position=UDim2.new(0,20,1,-24);open.Size=UDim2.fromOffset(190,46);stroke(open,C(255,203,66),2)
 local window=frame(gui,'Window',bg);window.Position=UDim2.fromScale(.035,.045);window.Size=UDim2.fromScale(.93,.91);corner(window,18);stroke(window,C(66,94,128))
 local heading=label(window,'Heading','STAR CHART',26,C(255,207,81),true);heading.Font=Enum.Font.FredokaOne
 local subtitle=label(window,'Subtitle','STARFALL SALVAGERS  /  NAVIGATION NETWORK',10,muted,true)
 local close=button(window,'Close','CLOSE  ×',panel)
 local chart=frame(window,'Chart',C(23,10,35));corner(chart,14);chart.ClipsDescendants=true
 local gradient=make('UIGradient',chart,'Gradient',{Color=ColorSequence.new(C(33,15,54),C(13,8,26)),Rotation=35})
 local rand=Random.new(94)
 for i=1,70 do
  local star=frame(chart,'Star',i%4==0 and C(125,150,220) or white);star.Size=UDim2.fromOffset(i%7==0 and 3 or 1,i%7==0 and 3 or 1);star.Position=UDim2.fromScale(rand:NextNumber(),rand:NextNumber());star.BackgroundTransparency=rand:NextNumber(.25,.8);corner(star,9)
 end
 local orbitFrames={}
 for i=1,2 do local orbit=frame(chart,'Orbit',panel);orbit.BackgroundTransparency=1;corner(orbit,999);stroke(orbit,C(66,83,125));table.insert(orbitFrames,orbit) end
 local center=button(chart,'Station','HUB',C(33,62,83));center.TextColor3=cyan;center.TextSize=12;center.AnchorPoint=Vector2.new(.5,.5);center.Position=UDim2.fromScale(.5,.5);center.Size=UDim2.fromOffset(48,48);corner(center,999);stroke(center,cyan,2)
 local home=label(chart,'Home','SALVAGE STATION',10,cyan,true);home.AnchorPoint=Vector2.new(.5,0);home.Position=UDim2.new(.5,0,.5,29);home.Size=UDim2.fromOffset(140,20);home.TextXAlignment=Enum.TextXAlignment.Center
 local nodes={};local routes={};local lines={}
 for i,s in sectors do
  local route=frame(chart,'Route_'..s.Id,s.Color);route.BackgroundTransparency=.65;route.AnchorPoint=Vector2.new(.5,.5);table.insert(lines,{Object=route,Position=s.MapPosition});routes[s.Id]=route
  local n=button(chart,'Sector_'..s.Id,string.format('%02d',i),s.Color:Lerp(bg,.72));n.TextColor3=s.Color;n.AnchorPoint=Vector2.new(.5,.5);n.Position=UDim2.fromScale(s.MapPosition.X,s.MapPosition.Y);n.Size=UDim2.fromOffset(42,42);corner(n,999);local outline=stroke(n,s.Color,2)
  local title=label(chart,'Label_'..s.Id,s.Short,10,s.Color,true);title.AnchorPoint=Vector2.new(.5,0);title.Position=UDim2.new(s.MapPosition.X,0,s.MapPosition.Y,25);title.Size=UDim2.fromOffset(150,20);title.TextXAlignment=Enum.TextXAlignment.Center
  local status=label(chart,'Status_'..s.Id,s.Status=='AVAILABLE' and '● CHARTED' or '◇ UNKNOWN',9,muted);status.AnchorPoint=Vector2.new(.5,0);status.Position=UDim2.new(s.MapPosition.X,0,s.MapPosition.Y,44);status.Size=UDim2.fromOffset(120,16);status.TextXAlignment=Enum.TextXAlignment.Center
  nodes[s.Id]={Button=n,Title=title,Status=status,Outline=outline,Position=s.MapPosition}
 end
 local detail=make('ScrollingFrame',window,'Details',{BackgroundColor3=panel,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=cyan,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),ScrollingDirection=Enum.ScrollingDirection.Y});corner(detail,14);stroke(detail,C(43,64,91))
 local eyebrow=label(detail,'Eyebrow','SECTOR PROFILE',10,muted,true)
 local name=label(detail,'SectorName','',26,white,true);name.Font=Enum.Font.FredokaOne
 local desc=label(detail,'Description','',14,muted)
 local stat=label(detail,'Stats','',15,cyan,true)
 local lootHeading=label(detail,'LootHeading','POSSIBLE DISCOVERIES',10,muted,true)
 local loot=label(detail,'LootTheme','',16,white,true)
 local state=label(detail,'State','',11,cyan,true)
 local note=label(detail,'Note','Select any sector to inspect its route.',11,muted)
 local accent=frame(detail,'Accent',cyan);accent.Size=UDim2.new(1,0,0,3);corner(accent,12)
 local v={Gui=gui,Window=window,Nodes=nodes,SelectedId=nil,Connections={}}
 local function bind(signal,fn) table.insert(v.Connections,signal:Connect(fn)) end
 function v:Select(id)
  local selected=nil
  for _,s in sectors do if s.Id==id then selected=s;break end end
  if not selected then return false end
  self.SelectedId=id;detail.CanvasPosition=Vector2.zero;name.Text=selected.Name;desc.Text=selected.Description;stat.Text=selected.Distance..'   /   '..selected.Risk..' RISK';stat.TextColor3=selected.Color
  loot.Text=selected.Theme;state.Text=selected.Status=='AVAILABLE' and '●  ROUTE CHARTED' or '◇  AWAITING DEEP-SPACE SURVEY';state.TextColor3=selected.Color;accent.BackgroundColor3=selected.Color
  for key,n in nodes do local active=key==id;n.Outline.Thickness=active and 3 or 1;n.Outline.Transparency=active and 0 or .4;n.Button.BackgroundColor3=active and selected.Color:Lerp(bg,.35) or sectors[tonumber(n.Button.Text)].Color:Lerp(bg,.72);routes[key].BackgroundTransparency=active and .05 or .7 end
  return true
 end
 function v:SetOpen(value) window.Visible=value;open.Visible=not value end
 function v:Layout()
  local w,h=window.AbsoluteSize.X,window.AbsoluteSize.Y
  local portrait=w<650 and h>w*.85
  rect(heading,20,14,math.max(120,w-150),34);heading.TextSize=portrait and 22 or 26
  rect(subtitle,20,49,w-40,20);rect(close,w-115,17,95,34)
  local cw,ch
  if portrait then
   cw=w-28;ch=math.max(100,(h-94)*.5);rect(chart,14,80,cw,ch);rect(detail,14,88+ch,cw,math.max(64,h-ch-102))
  else local detailWidth=math.min(304,w*.44);cw=w-detailWidth-46;ch=h-98;rect(chart,16,80,cw,ch);rect(detail,w-detailWidth-16,80,detailWidth,ch) end
  local dw,dh=detail.Size.X.Offset,detail.Size.Y.Offset
  local compact=portrait or dh<400
  rect(eyebrow,18,12,dw-36,18);rect(name,18,34,dw-36,compact and 32 or 65);name.TextSize=compact and 21 or 27
  rect(desc,18,compact and 72 or 103,dw-36,compact and 40 or 80);desc.TextSize=compact and 12 or 14
  rect(stat,18,compact and 116 or 193,dw-36,26);stat.TextSize=compact and 12 or 14
  rect(lootHeading,18,compact and 147 or 237,dw-36,18);rect(loot,18,compact and 167 or 263,dw-36,compact and 40 or 75);loot.TextSize=compact and 12 or 16
  rect(state,18,compact and 211 or 352,dw-36,24);rect(note,18,dh-42,dw-36,26);note.Visible=dh>420
  -- Short detail layouts use a compact horizontal profile, with every field retained.
  if portrait and dh<250 then
   rect(eyebrow,14,8,dw-28,14);rect(name,14,26,dw-28,28);rect(desc,14,57,dw-28,32);rect(stat,14,93,dw-28,20);rect(lootHeading,14,117,dw-28,16);rect(loot,14,136,dw-28,35);rect(state,14,174,dw-28,20)
  end
  desc.Visible=true
  if not portrait and dh<280 then
   rect(eyebrow,14,8,dw-28,14);rect(name,14,26,dw-28,28);desc.Visible=false;rect(stat,14,59,dw-28,20);rect(lootHeading,14,85,dw-28,16);rect(loot,14,105,dw-28,42);rect(state,14,155,dw-28,20)
  end
  for i,o in orbitFrames do o.AnchorPoint=Vector2.new(.5,.5);o.Position=UDim2.fromScale(.5,.5);o.Size=UDim2.fromOffset(cw*(i==1 and .44 or .89),ch*(i==1 and .42 or .8)) end
  for _,l in lines do local dx=(l.Position.X-.5)*cw;local dy=(l.Position.Y-.5)*ch;l.Object.Position=UDim2.fromOffset(cw*.5+dx*.5,ch*.5+dy*.5);l.Object.Size=UDim2.fromOffset(math.sqrt(dx*dx+dy*dy),2);l.Object.Rotation=math.deg(math.atan2(dy,dx)) end
  for _,n in nodes do
   local labelWidth=math.min(cw-6,cw<400 and 105 or 150)
   n.Title.TextSize=cw<400 and 8 or 10;n.Title.Size=UDim2.fromOffset(labelWidth,20);n.Title.Position=UDim2.fromOffset(math.clamp(n.Position.X*cw,labelWidth*.5+3,cw-labelWidth*.5-3),n.Position.Y*ch+25);n.Title.Visible=ch>=230
   n.Status.Visible=cw>=400 and ch>=280;n.Button.Size=UDim2.fromOffset(44,44)
  end
  home.Visible=ch>=170
  home.TextSize=cw<400 and 8 or 10;home.Size=UDim2.fromOffset(cw<400 and 110 or 140,20)
  open.Text=game:GetService('UserInputService').TouchEnabled and 'STAR CHART' or 'M  /  STAR CHART'
 end
 for _,s in sectors do bind(nodes[s.Id].Button.Activated,function() v:Select(s.Id) end) end
 bind(close.Activated,function() v:SetOpen(false) end);bind(open.Activated,function() v:SetOpen(true) end)
 bind(center.Activated,function() v:SetOpen(false) end)
 bind(window:GetPropertyChangedSignal('AbsoluteSize'),function() v:Layout() end)
 v:Select(sectors[1].Id);v:SetOpen(false);task.defer(function() if gui.Parent then v:Layout() end end)
 bind(gui.Destroying,function() for _,c in v.Connections do c:Disconnect() end end)
 UI.Current=v;return v
end
return UI
]====]
ui.Parent = shared
local client = Instance.new('LocalScript')
client.Name = 'StarfallMapClient'
client.Source = [====[local Players=game:GetService('Players')
local UserInputService=game:GetService('UserInputService')
local shared=game:GetService('ReplicatedStorage'):WaitForChild('StarfallMap')
local view=require(shared.MapUI).Build(Players.LocalPlayer:WaitForChild('PlayerGui'))
UserInputService.InputBegan:Connect(function(input,processed)
 if processed then return end
 if input.KeyCode==Enum.KeyCode.M then view:SetOpen(not view.Window.Visible)
 elseif input.KeyCode==Enum.KeyCode.Escape or input.KeyCode==Enum.KeyCode.ButtonB then view:SetOpen(false) end
end)
]====]
client.Parent = game.StarterPlayer.StarterPlayerScripts
local islandLifeClient = Instance.new('LocalScript')
islandLifeClient.Name = 'StarfallIslandLife'
islandLifeClient.Source = [====[-- Nearby cosmetic activity only. Never moves gameplay collision or grants items.
local RunService=game:GetService('RunService')
local islands=workspace:WaitForChild('StarfallMap'):WaitForChild('PlanetIslands')
local entries={};local lamps={};local seen={}
local function register(o)
 if seen[o]then return end
 if o:IsA('Model')and o:GetAttribute('IslandMotion')then
  seen[o]=true;local wings={};local motes={}
  for _,p in o:GetDescendants()do if p:IsA('BasePart')then
   if p:GetAttribute('WingSide')then table.insert(wings,{Part=p,Rest=p.CFrame,Side=p:GetAttribute('WingSide')})end
   if p:GetAttribute('MoteIndex')then table.insert(motes,{Part=p,Rest=p.CFrame,Index=p:GetAttribute('MoteIndex')})end
  end end
  table.insert(entries,{Model=o,Rest=o:GetAttribute('RestPivot'),Kind=o:GetAttribute('IslandMotion'),Radius=o:GetAttribute('MotionRadius'),Phase=o:GetAttribute('MotionPhase'),Wings=wings,Motes=motes})
 elseif o:IsA('BasePart')and o:GetAttribute('IslandPulse')then
  seen[o]=true;table.insert(lamps,{Part=o,Phase=o:GetAttribute('PulsePhase')})
 end
end
for _,o in islands:GetDescendants()do register(o)end
islands.DescendantAdded:Connect(register)
local accumulator=0
RunService.Heartbeat:Connect(function(dt)
 accumulator+=dt;if accumulator<.05 then return end;accumulator=0
 local camera=workspace.CurrentCamera;if not camera then return end
 local pos=camera.CFrame.Position;local time=workspace:GetServerTimeNow()
 for n=#entries,1,-1 do local e=entries[n]
  if not e.Model:IsDescendantOf(islands)then seen[e.Model]=nil;table.remove(entries,n)
  elseif (pos-e.Rest.Position).Magnitude<210 then
   local t=time+e.Phase;local at=e.Rest
   if e.Kind=='Flutter'or e.Kind=='Survey'then
    at=e.Rest*CFrame.new(math.sin(t*.55)*e.Radius,math.sin(t*1.7)*.45,math.cos(t*.55)*e.Radius)*CFrame.Angles(0,t*.55,0)
   elseif e.Kind=='Breathe'then at=e.Rest*CFrame.new(0,math.sin(t*1.5)*.12,0)*CFrame.Angles(0,0,math.sin(t*.7)*.025)
   else at=e.Rest*CFrame.Angles(0,t*.25,0)end
   e.Model:PivotTo(at)
   for _,w in e.Wings do if w.Part.Parent then
    local localRest=e.Rest:ToObjectSpace(w.Rest)
    w.Part.CFrame=at*localRest*CFrame.Angles(0,0,math.sin(t*(e.Kind=='Flutter'and 16 or 4))*.35*w.Side)
   end end
   for _,m in e.Motes do if m.Part.Parent then
    local localRest=e.Rest:ToObjectSpace(m.Rest);local cycle=(t*.28+m.Index*.19)%1
    m.Part.CFrame=at*localRest*CFrame.new(math.sin(t+m.Index)*.45,(e.Kind=='Snow'and (1-cycle)or cycle)*2,0)
    m.Part.Transparency=e.Kind=='Sparks'and ((t+m.Index*.4)%7<.5 and .1 or 1)or .15+math.abs(cycle-.5)*1.4
   end end
  end
 end
 for n=#lamps,1,-1 do local l=lamps[n]
  if not l.Part:IsDescendantOf(islands)then seen[l.Part]=nil;table.remove(lamps,n)
  elseif(pos-l.Part.Position).Magnitude<210 then l.Part.Transparency=((time+l.Phase)%3<.18)and .8 or 0 end
 end
end)
]====]
islandLifeClient.Parent = game.StarterPlayer.StarterPlayerScripts
local ambience = Instance.new('LocalScript')
ambience.Name = 'StarfallHomeAmbience'
ambience.Source = [====[-- Local home presentation: gentle motion, visitor-facing robots and quiet audio.
local RunService=game:GetService('RunService')
local Players=game:GetService('Players')
local SoundService=game:GetService('SoundService')
local ContentProvider=game:GetService('ContentProvider')
local hub=workspace:WaitForChild('StarfallMap'):WaitForChild('Hub')
local polish=hub:WaitForChild('WorldPolish')
local moving={};local eyes={};local robots={}
for _,o in hub:GetDescendants()do
 if o:IsA('Model')and(o.Name=='SwayFlag'or o.Name=='MascotPet')then
  table.insert(moving,{Model=o,Rest=o:GetPivot(),Pet=o.Name=='MascotPet',Phase=#moving*1.7})
 elseif o:IsA('BasePart')and o:GetAttribute('HomeBlink')then
  table.insert(eyes,{Part=o,Rest=o.Transparency,Phase=#eyes*.37})
 end
 if o:IsA('Model')and o:GetAttribute('TrackVisitor')then table.insert(robots,{Model=o,Rest=o:GetPivot()})end
end
local courier=hub.Parent:WaitForChild('Routes'):FindFirstChild('CourierShuttle')
local audio=Instance.new('SoundGroup');audio.Name='StarfallHomeAudio';audio.Parent=SoundService
local music=Instance.new('Sound');music.Name='HomeMusic';music.SoundId='rbxassetid://119229975910510';music.Volume=.1;music.Looped=true;music.SoundGroup=audio;music.Parent=SoundService
local engine=Instance.new('Sound');engine.Name='PublicShipIdle';engine.SoundId='rbxassetid://9119414091';engine.Volume=.045;engine.Looped=true;engine.SoundGroup=audio
engine.RollOffMode=Enum.RollOffMode.InverseTapered;engine.RollOffMinDistance=6;engine.RollOffMaxDistance=26;engine.Parent=hub.PublicArea.LaunchPad.StarterShip.Hull
for _,sound in {music,engine}do task.spawn(function()
 local ok=pcall(function()ContentProvider:PreloadAsync({sound})end)
 if ok and sound.IsLoaded and sound.Parent then sound:Play()end
end)end
local gui=Instance.new('ScreenGui');gui.Name='StarfallAudioControl';gui.ResetOnSpawn=false;gui.DisplayOrder=1;gui.Parent=Players.LocalPlayer:WaitForChild('PlayerGui')
local button=Instance.new('TextButton');button.Name='ToggleSound';button.AnchorPoint=Vector2.new(1,0);button.Position=UDim2.new(1,-16,0,64);button.Size=UDim2.fromOffset(122,48)
button.BackgroundColor3=Color3.fromRGB(42,58,70);button.BorderSizePixel=0;button.Font=Enum.Font.Arcade;button.TextSize=14;button.TextColor3=Color3.fromRGB(231,229,211);button.Text='SOUND: ON';button.Parent=gui
local border=Instance.new('UIStroke');border.Color=Color3.fromRGB(213,176,120);border.Thickness=2;border.Parent=button
local enabled=true;button.Activated:Connect(function()enabled=not enabled;audio.Volume=enabled and 1 or 0;button.Text=enabled and 'SOUND: ON'or 'SOUND: OFF'end)
local elapsed=0;local blinkTime=0
local connection
connection=RunService.RenderStepped:Connect(function(dt)
 if not polish:IsDescendantOf(workspace)then connection:Disconnect();music:Destroy();engine:Destroy();audio:Destroy();gui:Destroy();return end
 elapsed+=dt;blinkTime+=dt
 for _,m in moving do if m.Model.Parent then
  local t=elapsed+m.Phase
  if m.Pet then m.Model:PivotTo(m.Rest*CFrame.new(0,(math.sin(t*1.4)+1)*.07,0)*CFrame.Angles(0,math.sin(t*.45)*.09,0))
  else m.Model:PivotTo(m.Rest*CFrame.Angles(0,math.sin(t*1.3)*.08,math.sin(t*.7)*.025))end
 end end
 local char=Players.LocalPlayer.Character;local rootPart=char and char:FindFirstChild('HumanoidRootPart')
 for _,r in robots do if r.Model.Parent then
  local target=r.Rest
  if rootPart and (rootPart.Position-r.Rest.Position).Magnitude<18 then
   local flat=Vector3.new(rootPart.Position.X,r.Rest.Y,rootPart.Position.Z)
   if (flat-r.Rest.Position).Magnitude>1 then target=CFrame.lookAt(r.Rest.Position,flat)end
  end
  r.Model:PivotTo(r.Model:GetPivot():Lerp(target,math.min(dt*3,1)))
 end end
 if courier and courier.Parent then
  local a=elapsed*math.pi*2/75;local pos=Vector3.new(math.cos(a)*175,70+math.sin(a*2)*7,math.sin(a)*175)
  local nextPos=Vector3.new(math.cos(a+.01)*175,70+math.sin((a+.01)*2)*7,math.sin(a+.01)*175)
  courier:PivotTo(CFrame.lookAt(pos,nextPos)*CFrame.Angles(0,0,-.08))
 end
 if blinkTime>.08 then
  blinkTime=0
  for _,e in eyes do if e.Part.Parent then e.Part.Transparency=((elapsed+e.Phase)%7)<.13 and 1 or e.Rest end end
 end
end)
]====]
ambience.Parent = game.StarterPlayer.StarterPlayerScripts
for _,old in game.ServerScriptService:GetChildren() do
 if old.Name == 'StarfallPlotService' or old.Name == 'StarfallEggSpawnService' then old.Parent = resourceBackup end
end
local plotService = Instance.new('Script')
plotService.Name = 'StarfallPlotService'
plotService.Source = [====[-- Session ownership and spawns for the six home plots. No economy or pet grants.
local Players=game:GetService('Players')
local hub=workspace:WaitForChild('StarfallMap'):WaitForChild('Hub')
local plots=hub:WaitForChild('Plots')
local owned={}
local function label(plot,text)
 local t=plot.Nameplate.Surface:FindFirstChild('OwnerTitle')
 if t then t.Text=text end
end
local function sendHome(player,character)
 local plot=owned[player];if not plot then return end
 local rootPart=character:WaitForChild('HumanoidRootPart',10)
 if rootPart and owned[player]==plot and player.Character==character then
  character:PivotTo(plot.PlotSpawn.CFrame*CFrame.new(0,3,0))
 end
end
local function claim(player)
 if owned[player]then return end
 local chosen=nil
 for index=1,6 do
  local plot=plots:FindFirstChild(string.format('Plot%02d',index))
  if plot and (plot:GetAttribute('OwnerUserId')or 0)==0 then chosen=plot;break end
 end
 if chosen then
  owned[player]=chosen
  chosen:SetAttribute('OwnerUserId',player.UserId)
  chosen:SetAttribute('OwnerName',player.DisplayName)
  player:SetAttribute('StarfallPlotIndex',chosen:GetAttribute('PlotIndex'))
  player.RespawnLocation=chosen.PlotSpawn
  label(chosen,player.DisplayName..'\nPLOT '..string.format('%02d',chosen:GetAttribute('PlotIndex')))
 else
  player.RespawnLocation=hub.PublicSpawn
 end
 player.CharacterAdded:Connect(function(character)sendHome(player,character)end)
 if player.Character then task.spawn(sendHome,player,player.Character)end
end
local function release(player)
 local plot=owned[player];if not plot then return end
 owned[player]=nil;plot:SetAttribute('OwnerUserId',0);plot:SetAttribute('OwnerName',nil)
 label(plot,string.format('PLOT %02d\nAVAILABLE',plot:GetAttribute('PlotIndex')))
 for _,visitor in Players:GetPlayers()do
  if visitor~=player and not owned[visitor]then
   -- Only overflow visitors need a slot; normal player connections are already installed.
   owned[visitor]=plot;plot:SetAttribute('OwnerUserId',visitor.UserId);plot:SetAttribute('OwnerName',visitor.DisplayName)
   visitor:SetAttribute('StarfallPlotIndex',plot:GetAttribute('PlotIndex'));visitor.RespawnLocation=plot.PlotSpawn
   label(plot,visitor.DisplayName..'\nPLOT '..string.format('%02d',plot:GetAttribute('PlotIndex')))
   break
  end
 end
end
Players.PlayerAdded:Connect(claim)
Players.PlayerRemoving:Connect(release)
for _,player in Players:GetPlayers()do claim(player)end
]====]
plotService.Parent = game.ServerScriptService
local eggSpawnService = Instance.new('Script')
eggSpawnService.Name = 'StarfallEggSpawnService'
eggSpawnService.Source = [====[-- Random world positions only. Each planet uses one fixed biome egg template.
local Workspace=game:GetService('Workspace')
local Players=game:GetService('Players')
local ServerStorage=game:GetService('ServerStorage')
local islands=Workspace:WaitForChild('StarfallMap'):WaitForChild('PlanetIslands')
local templates=ServerStorage:WaitForChild('StarfallEggTemplates')
local random=Random.new()
local states={}
for _,island in islands:GetChildren()do
 local zones=island:WaitForChild('EggSpawnZones'):GetChildren()
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={island.Terrain}
 local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={island.Props}
 table.insert(states,{Island=island,Zones=zones,Folder=island.ActiveEggs,Template=templates:WaitForChild(island.Name),Ray=ray,Overlap=overlap,NextRefill=0})
end
local function activeEggs(state)
 local eggs={};local now=Workspace:GetServerTimeNow()
 for _,egg in state.Folder:GetChildren()do if egg:IsA('Model')and egg:GetAttribute('SpawnedEgg')then
  if (egg:GetAttribute('ExpiresAt')or math.huge)<=now then egg:Destroy()else table.insert(eggs,egg)end
 end end
 return eggs
end
local function surfaceAt(state,x,z,originY)
 local hit=Workspace:Raycast(Vector3.new(x,originY,z),Vector3.new(0,-96,0),state.Ray)
 if hit and hit.Normal.Y>.99 and hit.Instance:GetAttribute('EggGround')then return hit.Position end
end
local function candidate(state,existing)
 for _=1,32 do
  local zone=state.Zones[random:NextInteger(1,#state.Zones)]
  local localPoint=Vector3.new(random:NextNumber(-zone.Size.X*.5,zone.Size.X*.5),0,random:NextNumber(-zone.Size.Z*.5,zone.Size.Z*.5))
  local world=zone.CFrame:PointToWorldSpace(localPoint);local point=surfaceAt(state,world.X,world.Z,zone.Position.Y+40)
  if not point then continue end
  local landing=state.Island.LandingPad.PadSurface.Position
  if (Vector3.new(point.X,0,point.Z)-Vector3.new(landing.X,0,landing.Z)).Magnitude<21 then continue end
  local inLandingArea=false
  local clearances=state.Island.LandingPad:FindFirstChild('ShipClearances')
  if clearances then for _,area in clearances:GetChildren()do if area:IsA('BasePart')then
   local localPoint=area.CFrame:PointToObjectSpace(point)
   if math.abs(localPoint.X)<area.Size.X*.5+2.2 and math.abs(localPoint.Z)<area.Size.Z*.5+2.2 then inLandingArea=true;break end
  end end end
  if inLandingArea then continue end
  local supported=true
  for _,q in {Vector3.new(2.2,0,0),Vector3.new(-2.2,0,0),Vector3.new(0,0,2.2),Vector3.new(0,0,-2.2),Vector3.new(2.2,0,2.2),Vector3.new(-2.2,0,2.2),Vector3.new(2.2,0,-2.2),Vector3.new(-2.2,0,-2.2)}do
   local edge=surfaceAt(state,point.X+q.X,point.Z+q.Z,zone.Position.Y+40)
   if not edge or math.abs(edge.Y-point.Y)>.1 then supported=false;break end
  end
  if not supported then continue end
  if #Workspace:GetPartBoundsInBox(CFrame.new(point+Vector3.new(0,2.15,0)),Vector3.new(4.2,4.2,4.2),state.Overlap)>0 then continue end
  local clear=true
  for _,egg in existing do if (egg:GetPivot().Position-point).Magnitude<6 then clear=false;break end end
  if not clear then continue end
  for _,player in Players:GetPlayers()do
   local rootPart=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
   if rootPart and (rootPart.Position-point).Magnitude<6 then clear=false;break end
  end
  if clear then return point end
 end
end
local function fill(state,limit)
 local existing=activeEggs(state)
 local target=math.clamp(state.Island:GetAttribute('EggTargetCount')or 8,0,32)
 while #existing>target do table.remove(existing):Destroy()end
 for _=1,math.min(target-#existing,limit)do
  local point=candidate(state,existing);if not point then break end
  local egg=state.Template:Clone();egg.Name=state.Island.Name..'Egg'
  egg:SetAttribute('SpawnedEgg',true);egg:SetAttribute('SpawnPosition',point)
  egg:SetAttribute('ExpiresAt',Workspace:GetServerTimeNow()+math.max(state.Island:GetAttribute('EggLifetimeSeconds')or 180,1))
  egg:PivotTo(CFrame.new(point+Vector3.new(0,.025,0))*CFrame.Angles(0,random:NextNumber(0,math.pi*2),0))
  egg.Parent=state.Folder;table.insert(existing,egg)
 end
 state.Island:SetAttribute('ActiveEggCount',#existing)
end
for _,state in states do fill(state,32);state.NextRefill=os.clock()+math.max(state.Island:GetAttribute('EggRefillSeconds')or 6,1);task.wait()end
while islands:IsDescendantOf(Workspace)do
 task.wait(1)
 for _,state in states do if state.Island:IsDescendantOf(Workspace)and state.Island:IsDescendantOf(islands)and os.clock()>=state.NextRefill then
  fill(state,2)
  state.NextRefill=os.clock()+math.max(state.Island:GetAttribute('EggRefillSeconds')or 6,1)
 end end
end
]====]
eggSpawnService.Parent = game.ServerScriptService
game.StarterGui.ScreenOrientation = Enum.ScreenOrientation.Sensor
game.StarterPlayer.CameraMinZoomDistance = 5
game.StarterPlayer.CameraMaxZoomDistance = 96
print('Starfall Salvagers map installed. Press Play; use M or the STAR CHART button.')
