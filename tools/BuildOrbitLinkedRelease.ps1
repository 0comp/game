param([switch]$UpdateCurrent)
$ErrorActionPreference='Stop'
$workspacePath=[IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$releasePath=Join-Path $workspacePath 'releases/ORBIT-Linked-Stars'
$utf8=New-Object System.Text.UTF8Encoding($false)
$baseline=Get-Content -Raw -Encoding UTF8 -LiteralPath (Join-Path $workspacePath 'backups/ORBIT-before-linked-stars/StudioSources.json') | ConvertFrom-Json
$scripts=@(foreach($file in Get-ChildItem -Recurse -File -LiteralPath (Join-Path $releasePath 'src') -Filter '*.luau' | Sort-Object FullName){
    $relative=$file.FullName.Substring((Join-Path $releasePath 'src').Length+1).Replace('\','/')
    $class='ModuleScript'
    if($relative.StartsWith('shared/')){$path='ReplicatedStorage.ClickerKit.'+$relative.Substring(7).Replace('/','.').Replace('.luau','')}
    elseif($relative.StartsWith('server/')){$path='ServerScriptService.ClickerTemplate.'+($file.Name -replace '(\.server)?\.luau$','');if($file.Name.EndsWith('.server.luau')){$class='Script'}}
    else{$path='StarterPlayer.StarterPlayerScripts.'+($file.Name -replace '(\.client)?\.luau$','');if($file.Name.EndsWith('.client.luau')){$class='LocalScript'}}
    [ordered]@{Path=$path;Class=$class;Source=[IO.File]::ReadAllText($file.FullName)}
})
if($scripts.Count -ne 28){throw 'Expected all 28 release scripts.'}
$manifest=[ordered]@{CreatorId=$baseline.CreatorId;GameId=$baseline.GameId;PlaceId=$baseline.PlaceId;Remotes=$baseline.Remotes;Scripts=$scripts}
[IO.File]::WriteAllText((Join-Path $releasePath 'StudioSources.json'),($manifest|ConvertTo-Json -Depth 30),$utf8)
& (Join-Path $PSScriptRoot 'BuildOrbitSnapshot.ps1') -SnapshotFolder 'releases/ORBIT-Linked-Stars'
$prior=[IO.File]::ReadAllText((Join-Path $workspacePath 'releases/ORBIT-Content-Expansion/Install.luau'))
$header=$prior.Substring(0,$prior.IndexOf('setSource("')).Replace('-- ORBIT content expansion.','-- ORBIT linked star systems.').Replace('-- ORBIT / Space standalone game. Install into its own Roblox experience.','-- Version 3 accounts: update the existing ORBIT experience.')
$footer=$prior.Substring($prior.LastIndexOf('game:GetService("Players").CharacterAutoLoads=false')).Replace('ORBIT installed as the standalone Space game. Press Play.','ORBIT linked star systems installed. Publish the existing ORBIT place to release.')
$installer=New-Object System.Text.StringBuilder
[void]$installer.Append($header)
foreach($script in $scripts){
    if($script.Source.Contains(']====]')){throw 'Installer delimiter collision.'}
    [void]$installer.Append(('setSource("{0}","{1}",[====[' -f $script.Path,$script.Class)+"`n"+$script.Source+"]====])`n")
}
[void]$installer.Append($footer)
[IO.File]::WriteAllText((Join-Path $releasePath 'Install.luau'),$installer.ToString(),$utf8)
# Verify every native embedded source and installer entry before updating pointers.
[xml]$place=[IO.File]::ReadAllText((Join-Path $releasePath 'ORBIT.rbxlx'))
$embedded=$place.SelectNodes('//ProtectedString[@name="Source"]')
if($embedded.Count -ne $scripts.Count){throw 'Native source count mismatch.'}
foreach($script in $scripts){
    $name=$script.Path.Substring($script.Path.LastIndexOf('.')+1)
    $node=$place.SelectSingleNode('//Item[Properties/string[@name="Name"]="'+$name+'"]/Properties/ProtectedString[@name="Source"]')
    if($null -eq $node -or $node.InnerText -cne $script.Source){throw ('Embedded source differs: '+$script.Path)}
    if(-not $installer.ToString().Contains($script.Source)){throw ('Installer source differs: '+$script.Path)}
}
foreach($name in @('VerifyOrbitStarSystems','VerifyOrbitStarUI','VerifyOrbitStarServer','VerifyOrbitStarClient','VerifyOrbitRelease','VerifyOrbitLayout','VerifyOrbitExpansion','VerifyOrbitSaveCompatibility')){
    [IO.File]::Copy((Join-Path $PSScriptRoot ($name+'.luau')),(Join-Path $releasePath ($name+'.luau')),$true)
}
[void][IO.Directory]::CreateDirectory((Join-Path $releasePath 'Publishing'))
foreach($file in Get-ChildItem -File -LiteralPath (Join-Path $workspacePath 'games/Space/Publishing')){
    [IO.File]::Copy($file.FullName,(Join-Path $releasePath ('Publishing/'+$file.Name)),$true)
}
if($UpdateCurrent){
    [IO.File]::Copy((Join-Path $workspacePath 'games/Space/PUBLISH.md'),(Join-Path $releasePath 'PUBLISH.md'),$true)
    $oldInstaller=Join-Path $workspacePath 'backups/ORBIT-before-linked-stars/Install.luau'
    if(-not(Test-Path -LiteralPath $oldInstaller)){[IO.File]::Copy((Join-Path $workspacePath 'games/Space/Install.luau'),$oldInstaller,$false)}
    foreach($name in @('ORBIT.rbxlx','Install.luau')){[IO.File]::Copy((Join-Path $releasePath $name),(Join-Path $workspacePath ('games/Space/'+$name)),$true)}
    # Explicit source pointer prevents the old root template source being synced over ORBIT.
    $project=Get-Content -Raw -LiteralPath (Join-Path $releasePath 'default.project.json') | ConvertFrom-Json
    $project.tree.ReplicatedStorage.ClickerKit.'$path'='../../releases/ORBIT-Linked-Stars/src/shared'
    $project.tree.ServerScriptService.ClickerTemplate.'$path'='../../releases/ORBIT-Linked-Stars/src/server'
    $project.tree.StarterPlayer.StarterPlayerScripts.'$path'='../../releases/ORBIT-Linked-Stars/src/client'
    [IO.File]::WriteAllText((Join-Path $workspacePath 'games/Space/default.project.json'),($project|ConvertTo-Json -Depth 30),$utf8)
}
$files=@(Get-ChildItem -LiteralPath $releasePath | ForEach-Object FullName)
Compress-Archive -LiteralPath $files -DestinationPath (Join-Path $workspacePath 'releases/ORBIT-Linked-Stars.zip') -Force
if($UpdateCurrent){[IO.File]::Copy((Join-Path $workspacePath 'releases/ORBIT-Linked-Stars.zip'),(Join-Path $workspacePath 'releases/ORBIT-Publish.zip'),$true)}
Write-Output ('Verified '+$scripts.Count+' native and installer sources. Linked Stars package saved.')
