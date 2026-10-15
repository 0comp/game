local C=Color3.fromRGB;local V=Vector3.new
local root=workspace.StarfallMap;local kit=game.ServerStorage.StarfallMeshKit
if not kit:FindFirstChild('IceMoon') then
 local ice=game.CollectionService:GetTagged('Assistant-09f6ffe9-3ec9-4e30-8018-d54e46c176b2')[1];assert(ice,'Ice mesh is required');ice.Name='IceMoon';ice.Parent=kit
end
local function model(name,parent)local m=Instance.new('Model');m.Name=name;m.Parent=parent;return m end
local function p(parent,name,size,cf,color,mat)
 local o=Instance.new('Part');o.Name=name;o.Size=size;o.CFrame=cf;o.Color=color;o.Material=mat or Enum.Material.SmoothPlastic;o.Anchored=true;o.CanCollide=false;o.CanTouch=false;o.CastShadow=false;o.Parent=parent;return o
end
local function line(parent,name,a,b,w,color,alpha)
 local o=p(parent,name,V(w,w,(b-a).Magnitude),CFrame.lookAt((a+b)*.5,b),color,Enum.Material.Neon);o.Transparency=alpha or 0;return o
end
local function asset(key,parent,name,pos,maxSize,rotation)
 local m=kit[key]:Clone();m.Name=name
 local cf,size=m:GetBoundingBox();m.WorldPivot=cf;m:ScaleTo(maxSize/math.max(size.X,size.Y,size.Z));m:PivotTo(CFrame.new(pos)*(rotation or CFrame.new()))
 for _,o in m:GetDescendants()do if o:IsA('BasePart')then o.Anchored=true;o.CanCollide=false;o.CanTouch=false end end
 m.Parent=parent;return m
end
local sectors=model('Sectors',root);local routes=model('Routes',root)
local rand=Random.new(483)
local centers={ScrapBelt=V(-215,60,65),IceGraveyard=V(-305,135,-225),DerelictField=V(80,150,-340),NebulaCurrent=V(-235,150,300),AncientRuins=V(280,70,195),SingularityEdge=V(385,200,-120)}
local colors={ScrapBelt=C(216,155,88),IceGraveyard=C(108,204,226),DerelictField=C(113,156,197),NebulaCurrent=C(131,100,196),AncientRuins=C(164,108,207),SingularityEdge=C(215,92,146)}
for id,center in centers do
 local m=model(id,nil);m:SetAttribute('SectorId',id);m:SetAttribute('LandmarkCenter',center)
 local color=colors[id]
 -- Debris follows an uneven arc instead of identical circular pedestals.
 for i=1,12 do
  local a=i*.48;local r=rand:NextNumber(45,90)
  asset('Asteroid',m,'Debris',center+V(math.cos(a)*r,rand:NextNumber(-30,18),math.sin(a)*r),rand:NextNumber(8,22),CFrame.Angles(rand:NextNumber(),a,rand:NextNumber()))
 end
 if id=='ScrapBelt' then
  asset('Asteroid',m,'SalvageAsteroid',center,86,CFrame.Angles(.25,.5,-.2))
  local rig=model('SalvageRig',m)
  p(rig,'Platform',V(38,3,27),CFrame.new(center+V(0,35,0)),C(64,78,87))
  for _,x in {-14,14}do p(rig,'CraneTower',V(3,35,4),CFrame.new(center+V(x,53,-7)),C(201,139,71))end
  p(rig,'CraneArm',V(47,4,4),CFrame.new(center+V(4,70,-7))*CFrame.Angles(0,0,-.12),C(201,139,71))
  line(rig,'Cable',center+V(23,69,-7),center+V(23,42,-7),.35,C(96,116,128),.2)
  for i=1,5 do p(rig,'Cargo',V(6,5,8),CFrame.new(center+V(-12+i*5,39,5)),i%2==0 and color or C(56,68,79))end
 elseif id=='IceGraveyard' then
  asset('IceMoon',m,'ShatteredMoon',center+V(0,25,0),135,CFrame.Angles(.6,.4,-.25))
  for i=1,4 do asset('IceMoon',m,'FrozenFragment',center+V(-65+i*32,-45-i*5,55+i*8),rand:NextNumber(15,32),CFrame.Angles(i,.2*i,.4*i))end
 elseif id=='DerelictField' then
  local wreck=asset('Derelict',m,'BrokenCarrier',center+V(0,28,0),200,CFrame.Angles(.13,-.3,.16))
  local pivot=wreck:GetPivot()
  for _,piece in wreck:GetDescendants()do if piece:IsA('BasePart')then
   local rel=pivot:ToObjectSpace(piece.CFrame);local offset=rel.Position
   piece.Size=piece.Size*V(1,1,1.5);piece.CFrame=pivot*CFrame.new(offset*V(1,1,1.5))*rel.Rotation
   if string.find(piece.Name,'engines')then piece.CFrame=piece.CFrame*pivot.Rotation:Inverse()*CFrame.new(0,8,38)*pivot.Rotation*CFrame.Angles(.08,0,.13)end
   if string.find(piece.Name,'wings')then piece.CFrame=piece.CFrame*CFrame.new(0,14,7)*CFrame.Angles(0,-.08,.12)end
  end end
  for i=1,6 do line(m,'ExposedHullRib',center+V(-22,10,-15+i*9),center+V(22,20,-15+i*9),1.3,C(78,90,101),.4)end
 elseif id=='AncientRuins' then
  asset('Asteroid',m,'TempleFragment',center,125,CFrame.Angles(.1,.5,.08))
  asset('AlienGate',m,'AncientGateway',center+V(0,89,0),145,CFrame.Angles(0,-.4,0))
  for i=1,4 do
   local theta=i*math.pi*.5
   local pos=center+V(math.cos(theta)*53,12,math.sin(theta)*53)
   asset('Asteroid',m,'FloatingSanctum',pos,24,CFrame.Angles(i,.4*i,.2))
   local light=p(m,'RelicShard',V(1.8,13,1.8),CFrame.new(pos+V(0,17,0))*CFrame.Angles(0,.5,.2),color,Enum.Material.Neon);light.Transparency=.35
  end
 elseif id=='NebulaCurrent' then
  local core=p(m,'Pulsar',V(8,8,8),CFrame.new(center),C(189,207,255),Enum.Material.Neon);core.Shape=Enum.PartType.Ball
  for arm=1,3 do
   local previous=nil
   for i=0,36 do
    local a=arm*math.pi*2/3+i*.16;local r=12+i*2.3
    local pos=center+V(math.cos(a)*r,math.sin(a*1.5)*12,math.sin(a)*r*.65)
    if previous then line(m,'IonFilament',previous,pos,1.2+i*.04,arm==2 and C(89,151,201)or color,.45+i*.008)end
    previous=pos
   end
  end
 elseif id=='SingularityEdge' then
  local hole=p(m,'EventHorizon',V(88,88,88),CFrame.new(center),C(0,0,0),Enum.Material.Neon);hole.Shape=Enum.PartType.Ball
  local tilt=CFrame.new(center)*CFrame.Angles(.35,0,.2)
  for ring=1,4 do
   local r=45+ring*8;local previous=nil
   for i=0,80 do
    local a=i*math.pi*2/80;local pos=(tilt*CFrame.new(math.cos(a)*r,math.sin(a*3)*.5,math.sin(a)*r)).Position
    if previous then line(m,'AccretionStream',previous,pos,ring==1 and 1.7 or .8,ring==1 and C(246,204,221)or color,ring==1 and .13 or .65)end
    previous=pos
   end
  end
 end
 local direction=V(center.X,0,center.Z).Unit
 local start=direction*120+V(0,25,0);local finish=center-direction*100
 line(routes,'SubtleRoute_'..id,start,finish,.18,color,.86)
 m.Parent=sectors;task.wait()
