# Release 发布指南

发布内容分为源码仓库和 Release 附件。源码仓库不包含编译输出、开发工具、日志或设备采样记录；运行包、源码包和插件包通过 Releases 分发。

## 打包

按 [构建指南](BUILD.md) 生成完整运行目录，然后在仓库根目录执行：

```powershell
powershell -ExecutionPolicy Bypass -File scripts/package-release.ps1 -RuntimeDirectory dist/runtime -Version v1.5.0-peripheral.1
```

输出目录为 dist/releases/v1.5.0-peripheral.1/：

- BatteryMonitor-v1.5.0-peripheral.1-win-x64-portable.zip：完整运行包，入口为 bin/BatteryMonitor.exe。
- BatteryMonitor-v1.5.0-peripheral.1-source.zip：对应源码、必需构建依赖、测试与许可。
- BatteryMonitor-v1.5.0-peripheral.1-gm3323d-plugin.zip：鼠标插件与许可，需要包含本分支修正的宿主。
- SHA256SUMS.txt：附件校验文件。
- RELEASE-NOTES.md：发布说明。

打包脚本使用 Git 文件清单生成源码包，不包含 .git 或被忽略的文件。运行包会附带上游与第三方许可材料。

## 发布前检查

1. 检查待提交文件和附件，排除凭据、个人配置、设备标识、日志和调试产物。
2. 确认二进制与源码对应，并完成插件测试和适用的设备验证。
3. 保留原作者署名、完整许可证和第三方声明；确认运行库对应源码链接可访问。
4. 验证 SHA256SUMS.txt，使用 RELEASE-NOTES.md 作为发布正文。

## GitHub 发布

将源码推送到项目仓库后，创建 v1.5.0-peripheral.1 Release，上传上述三个 ZIP、SHA256SUMS.txt，以及可选的 RELEASE-NOTES.md。不要把整个 dist/ 目录或打包暂存目录上传。

普通仓库应保留上游来源声明。若使用 GitHub Fork，应在上游提交历史上应用修改，不要用无共同历史的仓库强制覆盖 Fork。
