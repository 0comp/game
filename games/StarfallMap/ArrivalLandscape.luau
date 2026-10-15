-- One shared surface landing anchor for future client-side ships; natural arrival landscape.
local root=workspace.StarfallMap
local V,CF=Vector3.new,CFrame.new
local order={'ScrapBelt','DerelictField','IceGraveyard','NebulaCurrent','AncientRuins','SingularityEdge'}
-- Composition is authored per destination. Each uses different routes, terrain and planting regions.
local designs={
 ScrapBelt={Name='Woodland and open flower meadow',
  Roads={{{0,-62},{-9,-42},{0,-31}},{{-28,-84},{-54,-81},{-82,-108},{-54,-139},{10,-145},{57,-121},{72,-61},{90,-15}}},
  Hills={{-67,-48,15,10,3,'Oval',-.2},{48,-94,13,9,2,'Oval',.35}},
  Groves={{-101,-66,28,40,48},{-58,-120,30,19,40},{84,-67,30,36,40},{12,-143,38,14,25}},
  Sites={{-47,-45},{67,-103},{-83,-104}},Style='Wood'},
 DerelictField={Name='Broken salvage ridges and wreck scatter',
  Roads={{{0,-62},{9,-43},{0,-31}},{{-28,-84},{-64,-93},{-80,-68},{-105,-46},{-88,-15}},{{28,-84},{65,-111},{53,-137},{-8,-145}}},
  Hills={{-62,-51,20,8,4,'Ledge',-.45},{65,-55,12,9,2,'Ledge',.3},{-48,-121,22,7,3,'Ledge',.2}},
  Groves={{-104,-90,35,39,35},{47,-139,43,15,38},{93,-48,30,30,32},{-44,-57,20,18,22}},
  Sites={{66,-122},{-60,-117},{-102,-51},{57,-49}},Style='Scrap'},
 IceGraveyard={Name='Long ice shelves and blue crystal pockets',
  Roads={{{0,-62},{-8,-45},{0,-31}},{{-28,-84},{-64,-104},{-100,-79},{-111,-38},{-88,-15}},{{28,-84},{58,-62},{94,-79},{80,-109},{43,-124},{0,-130}}},
  Hills={{-62,-49,26,10,2,'Shelf',-.18},{57,-119,25,12,3,'Shelf',.45}},
  Groves={{-95,-80,25,38,38},{69,-48,42,20,46},{-35,-137,43,17,36},{104,-100,19,30,24}},
  Sites={{-68,-121},{57,-46},{24,-132}},Style='Ice'},
 NebulaCurrent={Name='Asymmetric mushroom thickets and spore gardens',
  Roads={{{0,-62},{10,-47},{0,-31}},{{28,-84},{61,-87},{100,-55},{90,-15}},{{-28,-84},{-57,-67},{-95,-87},{-76,-125},{-14,-140},{39,-126},{61,-87}}},
  Hills={{-61,-112,17,12,3,'Oval',.65},{69,-48,11,15,4,'Oval',-.3},{14,-137,12,8,1,'Oval',.2}},
  Groves={{-95,-54,29,28,36},{-61,-115,36,25,55},{72,-109,36,31,42},{74,-41,27,17,28}},
  Sites={{-63,-49},{51,-122},{-94,-109}},Style='Spore'},
 AncientRuins={Name='Interrupted processional courts and overgrown walls',
  Roads={{{0,-62},{-3,-43},{0,-31}},{{-28,-84},{-63,-82},{-79,-55},{-88,-15}},{{28,-84},{62,-84},{75,-118},{32,-138},{-27,-134},{-63,-82}}},
  Hills={{-53,-48,12,9,1,'Court',0},{-63,-113,12,10,1,'Court',.28}},
  Groves={{-107,-63,25,40,40},{-50,-132,35,19,38},{92,-68,24,42,42},{24,-146,38,12,22}},
  Sites={{-65,-46},{58,-119},{-69,-111},{68,-43}},Style='Ruins'},
 SingularityEdge={Name='Diagonal crystal ridges and isolated machinery',
  Roads={{{0,-62},{7,-46},{0,-31}},{{-28,-84},{-54,-110},{-91,-100},{-121,-60},{-88,-15}},{{28,-84},{62,-61},{100,-70},{94,-101},{55,-120}}},
  Hills={{-67,-52,26,8,4,'Ledge',.7},{56,-125,24,7,3,'Ledge',-.55}},
  Groves={{-94,-84,30,40,42},{-25,-142,41,15,34},{79,-48,33,23,40},{92,-112,21,31,34}},
  Sites={{-62,-121},{57,-44},{87,-101}},Style='Storm'},
}
local results={}
for _,id in order do
 local island=root.PlanetIslands[id]
 assert(not island.Props:FindFirstChild('ArrivalLandscape'),'Arrival landscape already built: '..id)
 local land=island.LandingPad.PadSurface.Position
 local origin=V(land.X,island:GetAttribute('SurfaceY'),land.Z+84)
 local archive=game.ServerStorage:FindFirstChild('StarfallBeforeSharedLanding')or Instance.new('Folder')
 archive.Name='StarfallBeforeSharedLanding';archive.Parent=game.ServerStorage
 local saved=Instance.new('Folder');saved.Name=id;saved.Parent=archive
 island.LandingPad:Clone().Parent=saved
 local keep=island.LandingPad.ShipClearances:FindFirstChild('ShipClearance1')
 for _,s in island.LandingPad.ShipClearances:GetChildren()do if s~=keep then s.Parent=saved end end
 keep.CFrame=CF(origin.X,keep.Position.Y,origin.Z-84)
 island.LandingPad.PadSurface.Size=V(56,.2,44)
 island:SetAttribute('LandingMode','SharedClientShip');island:SetAttribute('SurfaceLandingSlots',1)
 local colors={};for h in island:GetAttribute('PaletteHex'):gmatch('[^,]+')do table.insert(colors,Color3.fromHex(h))end
 local ground,high,rock,accent,path=colors[1],colors[2],colors[#colors],colors[3],colors[3]
 if id=='DerelictField'then ground,high,rock,accent,path=colors[2],colors[3],colors[5],colors[1],colors[1]
 elseif id=='IceGraveyard'then ground,high,rock,accent,path=colors[2],colors[3],colors[1],colors[5],colors[4]
 elseif id=='NebulaCurrent'then ground,high,rock,accent,path=colors[3],colors[4],colors[1],colors[5],colors[4]
 elseif id=='AncientRuins'then ground,high,rock,accent,path=colors[1],colors[2],colors[5],colors[4],colors[3]
 elseif id=='SingularityEdge'then ground,high,rock,accent,path=colors[1],colors[2],colors[3],colors[5],colors[3]end
 local props=Instance.new('Model');props.Name='ArrivalLandscape';props.Parent=island.Props
 local terrain=Instance.new('Model');terrain.Name='ArrivalContours';terrain.Parent=island.Terrain
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={island.Terrain}
 local occupied={};local trees,low,mounds=0,0,0
 local design=designs[id]
 local function p(parent,name,size,at,color,solid,studs)
  local q=Instance.new('Part');q.Name=name;q.Size=size;q.CFrame=at;q.Color=color;q.Anchored=true
  q.CanCollide=solid==true;q.CanTouch=false;q.CanQuery=solid==true or id=='AncientRuins'
  q.TopSurface=studs and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth;q.BottomSurface=Enum.SurfaceType.Smooth
  q.Material=Enum.Material.Plastic;q.Parent=parent;return q
 end
 local function floor(x,z)
  local hit=workspace:Raycast(V(origin.X+x,origin.Y+40,origin.Z+z),V(0,-90,0),ray)
  return hit and hit.Normal.Y>.99 and hit.Instance:GetAttribute('EggGround')and hit.Position.Y or nil
 end
 local function flat(x,z,r)
  local y=floor(x,z);if not y then return end
  for _,q in {V(r,0,r),V(-r,0,r),V(r,0,-r),V(-r,0,-r)}do local h=floor(x+q.X,z+q.Z);if not h or math.abs(h-y)>.12 then return end end
  return y
 end
 local function shipClear(x,z,r)
  for _,s in island.LandingPad.ShipClearances:GetChildren()do
   local q=s.CFrame:PointToObjectSpace(V(origin.X+x,s.Position.Y,origin.Z+z))
   if math.abs(q.X)<s.Size.X*.5+r+2 and math.abs(q.Z)<s.Size.Z*.5+r+2 then return false end
  end
  return true
 end
 local routePoints={}
 local function curve(points)
  for n=1,#points-1 do
   local a,b,c,d=points[math.max(1,n-1)],points[n],points[n+1],points[math.min(#points,n+2)]
   for step=0,40 do
    local t=step/40;local t2,t3=t*t,t*t*t
    local q=(b*2+(c-a)*t+(a*2-b*5+c*4-d)*t2+(-a+b*3-c*3+d)*t3)*.5
    table.insert(routePoints,{q.X,q.Z})
   end
  end
 end
 for _,route in design.Roads do local points={}for _,q in route do table.insert(points,V(q[1],0,q[2]))end;curve(points)end
 local function roadDistance(x,z)
  local best=math.huge
  for _,q in routePoints do best=math.min(best,math.sqrt((q[1]-x)^2+(q[2]-z)^2))end
  return best
 end
 local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={island.Props}
 local function available(x,z,r)
  if z> -25 or not shipClear(x,z,r)or roadDistance(x,z)<r+3.5 then return end
  for _,a in occupied do if (V(x,0,z)-V(a.X,0,a.Z)).Magnitude<r+a.R+1.5 then return end end
  local y=flat(x,z,r);if not y then return end
  -- Exact support plus visual spacing around pre-existing arrival plants.
  if #workspace:GetPartBoundsInBox(CF(origin.X+x,y+5,origin.Z+z),V(r*2,10,r*2),overlap)>0 then return end
  return y
 end
 -- Small walkable contour gardens at the shore; never alter a ship's flat ground.
 for _,s in design.Hills do
  local x,z,rx,rz,levels,style,angle=table.unpack(s)
  local r=math.max(rx,rz)
  if style~='Oval'then
   r=math.max(math.abs(math.cos(angle))*rx+math.abs(math.sin(angle))*rz,math.abs(math.sin(angle))*rx+math.abs(math.cos(angle))*rz)
  end
  r+=(levels-1)*.4+.1
  local y=available(x,z,r)
  if not y then for attempt=1,60 do
   local a=attempt*2.399;local shift=3+attempt*.3
   local nx,nz=x+math.cos(a)*shift,z+math.sin(a)*shift
   local h=available(nx,nz,r)
   if h then x,z,y=nx,nz,h;break end
  end end
  -- Hills can be wider than ordinary prop footprints; their support is checked at all corners.
  if y then
   for level=1,levels do
    local sx,sz=math.max(3,rx-(level-1)*1.5),math.max(3,rz-(level-1)*1.5)
    local top=y+level*.5
    local at=CF(origin.X+x+(level-1)*.4,top-.25,origin.Z+z)*CFrame.Angles(0,angle,0)
    local color=(style=='Shelf'or style=='Court')and high or ground
    if style=='Oval'then
     local q=p(terrain,'WoodlandKnoll',V(.5,sx*2,sz*2),at*CFrame.Angles(0,0,math.pi*.5),color,true,false)
     q.Shape=Enum.PartType.Cylinder;q:SetAttribute('EggGround',true)
     for dx=-sx+1,sx-1,2 do
      local width=sz*math.sqrt(math.max(0,1-((math.abs(dx)+1)/sx)^2))*2
      if width>=2 then local skin=p(terrain,'KnollStuds',V(2,.05,math.floor(width/2)*2),at*CF(dx,.275,0),color,true,true);skin.CastShadow=false;skin:SetAttribute('EggGround',true)end
     end
    else
     local q=p(terrain,style=='Court'and 'BrokenCourt'or style=='Shelf'and 'IceShelf'or 'RidgeLedge',V(sx*2,.5,sz*2),at,color,true,true)
     q:SetAttribute('EggGround',true)
    end
   end
   mounds+=1
  end
 end
 -- One fused path surface avoids overlapping path plates at intersections.
 local routeParts={}
 for _,point in routePoints do
  local x,z=point[1],point[2]
  local y=flat(x,z,2.8)
  if not y and id~='IceGraveyard'and id~='SingularityEdge'then for inset=1,10 do
   local nx,nz=x*(1-inset*.01),z*(1-inset*.01)
   local h=flat(nx,nz,2.8)
   if h and math.abs(h-origin.Y)<.12 then x,z,y=nx,nz,h;break end
  end end
  if y and math.abs(y-origin.Y)<.12 then
   local q=p(terrain,'RouteDraft',V(.16,5.5,5.5),CF(origin.X+x,origin.Y+.08,origin.Z+z)*CFrame.Angles(0,0,math.pi*.5),path,true,false)
   q.Shape=Enum.PartType.Cylinder;q.CanCollide=false;q.CanQuery=false;table.insert(routeParts,q)
  end
 end
 local rest={}for n=2,#routeParts do table.insert(rest,routeParts[n])end
 local road=routeParts[1]:UnionAsync(rest,Enum.CollisionFidelity.PreciseConvexDecomposition)
 road.Name='ArrivalWalkways';road.CanCollide=true;road.CanQuery=true;road.UsePartColor=true;road.Color=path;road:SetAttribute('EggGround',true);road.Parent=terrain
 for _,q in routeParts do q:Destroy()end
 local roadRay=RaycastParams.new();roadRay.FilterType=Enum.RaycastFilterType.Include;roadRay.FilterDescendantsInstances={road}
 for x=-150,150,2 do
  local run=nil
  local function flush(z)
   if run then local length=z-run
    local skin=p(terrain,'WalkwayStuds',V(2,.05,length),CF(origin.X+x,origin.Y+.185,origin.Z+(run+z)*.5-1),path,true,true)
    skin.CastShadow=false;skin:SetAttribute('EggGround',true);run=nil
   end
  end
  for z=-170,-20,2 do
   local inside=true
   for _,dx in {-1,1}do for _,dz in {-1,1}do
    if not workspace:Raycast(V(origin.X+x+dx,origin.Y+2,origin.Z+z+dz),V(0,-4,0),roadRay)then inside=false end
   end end
   if inside then run=run or z else flush(z)end
  end
  flush(-18)
 end
 -- Reserve authored scene fragments before planting; worlds use different prop families.
 local scenes=0
 for n,site in design.Sites do
  local x,z,y
  local footprint=design.Style=='Ruins'and 8.6 or 7.2
  for attempt=0,60 do
   local angle=attempt*2.399;local r=attempt==0 and 0 or 4+attempt*.2
   local nx,nz=site[1]+math.cos(angle)*r,site[2]+math.sin(angle)*r
   local h=available(nx,nz,footprint)
   if h then x,z,y=nx,nz,h;break end
  end
  if y then
   local m=Instance.new('Model');m.Name=design.Style..'Scene'..n
   local at=CF(origin.X+x,y,origin.Z+z)*CFrame.Angles(0,n*1.7,0)
   if design.Style=='Wood'then
    if n%2==1 then
     for j=1,3 do local h=1+j*.65
      p(m,'OldStump',V(2.5,h,2.5),at*CF((j-2)*3,h*.5,math.sin(j)*2),rock,true,true)
      p(m,'StumpHeart',V(1.5,.12,1.5),at*CF((j-2)*3,h+.06,math.sin(j)*2),high,false,true)
     end
    else
     p(m,'FallenBranch',V(9,1.5,1.8),at*CF(0,.75,0),rock,true,true)
     for j=1,7 do local a=j*2.4;local r=2+j*.35
      p(m,'MeadowFlower',V(1.2,.35,1.2),at*CF(math.cos(a)*r,.45,math.sin(a)*r),j%2==0 and high or accent,false,true)
     end
    end
   elseif design.Style=='Scrap'then
    p(m,'WreckFrame',V(8,1,4),at*CF(0,1.3,0)*CFrame.Angles(0,0,.17),rock,true,true)
    for j=1,3 do
     p(m,'BrokenRib',V(.65,2+(j+n)%3,4.5),at*CF((j-2)*2.7,2,0)*CFrame.Angles(0,0,(j-2)*.18+n*.04),high,true,true)
    end
    p(m,'DiscardedEngine',V(2.5,2.5,3),at*CF(3,1.25,3.6),accent,true,true)
    p(m,'LooseHullPanel',V(4,.3,2.8),at*CF(-3,.7,3.2)*CFrame.Angles(.25,.4,.13),high,false,true)
   elseif design.Style=='Ice'then
    for j=1,4 do local h=2+(j*3+n)%6
     local q=p(m,'SplitIceBlade',V(1.5,h,2.5),at*CF((j-2.5)*2,h*.5,math.sin(j)*2)*CFrame.Angles(0,j*.5,0),j%2==0 and high or path,true,true)
     q.Shape=Enum.PartType.Block
    end
    p(m,'FrozenPocket',V(6,.15,4),at*CF(0,.1,-3),accent,false,false)
   elseif design.Style=='Spore'then
    for j=1,3 do local h=2+j*1.7;local a=j*2.4;local center=at*CF(math.cos(a)*3,0,math.sin(a)*3)
     p(m,'BentStem',V(.8,h,.8),center*CF(0,h*.5,0)*CFrame.Angles(0,0,.12*(j-2)),rock,true,true)
     p(m,'SplitCap',V(3+j*.5,1,2+j*.6),center*CF((j-2)*.25,h,0)*CFrame.Angles(0,j*.7,.06),j%2==0 and high or accent,false,true)
     p(m,'CapSpot',V(.8,.16,.8),center*CF((j-2)*.25,h+.6,0),ground,false,true)
    end
   elseif design.Style=='Ruins'then
    local court=p(terrain,'CourtyardFoundation',V(12,.4,12),at*CF(0,.2,0),high,true,true);court:SetAttribute('EggGround',true)
    at=at*CF(0,.4,0)
    p(m,'BuriedLintel',V(9,1.8,2.5),at*CF(0,.9,1),high,true,true)
    for j=1,3 do local h=j==n%3+1 and 4.8 or 1.4
     p(m,'BrokenWallBlock',V(2.5,h,2.5),at*CF((j-2)*3,h*.5,-1.6),path,true,true)
    end
    p(m,'FallenColumn',V(2,2,6),at*CF(2,1,6)*CFrame.Angles(0,.6,0),path,true,true)
    p(m,'MossPatch',V(3,.3,2),at*CF(-2,1.95,1),ground,false,true)
   else
    p(m,'CoilPlinth',V(5,1,5),at*CF(0,.5,0),rock,true,true)
    p(m,'CoilStem',V(1.2,5,1.2),at*CF(0,3,0),ground,true,true)
    for j=1,3 do p(m,'ChargedFin',V(4,.5,1),at*CF(0,1+j,0)*CFrame.Angles(0,j*.85,0),high,false,true)end
    local core=p(m,'EnergyCore',V(1.2,1.2,1.2),at*CF(0,6,0),accent,false,false);core.Material=Enum.Material.Neon
    core:SetAttribute('IslandPulse',true);core:SetAttribute('PulsePhase',n)
    for j=1,3 do p(m,'BrokenConduit',V(1,.7,3),at*CF((j-2)*2,.4,4)*CFrame.Angles(0,j*.4,0),rock,false,true)end
   end
   m.Parent=props;scenes+=1;table.insert(occupied,{X=x,Z=z,R=footprint})
  end
 end
 -- Irregular groves, variable size and rotation; no repeated planting grid.
 local template=island.Props.ExplorationDressing.MiddleAndBackground:GetChildren()[1]
 assert(template and template:IsA('Model'),'Missing biome scenery template')
 local function bottom(m)
  local y=math.huge
  for _,q in m:GetDescendants()do if q:IsA('BasePart')then
   local c,s=q.CFrame,q.Size
   local half=math.abs(c.RightVector.Y)*s.X*.5+math.abs(c.UpVector.Y)*s.Y*.5+math.abs(c.LookVector.Y)*s.Z*.5
   y=math.min(y,q.Position.Y-half)
  end end return y
 end
 for region,g in design.Groves do for n=1,g[5]do
  local angle=n*2.399963+region*.7;local radius=math.sqrt(n/g[5])
  local nx=g[1]+math.cos(angle)*radius*g[3];local nz=g[2]+math.sin(angle)*radius*g[4]
  local m=template:Clone();local pivot=m:GetPivot()
  m:ScaleTo(m:GetScale()*(.72+(.5+.5*math.sin(n*3.71+region))*.48))
  m:PivotTo(CF(origin.X+nx,origin.Y,origin.Z+nz)*CFrame.Angles(0,n*1.3+region,0)*pivot.Rotation)
  local _,size=m:GetBoundingBox();local radius=math.max(size.X,size.Z)*.5+.5
  local y=available(nx,nz,radius)
  if y then
   m:PivotTo(m:GetPivot()+V(0,y-bottom(m),0));m.Parent=props;trees+=1
   table.insert(occupied,{X=nx,Z=nz,R=radius})
  else m:Destroy()end
 end;task.wait()end
 for n=1,900 do
  local nx=math.sin(n*1.618)*150;local nz=-96+math.sin(n*2.719)*67;local y=available(nx,nz,1.7)
  if y then
   local m=Instance.new('Model');m.Name='ShoreCluster';local at=CF(origin.X+nx,y,origin.Z+nz)
   if id=='ScrapBelt'or id=='AncientRuins'or id=='NebulaCurrent'then
    for j=1,1+n%3 do
     local h=.7+(n+j)%4*.3;local dx=math.cos(j*2.4)*.8;local dz=math.sin(j*2.4)*.8
     p(m,'PlantStem',V(.25,h,.25),at*CF(dx,h*.5,dz),rock,false)
     p(m,'PlantCrown',V(.6+j*.2,.35,.6+j*.2),at*CF(dx,h+.2,dz),low%3==0 and accent or high,false,true)
    end
   else
    local height=.5+n%3*.25
    p(m,'ShoreStone',V(1.2+n%3*.4,height,1.4),at*CF(0,height*.5,0)*CFrame.Angles(0,n*.7,0),rock,false,true)
    local shard=p(m,'ShoreShard',V(.6,1+n%4*.35,.8),at*CF(.7,(1+n%4*.35)*.5,.3),n%2==0 and accent or high,false,false)
    shard.Shape=Enum.PartType.Block
   end
   m.Parent=props;low+=1;table.insert(occupied,{X=nx,Z=nz,R=1.7})
  end
  if n%100==0 then task.wait()end
 end
 island:SetAttribute('ArrivalLandscaped',true)
 -- Reduce cloned silhouettes in older groves too, without enlarging their reserved footprints.
 local variation=0
 local groups={island.Props.ExplorationDressing.MiddleAndBackground}
 for _,g in island.Props:GetChildren()do if g.Name:match('^SceneryGrove')then table.insert(groups,g)end end
 for _,g in groups do for _,m in g:GetChildren()do if m:IsA('Model')and not m:GetAttribute('CompositionVaried')then
  variation+=1
  local before=m:GetPivot();local groundY=bottom(m)
  m:ScaleTo(m:GetScale()*(.78+(.5+.5*math.sin(variation*2.71))*.22))
  m:PivotTo(before)
  m:PivotTo(m:GetPivot()+V(0,groundY-bottom(m),0))
  m:SetAttribute('CompositionVaried',true)
 end end end
 island:SetAttribute('CompositionTheme',design.Name)
 table.insert(results,{Id=id,Scenery=trees,GroundClusters=low,Landforms=mounds,AuthoredScenes=scenes,Theme=design.Name})
 task.wait()
end
return results