end
-- Reuse the sculpted ship kit at believable landing-pad and hangar scale.
local fleet=model('DockedFleet',root.Hub)
for i,d in {{V(-49,38,53),43,.2},{V(49,37,53),33,-.35},{V(-10,40,-57),50,.05}}do asset('Derelict',fleet,i==3 and 'HangarSurveyShip' or 'SalvageShuttle',d[1],d[2],CFrame.Angles(0,d[3],0))end
local backdrop=model('Backdrop',nil)
local planet=p(backdrop,'DistantPlanet',V(260,260,260),CFrame.new(-620,230,-770),C(48,64,94));planet.Shape=Enum.PartType.Ball
local moon=asset('Asteroid',backdrop,'DistantBrokenMoon',V(600,250,600),130,CFrame.Angles(.2,.6,0))
for i=1,180 do
 local a=rand:NextNumber(0,math.pi*2);local r=rand:NextNumber(720,940)
 local star=p(backdrop,'Star',V(1,1,1),CFrame.new(math.cos(a)*r,rand:NextNumber(-200,650),math.sin(a)*r),C(168,184,214),Enum.Material.Neon)
 local b=Instance.new('BillboardGui');b.Size=UDim2.fromOffset(i%11==0 and 3 or 1.5,i%11==0 and 3 or 1.5);b.MaxDistance=3000;b.Parent=star
 local dot=Instance.new('Frame');dot.Size=UDim2.fromScale(1,1);dot.BorderSizePixel=0;dot.BackgroundColor3=star.Color;dot.BackgroundTransparency=.2;dot.Parent=b
end
-- Sparse layered nebula sprites give depth without covering the player's foreground.
for i,d in {{V(-460,270,-700),500,C(53,57,102)},{V(480,190,-770),650,C(74,42,85)},{V(-600,320,580),460,C(32,67,90)}}do
 local a=p(backdrop,'NebulaAnchor',V(1,1,1),CFrame.new(d[1]),C(0,0,0));a.Transparency=1
 local b=Instance.new('BillboardGui');b.Size=UDim2.new(d[2],0,d[2]*.7,0);b.MaxDistance=3000;b.LightInfluence=0;b.Parent=a
 local img=Instance.new('ImageLabel');img.Size=UDim2.fromScale(1,1);img.BackgroundTransparency=1;img.Image='rbxasset://textures/particles/smoke_main.dds';img.ImageColor3=d[3];img.ImageTransparency=.35;img.Rotation=i*31;img.Parent=b
end
backdrop.Parent=root
return {Sectors=#sectors:GetChildren(),Meshes=#root:GetDescendants()}
