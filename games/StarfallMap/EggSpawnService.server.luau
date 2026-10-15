-- Random world positions only. Each planet uses one fixed biome egg template.
local Workspace=game:GetService('Workspace')
local Players=game:GetService('Players')
local ServerStorage=game:GetService('ServerStorage')
local islands=Workspace:WaitForChild('StarfallMap'):WaitForChild('PlanetIslands')
local templates=ServerStorage:WaitForChild('StarfallEggTemplates')
local random=Random.new()
local states={}
for _,island in islands:GetChildren()do
 local zones=island:WaitForChild('EggSpawnZones'):GetChildren()
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances={island.Terrain}
 local overlap=OverlapParams.new();overlap.FilterType=Enum.RaycastFilterType.Include;overlap.FilterDescendantsInstances={island.Props}
 table.insert(states,{Island=island,Zones=zones,Folder=island.ActiveEggs,Template=templates:WaitForChild(island.Name),Ray=ray,Overlap=overlap,NextRefill=0})
end
local function activeEggs(state)
 local eggs={};local now=Workspace:GetServerTimeNow()
 for _,egg in state.Folder:GetChildren()do if egg:IsA('Model')and egg:GetAttribute('SpawnedEgg')then
  if (egg:GetAttribute('ExpiresAt')or math.huge)<=now then egg:Destroy()else table.insert(eggs,egg)end
 end end
 return eggs
end
local function surfaceAt(state,x,z,originY)
 local hit=Workspace:Raycast(Vector3.new(x,originY,z),Vector3.new(0,-96,0),state.Ray)
 if hit and hit.Normal.Y>.99 and hit.Instance:GetAttribute('EggGround')then return hit.Position end
end
local function candidate(state,existing)
 for _=1,32 do
  local zone=state.Zones[random:NextInteger(1,#state.Zones)]
  local localPoint=Vector3.new(random:NextNumber(-zone.Size.X*.5,zone.Size.X*.5),0,random:NextNumber(-zone.Size.Z*.5,zone.Size.Z*.5))
  local world=zone.CFrame:PointToWorldSpace(localPoint);local point=surfaceAt(state,world.X,world.Z,zone.Position.Y+40)
  if not point then continue end
  local landing=state.Island.LandingPad.PadSurface.Position
  if (Vector3.new(point.X,0,point.Z)-Vector3.new(landing.X,0,landing.Z)).Magnitude<21 then continue end
  local inLandingArea=false
  local clearances=state.Island.LandingPad:FindFirstChild('ShipClearances')
  if clearances then for _,area in clearances:GetChildren()do if area:IsA('BasePart')then
   local localPoint=area.CFrame:PointToObjectSpace(point)
   if math.abs(localPoint.X)<area.Size.X*.5+2.2 and math.abs(localPoint.Z)<area.Size.Z*.5+2.2 then inLandingArea=true;break end
  end end end
  if inLandingArea then continue end
  local supported=true
  for _,q in {Vector3.new(2.2,0,0),Vector3.new(-2.2,0,0),Vector3.new(0,0,2.2),Vector3.new(0,0,-2.2),Vector3.new(2.2,0,2.2),Vector3.new(-2.2,0,2.2),Vector3.new(2.2,0,-2.2),Vector3.new(-2.2,0,-2.2)}do
   local edge=surfaceAt(state,point.X+q.X,point.Z+q.Z,zone.Position.Y+40)
   if not edge or math.abs(edge.Y-point.Y)>.1 then supported=false;break end
  end
  if not supported then continue end
  if #Workspace:GetPartBoundsInBox(CFrame.new(point+Vector3.new(0,2.15,0)),Vector3.new(4.2,4.2,4.2),state.Overlap)>0 then continue end
  local clear=true
  for _,egg in existing do if (egg:GetPivot().Position-point).Magnitude<6 then clear=false;break end end
  if not clear then continue end
  for _,player in Players:GetPlayers()do
   local rootPart=player.Character and player.Character:FindFirstChild('HumanoidRootPart')
   if rootPart and (rootPart.Position-point).Magnitude<6 then clear=false;break end
  end
  if clear then return point end
 end
end
local function fill(state,limit)
 local existing=activeEggs(state)
 local target=math.clamp(state.Island:GetAttribute('EggTargetCount')or 8,0,32)
 while #existing>target do table.remove(existing):Destroy()end
 for _=1,math.min(target-#existing,limit)do
  local point=candidate(state,existing);if not point then break end
  local egg=state.Template:Clone();egg.Name=state.Island.Name..'Egg'
  egg:SetAttribute('SpawnedEgg',true);egg:SetAttribute('SpawnPosition',point)
  egg:SetAttribute('ExpiresAt',Workspace:GetServerTimeNow()+math.max(state.Island:GetAttribute('EggLifetimeSeconds')or 180,1))
  egg:PivotTo(CFrame.new(point+Vector3.new(0,.025,0))*CFrame.Angles(0,random:NextNumber(0,math.pi*2),0))
  egg.Parent=state.Folder;table.insert(existing,egg)
 end
 state.Island:SetAttribute('ActiveEggCount',#existing)
end
for _,state in states do fill(state,32);state.NextRefill=os.clock()+math.max(state.Island:GetAttribute('EggRefillSeconds')or 6,1);task.wait()end
while islands:IsDescendantOf(Workspace)do
 task.wait(1)
 for _,state in states do if state.Island:IsDescendantOf(Workspace)and state.Island:IsDescendantOf(islands)and os.clock()>=state.NextRefill then
  fill(state,2)
  state.NextRefill=os.clock()+math.max(state.Island:GetAttribute('EggRefillSeconds')or 6,1)
 end end
end
