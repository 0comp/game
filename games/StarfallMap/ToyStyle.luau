-- User art direction: chunky, colorful Roblox plastic with exposed studs.
local C=Color3.fromRGB;local V=Vector3.new
local root=workspace.StarfallMap
local palette={
 {C(29,43,57),C(45,91,169)}, {C(99,119,133),C(141,167,194)},
 {C(166,183,191),C(237,243,250)}, {C(12,22,32),C(27,46,83)},
 {C(227,148,66),C(255,190,54)}, {C(101,214,228),C(88,221,255)},
 {C(221,231,231),C(249,250,255)}, {C(60,76,88),C(111,140,179)},
}
for _,o in root.Hub:GetDescendants()do
 if o:IsA('BasePart')and not o:IsA('MeshPart')then
  if o.Material~=Enum.Material.Neon and o.Material~=Enum.Material.Glass then o.Material=Enum.Material.Plastic;o.Reflectance=0 end
  for _,pair in palette do if (o.Color.R-pair[1].R)^2+(o.Color.G-pair[1].G)^2+(o.Color.B-pair[1].B)^2<.0001 then o.Color=pair[2];break end end
  if o.Size.X>=4 and o.Size.Z>=4 and o.CFrame.UpVector.Y>.95 and o.Material==Enum.Material.Plastic then o.TopSurface=Enum.SurfaceType.Studs end
  if o.Name=='DoorColumn'or o.Name=='DoorChamfer'then o.Color=C(242,246,255)end
 elseif o:IsA('TextLabel')then o.Font=Enum.Font.FredokaOne
 elseif o:IsA('PointLight')then o.Brightness=math.min(o.Brightness,.5)end
end
local function paintMesh(p,color)
 p.TextureID='';p.Color=color;p.Material=Enum.Material.Plastic;p.Reflectance=0;p.CastShadow=true
 for _,s in p:GetChildren()do if s:IsA('SurfaceAppearance')then s:Destroy()end end
end
for _,o in root:GetDescendants()do if o:IsA('MeshPart')then
 local color=C(112,126,153)
 if o:IsDescendantOf(root.Hub)or (o:IsDescendantOf(root.Sectors.DerelictField)and (string.find(o.Name,'hull')or string.find(o.Name,'wings')or string.find(o.Name,'engines')))then
  color=string.find(o.Name,'engines')and C(255,174,55)or string.find(o.Name,'wings')and C(55,127,218)or C(239,245,255)
 elseif o:IsDescendantOf(root.Sectors.IceGraveyard)then color=C(133,226,255)
 elseif o:IsDescendantOf(root.Sectors.AncientRuins)then color=o.Name=='body_geom'and C(106,90,151)or C(146,101,215)
 elseif o:IsDescendantOf(root.Sectors.ScrapBelt)then color=C(143,130,158)
 elseif o:IsDescendantOf(root.Sectors.NebulaCurrent)then color=C(116,101,170)
 end
 paintMesh(o,color)
end end
-- Small studded armor plates tie the sculpted craft to the building kit.
local armor=Instance.new('Model');armor.Name='StuddedShipArmor';armor.Parent=root.Hub
for _,ship in root.Hub.DockedFleet:GetChildren()do
 local cf,size=ship:GetBoundingBox();local top=cf.Position.Y+size.Y*.5
 for _,side in {-1,1}do
  local plate=Instance.new('Part');plate.Name='WingArmor';plate.Size=V(size.X*.23,.55,size.Z*.17);plate.CFrame=CFrame.new(cf.Position.X+side*size.X*.28,top-2,cf.Position.Z);plate.Color=C(59,132,222);plate.Material=Enum.Material.Plastic;plate.TopSurface=Enum.SurfaceType.Studs;plate.Anchored=true;plate.CanCollide=false;plate.Parent=armor
 end
end
-- Give the landings bright, studded play surfaces instead of metal plates.
for _,p in root.Hub.LandingPads:GetChildren()do
 if p:IsA('BasePart')and p.Name=='PadBase'then p.Color=C(50,100,181);p.Material=Enum.Material.Plastic;p.TopSurface=Enum.SurfaceType.Studs end
end
-- A smooth invisible collision ramp makes the visible studded stairs walkable.
local stairs=root.Hub.ObservationStairs
for _,p in stairs:GetChildren()do if p:IsA('BasePart')and(p.Name=='Step'or p.Name=='StepNosing')then p.CanCollide=false end end
local ramp=Instance.new('WedgePart');ramp.Name='StairCollisionRamp';ramp.Size=V(12,44.5,72);ramp.CFrame=CFrame.new(64,52.25,-53);ramp.Transparency=1;ramp.Anchored=true;ramp.Parent=stairs
local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Include;params.FilterDescendantsInstances={ramp}
local near=workspace:Raycast(V(64,120,-20),V(0,-130,0),params)
local far=workspace:Raycast(V(64,120,-86),V(0,-130,0),params)
if near and far and near.Position.Y>far.Position.Y then ramp.CFrame*=CFrame.Angles(0,math.pi,0)end
-- Remove the cloud diagnostics; use actual faceted meshes for a toy nebula backdrop.
for _,a in root.Backdrop:GetChildren()do if a.Name=='NebulaAnchor'then a:Destroy()end end
local clouds=Instance.new('Model');clouds.Name='ToyNebulaClouds';clouds.Parent=root.Backdrop
local kit=game.ServerStorage.StarfallMeshKit
for band,d in {{V(-480,270,-710),C(100,80,176)},{V(480,230,-760),C(155,80,173)},{V(-620,280,520),C(62,126,184)}}do
 for i=1,5 do
  local m=kit.Asteroid:Clone();m.Name='CloudPuff';local cf,size=m:GetBoundingBox();m.WorldPivot=cf;m:ScaleTo((155+i*10)/math.max(size.X,size.Y,size.Z));m:PivotTo(CFrame.new(d[1]+V((i-3)*65,math.sin(i)*30,math.cos(i)*20))*CFrame.Angles(i*.3,i*.5,i*.1))
  for _,p in m:GetDescendants()do if p:IsA('MeshPart')then paintMesh(p,d[2]);p.Material=Enum.Material.Neon;p.Transparency=.91;p.Anchored=true;p.CanCollide=false;p.CastShadow=false end end
  m.Parent=clouds
 end
end
local L=game.Lighting;L.Ambient=C(144,158,185);L.OutdoorAmbient=C(144,158,185);L.Brightness=2;L.ExposureCompensation=.05
L.StarfallColor.Contrast=.04;L.StarfallColor.Saturation=.12
L.StarfallBloom.Intensity=.12;L.StarfallBloom.Threshold=2
return {Style='Studded Roblox plastic',StairRamp=ramp.CFrame.Position,MeshTexturesRemoved=true}
