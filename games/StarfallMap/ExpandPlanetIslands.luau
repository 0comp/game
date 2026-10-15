-- Broader surface landscapes; never scales ships, eggs, trees, or character-sized props.
local V=Vector3.new;local CF=CFrame.new;local C=Color3.fromRGB
local root=workspace.StarfallMap
local islands=root.PlanetIslands
local backup=Instance.new('Folder');backup.Name='StarfallBeforeIslandExpansion';backup.Parent=game.ServerStorage
local palettes={
 ScrapBelt={C(112,183,70),C(110,103,90),C(239,194,91)},
 DerelictField={C(206,143,79),C(89,79,78),C(229,175,103)},
 IceGraveyard={C(129,205,218),C(81,123,157),C(231,243,233)},
 NebulaCurrent={C(151,103,190),C(91,75,125),C(159,205,92)},
 AncientRuins={C(130,169,92),C(99,111,103),C(221,198,122)},
 SingularityEdge={C(90,116,154),C(61,75,101),C(128,199,218)},
}
local order={'ScrapBelt','DerelictField','IceGraveyard','NebulaCurrent','AncientRuins','SingularityEdge'}
local results={}
local function part(parent,name,size,cf,color,solid)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color
 p.Anchored=true;p.CanCollide=solid==true;p.CanTouch=false;p.Material=Enum.Material.Plastic
 p.TopSurface=Enum.SurfaceType.Studs;p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
