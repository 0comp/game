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
