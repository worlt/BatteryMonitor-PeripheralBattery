# EXE 安装版

下载 `BatteryMonitor-v1.5.0-peripheral.3-win-x64-Setup.exe`，双击进入中文安装向导。Windows 10/11 x64，安装到当前用户，默认目录 `%LOCALAPPDATA%\Programs\BatteryMonitor-PeripheralBattery`，不需要管理员权限。安装后从开始菜单启动；安装结束时默认不自动运行，不新增开机自启。

程序和免安装 ZIP 使用完全相同的 EXE/Qt/插件，Esc 到托盘行为相同。已有程序请先从托盘退出再升级；不要同时运行两个版本。

可在 Windows“已安装的应用”或开始菜单中卸载。卸载只删除分发清单中的文件，不递归删除安装目录，保留 AppData 中的设置、历史以及额外添加的文件。

本安装包尚未代码签名，Windows/SmartScreen 可能提示未知发布者。请从本仓库 Release 获取并核对 SHA256；不要信任来源不明的同名文件。

## 重建安装器

开发环境下载官方 NSIS 3.11 ZIP（编译工具不随应用分发），运行：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/package-installer.ps1 -PortableArchive dist/releases/v1.5.0-peripheral.3/BatteryMonitor-v1.5.0-peripheral.3-win-x64-portable.zip -NsisCompiler C:/Tools/nsis-3.11/makensis.exe
```

脚本先验证便携包 SHA256，再解压到仓库内的唯一暂存目录，按精确文件清单生成安装/卸载命令。使用 zlib 压缩，NSIS 许可见 `licenses/NSIS-3.11/COPYING`。应用许可仍为原 MIT 与既有第三方许可，不变更上游版权。

安装/卸载测试：`tests/installer-smoke.ps1 -Installer <安装包绝对路径>`。测试只安装到经检查的仓库 `dist/installer-smoke/` 子目录；如果已有同名安装注册或开始菜单目录则拒绝覆盖。覆盖静默安装、全部文件 hash、快捷方式/卸载注册、锁定 EXE 的升级保护、静默卸载和额外文件保留。

## 本次补充发布的对应关系

安装器仅封装已发布 `v1.5.0-peripheral.3` 便携包；应用源码提交仍为 `d4169b201c50ce1f9aeb6466c454e4f90f2bc201`，原标签、源码 ZIP、便携 ZIP 和插件 ZIP 不改写。安装脚本单独提供 `installer-source.zip`；Release 正文记录其提交。NSIS 官方来源：https://nsis.sourceforge.io/Download 。
