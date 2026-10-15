param([string]$SnapshotFolder = 'backups/ORBIT-2026-10-13-release-check')
$ErrorActionPreference = 'Stop'
$workspacePath = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$snapshotPath = [IO.Path]::GetFullPath((Join-Path $workspacePath $SnapshotFolder))
if (-not $snapshotPath.StartsWith($workspacePath + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) { throw 'Snapshot must stay inside the workspace.' }
$snapshot = Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $snapshotPath 'StudioSources.json') | ConvertFrom-Json
$utf8 = New-Object System.Text.UTF8Encoding($false)
$doc = New-Object System.Xml.XmlDocument
$root = $doc.CreateElement('roblox'); $root.SetAttribute('version','4'); [void]$doc.AppendChild($root)
$nodes = @{}
function Add-Node($parent, [string]$class, [string]$name, $source = $null) {
    $item=$doc.CreateElement('Item'); $item.SetAttribute('class',$class); $item.SetAttribute('referent','RBX'+[Guid]::NewGuid().ToString('N'))
    $props=$doc.CreateElement('Properties'); [void]$item.AppendChild($props)
    $label=$doc.CreateElement('string'); $label.SetAttribute('name','Name'); $label.InnerText=$name; [void]$props.AppendChild($label)
    if($null -ne $source){ $code=$doc.CreateElement('ProtectedString'); $code.SetAttribute('name','Source'); $code.InnerText=$source; [void]$props.AppendChild($code) }
    [void]$parent.AppendChild($item); return $item
}
foreach($service in @('Workspace','ReplicatedStorage','ServerScriptService','StarterPlayer','StarterGui','Players','Lighting','SoundService')) { $nodes[$service]=Add-Node $root $service $service }
$nodes['ReplicatedStorage.ClickerKit']=Add-Node $nodes.ReplicatedStorage 'Folder' 'ClickerKit'
$nodes['ReplicatedStorage.ClickerKit.Themes']=Add-Node $nodes['ReplicatedStorage.ClickerKit'] 'Folder' 'Themes'
$nodes['ReplicatedStorage.ClickerKit.Remotes']=Add-Node $nodes['ReplicatedStorage.ClickerKit'] 'Folder' 'Remotes'
$nodes['ServerScriptService.ClickerTemplate']=Add-Node $nodes.ServerScriptService 'Folder' 'ClickerTemplate'
$nodes['StarterPlayer.StarterPlayerScripts']=Add-Node $nodes.StarterPlayer 'StarterPlayerScripts' 'StarterPlayerScripts'
foreach($remote in $snapshot.Remotes){ [void](Add-Node $nodes['ReplicatedStorage.ClickerKit.Remotes'] $remote.Class $remote.Name) }
foreach($script in $snapshot.Scripts){
    $dot=$script.Path.LastIndexOf('.'); $parentPath=$script.Path.Substring(0,$dot); $name=$script.Path.Substring($dot+1)
    if(-not $nodes.ContainsKey($parentPath)){ throw ('Missing parent: '+$parentPath) }
    [void](Add-Node $nodes[$parentPath] $script.Class $name $script.Source)
    if($script.Path.StartsWith('ReplicatedStorage.ClickerKit.')){ $relative='shared/'+$script.Path.Substring('ReplicatedStorage.ClickerKit.'.Length).Replace('.','/')+'.luau' }
    elseif($script.Path.StartsWith('ServerScriptService.ClickerTemplate.')){ $relative='server/'+$name+$(if($script.Class -eq 'Script'){'.server'}else{''})+'.luau' }
    else { $relative='client/'+$name+$(if($script.Class -eq 'LocalScript'){'.client'}else{''})+'.luau' }
    $destination=Join-Path (Join-Path $snapshotPath 'src') $relative
    [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($destination)); [IO.File]::WriteAllText($destination,$script.Source,$utf8)
}
$auto=$doc.CreateElement('bool'); $auto.SetAttribute('name','CharacterAutoLoads'); $auto.InnerText='false'; [void]$nodes.Players.SelectSingleNode('Properties').AppendChild($auto)
$orientation=$doc.CreateElement('token'); $orientation.SetAttribute('name','ScreenOrientation'); $orientation.InnerText='4'; [void]$nodes.StarterGui.SelectSingleNode('Properties').AppendChild($orientation)
$settings=New-Object System.Xml.XmlWriterSettings; $settings.Encoding=$utf8; $settings.Indent=$true; $settings.NewLineHandling=[System.Xml.NewLineHandling]::Entitize
$writer=[System.Xml.XmlWriter]::Create((Join-Path $snapshotPath 'ORBIT.rbxlx'),$settings)
try { $doc.Save($writer) } finally { $writer.Dispose() }
$project=Get-Content -Raw -LiteralPath (Join-Path $workspacePath 'default.project.json') | ConvertFrom-Json
$project.name='ORBIT-current'; [IO.File]::WriteAllText((Join-Path $snapshotPath 'default.project.json'),($project|ConvertTo-Json -Depth 30)+"`n",$utf8)
Write-Output ('Saved '+$snapshot.Scripts.Count+' Studio scripts and an openable ORBIT place in '+$SnapshotFolder)
