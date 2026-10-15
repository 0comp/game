-- STUDIO DEBUG ONLY. Excluded from the normal map installer.
local RunService=game:GetService('RunService')
if not RunService:IsStudio()then return end

local Players=game:GetService('Players')
local ReplicatedStorage=game:GetService('ReplicatedStorage')
local map=workspace:WaitForChild('StarfallMap')
local islands=map:WaitForChild('PlanetIslands')
local allowed={ScrapBelt=true,DerelictField=true,IceGraveyard=true,NebulaCurrent=true,AncientRuins=true,SingularityEdge=true}
local previous=ReplicatedStorage:FindFirstChild('StarfallStudioDebugTeleport')
if previous then previous:Destroy()end
local remote=Instance.new('RemoteEvent');remote.Name='StarfallStudioDebugTeleport';remote.Parent=ReplicatedStorage
local cooldown={}
remote.OnServerEvent:Connect(function(player,id)
 if typeof(id)~='string'or (id~='HOME'and not allowed[id])then return end
 if os.clock()-(cooldown[player]or -math.huge)<1 then
  remote:FireClient(player,false,'Please wait a moment.');return
 end
 cooldown[player]=os.clock()
 local character=player.Character
 local humanoid=character and character:FindFirstChildOfClass('Humanoid')
 local rootPart=character and character:FindFirstChild('HumanoidRootPart')
 if not rootPart or not humanoid or humanoid.Health<=0 then
  remote:FireClient(player,false,'Respawn before teleporting.');return
 end
 local target,label
 if id=='HOME'then
  local index=player:GetAttribute('StarfallPlotIndex')
  local plot=typeof(index)=='number'and map.Hub.Plots:FindFirstChild(string.format('Plot%02d',index))
  local spawn=plot and plot:FindFirstChild('PlotSpawn')or map.Hub:FindFirstChild('PublicSpawn')
  if spawn then target=spawn.CFrame*CFrame.new(0,3,0);label='Home'end
 else
  local island=islands:FindFirstChild(id)
  local pad=island and island:FindFirstChild('LandingPad')
  local anchor=pad and pad:FindFirstChild('ArrivalAnchor')
  if anchor then
   local slot=math.clamp(player:GetAttribute('StarfallPlotIndex')or 1,1,6)-1
   target=anchor.CFrame*CFrame.new((slot%3-1)*6,0,math.floor(slot/3)*6)
   label=island:GetAttribute('DisplayName')or id
  end
 end
 if not target then remote:FireClient(player,false,'Destination unavailable.');return end
 humanoid.Sit=false
 rootPart.AssemblyLinearVelocity=Vector3.zero;rootPart.AssemblyAngularVelocity=Vector3.zero
 character:PivotTo(target)
 remote:FireClient(player,true,label,target.Position)
end)
Players.PlayerRemoving:Connect(function(player)cooldown[player]=nil end)
