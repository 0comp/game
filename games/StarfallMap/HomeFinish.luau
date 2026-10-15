-- Clean ground joins and finish both market stalls on every visible side.
local C=Color3.fromRGB;local V=Vector3.new;local CF=CFrame.new
local hub=workspace.StarfallMap.Hub;local Y=30
assert(not hub:GetAttribute('SurfaceFinish'),'Home finish already applied')
local backup=Instance.new('Folder');backup.Name='StarfallBeforeSurfaceFinish';backup.Parent=game.ServerStorage
hub:Clone().Parent=backup
local P={path=C(213,176,120),wood=C(130,83,50),cream=C(231,226,204),dark=C(42,59,69),glass=C(72,119,143),gold=C(247,198,82)}
local function part(parent,name,size,cf,color,studs)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=Enum.Material.Plastic
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.TopSurface=studs and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local function model(name,parent)local m=Instance.new('Model');m.Name=name;m.Parent=parent;return m end
local function sign(parent,text,cf,w,h,color)
 local p=part(parent,'Sign',V(w,h,.22),cf,P.dark)
 for _,face in {Enum.NormalId.Front,Enum.NormalId.Back}do
  local g=Instance.new('SurfaceGui');g.Face=face;g.SizingMode=Enum.SurfaceGuiSizingMode.PixelsPerStud;g.PixelsPerStud=20;g.LightInfluence=0;g.Parent=p
  local t=Instance.new('TextLabel');t.Size=UDim2.fromScale(.94,.86);t.Position=UDim2.fromScale(.03,.07);t.BackgroundTransparency=1
  t.Font=Enum.Font.Arcade;t.Text=text;t.TextScaled=true;t.TextColor3=color;t.Parent=g
 end
end
local function beam(parent,a,b,w,color)
 part(parent,'TimberBrace',V(w,w,(b-a).Magnitude),CFrame.lookAt((a+b)*.5,b),color,true)
end

-- Each plot gets one continuous path. The plaza and angled paths share cut
-- boundaries; small smooth junction aprons prevent doubled rotated stud patterns.
local paths=model('FinishedWalkingPaths',hub)
local market=part(paths,'MarketWalk',V(72,.4,18),CF(0,Y+.2,18),P.path,true);market.CanCollide=true
for index=1,6 do
 local a=-math.pi*.5+(index-1)*math.pi/3;local dir=V(math.cos(a),0,math.sin(a))
 local inner=index==4 and 27 or 26
 if index==3 or index==5 then
  local outside=(36+4*math.abs(dir.Z))/math.abs(dir.X)
  local head=part(paths,'JunctionSource',V(8,.4,outside-inner),CFrame.lookAt(dir*((outside+inner)*.5),dir*((outside+inner)*.5)-dir)*CF(0,Y+.2,0),P.path)
  local cutter=part(paths,'JunctionCutter',V(72,4,18),CF(0,Y,18),P.path)
  local apron=head:SubtractAsync({cutter},Enum.CollisionFidelity.PreciseConvexDecomposition,Enum.RenderFidelity.Precise)
  apron.Name='JunctionApron'..index;apron.Anchored=true;apron.UsePartColor=true;apron.Color=P.path;apron.Material=Enum.Material.Plastic
  apron.CanCollide=true;apron.CanTouch=false;apron.Parent=paths;head:Destroy();cutter:Destroy()
  inner=outside
 end
 local outer=73
 local frame=CFrame.lookAt(dir*((inner+outer)*.5),dir*((inner+outer)*.5)-dir)
 part(paths,'PlotApproach'..index,V(8,.4,outer-inner),frame*CF(0,Y+.2,0),P.path,true).CanCollide=true
end
hub.WalkingPaths.Parent=backup;paths.Name='WalkingPaths'

for index=1,6 do
 local plot=hub.Plots[string.format('Plot%02d',index)]
 local cf=plot.Terrain.Lawn.CFrame*CF(0,-29.5,0)
 plot.EntrancePath.Parent=backup
 -- Borders finish outside the eight-stud lane rather than underneath it.
 local pad=plot.ShipPad
 pad.PadBorder.Size=V(13.5,.4,24);pad.PadBorder.CFrame=cf*CF(-11,Y+.2,1)
 pad.PadTop.Size=V(12.5,.3,22);pad.PadTop.CFrame=cf*CF(-11,Y+.55,1);pad.PadTop.TopSurface=Enum.SurfaceType.Smooth
 pad.StarterShip:PivotTo(pad.StarterShip:GetPivot()+V(0,.46,0))
 local grass=plot.PetGarden.GardenGrass;grass.Size=V(15,.4,26);grass.CFrame=cf*CF(12,Y+.2,1)
 for _,tile in plot.PetGarden:GetChildren()do if tile.Name=='PetDisplayTile'then
  tile.CFrame+=V(0,30.66-tile.Position.Y,0)
 end end
 for _,anchor in plot.PetGarden.PlacementAnchors:GetChildren()do anchor.CFrame+=V(0,30.8-anchor.Position.Y,0)end
 local trimCount=0
 for _,o in hub.WorldPolish['PlotDetail'..index]:GetChildren()do
  if o.Name=='PadTrim'then
   trimCount+=1;local side=trimCount==1 and -1 or 1;o.CFrame=cf*CF(-11+side*6,Y+.74,1)
  elseif o.Name=='FoodBowl' or o.Name=='BowlInset'then o.CFrame+=cf:VectorToWorldSpace(V(-.6,.4,0))end
 end
 -- Underlying lawn studs remain below the raised walk instead of bleeding through it.
 local link=plot.Terrain.LinkGround;link.CFrame+=V(0,-.28,0)
 task.wait()
end

