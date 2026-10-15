local hub=workspace.StarfallMap.Hub
local C=Color3.fromRGB
local V=Vector3.new
local function p(parent,name,size,cf,color,mat)
 local o=Instance.new('Part');o.Name=name;o.Size=size;o.CFrame=cf;o.Color=color;o.Material=mat or Enum.Material.SmoothPlastic;o.Anchored=true;o.CanCollide=false;o.CanTouch=false;o.CastShadow=true;o.Parent=parent;return o
end
local fleet=Instance.new('Model');fleet.Name='DockedFleet'
for i,position in {V(-78,35,0),V(78,35,0)} do
 local ship=Instance.new('Model');ship.Name=i==1 and 'SalvageShuttle' or 'SurveyProbe';ship.Parent=fleet
 local cf=CFrame.new(position)*CFrame.Angles(0,i==1 and math.pi/2 or -math.pi/2,0)
 local paint=i==1 and C(218,164,78) or C(100,171,196)
 p(ship,'Hull',V(9,5,22),cf,C(71,83,107))
 p(ship,'TopArmor',V(7,2,13),cf*CFrame.new(0,3,2),paint)
 p(ship,'Cockpit',V(6,2.5,6),cf*CFrame.new(0,3,-7),C(79,227,255),Enum.Material.Neon)
 for _,side in {-1,1} do
  p(ship,'Wing',V(10,1,10),cf*CFrame.new(side*8,-1,4)*CFrame.Angles(0,side*.3,0),paint)
  p(ship,'Engine',V(3,3,7),cf*CFrame.new(side*5,0,11),C(28,35,54))
  p(ship,'Thruster',V(2,2,.5),cf*CFrame.new(side*5,0,14.6),C(88,219,255),Enum.Material.Neon)
 end
end
fleet.Parent=hub
local crates=Instance.new('Model');crates.Name='StationCargo'
for i=1,10 do
 local side=i<=5 and -1 or 1;local x=side*(48+(i%2)*5);local z=-24+(i%5)*7
 p(crates,'CargoBox',V(5,4,5),CFrame.new(x,33,z),C(74,90,110))
 p(crates,'Latch',V(.5,2,.4),CFrame.new(x,33,z-2.6),C(255,184,76),Enum.Material.Neon)
end
crates.Parent=hub
return 'Added docked ships and station cargo'
