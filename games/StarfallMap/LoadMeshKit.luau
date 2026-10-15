-- Generated model assets owned by this map's authoring session.
local specs={Asteroid=109161846061376,Derelict=71697835508122,AlienGate=113296818406753,IceMoon=125222352024053}
local kit=game.ServerStorage:FindFirstChild('StarfallMeshKit') or Instance.new('Folder')
kit.Name='StarfallMeshKit';kit.Parent=game.ServerStorage
for name,id in specs do
 if not kit:FindFirstChild(name)then
  local loaded=game:GetService('InsertService'):LoadAsset(id)
  loaded.Name=name;loaded.Parent=kit
  for _,p in loaded:GetDescendants()do if p:IsA('BasePart')then p.Anchored=true end end
  task.wait()
 end
end
return kit
