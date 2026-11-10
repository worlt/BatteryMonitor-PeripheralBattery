# Release 发布指南

发布内容分为源码仓库和 Release 附件。源码仓库不包含编译输出、开发工具、日志或设备采样记录；运行包、源码包和插件包通过 Releases 分发。

## 打包

按 [构建指南](BUILD.md) 从发布仓库生成完整运行目录，运行回归测试并提交已审查的源码，然后在干净工作区根目录执行：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/package-release.ps1 -RuntimeDirectory dist/runtime -Version v1.5.0-peripheral.2
```

输出目录为 dist/releases/v1.5.0-peripheral.2/：

- BatteryMonitor-v1.5.0-peripheral.2-win-x64-portable.zip：完整运行包，入口为 bin/BatteryMonitor.exe。
- BatteryMonitor-v1.5.0-peripheral.2-source.zip：对应源码、必需构建依赖、测试与许可。
- BatteryMonitor-v1.5.0-peripheral.2-gm3323d-plugin.zip：鼠标插件与许可，需要包含本分支修正的宿主。
- SHA256SUMS.txt：附件校验文件。
- RELEASE-NOTES.md：发布说明。

打包脚本要求工作区干净，使用 `git archive HEAD` 生成准确对应提交的源码包，发布正文记录提交 ID。源码包不包含 .git 或未跟踪文件。运行包会附带上游与第三方许可材料。

## 发布前检查

1. 检查待提交文件和附件，排除凭据、个人配置、设备标识、日志和调试产物。
2. 确认二进制与源码对应，并完成插件测试和适用的设备验证。
3. 保留原作者署名、完整许可证和第三方声明；确认运行库对应源码链接可访问。
4. 验证 SHA256SUMS.txt，使用 RELEASE-NOTES.md 作为发布正文。

## GitHub 发布

创建指向该源码提交的 `v1.5.0-peripheral.2` 注释标签，非强制推送 `master` 与标签。先创建 Release 草稿并上传上述三个 ZIP、SHA256SUMS.txt、RELEASE-NOTES.md；检查名称、大小及校验后发布为非预发行版，设为 Latest。保留旧版 Release 和标签。不要把整个 dist/ 目录或打包暂存目录上传。

普通仓库应保留上游来源声明。若使用 GitHub Fork，应在上游提交历史上应用修改，不要用无共同历史的仓库强制覆盖 Fork。

## 回退

退出当前程序，重新运行保留的上一版便携包。新增 ManualCharging 设置默认关闭，旧版不使用该键；无需删除已有托盘、提醒、别名和历史记录。回退后的充电显示遵循旧版行为，GM3323D 充电报告修复也将撤回。
