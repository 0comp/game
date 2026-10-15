-- Contoured floating islands replacing the square terrain grid.
local V=Vector3.new;local CF=CFrame.new;local C=Color3.fromRGB
local root=workspace.StarfallMap
local order={'ScrapBelt','DerelictField','IceGraveyard','NebulaCurrent','AncientRuins','SingularityEdge'}
local hills={
 ScrapBelt={{-85,45,46,3},{75,90,48,1},{-20,124,40,2}},
 DerelictField={{-90,35,48,2},{85,55,52,3},{0,116,56,1}},
 IceGraveyard={{-95,45,52,1},{70,90,54,3},{-25,122,42,2}},
 NebulaCurrent={{-88,62,52,2},{86,52,50,1},{0,126,44,3}},
 AncientRuins={{-85,48,45,1},{80,66,48,1},{0,116,54,3}},
 SingularityEdge={{-85,50,54,3},{86,55,52,2},{-8,126,42,1}},
}
local outlines={
 ScrapBelt={{0,0,320,320},{-112,2,112,174},{115,24,102,142},{0,-91,222,154},{-18,110,190,136}},
 DerelictField={{0,0,320,300},{-120,20,132,174},{112,18,126,152},{0,-92,230,160},{-20,100,200,140}},
 IceGraveyard={{0,0,320,310},{-118,10,128,140},{120,38,120,160},{0,-92,226,160},{12,110,190,142}},
 NebulaCurrent={{0,0,310,320},{-112,5,124,172},{116,30,124,150},{0,-92,228,160},{-18,112,204,142}},
 AncientRuins={{0,0,320,310},{-110,-2,126,150},{118,22,108,144},{0,-90,226,164},{0,112,190,144}},
 SingularityEdge={{0,0,320,320},{-116,0,110,182},{120,22,120,166},{0,-90,230,160},{12,110,170,142}},
}
local bays={DerelictField={-165,35,90,85},IceGraveyard={163,0,72,76},NebulaCurrent={-166,42,78,72},AncientRuins={166,0,70,70},SingularityEdge={0,170,80,75}}
local backup=game.ServerStorage:FindFirstChild('StarfallBeforeOrganicIslands')or Instance.new('Folder')
backup.Name='StarfallBeforeOrganicIslands';backup.Parent=game.ServerStorage
local results={}
local function basePart(parent,name,size,cf,role,solid,studs)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Anchored=true
 p.CanCollide=solid==true;p.CanTouch=false;p.Material=Enum.Material.Plastic
 p.Color=C(112,183,70);p:SetAttribute('PaletteRole',role)
 p.TopSurface=studs and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
