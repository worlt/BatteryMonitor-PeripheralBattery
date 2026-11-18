[CmdletBinding()]
param([Parameter(Mandatory=$true)][string]$Installer)
$ErrorActionPreference='Stop'
$repo=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$setup=(Get-Item -LiteralPath $Installer).FullName
$install=[IO.Path]::GetFullPath((Join-Path $repo ('dist/installer-smoke/'+[guid]::NewGuid().ToString('N'))))
if(-not $install.StartsWith($repo+'\dist\installer-smoke\',[StringComparison]::OrdinalIgnoreCase)){throw 'Unsafe smoke installation path'}
$key='HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\BatteryMonitor-PeripheralBattery'
$menu=Join-Path ([Environment]::GetFolderPath('Programs')) 'BatteryMonitor 外设适配版'
if((Test-Path -LiteralPath $key) -or (Test-Path -LiteralPath $menu)){throw 'Existing user installation/shortcuts found: do not overwrite in smoke test'}
$p=Start-Process -FilePath $setup -ArgumentList '/S',("/D="+$install) -WindowStyle Hidden -PassThru
if(-not $p.WaitForExit(60000)){throw 'Installer timeout'}
if($p.ExitCode -ne 0){throw ('Installer exit code '+$p.ExitCode)}
Write-Output ('Silent installation succeeded: '+$install)
$original=Join-Path $repo 'dist/portable-verify-release3/BatteryMonitor-v1.5.0-peripheral.3-win-x64-portable'
$files=@(Get-ChildItem -LiteralPath $original -File -Recurse)
foreach($file in $files){
    $relative=$file.FullName.Substring($original.Length+1)
    $target=Join-Path $install $relative
    if(-not(Test-Path -LiteralPath $target)){throw "Installed payload missing: $relative"}
    if((Get-FileHash -LiteralPath $file.FullName).Hash -ne (Get-FileHash -LiteralPath $target).Hash){throw "Installed payload changed: $relative"}
}
$reg=Get-ItemProperty -LiteralPath $key
if($reg.InstallLocation -ne $install -or $reg.DisplayVersion -ne 'v1.5.0-peripheral.3'){throw 'Uninstall registration mismatch'}
if(-not(Test-Path -LiteralPath (Join-Path $menu 'BatteryMonitor.lnk'))){throw 'Start menu shortcut missing'}
if(-not(Test-Path -LiteralPath (Join-Path $install 'licenses/NSIS-3.11/COPYING'))){throw 'Installer notice missing'}
Write-Output ('All '+$files.Count+' portable files match byte-for-byte; shortcuts/uninstall registration verified.')
# Test upgrade to a locked binary: fail safely before changing files.
$before=(Get-FileHash -LiteralPath (Join-Path $install 'bin/BatteryMonitor.exe')).Hash
$locked=[IO.File]::Open((Join-Path $install 'bin/BatteryMonitor.exe'),[IO.FileMode]::Open,[IO.FileAccess]::Read,[IO.FileShare]::Read)
try{
    $blocked=Start-Process -FilePath $setup -ArgumentList '/S',("/D="+$install) -WindowStyle Hidden -PassThru
    if(-not $blocked.WaitForExit(30000)){throw 'Locked upgrade test timeout'}
    if($blocked.ExitCode -eq 0){throw 'Locked destination was not rejected'}
}finally{$locked.Dispose()}
if((Get-FileHash -LiteralPath (Join-Path $install 'bin/BatteryMonitor.exe')).Hash -ne $before){throw 'Locked upgrade altered executable'}
Write-Output 'Locked executable upgrade rejected without changing payload.'
# Uninstall must retain unrelated user files and their directories.
$sentinel=Join-Path $install 'user-file-to-preserve.txt'
[IO.File]::WriteAllText($sentinel,'preserve')
$uninstaller=Join-Path $install 'Uninstall.exe'
$u=Start-Process -FilePath $uninstaller -ArgumentList '/S' -WindowStyle Hidden -PassThru
if(-not $u.WaitForExit(30000)){throw 'Uninstaller timeout'}
$deadline=[DateTime]::UtcNow.AddSeconds(30)
while((Test-Path -LiteralPath $key) -or (Test-Path -LiteralPath $uninstaller)){
    if([DateTime]::UtcNow -gt $deadline){throw 'Uninstall did not complete'}
    Start-Sleep -Milliseconds 200
}
if(Test-Path -LiteralPath $menu){throw 'Start menu cleanup incomplete'}
if(-not(Test-Path -LiteralPath $sentinel) -or [IO.File]::ReadAllText($sentinel) -ne 'preserve'){throw 'Uninstaller removed unrelated user file'}
foreach($file in $files){if(Test-Path -LiteralPath (Join-Path $install $file.FullName.Substring($original.Length+1))){throw 'Packaged file left behind by uninstall'}}
Write-Output 'Silent uninstall passed: packaged files/registration/shortcuts removed; unrelated user file preserved.'
