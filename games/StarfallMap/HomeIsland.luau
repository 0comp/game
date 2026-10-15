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
