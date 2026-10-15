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
