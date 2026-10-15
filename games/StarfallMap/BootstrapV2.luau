assert(not workspace:FindFirstChild('StarfallMap'),'Preserve the existing StarfallMap before reinstalling')
local root=Instance.new('Model');root.Name='StarfallMap';root.Parent=workspace
local backup=game.ServerStorage:FindFirstChild('StarfallOriginalScene')or Instance.new('Folder');backup.Name='StarfallOriginalScene';backup.Parent=game.ServerStorage
for _,name in {'Baseplate','SpawnLocation'}do local p=workspace:FindFirstChild(name);if p then p.Parent=backup end end
local lighting=Instance.new('Folder');lighting.Name='Lighting';lighting.Parent=backup
for _,e in game.Lighting:GetChildren()do e.Parent=lighting end
local bloom=Instance.new('BloomEffect');bloom.Name='StarfallBloom';bloom.Parent=game.Lighting
local color=Instance.new('ColorCorrectionEffect');color.Name='StarfallColor';color.Parent=game.Lighting
local sky=Instance.new('Sky');sky.Name='StarfallSky';sky.CelestialBodiesShown=false;sky.Parent=game.Lighting
local box=Instance.new('Model');box.Name='SpaceBackdrop';box.Parent=root
for _,d in {{Vector3.new(1000,400,0),Vector3.new(2,2048,2048)},{Vector3.new(-1000,400,0),Vector3.new(2,2048,2048)},{Vector3.new(0,1400,0),Vector3.new(2048,2,2048)},{Vector3.new(0,-600,0),Vector3.new(2048,2,2048)},{Vector3.new(0,400,1000),Vector3.new(2048,2048,2)},{Vector3.new(0,400,-1000),Vector3.new(2048,2048,2)}}do
 local p=Instance.new('Part');p.Name='Space';p.Position=d[1];p.Size=d[2];p.Color=Color3.new();p.Material=Enum.Material.Neon;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.CastShadow=false;p.Parent=box
end
game.Players.CharacterAutoLoads=true
return root
