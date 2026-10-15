-- Session ownership and spawns for the six home plots. No economy or pet grants.
local Players=game:GetService('Players')
local hub=workspace:WaitForChild('StarfallMap'):WaitForChild('Hub')
local plots=hub:WaitForChild('Plots')
local owned={}
local function label(plot,text)
 local t=plot.Nameplate.Surface:FindFirstChild('OwnerTitle')
 if t then t.Text=text end
end
local function sendHome(player,character)
 local plot=owned[player];if not plot then return end
 local rootPart=character:WaitForChild('HumanoidRootPart',10)
 if rootPart and owned[player]==plot and player.Character==character then
  character:PivotTo(plot.PlotSpawn.CFrame*CFrame.new(0,3,0))
 end
end
local function claim(player)
 if owned[player]then return end
 local chosen=nil
 for index=1,6 do
  local plot=plots:FindFirstChild(string.format('Plot%02d',index))
  if plot and (plot:GetAttribute('OwnerUserId')or 0)==0 then chosen=plot;break end
 end
 if chosen then
  owned[player]=chosen
  chosen:SetAttribute('OwnerUserId',player.UserId)
  chosen:SetAttribute('OwnerName',player.DisplayName)
  player:SetAttribute('StarfallPlotIndex',chosen:GetAttribute('PlotIndex'))
  player.RespawnLocation=chosen.PlotSpawn
  label(chosen,player.DisplayName..'\nPLOT '..string.format('%02d',chosen:GetAttribute('PlotIndex')))
 else
  player.RespawnLocation=hub.PublicSpawn
 end
 player.CharacterAdded:Connect(function(character)sendHome(player,character)end)
 if player.Character then task.spawn(sendHome,player,player.Character)end
end
local function release(player)
 local plot=owned[player];if not plot then return end
 owned[player]=nil;plot:SetAttribute('OwnerUserId',0);plot:SetAttribute('OwnerName',nil)
 label(plot,string.format('PLOT %02d\nAVAILABLE',plot:GetAttribute('PlotIndex')))
 for _,visitor in Players:GetPlayers()do
  if visitor~=player and not owned[visitor]then
   -- Only overflow visitors need a slot; normal player connections are already installed.
   owned[visitor]=plot;plot:SetAttribute('OwnerUserId',visitor.UserId);plot:SetAttribute('OwnerName',visitor.DisplayName)
   visitor:SetAttribute('StarfallPlotIndex',plot:GetAttribute('PlotIndex'));visitor.RespawnLocation=plot.PlotSpawn
   label(plot,visitor.DisplayName..'\nPLOT '..string.format('%02d',plot:GetAttribute('PlotIndex')))
   break
  end
 end
end
Players.PlayerAdded:Connect(claim)
Players.PlayerRemoving:Connect(release)
for _,player in Players:GetPlayers()do claim(player)end
