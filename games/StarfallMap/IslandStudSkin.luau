-- Native studs on thin, merged top strips; the underlying CSG supplies the curved silhouette.
local V=Vector3.new;local CF=CFrame.new
local results={}
for _,island in workspace.StarfallMap.PlanetIslands:GetChildren()do
 assert(island:GetAttribute('OrganicIsland')and not island:GetAttribute('NativeStudSkin'),'Organic island required, skin must be applied once')
 local anchor=island.LandingPad.ArrivalAnchor
 local origin=V(anchor.Position.X,island:GetAttribute('SurfaceY'),anchor.Position.Z+78)
 local surfaces={}
 for _,p in island.Terrain:GetDescendants()do
  if p:IsA('BasePart')and p:GetAttribute('EggGround')and p.Name~='HillStep'then table.insert(surfaces,p)end
  local texture=p:FindFirstChild('ClassicStuds');if texture then texture:Destroy()end
 end
 local ray=RaycastParams.new();ray.FilterType=Enum.RaycastFilterType.Include;ray.FilterDescendantsInstances=surfaces
 local function sample(x,z)
  local hit=workspace:Raycast(V(origin.X+x,origin.Y+55,origin.Z+z),V(0,-95,0),ray)
  if hit and hit.Normal.Y>.99 then return hit.Position.Y,hit.Instance:GetAttribute('PaletteRole')or 'Ground'end
 end
 local skin=Instance.new('Model');skin.Name='NativeStudSurfaces';skin.Parent=island.Terrain
 local count=0
 for z=-188,188,4 do
  local row=Instance.new('Model');row.Name='StudRow'..z
  local start,finish,level,role
  local function flush()
   if start then
    local p=Instance.new('Part');p.Name='StudSurface';p.Size=V(finish-start+4,.05,4)
    p.CFrame=CF(origin.X+(start+finish)*.5,level+.025,origin.Z+z);p.CastShadow=false
    p.Anchored=true;p.CanCollide=true;p.CanTouch=false;p.Material=Enum.Material.Plastic
    p.TopSurface=Enum.SurfaceType.Studs;p.BottomSurface=Enum.SurfaceType.Smooth
    p:SetAttribute('EggGround',true);p:SetAttribute('PaletteRole',role);p.Parent=row;count+=1
   end
   start,finish,level,role=nil,nil,nil,nil
  end
  for x=-188,188,4 do
   local y,r=sample(x,z);local flat=y~=nil
   if flat then for _,q in {V(-2.02,0,-2.02),V(2.02,0,-2.02),V(-2.02,0,2.02),V(2.02,0,2.02)}do
    local edge=sample(x+q.X,z+q.Z);if not edge or math.abs(edge-y)>.04 then flat=false;break end
   end end
   if flat then
    if start and (math.abs(level-y)>.04 or role~=r)then flush()end
    if not start then start,level,role=x,y,r end
    finish=x
   else flush()end
  end
  flush();row.Parent=skin;task.wait()
 end
 for _,step in island.Terrain.HillsidePaths:GetChildren()do if step:IsA('BasePart')then step.CFrame+=V(0,.05,0)end end
 island.Props:PivotTo(island.Props:GetPivot()+V(0,.05,0))
 island.LandingPad:PivotTo(island.LandingPad:GetPivot()+V(0,.05,0))
 for _,zone in island.EggSpawnZones:GetChildren()do zone.CFrame+=V(0,.05,0)end
 island:SetAttribute('SurfaceY',origin.Y+.05);island:SetAttribute('NativeStudSkin',true)
 table.insert(results,{Id=island.Name,StudStrips=count})
end
return results
