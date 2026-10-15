-- Readable toy planet silhouettes replace the scattered first-pass dioramas.
local C=Color3.fromRGB;local V=Vector3.new;local CF=CFrame.new
local root=workspace.StarfallMap
assert(not root:GetAttribute('PlanetVista'),'Planet vista already applied')
local backup=Instance.new('Folder');backup.Name='StarfallBeforePlanetVista';backup.Parent=game.ServerStorage
for _,name in {'Sectors','Routes','Backdrop'}do local o=root:FindFirstChild(name);if o then o.Parent=backup end end
local function part(parent,name,size,cf,color,studs)
 local p=Instance.new('Part');p.Name=name;p.Size=size;p.CFrame=cf;p.Color=color;p.Material=Enum.Material.Plastic
 p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.TopSurface=studs and Enum.SurfaceType.Studs or Enum.SurfaceType.Smooth
 p.BottomSurface=Enum.SurfaceType.Smooth;p.Parent=parent;return p
end
local sectors=Instance.new('Model');sectors.Name='Sectors';sectors.Parent=root
local definitions={
 {'ScrapBelt',V(-270,110,-190),40,C(67,151,171),C(128,191,78),C(213,165,95)},
 {'IceGraveyard',V(-510,180,120),53,C(91,175,208),C(220,240,230),C(146,217,226)},
 {'DerelictField',V(310,140,-310),48,C(187,113,66),C(219,155,89),C(112,82,85)},
 {'NebulaCurrent',V(80,230,-650),58,C(128,91,183),C(99,173,181),C(180,138,207)},
 {'AncientRuins',V(550,160,190),62,C(147,157,94),C(205,190,126),C(116,139,133)},
 {'SingularityEdge',V(-80,260,700),57,C(49,43,82),C(102,69,132),C(169,112,174)},
}
for index,d in definitions do
 local m=Instance.new('Model');m.Name=d[1];m:SetAttribute('VistaOnly',true);m.Parent=sectors
 local center,r=d[2],d[3];local body=part(m,'Planet',V(r*2,r*2,r*2),CF(center),d[4]);body.Shape=Enum.PartType.Ball
 local facing=CFrame.lookAt(center,V(0,35,0))
 for group,offset in {Vector2.new(0,0),Vector2.new(1.8,.3),Vector2.new(-1.8,-.35)}do
  for n,cell in {Vector2.new(0,0),Vector2.new(-1,0),Vector2.new(1,0),Vector2.new(0,-1),Vector2.new(0,1),Vector2.new(1,1),Vector2.new(-1,-1)}do
   local latitude=offset.Y+cell.Y*.21;local longitude=offset.X+cell.X*.21
   local localDir=V(math.sin(longitude)*math.cos(latitude),math.sin(latitude),-math.cos(longitude)*math.cos(latitude))
   local dir=facing:VectorToWorldSpace(localDir);local pos=center+dir*(r-.7)
   local cf=CFrame.lookAt(pos,pos+dir)*CFrame.Angles(-math.pi*.5,0,0)
   part(m,'ContinentPlate',V(r*.24,2.5,r*.24),cf,group==2 and d[6]or d[5],true)
  end
 end
 if index==2 or index==6 then
  local plane=CF(center)*CFrame.Angles(.2,0,index==2 and -.4 or .45)
  local outer=part(m,'RingSource',V(1.2,r*3.15,r*3.15),plane*CFrame.Angles(0,0,math.pi*.5),index==2 and C(184,214,219)or C(181,125,180));outer.Shape=Enum.PartType.Cylinder
  local inner=part(m,'RingCutter',V(6,r*2.8,r*2.8),outer.CFrame,d[4]);inner.Shape=Enum.PartType.Cylinder
  local ring=outer:SubtractAsync({inner},Enum.CollisionFidelity.Box,Enum.RenderFidelity.Precise)
  ring.Name='OrbitRing';ring.UsePartColor=true;ring.Color=outer.Color;ring.Anchored=true;ring.CanCollide=false;ring.CanTouch=false;ring.Parent=m
  outer:Destroy();inner:Destroy()
 end
 if index==3 then
  for n=1,7 do
   local a=n*math.pi*2/7;local pos=center+V(math.cos(a)*r*1.6,math.sin(a*2)*14,math.sin(a)*r*1.6)
   part(m,'SmallAsteroid',V(7+n%3,6+n%2,8),CF(pos)*CFrame.Angles(n*.3,n*.7,.2),C(74,79,89),true)
  end
 end
 task.wait()
end
local routes=Instance.new('Model');routes.Name='Routes';routes.Parent=root
local courier=Instance.new('Model');courier.Name='CourierShuttle';courier:SetAttribute('DisplayOnly',true);courier.Parent=routes
local base=CF(-160,70,-120)
local hull=part(courier,'Hull',V(2.5,1.5,6),base,C(229,227,207),true);courier.PrimaryPart=hull
part(courier,'Cockpit',V(2,1,2),base*CF(0,1,-1.5),C(52,84,112))
part(courier,'Wing',V(6,.4,2.5),base*CF(0,-.3,1),C(236,137,57),true)
for _,x in {-2,2}do
 part(courier,'Engine',V(1.2,1.2,3),base*CF(x,0,1),C(42,58,70),true)
 local glow=part(courier,'Exhaust',V(.8,.8,.2),base*CF(x,0,2.7),C(111,224,239));glow.Material=Enum.Material.Neon;glow.CastShadow=false
end
root:SetAttribute('PlanetVista',true)
return {PlanetVistas=#sectors:GetChildren(),Archived=backup:GetFullName()}
