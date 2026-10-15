# Rebuild both standalone games from the shared gameplay source.
# Run from any directory: powershell -ExecutionPolicy Bypass -File tools/BuildGames.ps1
$ErrorActionPreference = 'Stop'
$workspacePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$utf8 = New-Object System.Text.UTF8Encoding($false)

function Read-Source([string]$Path) {
    return [IO.File]::ReadAllText($Path).Replace("`r`n", "`n").TrimEnd() + "`n"
}

function Add-PlaceItem($Document, $Parent, [string]$Class, [string]$Name, $Source = $null) {
    $item = $Document.CreateElement('Item')
    $item.SetAttribute('class', $Class)
    $item.SetAttribute('referent', 'RBX' + [Guid]::NewGuid().ToString('N'))
    $properties = $Document.CreateElement('Properties')
    $nameProperty = $Document.CreateElement('string')
    $nameProperty.SetAttribute('name', 'Name')
    $nameProperty.InnerText = $Name
    [void]$properties.AppendChild($nameProperty)
    if ($null -ne $Source) {
        $sourceProperty = $Document.CreateElement('ProtectedString')
        $sourceProperty.SetAttribute('name', 'Source')
        $sourceProperty.InnerText = $Source
        [void]$properties.AppendChild($sourceProperty)
    }
    [void]$item.AppendChild($properties)
    [void]$Parent.AppendChild($item)
    return $item
}

$remoteNames = @('RequestAction', 'RequestClick', 'RequestPurchase', 'RequestZone', 'RequestPrestige', 'RequestSnapshot', 'StateUpdate')
$sharedPath = Join-Path $workspacePath 'src/shared'
$projectSource = Get-Content -Raw -LiteralPath (Join-Path $workspacePath 'default.project.json')
$installerSource = Read-Source (Join-Path $workspacePath 'tools/InstallTemplate.luau')
$installerHeader = $installerSource.Substring(0, $installerSource.IndexOf('setSource("'))
$installerFooter = $installerSource.Substring($installerSource.LastIndexOf('game:GetService("Players").CharacterAutoLoads=false'))