for _,id in order do
 local island=root.PlanetIslands[id];assert(not island:GetAttribute('OrganicIsland'),'Already reshaped: '..id)
 local Y=island:GetAttribute('SurfaceY');local center=island.PrimaryPart.Position
 local origin=V(center.X,Y,center.Z)
 local oldTerrain=island.Terrain;local oldProps=island.Props
 local saved=Instance.new('Folder');saved.Name=id;saved.Parent=backup
 island.EggSpawnZones:Clone().Parent=saved
 local terrain=Instance.new('Model');terrain.Name='OrganicTerrainDraft';terrain.Parent=island
 local function unionDiscs(name,shapes,top,height,role,ground)
  local parts={}
  for _,s in shapes do
   local p=basePart(terrain,'ContourSource',V(height,s[3],s[4]),CF(origin.X+s[1],top-height*.5,origin.Z+s[2])*CFrame.Angles(0,0,math.pi*.5),role,true,false)
   p.Shape=Enum.PartType.Cylinder;table.insert(parts,p)
  end
  local result
  if #parts==1 then result=parts[1]else
   local others={};for n=2,#parts do table.insert(others,parts[n])end
   result=parts[1]:UnionAsync(others,Enum.CollisionFidelity.PreciseConvexDecomposition,Enum.RenderFidelity.Precise)
   result.Parent=terrain;for _,p in parts do p:Destroy()end
  end
  local bay=bays[id]
  if bay then
   local cutter=basePart(terrain,'CoveCutter',V(height+6,bay[3],bay[4]),CF(origin.X+bay[1],top-height*.5,origin.Z+bay[2])*CFrame.Angles(0,0,math.pi*.5),role,false,false)
   cutter.Shape=Enum.PartType.Cylinder
   local cut=result:SubtractAsync({cutter},Enum.CollisionFidelity.PreciseConvexDecomposition,Enum.RenderFidelity.Precise)
   cut.Parent=terrain;result:Destroy();cutter:Destroy();result=cut
  end
  result.Name=name;result.Anchored=true;result.CanCollide=true;result.CanTouch=false
  result.Material=Enum.Material.Plastic;result:SetAttribute('PaletteRole',role)
  if result:IsA('UnionOperation')then result.UsePartColor=true end
  if ground then
   result:SetAttribute('EggGround',true)
   for _,face in {'TopSurface','BottomSurface','LeftSurface','RightSurface','FrontSurface','BackSurface'}do result[face]=Enum.SurfaceType.Studs end
  end
  task.wait();return result
 end
 local shape=outlines[id]
 local ground=unionDiscs('IslandSurface',shape,Y,1.4,'Ground',true)
 island.PrimaryPart=ground
 local function cliffLayer(scale,height,top,role,name)
  local p=ground:Clone();p.Name=name;p:SetAttribute('EggGround',nil);p:SetAttribute('PaletteRole',role)
  local texture=p:FindFirstChild('ClassicStuds');if texture then texture:Destroy()end
  local s=ground.Size;local r=ground.CFrame
  local sx=math.abs(r.RightVector.Y)>.9;local sy=math.abs(r.UpVector.Y)>.9
  p.Size=V(sx and height or s.X*scale,sy and height or s.Y*scale,(not sx and not sy)and height or s.Z*scale)
  p.CFrame=r+V(0,top-height*.5-r.Position.Y,0)
  for _,face in {'TopSurface','BottomSurface','LeftSurface','RightSurface','FrontSurface','BackSurface'}do p[face]=Enum.SurfaceType.Smooth end
  p.Parent=terrain;return p
 end
 cliffLayer(1,13,Y-1.4,'Rock','UpperCliff')
 cliffLayer(.89,12,Y-14.4,'Deep','LowerCliff')
 cliffLayer(.68,13,Y-26.4,'Rock','IslandCore')
 local moundParts={}
 for level=1,3 do
  local shapes={}
  for _,h in hills[id]do if level<=h[4]then
   local r=h[3]-(level-1)*14
   table.insert(shapes,{h[1]+(level-1)*3,h[2]+(level-1)*2,r*2,r*1.8})
  end end
  moundParts[level]=unionDiscs('HillContour'..level,shapes,Y+level*4,4,level==3 and 'High'or 'Ground',true)
 end
 -- Short access paths climb each hill from its southern shoulder.
 local stairs=Instance.new('Model');stairs.Name='HillsidePaths';stairs.Parent=terrain
 for _,h in hills[id]do for level=1,h[4]do
  local radius=(h[3]-(level-1)*14)*.9
  for n=1,7 do
   local rise=n*.5;local z=h[2]+(level-1)*2-radius-(7.5-n)*1.4
   local p=basePart(stairs,'HillStep',V(8,rise,1.4),CF(origin.X+h[1]+(level-1)*3,Y+(level-1)*4+rise*.5,origin.Z+z),'Path',true,true)
   p:SetAttribute('EggGround',true)
  end
 end end
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={terrain}
 local function floorAt(x,z)
  local hit=workspace:Raycast(V(origin.X+x,Y+65,origin.Z+z),V(0,-120,0),ray)
  if hit and hit.Normal.Y>.99 and hit.Instance:GetAttribute('EggGround')then return hit.Position.Y end
 end
 -- The central valley remains open. Trail pieces are fused into one clean surface.
 local trail={}
 for n=0,40 do local z=-32+n*2;local x=math.sin(n*.115)*13
  if math.abs((floorAt(x,z)or -1000)-Y)<.1 then table.insert(trail,{x,z,12,12})end
 end
 if #trail>0 then unionDiscs('CurvedTrail',trail,Y+.42,.4,'Path',true)end
 local props=Instance.new('Model');props.Name='OrganicPropsDraft';props.Parent=island
 local function asset(name)
  for _,p in oldProps:GetDescendants()do if p:IsA('Model')and p.Name==name then return p end end
 end
 local templates={
  ScrapBelt=asset('BlockTree'),DerelictField=asset('BoulderPile'),IceGraveyard=asset('CrystalCluster'),
  NebulaCurrent=asset('BlockMushroom'),AncientRuins=asset('BlockTree'),SingularityEdge=asset('CrystalCluster'),
 }
 local function place(template,x,z,yaw,parent)
  if not template then return end
  local p=template:Clone();local box,size=p:GetBoundingBox()
  local half=math.min(math.max(size.X,size.Z)*.55,10)
  local targetY
  for _,shift in {V(0,0,0),V(6,0,0),V(-6,0,0),V(0,0,6),V(0,0,-6)}do
   local nx,nz=x+shift.X,z+shift.Z
   if nz<-34 and math.abs(nx)<96 then continue end
   local y=floorAt(nx,nz);local flat=y~=nil
   if flat then for _,q in {V(-half,0,-half),V(half,0,-half),V(-half,0,half),V(half,0,half)}do
    local edge=floorAt(nx+q.X,nz+q.Z);if not edge or math.abs(edge-y)>.15 then flat=false;break end
   end end
   if flat then x,z,targetY=nx,nz,y;break end
  end
  if not targetY then p:Destroy();return end
  p:PivotTo(CF(origin.X+x,targetY,origin.Z+z)*CFrame.Angles(0,yaw or 0,0))
  local cf,s=p:GetBoundingBox();p:PivotTo(p:GetPivot()+V(0,targetY-(cf.Y-s.Y*.5),0))
  p.Parent=parent or props;return p
 end
 local groves={{-115,-7},{112,6},{-104,77},{92,94},{-29,139},{-43,22}}
 local placed=0
 for g,pt in groves do
  local grove=Instance.new('Model');grove.Name='SceneryGrove'..g
  for n=1,9 do local a=n*2.4+g*.7;local radius=6+math.sqrt(n)*5
   if place(templates[id],pt[1]+math.cos(a)*radius,pt[2]+math.sin(a)*radius,a,grove)then placed+=1 end
  end
  grove.Parent=props;task.wait()
 end
 -- Preserve each biome's landmark; cluster it as one complete object.
 if id=='ScrapBelt'then
  unionDiscs('NestingClearing',{{-40,-12,18,16}},Y+.42,.4,'Path',true)
  local flowers=Instance.new('Model');flowers.Name='NestingFlowers';flowers.Parent=props
  for n=1,12 do local a=n*math.pi/6;local x,z=-40+math.cos(a)*11,-12+math.sin(a)*10
   local y=floorAt(x,z)
   if y then
    basePart(flowers,'FlowerStem',V(.25,1.2,.25),CF(origin.X+x,y+.6,origin.Z+z),'Leaf',false,false)
    basePart(flowers,'FlowerHead',V(1.4,.4,1.4),CF(origin.X+x,y+1.4,origin.Z+z),'Accent',false,true)
   end
  end
 elseif id=='DerelictField'then place(asset('CrashedEngine'),85,55,.45)
 elseif id=='AncientRuins'then place(asset('RuinGate'),0,116,0)
 elseif id=='SingularityEdge'then place(asset('StormMast'),-85,50,0);place(asset('StormMast'),86,55,0)end
 local details=Instance.new('Model');details.Name='ShoreDetails';details.Parent=props
 for n=1,44 do
  local a=n*math.pi*2/44;local x=math.cos(a)*(128+8*math.sin(a*3));local z=math.sin(a)*(139+6*math.cos(a*2))
  if z>-34 or math.abs(x)>102 then
   local y=floorAt(x,z)
   if y then
    local p=basePart(details,'ShoreStone',V(2.2,1.1,2),CF(origin.X+x,y+.55,origin.Z+z)*CFrame.Angles(0,a,0),'Rock',false,true)
    if id=='ScrapBelt'or id=='NebulaCurrent'or id=='AncientRuins'then
     basePart(details,'PlantStem',V(.3,1.1,.3),CF(origin.X+x+2,y+.55,origin.Z+z),'Stem',false,false)
     basePart(details,'PlantCrown',V(1.4,.6,1.4),CF(origin.X+x+2,y+1.3,origin.Z+z),'LeafLight',false,true)
    end
   end
  end
 end
 -- Tapered underside rock points follow the perimeter rather than a square grid.
 for n=1,12 do
  local a=n*math.pi/6;local x,z=math.cos(a)*113,math.sin(a)*115
  local p=Instance.new('WedgePart');p.Name='UndersideRock';p.Size=V(20,12+n%3*3,24)
  p.CFrame=CF(origin.X+x,Y-37,origin.Z+z)*CFrame.Angles(0,-a,math.pi)
  p.Material=Enum.Material.Plastic;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p:SetAttribute('PaletteRole','Deep');p.Parent=terrain
 end
 oldTerrain.Parent=saved;oldProps.Parent=saved
 terrain.Name='Terrain';props.Name='Props'
 local zones=island.EggSpawnZones;zones:ClearAllChildren();local count=0
 for _,z in {-12,24,66,110}do for _,x in {-108,-58,0,58,108}do
  local y=floorAt(x,z)
  if y then
   count+=1;local p=basePart(zones,'OrganicZone'..count,V(18,1,18),CF(origin.X+x,y+12,origin.Z+z),'Ground',false,false)
   p.Transparency=1;p.CanQuery=false
  end
 end end
 island:SetAttribute('OrganicIsland',true);island:SetAttribute('SurfaceWidth',340);island:SetAttribute('SurfaceDepth',350)
 table.insert(results,{Id=id,Groves=6,Scenery=placed,EggZones=count,ShipCapacity=6})
 task.wait()
end
return results
