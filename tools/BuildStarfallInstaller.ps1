$projectRoot = Split-Path -Parent $PSScriptRoot
$sourceRoot = Join-Path $projectRoot 'games/StarfallMap'
$buildSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'BootstrapV2.luau')
$polishSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'LoadMeshKit.luau')
$detailSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'RefineStation.luau')
$landmarkSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'RefineLandmarks.luau')
$toySource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'ToyStyle.luau')
$referenceSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'ReferencePass.luau')
$homeSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'HomeIsland.luau')
$homePolishSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'HomePolish.luau')
$homeFinishSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'HomeFinish.luau')
$spaceportSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'SpaceportRefinement.luau')
$vistaSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'PlanetVista.luau')
$islandsSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'PlanetIslands.luau')
$expansionSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'ExpandPlanetIslands.luau')
$paletteSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'WorldPalettes.luau')
$organicSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'OrganicIslands.luau')
$studSkinSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'IslandStudSkin.luau')
$worldLandmarksSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'WorldLandmarks.luau')
$biomeArtSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'BiomeArtDirection.luau')
$propVarietySource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'PropVariety.luau')
$discoverySource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'DiscoveryScenes.luau')
$arrivalLandscapeSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'ArrivalLandscape.luau')
$islandLifeSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'IslandLife.luau')
$islandLifeClientSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'IslandLife.client.luau')
$explorationSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'ExplorationDressing.luau')
$eggSpawnSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'EggSpawnService.server.luau')
$ambienceSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'HomeAmbience.client.luau')
$plotServiceSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'PlotService.server.luau')
$catalogSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'SectorCatalog.luau')
$uiSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'MapUI.luau')
$clientSource = Get-Content -Raw -LiteralPath (Join-Path $sourceRoot 'MapClient.client.luau')
$installerText = @'
-- Starfall Salvagers local map installer. Run in Studio Command Bar while stopped.
-- Refuses to overwrite an existing Workspace.StarfallMap.
local function buildMap()
__BUILD__
end
buildMap()
local function polishMap()
__POLISH__
end
polishMap()
local function detailMap()
__DETAIL__
end
detailMap()
local function landmarkMap()
__LANDMARKS__
end
landmarkMap()
local function toyStyle()
__TOYSTYLE__
end
toyStyle()
local function referencePass()
__REFERENCE__
end
referencePass()
local function homeIsland()
__HOME__
end
homeIsland()
local function polishHome()
__HOMEPOLISH__
end
polishHome()
local function finishHome()
__HOMEFINISH__
end
finishHome()
local function refineSpaceport()
__SPACEPORT__
end
refineSpaceport()
local function planetVista()
__VISTA__
end
planetVista()
local function planetIslands()
__ISLANDS__
end
planetIslands()
local function expandPlanetIslands()
__EXPANSION__
end
expandPlanetIslands()
local function shapeOrganicIslands()
__ORGANIC__
end
shapeOrganicIslands()
local function addWorldLandmarks()
__WORLDLANDMARKS__
end
addWorldLandmarks()
local function applyIslandStudSkin()
__STUDSKIN__
end
applyIslandStudSkin()
local function dressExplorationAreas()
__EXPLORATION__
end
dressExplorationAreas()
local function applyWorldPalettes()
__PALETTES__
end
applyWorldPalettes()
local function addIslandLife()
__ISLANDLIFE__
end
addIslandLife()
local function landscapeArrivals()
__ARRIVALLANDSCAPE__
end
landscapeArrivals()
local function directBiomeArt()
__BIOMEART__
end
directBiomeArt()
local function refinePropVariety()
__PROPVARIETY__
end
refinePropVariety()
local function buildDiscoveryScenes()
__DISCOVERYSCENES__
end
buildDiscoveryScenes()
local resourceBackup = Instance.new('Folder')
resourceBackup.Name = 'PreviousStarfallScripts'
resourceBackup.Parent = game.ServerStorage
for _,old in game.ReplicatedStorage:GetChildren() do
 if old.Name == 'StarfallMap' then old.Parent = resourceBackup end
end
for _,old in game.StarterPlayer.StarterPlayerScripts:GetChildren() do
 if old.Name == 'StarfallMapClient' or old.Name == 'StarfallHomeAmbience' or old.Name == 'StarfallIslandLife' then old.Parent = resourceBackup end
