-- Nearby cosmetic activity only. Never moves gameplay collision or grants items.
local RunService=game:GetService('RunService')
local islands=workspace:WaitForChild('StarfallMap'):WaitForChild('PlanetIslands')
local entries={};local lamps={};local seen={}
local function register(o)
 if seen[o]then return end
 if o:IsA('Model')and o:GetAttribute('IslandMotion')then
  seen[o]=true;local wings={};local motes={}
  for _,p in o:GetDescendants()do if p:IsA('BasePart')then
   if p:GetAttribute('WingSide')then table.insert(wings,{Part=p,Rest=p.CFrame,Side=p:GetAttribute('WingSide')})end
   if p:GetAttribute('MoteIndex')then table.insert(motes,{Part=p,Rest=p.CFrame,Index=p:GetAttribute('MoteIndex')})end
  end end
  table.insert(entries,{Model=o,Rest=o:GetAttribute('RestPivot'),Kind=o:GetAttribute('IslandMotion'),Radius=o:GetAttribute('MotionRadius'),Phase=o:GetAttribute('MotionPhase'),Wings=wings,Motes=motes})
 elseif o:IsA('BasePart')and o:GetAttribute('IslandPulse')then
  seen[o]=true;table.insert(lamps,{Part=o,Phase=o:GetAttribute('PulsePhase')})
 end
end
for _,o in islands:GetDescendants()do register(o)end
islands.DescendantAdded:Connect(register)
local accumulator=0
RunService.Heartbeat:Connect(function(dt)
 accumulator+=dt;if accumulator<.05 then return end;accumulator=0
 local camera=workspace.CurrentCamera;if not camera then return end
 local pos=camera.CFrame.Position;local time=workspace:GetServerTimeNow()
 for n=#entries,1,-1 do local e=entries[n]
  if not e.Model:IsDescendantOf(islands)then seen[e.Model]=nil;table.remove(entries,n)
  elseif (pos-e.Rest.Position).Magnitude<210 then
   local t=time+e.Phase;local at=e.Rest
   if e.Kind=='Flutter'or e.Kind=='Survey'then
    at=e.Rest*CFrame.new(math.sin(t*.55)*e.Radius,math.sin(t*1.7)*.45,math.cos(t*.55)*e.Radius)*CFrame.Angles(0,t*.55,0)
   elseif e.Kind=='Breathe'then at=e.Rest*CFrame.new(0,math.sin(t*1.5)*.12,0)*CFrame.Angles(0,0,math.sin(t*.7)*.025)
   else at=e.Rest*CFrame.Angles(0,t*.25,0)end
   e.Model:PivotTo(at)
   for _,w in e.Wings do if w.Part.Parent then
    local localRest=e.Rest:ToObjectSpace(w.Rest)
    w.Part.CFrame=at*localRest*CFrame.Angles(0,0,math.sin(t*(e.Kind=='Flutter'and 16 or 4))*.35*w.Side)
   end end
   for _,m in e.Motes do if m.Part.Parent then
    local localRest=e.Rest:ToObjectSpace(m.Rest);local cycle=(t*.28+m.Index*.19)%1
    m.Part.CFrame=at*localRest*CFrame.new(math.sin(t+m.Index)*.45,(e.Kind=='Snow'and (1-cycle)or cycle)*2,0)
    m.Part.Transparency=e.Kind=='Sparks'and ((t+m.Index*.4)%7<.5 and .1 or 1)or .15+math.abs(cycle-.5)*1.4
   end end
  end
 end
 for n=#lamps,1,-1 do local l=lamps[n]
  if not l.Part:IsDescendantOf(islands)then seen[l.Part]=nil;table.remove(lamps,n)
  elseif(pos-l.Part.Position).Magnitude<210 then l.Part.Transparency=((time+l.Phase)%3<.18)and .8 or 0 end
 end
end)
