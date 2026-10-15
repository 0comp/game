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
