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
