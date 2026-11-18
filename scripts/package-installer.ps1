[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$PortableArchive,
    [Parameter(Mandatory=$true)][string]$NsisCompiler,
    [string]$Version='v1.5.0-peripheral.3'
)
$ErrorActionPreference='Stop'
$repo=(Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
if($Version -notmatch '^v([0-9]+)[.]([0-9]+)[.]([0-9]+)-peripheral[.]([0-9]+)$'){throw 'Invalid fork version'}
$numericVersion=$Matches[1]+'.'+$Matches[2]+'.'+$Matches[3]+'.'+$Matches[4]
$archive=(Get-Item -LiteralPath $PortableArchive).FullName
$compiler=(Get-Item -LiteralPath $NsisCompiler).FullName
$name="BatteryMonitor-$Version-win-x64-portable.zip"
if([IO.Path]::GetFileName($archive) -ne $name){throw 'Unexpected portable archive name'}
$manifest=Join-Path ([IO.Path]::GetDirectoryName($archive)) 'SHA256SUMS.txt'
$line=Get-Content -LiteralPath $manifest | Where-Object { $_ -match ('  '+[regex]::Escape($name)+'$') }
if(@($line).Count -ne 1 -or $line -notmatch '^([a-f0-9]{64})  '){throw 'Portable checksum is missing'}
$expected=$Matches[1]
if((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant() -ne $expected){throw 'Portable checksum mismatch'}
$output=Join-Path $repo "dist/releases/$Version/BatteryMonitor-$Version-win-x64-Setup.exe"
if(Test-Path -LiteralPath $output){throw 'Installer already exists; do not silently overwrite it'}
$stage=Join-Path $repo ('dist/installer-staging/'+$Version+'-'+[guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $stage -Force | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip=[IO.Compression.ZipFile]::OpenRead($archive)
$prefix="BatteryMonitor-$Version-win-x64-portable/"
try{
    foreach($entry in $zip.Entries){
        $entryPath=$entry.FullName.Replace('\','/')
        if(-not $entryPath.StartsWith($prefix,[StringComparison]::Ordinal)){throw 'Unexpected archive root'}
        $relative=$entryPath.Substring($prefix.Length).Replace('/','\')
        if(-not $relative -or $entryPath.EndsWith('/')){continue}
        $target=[IO.Path]::GetFullPath((Join-Path $stage $relative))
        if(-not $target.StartsWith($stage+'\',[StringComparison]::OrdinalIgnoreCase)){throw 'Archive path escapes staging directory'}
        if($relative.Contains('"') -or $relative.Contains('$') -or $relative.Contains(':')){throw 'Unsafe archive filename'}
        New-Item -ItemType Directory -Path ([IO.Path]::GetDirectoryName($target)) -Force | Out-Null
        [IO.Compression.ZipFileExtensions]::ExtractToFile($entry,$target,$false)
    }
}finally{$zip.Dispose()}
foreach($required in @('bin/BatteryMonitor.exe','bin/Qt6Core.dll','bin/hidapi.dll','LICENSE','docs/fork/RUNTIME-SOURCES.md')){
    if(-not(Test-Path -LiteralPath (Join-Path $stage $required) -PathType Leaf)){throw "Incomplete payload: $required"}
}
Copy-Item -LiteralPath (Join-Path $repo 'licenses/NSIS-3.11') -Destination (Join-Path $stage 'licenses/NSIS-3.11') -Recurse
Copy-Item -LiteralPath (Join-Path $repo 'docs/fork/INSTALLER.md') -Destination (Join-Path $stage 'INSTALLER.md')
# The icon is a compiler input only, never installed into the application folder.
Copy-Item -LiteralPath (Join-Path $repo 'res/icon.ico') -Destination (Join-Path $stage 'res-installer.ico')
$files=@(Get-ChildItem -LiteralPath $stage -File -Recurse | Where-Object Name -ne 'res-installer.ico' | Sort-Object FullName)
$install=New-Object 'System.Collections.Generic.List[string]'
$uninstall=New-Object 'System.Collections.Generic.List[string]'
$directories=New-Object 'System.Collections.Generic.HashSet[string]'
foreach($file in $files){
    $relative=$file.FullName.Substring($stage.Length+1)
    $directory=[IO.Path]::GetDirectoryName($relative)
    $install.Add('SetOutPath "$INSTDIR'+$(if($directory){'\'+$directory})+'"')
    $install.Add('File "'+$file.FullName+'"')
    $uninstall.Add('Delete "$INSTDIR\'+$relative+'"')
    while($directory){$null=$directories.Add($directory);$directory=[IO.Path]::GetDirectoryName($directory)}
}
foreach($directory in ($directories | Sort-Object Length -Descending)){$uninstall.Add('RMDir "$INSTDIR\'+$directory+'"')}
[IO.File]::WriteAllLines((Join-Path $stage 'InstallFiles.nsh'),$install,[Text.UTF8Encoding]::new($true))
[IO.File]::WriteAllLines((Join-Path $stage 'UninstallFiles.nsh'),$uninstall,[Text.UTF8Encoding]::new($true))
$kb=[int][math]::Ceiling(($files | Measure-Object Length -Sum).Sum/1024)
& $compiler '/V3' "/DVERSION=$Version" "/DVERSION_FILE=$numericVersion" "/DOUT_FILE=$output" "/DPAYLOAD=$stage" "/DMANIFEST_DIR=$stage" "/DINSTALL_KB=$kb" (Join-Path $repo 'scripts/installer/BatteryMonitor.nsi')
if($LASTEXITCODE -ne 0){throw 'NSIS compilation failed'}
Get-FileHash -LiteralPath $output -Algorithm SHA256
Write-Output ('Installer: '+$output)
Write-Output ('Payload portable SHA256: '+$expected)
