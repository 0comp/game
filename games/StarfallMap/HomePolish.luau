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
