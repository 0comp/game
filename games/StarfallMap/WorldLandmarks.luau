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
