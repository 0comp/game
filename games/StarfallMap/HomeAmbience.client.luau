-- Local home presentation: gentle motion, visitor-facing robots and quiet audio.
local RunService=game:GetService('RunService')
local Players=game:GetService('Players')
local SoundService=game:GetService('SoundService')
local ContentProvider=game:GetService('ContentProvider')
local hub=workspace:WaitForChild('StarfallMap'):WaitForChild('Hub')
local polish=hub:WaitForChild('WorldPolish')
local moving={};local eyes={};local robots={}
for _,o in hub:GetDescendants()do
 if o:IsA('Model')and(o.Name=='SwayFlag'or o.Name=='MascotPet')then
  table.insert(moving,{Model=o,Rest=o:GetPivot(),Pet=o.Name=='MascotPet',Phase=#moving*1.7})
 elseif o:IsA('BasePart')and o:GetAttribute('HomeBlink')then
  table.insert(eyes,{Part=o,Rest=o.Transparency,Phase=#eyes*.37})
 end
 if o:IsA('Model')and o:GetAttribute('TrackVisitor')then table.insert(robots,{Model=o,Rest=o:GetPivot()})end
end
local courier=hub.Parent:WaitForChild('Routes'):FindFirstChild('CourierShuttle')
local audio=Instance.new('SoundGroup');audio.Name='StarfallHomeAudio';audio.Parent=SoundService
local music=Instance.new('Sound');music.Name='HomeMusic';music.SoundId='rbxassetid://119229975910510';music.Volume=.1;music.Looped=true;music.SoundGroup=audio;music.Parent=SoundService
local engine=Instance.new('Sound');engine.Name='PublicShipIdle';engine.SoundId='rbxassetid://9119414091';engine.Volume=.045;engine.Looped=true;engine.SoundGroup=audio
engine.RollOffMode=Enum.RollOffMode.InverseTapered;engine.RollOffMinDistance=6;engine.RollOffMaxDistance=26;engine.Parent=hub.PublicArea.LaunchPad.StarterShip.Hull
for _,sound in {music,engine}do task.spawn(function()
 local ok=pcall(function()ContentProvider:PreloadAsync({sound})end)
 if ok and sound.IsLoaded and sound.Parent then sound:Play()end
end)end
local gui=Instance.new('ScreenGui');gui.Name='StarfallAudioControl';gui.ResetOnSpawn=false;gui.DisplayOrder=1;gui.Parent=Players.LocalPlayer:WaitForChild('PlayerGui')
local button=Instance.new('TextButton');button.Name='ToggleSound';button.AnchorPoint=Vector2.new(1,0);button.Position=UDim2.new(1,-16,0,64);button.Size=UDim2.fromOffset(122,48)
button.BackgroundColor3=Color3.fromRGB(42,58,70);button.BorderSizePixel=0;button.Font=Enum.Font.Arcade;button.TextSize=14;button.TextColor3=Color3.fromRGB(231,229,211);button.Text='SOUND: ON';button.Parent=gui
local border=Instance.new('UIStroke');border.Color=Color3.fromRGB(213,176,120);border.Thickness=2;border.Parent=button
local enabled=true;button.Activated:Connect(function()enabled=not enabled;audio.Volume=enabled and 1 or 0;button.Text=enabled and 'SOUND: ON'or 'SOUND: OFF'end)
local elapsed=0;local blinkTime=0
local connection
connection=RunService.RenderStepped:Connect(function(dt)
 if not polish:IsDescendantOf(workspace)then connection:Disconnect();music:Destroy();engine:Destroy();audio:Destroy();gui:Destroy();return end
 elapsed+=dt;blinkTime+=dt
 for _,m in moving do if m.Model.Parent then
  local t=elapsed+m.Phase
  if m.Pet then m.Model:PivotTo(m.Rest*CFrame.new(0,(math.sin(t*1.4)+1)*.07,0)*CFrame.Angles(0,math.sin(t*.45)*.09,0))
  else m.Model:PivotTo(m.Rest*CFrame.Angles(0,math.sin(t*1.3)*.08,math.sin(t*.7)*.025))end
 end end
 local char=Players.LocalPlayer.Character;local rootPart=char and char:FindFirstChild('HumanoidRootPart')
 for _,r in robots do if r.Model.Parent then
  local target=r.Rest
  if rootPart and (rootPart.Position-r.Rest.Position).Magnitude<18 then
   local flat=Vector3.new(rootPart.Position.X,r.Rest.Y,rootPart.Position.Z)
   if (flat-r.Rest.Position).Magnitude>1 then target=CFrame.lookAt(r.Rest.Position,flat)end
  end
  r.Model:PivotTo(r.Model:GetPivot():Lerp(target,math.min(dt*3,1)))
 end end
 if courier and courier.Parent then
  local a=elapsed*math.pi*2/75;local pos=Vector3.new(math.cos(a)*175,70+math.sin(a*2)*7,math.sin(a)*175)
  local nextPos=Vector3.new(math.cos(a+.01)*175,70+math.sin((a+.01)*2)*7,math.sin(a+.01)*175)
  courier:PivotTo(CFrame.lookAt(pos,nextPos)*CFrame.Angles(0,0,-.08))
 end
 if blinkTime>.08 then
  blinkTime=0
  for _,e in eyes do if e.Part.Parent then e.Part.Transparency=((elapsed+e.Phase)%7)<.13 and 1 or e.Rest end end
 end
end)
