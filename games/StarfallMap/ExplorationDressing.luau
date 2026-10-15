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