local launch=hub.PublicArea.LaunchPad
launch.PadBorder.Size=V(27,.4,29);launch.PadBorder.CFrame=CF(0,Y+.2,-7)
launch.PadSurface.Size=V(24,.3,26);launch.PadSurface.CFrame=CF(0,Y+.55,-7);launch.PadSurface.TopSurface=Enum.SurfaceType.Smooth
launch.StarterShip:PivotTo(launch.StarterShip:GetPivot()+V(0,.32,0))
for _,o in launch:GetChildren()do
 if o.Name=='PaintStripe'then o.CFrame+=V(0,.32,0)
 elseif o.Name=='Bumper'then o.CFrame+=V(0,.4,0)end
end
launch.PadSurface.LaunchAnchor.CFrame=CF(0,.15,0)
for _,o in hub.WorldPolish.LaunchDetail:GetChildren()do
 if o.Name=='PadHazard'then o.CFrame+=V(0,.28,0)
 elseif o.Name=='PadSide'then o.CFrame+=V(0,.25,0)end
end

local wraps=model('ShopWrap',hub.WorldPolish)
for index,shop in {hub.PublicArea.Shops.PetShop,hub.PublicArea.Shops.ShipShop}do
 local x=shop.BackWall.Position.X;local accent=shop.Canopy.Color
 local detail=model(shop.Name..'Exterior',nil)
 shop.Floor.Size=V(16,.4,14);shop.Floor.CFrame=CF(x,Y+.2,-1)
 -- Low side walls leave the stall welcoming and keep the shopkeeper visible.
 for _,side in {-1,1}do
  local sx=x+side*6.7
  part(detail,'RearCornerPost',V(.9,10,.9),CF(sx,Y+5,-6),P.wood,true).CanCollide=true
  part(detail,'SideWall',V(.45,2.8,10),CF(sx,Y+1.4,-1),P.cream,true).CanCollide=true
  part(detail,'SidePanel',V(.16,1.4,8.7),CF(sx+side*.32,Y+1.2,-1),accent,true)
  part(detail,'SideRail',V(.7,.35,10.3),CF(sx,Y+2.95,-1),P.wood,true)
  beam(detail,V(sx,Y+9.7,-5.6),V(sx,Y+7.2,-3.3),.4,P.wood)
  beam(detail,V(sx,Y+9.7,3.6),V(sx,Y+7.2,1.3),.4,P.wood)
  for _,z in {-2.7,.7}do part(detail,'SideSignSupport',V(.28,3,.28),CF(sx+side*.22,Y+4.5,z),P.wood,true)end
  sign(detail,index==1 and 'PETS' or 'SHIP WORKS',CF(sx+side*.4,Y+5.6,-1)*CFrame.Angles(0,side*math.pi*.5,0),5.5,1.7,P.cream)
  -- Framed rear windows have layered depths so their faces never share a plane.
  local wx=x+side*4.5
  part(detail,'RearWindowFrame',V(3.5,2.8,.2),CF(wx,Y+4.8,-7.12),accent,true)
  part(detail,'RearWindowGlass',V(2.9,2.2,.12),CF(wx,Y+4.8,-7.3),P.glass)
  part(detail,'WindowMullion',V(.2,2.2,.1),CF(wx,Y+4.8,-7.42),P.cream)
  part(detail,'WindowMullion',V(2.9,.2,.1),CF(wx,Y+4.8,-7.42),P.cream)
  part(detail,'WindowSill',V(3.8,.3,.65),CF(wx,Y+3.3,-7.3),P.wood,true)
  part(detail,'RearWainscot',V(5,1.5,.18),CF(wx,Y+.85,-7.15),accent,true)
 end
 part(detail,'DoorFrame',V(3.3,6.2,.22),CF(x,Y+3.1,-7.12),P.wood,true)
 part(detail,'ServiceDoor',V(2.7,5.6,.16),CF(x,Y+3,-7.33),accent,true)
 part(detail,'DoorWindow',V(1.9,1.3,.12),CF(x,Y+4.6,-7.5),P.dark)
 part(detail,'DoorHandle',V(.25,.5,.23),CF(x+.85,Y+2.7,-7.5),P.gold)
 sign(detail,index==1 and 'PET EXCHANGE' or 'SHIP WORKS',CF(x,Y+7.2,-7.28),12,1.1,P.cream)
 -- Fascia wraps the roof, hiding raw stripe ends from rear and side views.
 for _,z in {-8.65,6.65}do part(detail,'RoofFascia',V(16.4,.65,.35),CF(x,Y+10.7,z),accent,true)end
 for _,side in {-1,1}do part(detail,'RoofFascia',V(.35,.65,15.6),CF(x+side*8.05,Y+10.7,-1),accent,true)end
 part(detail,'RoofVent',V(2.6,.65,2.2),CF(x+3.8,Y+11.45,-4),P.dark,true)
 for j=1,4 do part(detail,'VentSlat',V(2,.1,.18),CF(x+3.8,Y+11.83,-4.75+j*.3),P.cream)end
 local lamp=part(detail,'RearLantern',V(.7,.9,.7),CF(x+5.8,Y+6.7,-7.7),P.gold)
 part(detail,'LanternHood',V(1,.2,1),CF(x+5.8,Y+7.25,-7.7),P.dark,true)
 local light=Instance.new('PointLight');light.Color=P.gold;light.Brightness=.3;light.Range=7;light.Parent=lamp
 detail.Parent=wraps;task.wait()
end
hub:SetAttribute('SurfaceFinish',true)
return {Plots=#hub.Plots:GetChildren(),Paths=#paths:GetChildren(),ShopExteriors=#wraps:GetChildren(),Backup=backup:GetFullName()}