foreach ($theme in @('Space', 'Bakery')) {
    $gameName = if ($theme -eq 'Space') { 'ORBIT' } else { 'CRUMBLE' }
    $gamePath = Join-Path $workspacePath ('games/' + $theme)
    $themeSource = Read-Source (Join-Path $gamePath 'ThemeConfig.luau')

    # Each Rojo project pins its own entry module while sharing maintained code.
    $project = $projectSource | ConvertFrom-Json
    $project.name = $gameName
    $project.tree.ReplicatedStorage.ClickerKit.PSObject.Properties.Remove('$path')
    foreach ($file in Get-ChildItem -LiteralPath $sharedPath -File -Filter '*.luau') {
        $moduleName = $file.BaseName
        $project.tree.ReplicatedStorage.ClickerKit | Add-Member -NotePropertyName $moduleName -NotePropertyValue ([ordered]@{ '$path' = ('../../src/shared/' + $file.Name) }) -Force
    }
    $project.tree.ReplicatedStorage.ClickerKit | Add-Member -NotePropertyName Themes -NotePropertyValue ([ordered]@{ '$path' = '../../src/shared/Themes' }) -Force
    $project.tree.ReplicatedStorage.ClickerKit | Add-Member -NotePropertyName ThemeConfig -NotePropertyValue ([ordered]@{ '$path' = 'ThemeConfig.luau' }) -Force
    $project.tree.ServerScriptService.ClickerTemplate.'$path' = '../../src/server'
    $project.tree.StarterPlayer.StarterPlayerScripts.'$path' = '../../src/client'
    [IO.File]::WriteAllText((Join-Path $gamePath 'default.project.json'), ($project | ConvertTo-Json -Depth 30) + "`n", $utf8)

    $scripts = [ordered]@{}
    foreach ($file in Get-ChildItem -LiteralPath $sharedPath -Recurse -File -Filter '*.luau' | Sort-Object FullName) {
        $relative = $file.FullName.Substring($sharedPath.Length + 1).Replace('\', '.')
        $name = $relative.Substring(0, $relative.Length - 5)
        $source = if ($name -eq 'ThemeConfig') { $themeSource } else { Read-Source $file.FullName }
        $scripts['ReplicatedStorage.ClickerKit.' + $name] = @{ Class = 'ModuleScript'; Source = $source }
    }
    foreach ($area in @('server', 'client')) {
        foreach ($file in Get-ChildItem -LiteralPath (Join-Path $workspacePath ('src/' + $area)) -File -Filter '*.luau' | Sort-Object Name) {
            $name = $file.Name -replace '\.(server|client)\.luau$', '' -replace '\.luau$', ''
            $class = if ($file.Name.EndsWith('.server.luau')) { 'Script' } elseif ($file.Name.EndsWith('.client.luau')) { 'LocalScript' } else { 'ModuleScript' }
            $prefix = if ($area -eq 'server') { 'ServerScriptService.ClickerTemplate.' } else { 'StarterPlayer.StarterPlayerScripts.' }
            $scripts[$prefix + $name] = @{ Class = $class; Source = (Read-Source $file.FullName) }
        }
    }

    # Standalone installer embeds all sources and never needs a theme switch.
    $installer = New-Object System.Text.StringBuilder
    [void]$installer.Append("-- $gameName / $theme standalone game. Install into its own Roblox experience.`n")
    [void]$installer.Append($installerHeader)
    foreach ($entry in $scripts.GetEnumerator()) {
        if ($entry.Value.Source.Contains(']====]')) { throw 'Source collides with installer delimiter.' }
        [void]$installer.Append(('setSource("{0}","{1}",[====[' -f $entry.Key, $entry.Value.Class) + "`n")
        [void]$installer.Append($entry.Value.Source)
        [void]$installer.Append("]====])`n")
    }
    [void]$installer.Append($installerFooter.Replace('Animated 2D clicker installed. ThemeConfig selects Space or Bakery. Press Play.', "$gameName installed as the standalone $theme game. Press Play."))
    [IO.File]::WriteAllText((Join-Path $gamePath 'Install.luau'), $installer.ToString(), $utf8)

    # Native Roblox XML place file: open directly in Studio and press Play.
    $document = New-Object System.Xml.XmlDocument
    $roblox = $document.CreateElement('roblox')
    $roblox.SetAttribute('version', '4')
    [void]$document.AppendChild($roblox)
    $nodes = @{}
    foreach ($service in @('Workspace', 'ReplicatedStorage', 'ServerScriptService', 'StarterPlayer', 'StarterGui', 'Players', 'Lighting', 'SoundService')) {
        $nodes[$service] = Add-PlaceItem $document $roblox $service $service
    }
    $nodes['ReplicatedStorage.ClickerKit'] = Add-PlaceItem $document $nodes.ReplicatedStorage 'Folder' 'ClickerKit'
    $nodes['ReplicatedStorage.ClickerKit.Themes'] = Add-PlaceItem $document $nodes['ReplicatedStorage.ClickerKit'] 'Folder' 'Themes'
    $nodes['ReplicatedStorage.ClickerKit.Remotes'] = Add-PlaceItem $document $nodes['ReplicatedStorage.ClickerKit'] 'Folder' 'Remotes'
    $nodes['ServerScriptService.ClickerTemplate'] = Add-PlaceItem $document $nodes.ServerScriptService 'Folder' 'ClickerTemplate'
    $nodes['StarterPlayer.StarterPlayerScripts'] = Add-PlaceItem $document $nodes.StarterPlayer 'StarterPlayerScripts' 'StarterPlayerScripts'
    foreach ($remote in $remoteNames) { [void](Add-PlaceItem $document $nodes['ReplicatedStorage.ClickerKit.Remotes'] 'RemoteEvent' $remote) }
    foreach ($entry in $scripts.GetEnumerator()) {
        $dot = $entry.Key.LastIndexOf('.')
        $parent = $nodes[$entry.Key.Substring(0, $dot)]
        if ($null -eq $parent) { throw ('Missing place parent: ' + $entry.Key) }
        [void](Add-PlaceItem $document $parent $entry.Value.Class $entry.Key.Substring($dot + 1) $entry.Value.Source)
    }
    $autoLoads = $document.CreateElement('bool'); $autoLoads.SetAttribute('name', 'CharacterAutoLoads'); $autoLoads.InnerText = 'false'
    [void]$nodes.Players.SelectSingleNode('Properties').AppendChild($autoLoads)
    $orientation = $document.CreateElement('token'); $orientation.SetAttribute('name', 'ScreenOrientation'); $orientation.InnerText = '4'
    [void]$nodes.StarterGui.SelectSingleNode('Properties').AppendChild($orientation)
    $settings = New-Object System.Xml.XmlWriterSettings
    $settings.Encoding = $utf8; $settings.Indent = $true; $settings.NewLineHandling = [System.Xml.NewLineHandling]::Entitize
    $writer = [System.Xml.XmlWriter]::Create((Join-Path $gamePath ($gameName + '.rbxlx')), $settings)
    try { $document.Save($writer) } finally { $writer.Dispose() }
    Write-Output "$gameName created: games/$theme/$gameName.rbxlx"
}

# Refresh the generic installer from the same current sources.
$scripts['ReplicatedStorage.ClickerKit.ThemeConfig'].Source = Read-Source (Join-Path $sharedPath 'ThemeConfig.luau')
$genericInstaller = New-Object System.Text.StringBuilder
[void]$genericInstaller.Append($installerHeader)
foreach ($entry in $scripts.GetEnumerator()) {
    if ($entry.Value.Source.Contains(']====]')) { throw 'Source collides with installer delimiter.' }
    [void]$genericInstaller.Append(('setSource("{0}","{1}",[====[' -f $entry.Key, $entry.Value.Class) + "`n")
    [void]$genericInstaller.Append($entry.Value.Source)
    [void]$genericInstaller.Append("]====])`n")
}
[void]$genericInstaller.Append($installerFooter)
[IO.File]::WriteAllText((Join-Path $workspacePath 'tools/InstallTemplate.luau'), $genericInstaller.ToString(), $utf8)

# Save a clean, self-contained template based on the Space game.
$templatePath = Join-Path $workspacePath 'templates/SpaceClicker'
$templateSource = Read-Source (Join-Path $templatePath 'ThemeConfig.luau')
$sourceRoot = Join-Path $workspacePath 'src'
foreach ($file in Get-ChildItem -LiteralPath $sourceRoot -Recurse -File) {
    $relative = $file.FullName.Substring($sourceRoot.Length + 1)
    $destination = Join-Path (Join-Path $templatePath 'src') $relative
    [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($destination))
    [IO.File]::Copy($file.FullName, $destination, $true)
}
[IO.File]::WriteAllText((Join-Path $templatePath 'src/shared/ThemeConfig.luau'), $templateSource, $utf8)
$templateProject = $projectSource | ConvertFrom-Json
$templateProject.name = 'SpaceClickerTemplate'
[IO.File]::WriteAllText((Join-Path $templatePath 'default.project.json'), ($templateProject | ConvertTo-Json -Depth 30) + "`n", $utf8)
[IO.File]::Copy((Join-Path $workspacePath 'tools/RefreshPreview.luau'), (Join-Path $templatePath 'RefreshPreview.luau'), $true)

$templateDocument = New-Object System.Xml.XmlDocument
$templateDocument.PreserveWhitespace = $true
$templateDocument.Load((Join-Path $workspacePath 'games/Space/ORBIT.rbxlx'))
$templateEntry = $templateDocument.SelectSingleNode("//Item[Properties/string[@name='Name']='ThemeConfig']/Properties/ProtectedString[@name='Source']")
if ($null -eq $templateEntry) { throw 'Template entry module missing.' }
$templateEntry.InnerText = $templateSource
$templateDocument.Save((Join-Path $templatePath 'SpaceClickerTemplate.rbxlx'))

$spaceInstaller = Read-Source (Join-Path $workspacePath 'games/Space/Install.luau')
$fixedSpaceSource = Read-Source (Join-Path $workspacePath 'games/Space/ThemeConfig.luau')
$templateInstaller = $spaceInstaller.Replace($fixedSpaceSource, $templateSource).Replace('-- ORBIT / Space standalone game. Install into its own Roblox experience.', '-- Reusable Space Clicker template. Install in a fresh experience and customize ThemeConfig.').Replace('ORBIT installed as the standalone Space game.', 'Space Clicker template installed. Customize ThemeConfig before publishing.')
[IO.File]::WriteAllText((Join-Path $templatePath 'Install.luau'), $templateInstaller, $utf8)

& (Join-Path $PSScriptRoot 'BuildListingAssets.ps1')

# Portable release archives include the place, installer and listing materials.
[void][IO.Directory]::CreateDirectory((Join-Path $workspacePath 'releases'))
foreach ($entry in @(@('Space','ORBIT'), @('Bakery','CRUMBLE'))) {
    $packagePath = Join-Path $workspacePath ('games/' + $entry[0])
    [IO.File]::Copy((Join-Path $workspacePath 'games/PUBLISH.md'), (Join-Path $packagePath 'PUBLISH.md'), $true)
    $packageFiles = @((Join-Path $packagePath ($entry[1] + '.rbxlx')), (Join-Path $packagePath 'Install.luau'), (Join-Path $packagePath 'Publishing'), (Join-Path $packagePath 'PUBLISH.md'))
    Compress-Archive -LiteralPath $packageFiles -DestinationPath (Join-Path $workspacePath ('releases/' + $entry[1] + '-Publish.zip')) -Force
}
$templateFiles = @(Get-ChildItem -LiteralPath $templatePath | Where-Object { $_.Extension -ne '.lock' } | ForEach-Object FullName)
Compress-Archive -LiteralPath $templateFiles -DestinationPath (Join-Path $workspacePath 'releases/SpaceClicker-Template.zip') -Force
Write-Output 'Publishing packages and reusable Space template saved in releases/.'
