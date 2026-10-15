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
