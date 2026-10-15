-- Decorative details only; no rewards, hazards or rarity rolls.
local root=workspace.StarfallMap
local V,CF=Vector3.new,CFrame.new
local order={'ScrapBelt','DerelictField','IceGraveyard','NebulaCurrent','AncientRuins','SingularityEdge'}
local results={}
for _,id in order do
 local island=root.PlanetIslands[id]
 assert(not island.Props:FindFirstChild('IslandLife'),'IslandLife already exists: '..id)
 local folder=Instance.new('Model');folder.Name='IslandLife';folder.Parent=island.Props
 local colors={};for h in island:GetAttribute('PaletteHex'):gmatch('[^,]+')do table.insert(colors,Color3.fromHex(h))end
 local dark,light,accent=colors[#colors],colors[1],colors[3]
 if id=='IceGraveyard'then dark,light,accent=colors[1],colors[4],colors[2]
 elseif id=='AncientRuins'then dark,light,accent=colors[5],colors[3],colors[4]
 elseif id=='NebulaCurrent'then dark,light,accent=colors[1],colors[5],colors[3]
 elseif id=='SingularityEdge'then dark,light,accent=colors[1],colors[3],colors[5]end
 local count=0
 local function p(parent,name,size,at,color,glow)
  local q=Instance.new('Part');q.Name=name;q.Size=size;q.CFrame=at;q.Color=color
  q.Anchored=true;q.CanCollide=false;q.CanTouch=false;q.CanQuery=false
  q.Material=glow and Enum.Material.Neon or Enum.Material.Plastic
  q.TopSurface=glow and Enum.SurfaceType.Smooth or Enum.SurfaceType.Studs;q.BottomSurface=Enum.SurfaceType.Smooth
  q.CastShadow=not glow;q.Parent=parent;count+=1;return q
 end
 local function motion(model,kind,radius)
  model:SetAttribute('IslandMotion',kind);model:SetAttribute('MotionRadius',radius or 0)
  model:SetAttribute('MotionPhase',count*.73);model:SetAttribute('RestPivot',model:GetPivot())
 end
 local function motes(at,kind,n)
  local m=Instance.new('Model');m.Name=kind;m.Parent=folder
  for j=1,n do
   local q=p(m,'Mote',V(.22,.22,.22),at*CF(math.cos(j*2.4)*1.8,j*.7,math.sin(j*2.4)*1.8),light,false)
   q:SetAttribute('MoteIndex',j)
  end
  motion(m,kind,2)
 end
 local function visitor(at,index)
  local m=Instance.new('Model');m.Name=(id=='ScrapBelt' or id=='NebulaCurrent')and 'FlutterBug' or 'SurveyDrone';m.Parent=folder
  local bug=m.Name=='FlutterBug'
  p(m,'Body',bug and V(.8,.65,1.2)or V(2,1.1,1.5),at,accent)
  p(m,'Face',bug and V(.65,.4,.12)or V(1.6,.65,.12),at*CF(0,.1,-(bug and .65 or .81)),dark)
  for _,s in {-1,1}do
   p(m,'Eye',V(.17,.17,.12),at*CF(s*(bug and .18 or .45),.15,-(bug and .74 or .9)),light)
   local wing=p(m,'Wing',bug and V(1.1,.12,1)or V(.65,.22,1.8),at*CF(s*(bug and .8 or 1.3),.2,0),light)
   wing:SetAttribute('WingSide',s)
   if not bug then p(m,'Thruster',V(.4,.22,.4),at*CF(s*1.3,-.23,.3),accent,true)end
  end
  if not bug then p(m,'Antenna',V(.14,.7,.14),at*CF(.6,.85,.1),dark)end
  motion(m,bug and 'Flutter' or 'Survey',bug and 2.5 or 3)
 end
 local sources=island.Props.ExplorationDressing:GetDescendants()
 local visitors=0
 for _,s in sources do if s:IsA('BasePart')then
  local at=s.CFrame;local top=at*CF(0,s.Size.Y*.5,0)
  if s.Name=='FallenLog'then
   for _,side in {-1,1}do
    p(folder,'LogEnd',V(1.65,1.65,.08),at*CF(0,0,side*(s.Size.Z*.5+.045)),light)
    p(folder,'Heartwood',V(.75,.75,.1),at*CF(0,0,side*(s.Size.Z*.5+.1)),accent)
   end
   for j=1,3 do p(folder,'TinyFungus',V(.65,.35,.65),top*CF(.35,.25,j-2),light)end
  elseif s.Name=='FlowerHead'then
   p(folder,'FlowerCenter',V(.55,.2,.55),top*CF(0,.1,0),dark)
   for j=1,4 do local a=j*math.pi*.5;p(folder,'Petal',V(.65,.2,.65),top*CF(math.cos(a)*.68,.08,math.sin(a)*.68),light)end
  elseif s.Name=='CargoCrate'then
   for _,x in {-1.6,1.6}do for _,y in {-1.25,1.25}do
    p(folder,'CrateRivet',V(.22,.22,.13),at*CF(x,y,-2.08),light)
   end end
   p(folder,'CargoLabel',V(1.3,.65,.12),at*CF(0,.15,-2.08),dark)
   p(folder,'LabelStripe',V(.8,.16,.13),at*CF(0,.15,-2.15),light)
   p(folder,'CrateHandle',V(.8,.2,.35),top*CF(0,.15,0),dark)
  elseif s.Name=='OreFragment'then motes(top*CF(0,.3,0),'Sparks',3)
  elseif s.Name=='IceShelfFragment'then
   for j=1,3 do p(folder,'IceFissure',V(.1,.03,1.6),top*CF(j-2,.025,0)*CFrame.Angles(0,j*.7,0),accent)end
   motes(top*CF(0,1,0),'Snow',4)
  elseif s.Name=='CrystalSpire'then
   p(folder,'CrystalGlint',V(.15,.65,.15),top*CF(0,.4,0),light,true)
   motes(top,'Shimmer',3)
  elseif s.Name=='SporeHead'then
   for j=1,4 do p(folder,'MushroomSpot',V(.6,.12,.6),top*CF(math.cos(j*2.4),.07,math.sin(j*2.4)),accent)end
   motes(top*CF(0,.3,0),'Spores',4)
   -- Animate only the cap and its spots together, keeping the rooted stalk still.
   local cap=Instance.new('Model');cap.Name='BreathingCap';cap.Parent=folder
   local copy=s:Clone();copy.CanCollide=false;copy.CanTouch=false;copy.CanQuery=false;copy.Parent=cap
   s.Transparency=1
   for _,q in folder:GetChildren()do if q:IsA('BasePart')and q.Name=='MushroomSpot'and(q.Position-s.Position).Magnitude<4 then q.Parent=cap end end
   motion(cap,'Breathe',0)
  elseif s.Name=='BrokenColumn'then
   p(folder,'RunePlaque',V(1.5,1.4,.12),at*CF(0,0,-1.57),dark)
   for j=1,3 do p(folder,'RuneStroke',V(.16,.7,.12),at*CF((j-2)*.37,0,-1.66)*CFrame.Angles(0,0,j*.3),accent)end
   motes(top*CF(0,1.4,0),'Runes',3)
  elseif s.Name=='CourtyardSlab'then
   for j=1,3 do p(folder,'CourtyardInlay',V(.2,.04,2.3),top*CF(j-2,.035,-.4),accent)end
  elseif s.Name=='DamagedGenerator'then
   for _,side in {-1,1}do
    p(folder,'GeneratorFoot',V(.65,.4,3),at*CF(side*1.8,-1.3,0),dark)
    p(folder,'Gauge',V(.6,.6,.15),at*CF(side*1.5,.45,-2.08),light)
    local lamp=p(folder,'StatusLamp',V(.3,.3,.15),at*CF(side*1.5,.45,-2.18),accent,true)
    lamp:SetAttribute('IslandPulse',true);lamp:SetAttribute('PulsePhase',count*.4)
   end
   motes(top*CF(0,.5,0),'Sparks',4)
  end
  if visitors<6 and (s.Name=='FallenLog'or s.Name=='CargoCrate'or s.Name=='IceShelfFragment'or s.Name=='SporeHead'or s.Name=='BrokenColumn'or s.Name=='DamagedGenerator')then
   visitors+=1;visitor(top*CF(0,3.5,0),visitors)
  end
 end end
 island:SetAttribute('IslandLifeDetailed',true)
 table.insert(results,{Id=id,DetailParts=count,AmbientVisitors=visitors})
 task.wait()
end
return results
