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
