[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$RuntimeDirectory,
    [string]$Version = "v1.5.0-peripheral.2"
)

$ErrorActionPreference = "Stop"
$repository = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot "..")).Path
if ($Version -notmatch "^v[0-9]+[.][0-9]+[.][0-9]+-[a-z0-9.-]+$") {
    throw "Use a fork release identifier such as v1.5.0-peripheral.2."
}
$workingChanges = & git -C $repository status --porcelain --untracked-files=normal
if ($LASTEXITCODE -ne 0 -or $workingChanges) { throw "Commit the reviewed source before packaging a release." }
$sourceCommit = & git -C $repository rev-parse HEAD
if ($LASTEXITCODE -ne 0) { throw "Cannot determine source commit." }
$runtime = (Resolve-Path -LiteralPath $RuntimeDirectory).Path
$executable = Join-Path $runtime "bin/BatteryMonitor.exe"
if (-not (Test-Path -LiteralPath $executable -PathType Leaf)) {
    throw "RuntimeDirectory must contain bin/BatteryMonitor.exe and its deployment dependencies."
}
foreach ($required in @("bin/Qt6Core.dll", "bin/Qt6Widgets.dll", "bin/hidapi.dll")) {
    if (-not (Test-Path -LiteralPath (Join-Path $runtime $required) -PathType Leaf)) {
        throw "Incomplete runtime: $required is missing."
    }
}
$releaseDirectory = Join-Path $repository ("dist/releases/" + $Version)
$stagingDirectory = Join-Path $repository ("dist/release-staging/" + $Version + "-" + [Guid]::NewGuid().ToString("N"))
$allowedRoot = $repository + [IO.Path]::DirectorySeparatorChar
foreach ($target in @($releaseDirectory, $stagingDirectory)) {
    if (-not [IO.Path]::GetFullPath($target).StartsWith($allowedRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw "Output path must remain inside the repository."
    }
}
if (Test-Path -LiteralPath $releaseDirectory) {
    throw "Release directory already exists; use a new version or archive it manually."
}
New-Item -ItemType Directory -Path $releaseDirectory, $stagingDirectory -Force | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem

function Copy-ReleaseFile([string]$Source, [string]$Destination) {
    New-Item -ItemType Directory -Path ([IO.Path]::GetDirectoryName($Destination)) -Force | Out-Null
    Copy-Item -LiteralPath $Source -Destination $Destination
}

function Copy-ReleaseNotices([string]$Destination) {
    foreach ($notice in @("LICENSE", "README.md", "UPSTREAM.md", "MODIFICATIONS.md", "THIRD-PARTY-NOTICES.md", "CHANGELOG.md")) {
        Copy-ReleaseFile (Join-Path $repository $notice) (Join-Path $Destination $notice)
    }
    Copy-Item -LiteralPath (Join-Path $repository "licenses") -Destination (Join-Path $Destination "licenses") -Recurse
    Copy-Item -LiteralPath (Join-Path $repository "docs/fork") -Destination (Join-Path $Destination "docs/fork") -Recurse
}

function Compress-ReleaseDirectory([string]$Directory, [string]$Archive) {
    [IO.Compression.ZipFile]::CreateFromDirectory($Directory, $Archive, [IO.Compression.CompressionLevel]::Optimal, $true)
}

$portable = Join-Path $stagingDirectory ("BatteryMonitor-" + $Version + "-win-x64-portable")
New-Item -ItemType Directory -Path $portable -Force | Out-Null
foreach ($file in Get-ChildItem -LiteralPath $runtime -File -Recurse) {
    $relative = $file.FullName.Substring($runtime.Length + 1).Replace([IO.Path]::DirectorySeparatorChar, '/')
    if ($file.Extension -in @(".pdb", ".obj", ".log", ".tmp", ".bak")) { continue }
    if ($relative -match "(^|/)(backups|research|gm3323d)(/|$)") { continue }
    if ($relative -in @("适配说明.md", "BatteryMonitor-MIT-LICENSE.txt")) { continue }
    Copy-ReleaseFile $file.FullName (Join-Path $portable $relative)
}
Copy-ReleaseFile (Join-Path $repository "plugins/peripheral-battery/gm3323d-readonly.js") (Join-Path $portable "bin/plugins/peripheral-battery/gm3323d-readonly.js")
New-Item -ItemType Directory -Path (Join-Path $portable "docs") -Force | Out-Null
Copy-ReleaseNotices $portable
Compress-ReleaseDirectory $portable (Join-Path $releaseDirectory ("BatteryMonitor-" + $Version + "-win-x64-portable.zip"))

$sourceArchive = Join-Path $releaseDirectory ("BatteryMonitor-" + $Version + "-source.zip")
& git -C $repository -c core.autocrlf=false archive --format=zip ("--prefix=BatteryMonitor-" + $Version + "-source/") ("--output=" + $sourceArchive) $sourceCommit
if ($LASTEXITCODE -ne 0) { throw "Git source archive failed." }

$plugin = Join-Path $stagingDirectory ("BatteryMonitor-" + $Version + "-gm3323d-plugin")
New-Item -ItemType Directory -Path (Join-Path $plugin "licenses") -Force | Out-Null
Copy-ReleaseFile (Join-Path $repository "plugins/peripheral-battery/gm3323d-readonly.js") (Join-Path $plugin "plugins/peripheral-battery/gm3323d-readonly.js")
Copy-ReleaseFile (Join-Path $repository "docs/fork/GM3323D-PLUGIN.md") (Join-Path $plugin "README.md")
foreach ($notice in @("LICENSE", "MODIFICATIONS.md", "UPSTREAM.md")) {
    Copy-ReleaseFile (Join-Path $repository $notice) (Join-Path $plugin $notice)
}
foreach ($notice in @("BatteryMonitor-MIT.txt", "GM3323D-MouseLight-MIT.txt")) {
    Copy-ReleaseFile (Join-Path $repository ("licenses/" + $notice)) (Join-Path $plugin ("licenses/" + $notice))
}
Compress-ReleaseDirectory $plugin (Join-Path $releaseDirectory ("BatteryMonitor-" + $Version + "-gm3323d-plugin.zip"))

$executableHash = (Get-FileHash -LiteralPath $executable -Algorithm SHA256).Hash.ToLowerInvariant()
$notes = @"
# BatteryMonitor $Version — 非官方外设适配版

基于 [JKWTCN/BatteryMonitor](https://github.com/JKWTCN/BatteryMonitor)，原作者 [JKWTCN](https://github.com/JKWTCN)，MIT。基线提交：50f628c1ae1ced004e9fa03737cee9d6a561d80e。本分支由 [worlt](https://github.com/worlt) 维护，不代表上游官方发行。原版权与许可完整保留；第三方运行库另适用其许可。

## 下载
- win-x64-portable.zip：推荐；完整解压后运行 bin/BatteryMonitor.exe。Windows 10/11 x64。
- source.zip：对应应用源码、必需构建依赖、测试与许可；不含工具缓存、调研和构建产物。
- gm3323d-plugin.zip：仅鼠标插件，需要本分支修正的宿主；不含键盘原生适配。
- SHA256SUMS.txt：下载校验。

## 修改与限制
- GM3323D：修复充电报告被丢弃、鼠标消失的问题，解析观察到的充电标志；电量仍为未校准的 10% 档位约数，保持只读。
- S87Pro 蓝牙：保留 Windows PnP 电量优先及 GATT 回退，两条百分比读取路径明确显示“充电未知”。自动充电识别仍未实现。
- 设备详情新增“手动标记正在充电”，默认关闭、按设备保存，显示闪电和“正在充电（手动标记）”；拔线后需手动取消。断开或数据过期时不显示实时充电，重新连接后恢复已保存的选择。设备上报状态优先。
- WebSocket 增加 chargingKnown / chargingSource（device、manual、unknown），保留原 charging 字段。
- 单台设备采样验证，鼠标报告解析及充电来源/设置隔离回归测试通过。未完成长期休眠、全程充放电校准或全部上游设备重测；S87Pro 2.4G/USB 未验证。
- 内部版本号沿用上游格式，请以本发布标识和校验区分。

## 升级与回退
退出旧程序，将便携包解压到新目录后运行；不要同时运行两个版本。系统中已有设置会继续使用。若遇回归，退出新程序后重新运行保留的 v1.5.0-peripheral.1；取消手动充电标记可恢复“充电未知”。旧版本 Release 保留。

## 许可与源码
应用 MIT；原 LICENSE、鼠标协议参考 MIT、hidapi BSD、quickjs-ng MIT 与 Qt 许可随包。Qt 6.8.3 未修改动态库的对应源码直接下载地址、SHA256、替换说明及第三方官方 SPDX 清单见包内 docs/fork/RUNTIME-SOURCES.md 和 licenses/Qt-6.8.3/。该说明必须与二进制一起分发；发布者需维护对应源码访问。Microsoft 运行库不以 MIT 重新授权。

源码提交：$sourceCommit

主程序 SHA256：$executableHash
"@
[IO.File]::WriteAllText((Join-Path $releaseDirectory "RELEASE-NOTES.md"), $notes, [Text.UTF8Encoding]::new($false))
$hashes = foreach ($archive in Get-ChildItem -LiteralPath $releaseDirectory -File | Sort-Object Name) {
    (Get-FileHash -LiteralPath $archive.FullName -Algorithm SHA256).Hash.ToLowerInvariant() + "  " + $archive.Name
}
[IO.File]::WriteAllLines((Join-Path $releaseDirectory "SHA256SUMS.txt"), $hashes, [Text.UTF8Encoding]::new($false))
Write-Output ("Release files: " + $releaseDirectory)
