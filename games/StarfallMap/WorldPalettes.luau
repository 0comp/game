-- One user-supplied palette per destination; exact swatches, no blended colors.
local root=workspace.StarfallMap
local definitions={
 {Id='ScrapBelt',Image=5,Name='Forest Greens',Hex={'5BBA6F','3FA34D','2A9134','137547','0C6038','054A29'},Ground=1,High=2,Rock=4,Deep=6,Leaf=3,LeafLight=2,Stem=5,Accent=1,Highlight=1,Path=3,Shell=1},
 {Id='DerelictField',Image=3,Name='Muted Quarry',Hex={'CFCFEA','A89B9D','816C61','575A4B','2A2C24'},Ground=2,High=3,Rock=4,Deep=5,Leaf=4,LeafLight=1,Stem=5,Accent=1,Highlight=1,Path=1,Shell=2},
 {Id='IceGraveyard',Image=2,Name='Aqua Frost',Hex={'363732','53D8FB','66C3FF','DCE1E9','D4AFB9'},Ground=2,High=3,Rock=1,Deep=1,Leaf=3,LeafLight=4,Stem=1,Accent=5,Highlight=4,Path=4,Shell=4},
 {Id='NebulaCurrent',Image=1,Name='Orchid Violet',Hex={'420039','932F6D','E07BE0','DCCCFF','F6F2FF'},Ground=3,High=4,Rock=2,Deep=1,Leaf=2,LeafLight=4,Stem=1,Accent=5,Highlight=5,Path=4,Shell=4},
 {Id='AncientRuins',Image=4,Name='Teal Relics',Hex={'0E7C7B','17BEBB','D4F4DD','D62246','4B1D3F'},Ground=1,High=2,Rock=5,Deep=5,Leaf=2,LeafLight=3,Stem=5,Accent=4,Highlight=3,Path=3,Shell=3},
 {Id='SingularityEdge',Image=6,Name='Electric Candy',Hex={'0091AD','6AFEFF','FFF4E4','FFED9C','FF57BB'},Ground=1,High=2,Rock=3,Deep=1,Leaf=4,LeafLight=5,Stem=1,Accent=5,Highlight=4,Path=3,Shell=3},
}
local function fromHex(hex)return Color3.fromRGB(tonumber(hex:sub(1,2),16),tonumber(hex:sub(3,4),16),tonumber(hex:sub(5,6),16))end
local function setColor(part,color)
 if part:GetAttribute('PrePaletteColor')==nil then part:SetAttribute('PrePaletteColor',part.Color)end
 part.Color=color
 if part:IsA('UnionOperation')then part.UsePartColor=true end
end
local results={}
for _,d in definitions do
 local colors={};for _,hex in d.Hex do table.insert(colors,fromHex(hex))end
 local function color(role)return colors[d[role]]end
 local function metadata(model)
  model:SetAttribute('PaletteName',d.Name);model:SetAttribute('PaletteImageIndex',d.Image)
  model:SetAttribute('PaletteHex',table.concat(d.Hex,','))
 end
 local island=root.PlanetIslands[d.Id];local planet=root.Planets[d.Id]
 metadata(island);metadata(planet)
 local count=0
 for _,part in island:GetDescendants()do if part:IsA('BasePart')then
  local name=part.Name;local role='Rock'
  if part:GetAttribute('PaletteRole')then role=part:GetAttribute('PaletteRole')
  elseif name=='GroundCell'then
   local h=part:GetAttribute('TerrainHeight')or 0
   role=h>=8 and 'Highlight'or h>0 and 'High'or 'Ground'
   -- Green and purple landscapes retain their colored upper ground.
   if d.Id=='ScrapBelt'or d.Id=='NebulaCurrent'or d.Id=='DerelictField'then role=h>0 and 'High'or 'Ground'end
  elseif name=='RockCell'or name=='CliffFoot'then role='Rock'
  elseif name=='CliffFace'then role='High'
  elseif name=='HangingRock'then role='Deep'
  elseif name=='HalfStudStep'or name=='StoneSlab'then role='Path'
  elseif name=='Trunk'or name=='Stem'or name=='PlantStem'or name=='FlowerStem'or name=='MeadowFlagPole'then role='Stem'
  elseif name=='Crown'or name=='TreeCrown'or name=='Cap'or name=='MushroomCap'or name=='PlantCrown'or name=='RuinVine'then role='Leaf'
  elseif name=='LeafCluster'or name=='CrownTop'or name=='CapTop'then role='LeafLight'
  elseif name=='Crystal'or name=='IceShard'or name=='StormShoot'then role='High'
  elseif name=='CrystalTip'or name=='Spot'then role='Highlight'
  elseif name=='FlowerHead'or name=='MeadowFlag'or name=='Ore'or name=='OrePlate'or name=='Collector'or name=='Armor'then role='Accent'
  elseif name=='RuinPillar'or name=='RuinCap'or name=='RuinLintel'then role='Highlight'
  elseif name=='RuinInlay'then role='Accent'
  elseif name=='Hull'or name=='CargoBox'or name=='BrokenFin'then role='High'
  elseif name=='DeadNozzle'or name=='Mast'or name=='Base'then role='Deep'
  elseif name=='SmallGroundDetail'then role='LeafLight'
  end
  setColor(part,color(role));count+=1
 end end
 local plate=0
 for _,part in planet:GetDescendants()do if part:IsA('BasePart')then
  local role='Rock'
  if part.Name=='Planet'then role='Ground'
  elseif part.Name=='ContinentPlate'then plate+=1;role=plate%3==0 and 'Highlight'or 'High'
  elseif part.Name=='OrbitRing'then role='Accent'end
  setColor(part,color(role))
 end end
 local template=game.ServerStorage.StarfallEggTemplates[d.Id];metadata(template)
 for _,part in template:GetDescendants()do if part:IsA('BasePart')then
  local role=part.Name=='Shell'and 'Shell'or part.Name=='Nest'and 'Ground'or 'Accent'
  if part.Name=='LeafPlate'then role='Leaf'
  elseif part.Name=='IceTip'or part.Name=='AntennaTip'then role='High'end
  setColor(part,color(role))
 end end
 table.insert(results,{Id=d.Id,Palette=d.Name,Image=d.Image,ColoredParts=count})
 task.wait()
end
return results