end
local shared = Instance.new('Folder')
shared.Name = 'StarfallMap'
shared.Parent = game.ReplicatedStorage
local catalog = Instance.new('ModuleScript')
catalog.Name = 'SectorCatalog'
catalog.Source = [====[__CATALOG__]====]
catalog.Parent = shared
local ui = Instance.new('ModuleScript')
ui.Name = 'MapUI'
ui.Source = [====[__UI__]====]
ui.Parent = shared
local client = Instance.new('LocalScript')
client.Name = 'StarfallMapClient'
client.Source = [====[__CLIENT__]====]
client.Parent = game.StarterPlayer.StarterPlayerScripts
local islandLifeClient = Instance.new('LocalScript')
islandLifeClient.Name = 'StarfallIslandLife'
islandLifeClient.Source = [====[__ISLANDLIFECLIENT__]====]
islandLifeClient.Parent = game.StarterPlayer.StarterPlayerScripts
local ambience = Instance.new('LocalScript')
ambience.Name = 'StarfallHomeAmbience'
ambience.Source = [====[__AMBIENCE__]====]
ambience.Parent = game.StarterPlayer.StarterPlayerScripts
for _,old in game.ServerScriptService:GetChildren() do
 if old.Name == 'StarfallPlotService' or old.Name == 'StarfallEggSpawnService' then old.Parent = resourceBackup end
end
local plotService = Instance.new('Script')
plotService.Name = 'StarfallPlotService'
plotService.Source = [====[__PLOTSERVICE__]====]
plotService.Parent = game.ServerScriptService
local eggSpawnService = Instance.new('Script')
eggSpawnService.Name = 'StarfallEggSpawnService'
eggSpawnService.Source = [====[__EGGSPAWN__]====]
eggSpawnService.Parent = game.ServerScriptService
game.StarterGui.ScreenOrientation = Enum.ScreenOrientation.Sensor
game.StarterPlayer.CameraMinZoomDistance = 5
game.StarterPlayer.CameraMaxZoomDistance = 96
print('Starfall Salvagers map installed. Press Play; use M or the STAR CHART button.')
'@
$installerText = $installerText.Replace('__BUILD__',$buildSource).Replace('__POLISH__',$polishSource).Replace('__DETAIL__',$detailSource).Replace('__LANDMARKS__',$landmarkSource).Replace('__TOYSTYLE__',$toySource).Replace('__REFERENCE__',$referenceSource).Replace('__HOME__',$homeSource).Replace('__HOMEPOLISH__',$homePolishSource).Replace('__HOMEFINISH__',$homeFinishSource).Replace('__SPACEPORT__',$spaceportSource).Replace('__VISTA__',$vistaSource).Replace('__ISLANDS__',$islandsSource).Replace('__EGGSPAWN__',$eggSpawnSource).Replace('__AMBIENCE__',$ambienceSource).Replace('__PLOTSERVICE__',$plotServiceSource).Replace('__CATALOG__',$catalogSource).Replace('__UI__',$uiSource).Replace('__CLIENT__',$clientSource)
$installerText = $installerText.Replace('__EXPANSION__',$expansionSource)
$installerText = $installerText.Replace('__PALETTES__',$paletteSource)
$installerText = $installerText.Replace('__ORGANIC__',$organicSource)
$installerText = $installerText.Replace('__STUDSKIN__',$studSkinSource)
$installerText = $installerText.Replace('__WORLDLANDMARKS__',$worldLandmarksSource)
$installerText = $installerText.Replace('__EXPLORATION__',$explorationSource)
$installerText = $installerText.Replace('__ISLANDLIFE__',$islandLifeSource).Replace('__ISLANDLIFECLIENT__',$islandLifeClientSource)
$installerText = $installerText.Replace('__ARRIVALLANDSCAPE__',$arrivalLandscapeSource)
$installerText = $installerText.Replace('__BIOMEART__',$biomeArtSource)
$installerText = $installerText.Replace('__PROPVARIETY__',$propVarietySource)
$installerText = $installerText.Replace('__DISCOVERYSCENES__',$discoverySource)
Set-Content -LiteralPath (Join-Path $sourceRoot 'InstallMap.luau') -Value $installerText
Write-Output 'Starfall standalone installer regenerated.'