for biome,id in order do
 local island=islands:FindFirstChild(id);assert(island and not island:GetAttribute('ExpandedSurface'),'Surface missing or already expanded: '..id)
 island:Clone().Parent=backup
 local origin=island.PrimaryPart.Position;local Y=island:GetAttribute('SurfaceY')
 local ground,rock,accent=table.unpack(palettes[id])
 local cells={};local CELL=16
 local function key(i,j)return i..':'..j end
 local function height(i,j)
  if j<=-3 then return 0 end -- Uninterrupted arrival meadow for all six ships.
  if biome==1 then
   return math.max(i<=-3 and math.clamp(j+1,0,3)*2 or 0,i>=3 and math.clamp(j-1,0,4)*2 or 0)
  elseif biome==2 then
   if math.abs(i)<=2 and j<=4 then return 0 end
   return math.min(8,math.max(0,j+2)*2,math.max(2,math.abs(i)-1)*2)
  elseif biome==3 then
   return math.max(0,math.floor((j+1)/2))*2+(i<=-4 and j>=1 and 2 or 0)
  elseif biome==4 then
   return math.max(i<=-2 and math.clamp(j+2,0,4)*2 or 0,i>=3 and math.clamp(j,0,5)*2 or 0)
  elseif biome==5 then return math.clamp(j+1,0,5)*2
  else
   return math.max(0,math.clamp(j,0,4)*2)+(math.abs(i)>=3 and math.clamp(j+2,0,3)*2 or 0)
  end
 end
 for j=-8,8 do for i=-7,7 do
  local included=(i/7.7)^2+(j/9)^2<1
  if j<=-3 then included=math.abs(i)<=6 end
  if j==-8 then included=math.abs(i)<=4 end -- Clip the meadow's front corners.
  if included then cells[key(i,j)]={I=i,J=j,H=height(i,j)}end
 end end
 local function cellAt(x,z)return cells[key(math.floor(x/CELL+.5),math.floor(z/CELL+.5))]end
 local function elevation(x,z)local c=cellAt(x,z);return c and c.H end
 local terrain=Instance.new('Model');terrain.Name='ExpandedTerrainDraft';terrain.Parent=island
 local floorCount,stepCount=0,0
 for j=-8,8 do
  local row=Instance.new('Model');row.Name='TerrainRow'..j
  for i=-7,7 do local c=cells[key(i,j)];if c then
   local tint=ground:Lerp(accent,math.min(c.H/90,.18))
   local tile=part(row,'GroundCell',V(CELL,1,CELL),CF(origin.X+i*CELL,Y+c.H-.5,origin.Z+j*CELL),tint,true)
   part(row,'RockCell',V(CELL,11+c.H,CELL),CF(origin.X+i*CELL,Y+(c.H-13)*.5,origin.Z+j*CELL),rock,true)
   tile:SetAttribute('EggGround',true);tile:SetAttribute('TerrainHeight',c.H);floorCount+=1
   if i==0 and j==0 then island.PrimaryPart=tile end
   if not cells[key(i-1,j)]or not cells[key(i+1,j)]or not cells[key(i,j-1)]or not cells[key(i,j+1)]then
    -- Side detailing stays completely below the walkable floor.
    part(row,'CliffFoot',V(14,6,14),CF(origin.X+i*CELL,Y-15,origin.Z+j*CELL),rock,true)
    part(row,'CliffFace',V(16.08,.9,16.08),CF(origin.X+i*CELL,Y-5,origin.Z+j*CELL),rock:Lerp(accent,.12),false)
    if (i+j)%3==0 then
     local point=Instance.new('WedgePart');point.Name='HangingRock';point.Size=V(10,10,12)
     point.CFrame=CF(origin.X+i*CELL,Y-23,origin.Z+j*CELL)*CFrame.Angles(0,math.pi*((i+j)%4)/2,0)
     point.Color=rock;point.Material=Enum.Material.Plastic;point.Anchored=true;point.CanCollide=false;point.Parent=row
    end
   end
  end end
  row.Parent=terrain;task.wait()
 end
 local stairs=Instance.new('Model');stairs.Name='TerrainStairs';stairs.Parent=terrain
 local function connect(a,b)
  if not a or not b or a.H==b.H then return end
  local low,high=a,b;if low.H>high.H then low,high=high,low end
  local dx,dz=high.I-low.I,high.J-low.J;local rise=high.H-low.H
  local count=math.ceil(rise/.5);local tread=math.min(1.4,14/count)
  local boundary=V((low.I+high.I)*8,0,(low.J+high.J)*8)
  for n=1,count do
   local h=n*rise/count;local p2=boundary-V(dx,0,dz)*((count-n+.5)*tread)
   local size=dx~=0 and V(tread,h,7)or V(7,h,tread)
   local step=part(stairs,'HalfStudStep',size,CF(origin.X+p2.X,Y+low.H+h*.5,origin.Z+p2.Z),accent,true)
   step:SetAttribute('EggGround',true);stepCount+=1
  end
 end
 -- Three north/south routes and cross-links make the upper ground reachable on foot.
 for _,i in {-4,0,4}do for j=-3,7 do connect(cells[key(i,j)],cells[key(i,j+1)])end end
 for _,j in {-1,2,5}do for i=-7,6 do connect(cells[key(i,j)],cells[key(i+1,j)])end end
 -- Preserve the gate's internal spacing when spreading the wider landscape.
 if biome==5 then
  local gate=Instance.new('Model');gate.Name='RuinGate';gate.Parent=island.Props
  for _,item in island.Props:GetChildren()do
   if item.Name=='RuinPillar'or item.Name=='RuinCap'or item.Name=='RuinLintel'or item.Name=='RuinInlay'or item.Name=='RuinVine'then item.Parent=gate end
  end
 end
 -- Move each complete prop as a unit; its physical size remains unchanged.
 local function moveProp(item,scatter)
  local cf=item:IsA('Model')and item:GetPivot()or item.CFrame
  local offset=cf.Position-V(origin.X,Y,origin.Z)
  local x,z=offset.X*2.15,math.max(-27,offset.Z*2.3+16)
  local h=elevation(x,z)
  if h==nil then x*=.85;z*=.85;h=elevation(x,z)or 0 end
  local oldH=0
  if not scatter and (biome==2 or biome==5 or biome==6)then
   if offset.Z>=16.8 and math.abs(offset.X)<(biome==2 and 25.6 or biome==5 and 30.4 or 32)then oldH=biome==5 and 4.8 or 3.6 end
  end
  local delta=V(x-offset.X,h-oldH,z-offset.Z)
  if item:IsA('Model')then item:PivotTo(cf+delta)else item.CFrame=cf+delta end
 end
 for _,item in island.Props:GetChildren()do
  if item.Name=='EdgeDetails'then for _,detail in item:GetChildren()do moveProp(detail,true)end else moveProp(item)end
 end
 -- Bring every prop's base to the new terrain without stretching trees or ruins.
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={terrain}
 for _,item in island.Props:GetChildren()do if item.Name~='EdgeDetails'then
  local cf,size
  if item:IsA('Model')then cf,size=item:GetBoundingBox()else cf,size=item.CFrame,item.Size end
  -- Keep small props wholly on one terrace, including their rotated footprint.
  local radius=math.max(size.X,size.Z)*.75
  if radius<7 then
   local x,z=cf.X-origin.X,cf.Z-origin.Z;local cell=cellAt(x,z)
   if cell then
    local margin=8-radius-.2
    local nx=cell.I*16+math.clamp(x-cell.I*16,-margin,margin)
    local nz=cell.J*16+math.clamp(z-cell.J*16,-margin,margin)
    local shift=V(nx-x,0,nz-z)
    if item:IsA('Model')then item:PivotTo(item:GetPivot()+shift)else item.CFrame+=shift end
    cf+=shift
   end
  end
  local hit=workspace:Raycast(V(cf.X,Y+50,cf.Z),V(0,-100,0),ray)
  if hit then
   local shift=V(0,hit.Position.Y-(cf.Y-size.Y*.5),0)
   if item:IsA('Model')then item:PivotTo(item:GetPivot()+shift)else item.CFrame+=shift end
  end
 end end
 local landscape=Instance.new('Model');landscape.Name='ExpandedLandscape';landscape.Parent=island.Props
 local function landscapeCluster(x,z,n)
  local cell=cellAt(x,z);if not cell then return end
  -- A six-stud crown fits inside a 16-stud cell with this four-stud margin.
  x=cell.I*16+math.clamp(x-cell.I*16,-4,4)
  z=cell.J*16+math.clamp(z-cell.J*16,-4,4)
  local h=cell.H
  local cluster=Instance.new('Model');cluster.Name='Cluster'..n;cluster.Parent=landscape
  local base=CF(origin.X+x,Y+h,origin.Z+z)
  if biome==1 or biome==4 or biome==5 then
   local trunk=biome==4 and C(217,205,188)or C(125,83,54)
   local leaves=biome==4 and C(161,205,91)or biome==5 and C(65,132,91)or C(48,140,75)
   local ht=biome==4 and 4+n%3 or 6+n%4
   part(cluster,'Stem',V(1.3,ht,1.3),base*CF(0,ht*.5,0),trunk,true)
   part(cluster,biome==4 and 'MushroomCap'or 'TreeCrown',V(5.6,biome==4 and 1.4 or 3.4,5.6),base*CF(0,ht,0),leaves,false)
   part(cluster,'CrownTop',V(3.8,1.8,3.8),base*CF(0,ht+1.7,0),leaves:Lerp(accent,.16),false)
  else
   local color=biome==3 and C(94,180,206)or rock
   part(cluster,'LowBoulder',V(4,2.2,3.5),base*CF(0,1.1,0),color,true)
   part(cluster,biome==2 and 'Ore'or 'Crystal',V(1.7,3+n%3,1.7),base*CF(1.4,(3+n%3)*.5,-.6),accent,true)
  end
 end
 for n=1,28 do
  local side=n%2==0 and 1 or -1;local x=side*(38+(n*13)%63);local z=-16+(n*19)%131
  landscapeCluster(x,z,n)
 end
 for n,pt in {V(-24,0,5),V(26,0,22),V(-24,0,52),V(25,0,76),V(-36,0,-104),V(36,0,-92),V(-100,0,-80),V(100,0,-80)}do
  landscapeCluster(pt.X,pt.Z,n+28)
 end
 local groundDetails=Instance.new('Model');groundDetails.Name='MeadowDetails';groundDetails.Parent=island.Props
 for n,pt in {V(-48,0,-128),V(0,0,-128),V(48,0,-128),V(-100,0,-112),V(100,0,-112),V(-36,0,-60),V(36,0,-60)}do
  local color=biome==1 and C(82,150,67)or ground:Lerp(accent,.35)
  for k=-1,1 do
   part(groundDetails,'SmallGroundDetail',V(1.3,.6,1.3),CF(origin.X+pt.X+k*1.5,Y+.3,origin.Z+pt.Z+(k%2)*1.5),color,false)
  end
 end
 -- Only authoring markers: the meadow itself has no parking-pad geometry.
 local pad=island.LandingPad;local anchor=pad.ArrivalAnchor
 for _,item in pad:GetChildren()do if item~=anchor then item:Destroy()end end
 local padSurface=part(pad,'PadSurface',V(208,.2,88),CF(origin.X,Y-.2,origin.Z-84),ground,false)
 padSurface.Transparency=1;padSurface.CanQuery=false
 local landingAnchor=Instance.new('Attachment');landingAnchor.Name='LandingAnchor';landingAnchor.Parent=padSurface;landingAnchor.Position=V(0,.2,0)
 anchor.CFrame=CF(origin.X,Y+3,origin.Z-78)
 local clearances=Instance.new('Folder');clearances.Name='ShipClearances';clearances.Parent=pad
 for row=1,2 do for col=1,3 do
  local x=(col-2)*72;local z=row==1 and -102 or -58
  local area=part(clearances,'ShipClearance'..((row-1)*3+col),V(40,1,32),CF(origin.X+x,Y+.5,origin.Z+z),accent,false)
  area.Transparency=1;area.CanQuery=false;area:SetAttribute('ShipSlot',(row-1)*3+col)
  local slot=Instance.new('Attachment');slot.Name='ShipAnchor';slot.Position=V(0,-.5,0);slot.Parent=area
 end end
 -- A pair of small perimeter flags identifies the arrival meadow from higher ground.
 for _,side in {-1,1}do
  part(pad,'MeadowFlagPole',V(.5,7,.5),CF(origin.X+side*101,Y+3.5,origin.Z-40),rock,true)
  part(pad,'MeadowFlag',V(3,1.8,.2),CF(origin.X+side*101+1.5,Y+6,origin.Z-40),accent,false)
 end
 local zones=island.EggSpawnZones;zones:ClearAllChildren()
 local zoneCount=0
 for j=-1,6,2 do for i=-5,5,2 do
  local h=elevation(i*16,j*16);if h~=nil then
   zoneCount+=1;local zone=part(zones,'Zone'..zoneCount,V(13,1,13),CF(origin.X+i*16,Y+h+12,origin.Z+j*16),ground,false)
   zone.Transparency=1;zone.CanQuery=false
  end
 end end
 island.Terrain:Destroy();terrain.Name='Terrain'
 island:SetAttribute('ExpandedSurface',true);island:SetAttribute('ShipCapacity',6)
 island:SetAttribute('SurfaceWidth',240);island:SetAttribute('SurfaceDepth',272)
 table.insert(results,{Id=id,GroundCells=floorCount,StairSteps=stepCount,ShipClearances=6,EggZones=zoneCount})
 task.wait()
end
return results
