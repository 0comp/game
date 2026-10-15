local C=Color3.fromRGB
local root=workspace.StarfallMap
local backup=game.ServerStorage:FindFirstChild('StarfallOriginalScene')
local lightingBackup=Instance.new('Folder');lightingBackup.Name='Lighting';lightingBackup.Parent=backup
for _,effect in game.Lighting:GetChildren() do
 if not string.find(effect.Name,'Starfall',1,true) then effect.Parent=lightingBackup end
end
local box=Instance.new('Model');box.Name='SpaceBackdrop'
local center=Vector3.new(0,400,0)
local faces={
 {Vector3.new(1000,0,0),Vector3.new(2,2048,2048)},
 {Vector3.new(-1000,0,0),Vector3.new(2,2048,2048)},
 {Vector3.new(0,1000,0),Vector3.new(2048,2,2048)},
 {Vector3.new(0,-1000,0),Vector3.new(2048,2,2048)},
 {Vector3.new(0,0,1000),Vector3.new(2048,2048,2)},
 {Vector3.new(0,0,-1000),Vector3.new(2048,2048,2)},
}
for _,face in faces do
 local p=Instance.new('Part');p.Name='Space';p.Size=face[2];p.Position=center+face[1];p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Color=C(0,0,0);p.Material=Enum.Material.Neon;p.Parent=box
end
box.Parent=root
for _,p in root:GetDescendants() do
 if p:IsA('BasePart') and p.Material==Enum.Material.Metal then p.Material=Enum.Material.SmoothPlastic end
 if p:IsA('BillboardGui') then p.Size=UDim2.fromOffset(180,38);p.MaxDistance=1200;local t=p:FindFirstChildWhichIsA('TextLabel');if t then t.TextSize=12 end end
 if p:IsA('BasePart') and p.Name=='Star' then
  local b=Instance.new('BillboardGui');b.Size=UDim2.fromOffset(2,2);b.MaxDistance=3000;b.LightInfluence=0;b.Parent=p
  local dot=Instance.new('Frame');dot.Size=UDim2.fromScale(1,1);dot.BackgroundColor3=p.Color;dot.BorderSizePixel=0;dot.Parent=b
 end
 if p:IsA('SurfaceGui') then local twin=p:Clone();twin.Face=Enum.NormalId.Back;twin.Parent=p.Parent end
end
local L=game.Lighting
L.ClockTime=14;L.Brightness=3;L.Ambient=C(115,130,165);L.OutdoorAmbient=C(115,130,165);L.ExposureCompensation=.4;L.EnvironmentDiffuseScale=.7;L.EnvironmentSpecularScale=.5
return 'Space backdrop and brighter station materials applied'
