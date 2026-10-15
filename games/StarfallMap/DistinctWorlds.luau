-- Final world rebuild: six silhouettes and terrain grammars, not six painted round sheets.
local V,CF=Vector3.new,CFrame.new
local root=workspace.StarfallMap
local order={'ScrapBelt','DerelictField','IceGraveyard','NebulaCurrent','AncientRuins','SingularityEdge'}
-- Profiles: local X,Z, width,depth,top height,shape,yaw. One shared landing remains at 0,-84.
local designs={
 ScrapBelt={Name='Branching meadow',Ground=2,High=1,Deep=6,Rock=5,Accent=3,Path=4,
  Profiles={{0,-70,110,116,0,'Oval',0},{-55,3,122,96,0,'Oval',-.4},{-108,65,112,90,0,'Oval',-.45},{70,30,140,92,0,'Oval',.4},{112,87,98,82,0,'Oval',.2},{0,35,96,200,0,'Oval',0},{0,115,70,64,4,'Oval',0}},
  Links={{1,2,15},{2,3,15},{1,4,15},{4,5,15},{1,6,16},{6,7,12}},
  Hero='HollowHeartTree',HeroAt={0,113},Scale=1.45,
  Groves={{-110,63,35,26,35},{112,85,31,25,29},{-45,5,25,25,14}},EggCount=12,Prop='Tree'},
 DerelictField={Name='Fractured salvage plates',Ground=3,High=2,Deep=5,Rock=4,Accent=1,Path=4,
  Profiles={{0,-76,104,112,0,'Plate',0},{-84,-5,102,96,4,'Plate',-.24},{80,12,98,102,8,'Plate',.32},{-10,103,116,90,12,'Plate',-.12},{112,-74,66,58,0,'Plate',-.18}},
  Links={{1,2,12},{1,3,12},{2,4,13},{3,4,12},{1,5,10}},
  Hero='CrashedScout',HeroAt={-8,100},Scale=1.35,
  Groves={{-98,2,31,28,19},{93,18,27,32,16},{108,-76,22,18,8}},EggCount=12,Prop='Salvage'},
 IceGraveyard={Name='Raised ice crescent',Ground=4,High=2,Deep=1,Rock=3,Accent=5,Path=2,
  Profiles={{0,-84,98,90,0,'Oval',0},{-82,-58,112,84,2,'Oval',-.3},{-108,8,86,104,6,'Oval',0},{-75,86,102,90,10,'Oval',.3},{5,117,108,74,14,'Oval',0},{80,83,92,76,10,'Oval',-.4}},
  Links={{1,2,14},{2,3,15},{3,4,14},{4,5,16},{5,6,14}},
  Hero='FrostArch',HeroAt={0,117},Scale=1.45,
  Groves={{-112,8,25,35,17},{-73,91,33,24,14},{84,85,29,20,14}},EggCount=12,Prop='Ice'},
 NebulaCurrent={Name='Clustered mushroom mounds',Ground=3,High=2,Deep=1,Rock=4,Accent=5,Path=2,
  Profiles={{0,-76,116,106,0,'Oval',0},{-86,6,112,104,5,'Oval',0},{70,18,112,96,9,'Oval',.2},{-46,108,104,96,13,'Oval',-.2},{72,113,88,84,6,'Oval',0}},
  Links={{1,2,18},{1,3,16},{2,4,18},{3,5,16},{4,5,13}},
  Hero='MushroomFamily',HeroAt={-46,105},Scale=1.65,
  Groves={{-88,7,34,31,25},{72,17,34,26,22},{76,115,25,25,16}},EggCount=12,Prop='Mushroom'},
 AncientRuins={Name='Stepped broken courtyards',Ground=1,High=3,Deep=5,Rock=2,Accent=4,Path=3,
  Profiles={{0,-80,108,108,0,'Plate',0},{0,13,144,104,4,'Plate',0},{-103,40,68,96,4,'Plate',0},{14,115,112,80,12,'Plate',0},{106,-8,62,78,8,'Plate',0}},
  Links={{1,2,28},{2,3,20},{2,4,28},{2,5,18}},
  Hero='TempleGate',HeroAt={14,113},Scale=1.5,
  Groves={{-103,39,22,34,13},{106,-8,20,25,10},{-44,13,18,29,10}},EggCount=12,Prop='Ruin'},
 SingularityEdge={Name='Diagonal ridge spine',Ground=1,High=2,Deep=1,Rock=3,Accent=5,Path=2,
  Profiles={{0,-84,100,96,0,'Plate',-.32},{-36,-6,146,55,5,'Plate',-.62},{26,61,164,54,11,'Plate',-.62},{-7,135,96,62,17,'Plate',.25}},
  Links={{1,2,20},{2,3,19},{3,4,18}},
  Hero='StormBeacon',HeroAt={-7,135},Scale=1.65,
  Groves={{-54,-8,45,16,17},{31,58,54,15,20},{-4,135,28,18,7}},EggCount=12,Prop='Storm'},
}
local backup=game.ServerStorage:FindFirstChild('StarfallBeforeDistinctWorlds')or Instance.new('Folder')
backup.Name='StarfallBeforeDistinctWorlds';backup.Parent=game.ServerStorage
local results={}
for seed,id in order do
 seed=({ScrapBelt=1,DerelictField=2,IceGraveyard=3,NebulaCurrent=4,AncientRuins=5,SingularityEdge=6})[id]
 local island=root.PlanetIslands[id];assert(not island:GetAttribute('DistinctWorld'),'World already rebuilt: '..id)
 local d=designs[id];local colors={};for h in island:GetAttribute('PaletteHex'):gmatch('[^,]+')do table.insert(colors,Color3.fromHex(h))end
 local origin=V(island.LandingPad.PadSurface.Position.X,island:GetAttribute('SurfaceY'),island.LandingPad.PadSurface.Position.Z+84)
 local saved=Instance.new('Folder');saved.Name=id;saved.Parent=backup
 for _,q in island.LandingPad:GetChildren()do if q.Name=='MeadowFlag'or q.Name=='MeadowFlagPole'then q.Parent=saved end end
 local hero=island.Props:FindFirstChild(d.Hero):Clone()
 island.Terrain.Parent=saved;island.Props.Parent=saved;island.EggSpawnZones.Parent=saved
 local terrain=Instance.new('Model');terrain.Name='Terrain';terrain.Parent=island
 local props=Instance.new('Model');props.Name='Props';props.Parent=island
 local zones=Instance.new('Folder');zones.Name='EggSpawnZones';zones.Parent=island
 local count=0
 local function p(parent,name,size,at,color,solid,studs,class)
  local q=Instance.new(class or 'Part');q.Name=name;q.Size=size;q.CFrame=at;q.Color=colors[color]
  q.Anchored=true;q.CanCollide=solid==true;q.CanQuery=solid==true;q.CanTouch=false
  q.Material=Enum.Material.SmoothPlastic;q.TopSurface=studs and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth;q.BottomSurface=Enum.SurfaceType.Smooth
  q.Parent=parent;count+=1;return q
 end
 local topByLevel={}
 for n,s in d.Profiles do
  local at=CF(origin.X+s[1],origin.Y+s[5]-.7,origin.Z+s[2])*CFrame.Angles(0,s[7],0)
  local q
  if s[6]=='Oval'then
   q=p(terrain,'ProfileDraft',V(1.4,s[3],s[4]),at*CFrame.Angles(0,0,math.pi*.5),d.Ground,true,false);q.Shape=Enum.PartType.Cylinder
  else q=p(terrain,'ProfileDraft',V(s[3],1.4,s[4]),at,d.Ground,true,false)end
  if id=='DerelictField'and n>1 then
   local cutter=p(terrain,'BrokenCorner',V(24,8,20),at*CF(s[3]*.5,0,s[4]*.5),d.Ground,false,false)
   local cut=q:SubtractAsync({cutter},Enum.CollisionFidelity.PreciseConvexDecomposition,Enum.RenderFidelity.Precise)
   cut.Parent=terrain;q:Destroy();cutter:Destroy();q=cut
  end
  topByLevel[s[5]]=topByLevel[s[5]]or {};table.insert(topByLevel[s[5]],q)
  if(id=='IceGraveyard'or id=='NebulaCurrent')and s[5]>0 then
   local under=p(terrain,'GroundNeckSource',V(1.4,s[3]*1.1,s[4]*1.1),CF(origin.X+s[1],origin.Y-.7,origin.Z+s[2])*CFrame.Angles(0,s[7],0)*CFrame.Angles(0,0,math.pi*.5),d.Ground,true,false)
   under.Shape=Enum.PartType.Cylinder;topByLevel[0]=topByLevel[0]or {};table.insert(topByLevel[0],under)
  end
 end
 local surfaces={}
 for level,parts in topByLevel do
  local q=parts[1]
  if #parts>1 then local others={}for n=2,#parts do table.insert(others,parts[n])end
   q=parts[1]:UnionAsync(others,Enum.CollisionFidelity.PreciseConvexDecomposition,Enum.RenderFidelity.Precise);q.Parent=terrain
   for _,old in parts do old:Destroy()end
  end
  q.Name='BiomeSurface'..level;q:SetAttribute('EggGround',true);q:SetAttribute('TerrainLevel',level);q.Anchored=true;q.CanCollide=true;q.CanQuery=true
  q.Color=colors[level==0 and d.Ground or d.High];if q:IsA('UnionOperation')then q.UsePartColor=true end
  table.insert(surfaces,q)
  if level==0 then island.PrimaryPart=q end
  -- Thick tapered islands retain a readable silhouette in side view.
  local s,cf=q.Size,q.CFrame
  local vertical=math.abs(cf.RightVector.Y)>.9 and 1 or math.abs(cf.UpVector.Y)>.9 and 2 or 3
  for n,band in {{1,11,d.Rock},{.87,12,d.Deep},{.65,10,d.Rock}}do
   local lower=q:Clone();lower.Name='CliffBand';lower:SetAttribute('EggGround',nil)
   lower.Size=V(vertical==1 and band[2]or s.X*band[1],vertical==2 and band[2]or s.Y*band[1],vertical==3 and band[2]or s.Z*band[1])
   local top=origin.Y+level-1.4-(n==1 and 0 or n==2 and 11 or 23)
   lower.CFrame=cf+V(0,top-band[2]*.5-cf.Y,0);lower.Color=colors[band[3]];lower.Parent=terrain
  end
  task.wait()
 end
 -- Visible terrain connections: riveted bridges, broad court stairs or natural narrow necks.
 local profileRay=RaycastParams.new();profileRay.FilterType=Enum.RaycastFilterType.Include;profileRay.FilterDescendantsInstances=surfaces
 for _,link in d.Links do
  local a,b=d.Profiles[link[1]],d.Profiles[link[2]]
  local from=V(origin.X+a[1],origin.Y+a[5],origin.Z+a[2]);local to=V(origin.X+b[1],origin.Y+b[5],origin.Z+b[2])
  if link[1]==1 then
   local center=V(origin.X,origin.Y,origin.Z-84);local dir=V(to.X-center.X,0,to.Z-center.Z).Unit
   local half=link[3]*.5+3
   local exit=math.min((20+half)/math.max(.001,math.abs(dir.X)),(16+half)/math.max(.001,math.abs(dir.Z)))
   from=center+dir*exit
  end
  local initial=V(to.X-from.X,0,to.Z-from.Z);local initialLength=initial.Magnitude;local direction=initial.Unit
  if to.Y>from.Y+.1 then
   -- End the climb at the first destination shelf edge, rather than at its center.
   for sample=0,math.ceil(initialLength)do
    local at=from+direction*math.min(sample,initialLength)
    local hit=workspace:Raycast(V(at.X,origin.Y+70,at.Z),V(0,-130,0),profileRay)
    if hit and hit.Position.Y>=to.Y-.1 then to=V(at.X+direction.X*.5,to.Y,at.Z+direction.Z*.5);break end
   end
  elseif to.Y<from.Y-.1 then
   -- Begin descending outside the high ledge, with enough tread length over the lower surface.
   for sample=0,math.ceil(initialLength)do
    local at=from+direction*math.min(sample,initialLength)
    local hit=workspace:Raycast(V(at.X,origin.Y+70,at.Z),V(0,-130,0),profileRay)
    if not hit or hit.Position.Y<from.Y-.1 then
     from=V(at.X,from.Y,at.Z)
     local run=math.max(9,(from.Y-to.Y)*3)
     to=V(from.X+direction.X*run,to.Y,from.Z+direction.Z*run);break
    end
   end
  end
  local delta=to-from;local horizontal=V(delta.X,0,delta.Z);local length=horizontal.Magnitude
  local steps=math.max(1,math.ceil(math.abs(delta.Y)/.5));local segment=length/steps
  for n=1,steps do
   local t=(n-.5)/steps;local pos=from:Lerp(to,t);local rise=delta.Y==0 and 0 or (delta.Y>0 and n/steps or (n-1)/steps)*delta.Y
   local level=from.Y+rise
   local covered=workspace:Raycast(V(pos.X,origin.Y+70,pos.Z),V(0,-130,0),profileRay)
   if delta.Y==0 and covered and math.abs(covered.Position.Y-level)<.02 then continue end
   local thickness=id=='DerelictField'and .8 or 6
   local at=CF(V(pos.X,level+.03-thickness*.5,pos.Z),V(pos.X,level+.03-thickness*.5,pos.Z)+horizontal)
   local q=p(terrain,id=='DerelictField'and 'SalvageBridge'or id=='AncientRuins'and 'ProcessionalStair'or 'TerrainNeck',V(link[3],thickness,segment+.08),at,id=='DerelictField'and d.Path or d.Ground,true,id=='DerelictField'and n%3==0 or id=='AncientRuins'and n%4==0)
   q:SetAttribute('EggGround',true)
  end
  task.wait()
 end
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={terrain}
 local function ground(x,z)
  local h=workspace:Raycast(V(origin.X+x,origin.Y+85,origin.Z+z),V(0,-145,0),ray)
  return h and h.Normal.Y>.99 and h.Instance:GetAttribute('EggGround')and h.Position.Y or nil
 end
 local function flat(x,z,r)
  local y=ground(x,z);if not y then return end
  for _,dx in {-r,0,r}do for _,dz in {-r,0,r}do local h=ground(x+dx,z+dz);if not h or math.abs(h-y)>.11 then return end end end
  return y
 end
 local function bottom(m)
  local low=math.huge;for _,q in m:GetDescendants()do if q:IsA('BasePart')then local s,c=q.Size,q.CFrame
   local extent=math.abs(c.RightVector.Y)*s.X*.5+math.abs(c.UpVector.Y)*s.Y*.5+math.abs(c.LookVector.Y)*s.Z*.5
   low=math.min(low,q.Position.Y-extent)
  end end;return low
 end
 local hy=assert(ground(d.HeroAt[1],d.HeroAt[2]),'Hero has no support: '..id)
 hero:ScaleTo(hero:GetScale()*d.Scale);hero:PivotTo(CF(origin.X+d.HeroAt[1],hy,origin.Z+d.HeroAt[2])*hero:GetPivot().Rotation)
 hero:PivotTo(hero:GetPivot()+V(0,hy-bottom(hero),0));hero.Parent=props
 local _,heroSize=hero:GetBoundingBox();local heroRadius=math.max(heroSize.X,heroSize.Z)*.5+6
 local function landing(x,z,r)
  local s=island.LandingPad.ShipClearances.ShipClearance1;local at=s.CFrame:PointToObjectSpace(V(origin.X+x,s.Position.Y,origin.Z+z))
  return math.abs(at.X)<s.Size.X*.5+r+3 and math.abs(at.Z)<s.Size.Z*.5+r+3
 end
 local function heroClear(x,z,r)
  if id=='AncientRuins'and math.abs(math.abs(x)-58)<r+2 and math.abs(z-32)<r+17 then return false end
  return(V(x,0,z)-V(d.HeroAt[1],0,d.HeroAt[2])).Magnitude>heroRadius+r
 end
 local meadowRoute={}
 if id=='ScrapBelt'then
  local paths={{{0,-61},{-30,-18},{-60,12},{-99,50}},{{0,-61},{40,5},{82,37},{112,66}},{{0,-61},{0,28},{0,82}}}
  for _,points in paths do for n=1,#points-1 do
   local function point(k)local q=points[math.clamp(k,1,#points)];return V(q[1],0,q[2])end
   local a,b,c,e=point(n-1),point(n),point(n+1),point(n+2)
   for step=0,40 do local t=step/40;local t2,t3=t*t,t*t*t
    table.insert(meadowRoute,(b*2+(c-a)*t+(a*2-b*5+c*4-e)*t2+(-a+b*3-c*3+e)*t3)*.5)
   end
  end end
 end
 local function trailClear(x,z,r)
  for _,q in meadowRoute do if(V(x,0,z)-q).Magnitude<r+3 then return false end end
  return true
 end
 local used={};local pockets={}
 -- Reserve egg clearings first, across the new heights; spatial randomness is unchanged.
 for round=1,90 do
  for profile,s in d.Profiles do
   local angle=round*2.399+profile*.79;local r=.15+((round-1)%9)/14
   local x=s[1]+math.cos(angle)*s[3]*r*.5;local z=s[2]+math.sin(angle)*s[4]*r*.5
   if landing(x,z,12)or not heroClear(x,z,12)or not trailClear(x,z,12)then continue end
   local y=flat(x,z,9);if not y then continue end
   local separate=true;for _,old in pockets do if(V(x,0,z)-V(old.X,0,old.Z)).Magnitude<25 then separate=false end end
   if separate then
    table.insert(pockets,{X=x,Z=z,Y=y})
    local q=p(zones,'SearchClearing'..#pockets,V(10,1,10),CF(origin.X+x,y+12,origin.Z+z),d.Ground,false,false)
    q.Transparency=1;q:SetAttribute('Subarea',d.Name)
   end
   if #pockets>=d.EggCount then break end
  end
  if #pockets>=d.EggCount then break end
 end
 assert(#pockets>=8,'Not enough supported egg clearings: '..id)
 local function available(x,z,r)
  if landing(x,z,r)or not heroClear(x,z,r)or not trailClear(x,z,r)then return end
  for _,q in pockets do if(V(x,0,z)-V(q.X,0,q.Z)).Magnitude<r+10 then return end end
  for _,q in used do if(V(x,0,z)-V(q.X,0,q.Z)).Magnitude<r+q.R+2 then return end end
  return flat(x,z,r)
 end
 local function plant(x,z,y,n,scale)
  local m=Instance.new('Model');m.Name=d.Prop..'Cluster';local at=CF(origin.X+x,y,origin.Z+z)*CFrame.Angles(0,n*1.713,0)
  local h=(7+n%5)*scale
  if d.Prop=='Tree'then
   p(m,'Trunk',V(.9,h*.65,.9),at*CF(0,h*.325,0),d.Deep,true,n%4==0)
   if n%3==0 then
    for k=1,3 do local w=(6.8-k*1.3)*scale
     p(m,'PineTier',V(w,h*.22,w),at*CF(0,h*(.42+k*.17),0),k%2==0 and 1 or 3,false,k==3)
    end
   elseif n%3==1 then
    for _,side in {-1,1}do p(m,'ForkCrown',V(4.5*scale,3.3*scale,4*scale),at*CF(side*1.6*scale,h*(side==1 and .8 or .64),0),side==1 and 2 or 3,false,false)end
   else
    p(m,'BroadCanopy',V(7*scale,3.5*scale,5.5*scale),at*CF(0,h*.77,0),3,false,false)
    p(m,'CanopyTop',V(4*scale,2*scale,4*scale),at*CF(1*scale,h*.97,0),1,false,n%5==0)
   end
  elseif d.Prop=='Mushroom'then
   for j=1,n%3+1 do local h=(4+j*2.5+n%4)*scale;local dx=(j-2)*2.1*scale
    p(m,'Stalk',V(.8*scale,h,.8*scale),at*CF(dx,h*.5,0),d.Deep,true,false)
    local cap=p(m,'AngularCap',V((4+j)*scale,1.2*scale,(4+j)*scale),at*CF(dx,h,0)*CFrame.Angles(0,j*.4,0),n%2==0 and 4 or 2,false,n%6==0)
    if n%2==0 then p(m,'CapCrown',V(2.8*scale,.6*scale,2.8*scale),cap.CFrame*CF(0,.9*scale,0),3,false,false)end
   end
  elseif d.Prop=='Ice'then
   for j=1,3 do local h=(4+j*2+n%3)*scale
    p(m,'IceBlade',V(1.5*scale,h,2.3*scale),at*CF((j-2)*2*scale,h*.5,0)*CFrame.Angles(0,j*.5,0),j==2 and 3 or 4,true,false,'WedgePart')
   end
  elseif d.Prop=='Ruin'then
   if n%3==0 then
    for _,side in {-1,1}do p(m,'ColumnRemnant',V(2.4*scale,(4+side*2)*scale,2.4*scale),at*CF(side*2*scale,(4+side*2)*scale*.5,0),3,true,false)end
   else
    for j=1,3 do local h=(2+(j+n)%4)*scale
     p(m,'WallRemnant',V(2.4*scale,h,1.8*scale),at*CF((j-2)*2.4*scale,h*.5,0),n%2==0 and 3 or 2,true,n%5==0)
    end
   end
   if n%3~=0 then local height=(2+(2+n)%4)*scale;p(m,'MossTop',V(2.2*scale,.3*scale,1.7*scale),at*CF(0,height+.15*scale,0),1,false,false)end
  elseif d.Prop=='Salvage'then
   if n%3==0 then
    p(m,'ScrapCabinet',V(4*scale,3*scale,4*scale),at*CF(0,1.5*scale,0),2,true,true)
    p(m,'DarkWindow',V(2.4*scale,1.1*scale,.12),at*CF(0,1.8*scale,-2.1*scale),5,false,false)
   else
    for j=1,3 do p(m,'HullFragment',V((2+j)*scale,.8*scale,(3+j)*scale),at*CF((j-2)*1.4*scale,.4*scale+(j-1)*.3*scale,0)*CFrame.Angles(0,j*.5,0),j%2==0 and 2 or 4,true,j==1)end
   end
  else
   if n%4==0 then
    p(m,'PylonFoot',V(4*scale,1*scale,4*scale),at*CF(0,.5*scale,0),3,true,true)
    p(m,'PylonMast',V(.9*scale,h,.9*scale),at*CF(0,h*.5+1*scale,0),1,true,false)
    p(m,'PylonCrossbar',V(5*scale,.9*scale,1.5*scale),at*CF(0,h+1*scale,0),2,false,false)
    local q=p(m,'ChargedCore',V(.7,.7,.7),at*CF(0,h+2*scale,0),5,false,false);q.Material=Enum.Material.Neon
   else for j=1,3 do local h=(3+j*1.7)*scale
    p(m,'TiltedCrystal',V(1.3*scale,h,1.8*scale),at*CF((j-2)*1.6*scale,h*.5,0)*CFrame.Angles(0,j*.7,0),j==2 and 5 or 2,true,false,'WedgePart')
   end end
  end
  m.Parent=props
 end
 local plants=0
 for group,g in d.Groves do
  for pass=1,2 do
  for n=1,g[5]do
   local a=n*2.399+group*.9+(pass-1)*.65;local r=math.sqrt(n/g[5]);local x=g[1]+math.cos(a)*r*g[3];local z=g[2]+math.sin(a)*r*g[4]
   local scale=.72+(.5+.5*math.sin(n*3.9+group))*.42
   local footprint=({Tree=4.8,Mushroom=7,Ice=4,Ruin=4.1,Salvage=5,Storm=3.6})[d.Prop]*scale
   local y=available(x,z,footprint)
   if y then plant(x,z,y,n+group*13,scale);plants+=1;table.insert(used,{X=x,Z=z,R=footprint})end
  end
  end
  task.wait()
 end
 -- Broad smooth color/material fields. A few small patches carry classic studs, not the whole island.
 local patches=0;local studPatches=0
 for z=-145,165,12 do for x=-150,150,12 do
  local y=flat(x,z,6.1)
  if y and not landing(x,z,7)and math.noise(x*.027,z*.027,seed*.37)>.1 then
   local index=d.Prop=='Tree'and(math.noise(x*.017,z*.017)>.1 and 1 or 3)or d.High
   local stud=(math.floor(x/12)+math.floor(z/12))%9==0
   local q=p(terrain,stud and 'StudPatch'or 'BiomePatch',V(12,.05,12),CF(origin.X+x,y+.025,origin.Z+z),index,true,stud)
   q:SetAttribute('EggGround',true);q.CastShadow=false;patches+=1;if stud then studPatches+=1 end
  end
 end;task.wait()end
 -- Sparse terrain-native navigation: meadow foot trails; others use their shelves and stairs.
 if id=='ScrapBelt'then
  local crumbs={}
  for _,point in meadowRoute do
    local x,z=point.X,point.Z
    local y=flat(x,z,2.2);if y then local q=p(terrain,'TrailDraft',V(.12,4.5,4.5),CF(origin.X+x,y+.06,origin.Z+z)*CFrame.Angles(0,0,math.pi*.5),d.Path,false,false);q.Shape=Enum.PartType.Cylinder;table.insert(crumbs,q)end
  end
  if #crumbs>1 then local others={}for n=2,#crumbs do table.insert(others,crumbs[n])end
   local q=crumbs[1]:UnionAsync(others,Enum.CollisionFidelity.PreciseConvexDecomposition);q.Name='MeadowFootpaths';q.Anchored=true;q.CanCollide=true;q.CanQuery=true;q.UsePartColor=true;q.Color=colors[d.Path];q:SetAttribute('EggGround',true);q.Parent=terrain
   for _,old in crumbs do old:Destroy()end
  end
 end
 local low=0
 for n=1,420 do local x=math.sin(n*1.618)*150;local z=12+math.sin(n*2.719)*153;local y=available(x,z,1.8)
  if y then
   local m=Instance.new('Model');m.Name='GroundDetail';local at=CF(origin.X+x,y,origin.Z+z)
   if d.Prop=='Tree'or d.Prop=='Mushroom'then
    p(m,'ShortStem',V(.22,1,.22),at*CF(0,.5,0),d.Deep,false,false)
    p(m,'FlowerOrSpore',V(.8,.35,.8),at*CF(0,1.1,0),n%2==0 and d.Accent or d.High,false,n%9==0)
   else p(m,'GroundFragment',V(1.3+n%3*.3,.6,1.4),at*CF(0,.3,0)*CFrame.Angles(0,n*.7,0),n%2==0 and d.Rock or d.High,false,n%13==0)end
   m.Parent=props;table.insert(used,{X=x,Z=z,R=1.8});low+=1
  end
  if n%100==0 then task.wait()end
 end
 -- Companion structures reinforce the biome grammar and frame the main landmark.
 if id=='DerelictField'then
  local at=CF(origin.X-32,hy,origin.Z+105)
  p(props,'WreckCrane',V(2.4,27,2.4),at*CF(0,13.5,0),5,true,false)
  p(props,'BentCraneArm',V(22,2.4,2.4),at*CF(8,26,0)*CFrame.Angles(0,0,-.22),2,false,true)
 elseif id=='AncientRuins'then
  for _,side in {-1,1}do local x,z=side*58,32;local y=ground(x,z)
   if y then p(props,'ProcessionalWall',V(3,12,34),CF(origin.X+x,y+6,origin.Z+z),3,true,false)end
  end
 elseif id=='SingularityEdge'then
  for n,point in {{-121,38},{119,87},{-76,136}}do
   local at=CF(origin.X+point[1],origin.Y+9+n*3,origin.Z+point[2])
   p(props,'FloatingPylonIsland',V(24,7,22),at,1,false,false)
   p(props,'IsolatedPylon',V(2,16,2),at*CF(0,11.5,0),3,false,false)
   p(props,'PylonHead',V(9,2,4),at*CF(0,20.5,0),2,false,false)
  end
 end
 -- Nearby drifting fragments and faint motes reuse the existing cosmetic client.
 for n,s in d.Profiles do if n>1 and n%2==0 then
  local x,z=s[1]+s[3]*.35,s[2];local y=ground(x,z)
  if y and not landing(x,z,5)then
   local m=Instance.new('Model');m.Name='DriftingBiomeFragments';m.Parent=props
   for j=1,3 do local q=p(m,'Mote',V(.7+j*.35,.7,.7+j*.35),CF(origin.X+x+math.cos(j*2.4)*2,y+8+j,origin.Z+z+math.sin(j*2.4)*2),d.Rock,false,false);q:SetAttribute('MoteIndex',j)end
   m:SetAttribute('IslandMotion','Shimmer');m:SetAttribute('MotionRadius',2);m:SetAttribute('MotionPhase',n);m:SetAttribute('RestPivot',m:GetPivot())
  end
 end end
 local materials={ScrapBelt={Enum.Material.Grass,Enum.Material.Slate},DerelictField={Enum.Material.Metal,Enum.Material.CorrodedMetal},IceGraveyard={Enum.Material.Ice,Enum.Material.Ice},NebulaCurrent={Enum.Material.Sand,Enum.Material.Slate},AncientRuins={Enum.Material.Concrete,Enum.Material.Slate},SingularityEdge={Enum.Material.Slate,Enum.Material.Basalt}}
 for _,q in terrain:GetDescendants()do if q:IsA('BasePart')then
  q.Material=q.TopSurface==Enum.SurfaceType.Studs and Enum.Material.Plastic or q.Name=='CliffBand'and materials[id][2]or q.Name=='MeadowFootpaths'and Enum.Material.Ground or materials[id][1]
 end end
 island:SetAttribute('DistinctWorld',true);island:SetAttribute('CompositionTheme',d.Name);island:SetAttribute('WorldLandmark',hero.Name)
 table.insert(results,{Id=id,Theme=d.Name,Profiles=#d.Profiles,PropClusters=plants,LowDetails=low,EggZones=#pockets,StudPatches=studPatches,PalettePatches=patches})
 task.wait()
end
return results
