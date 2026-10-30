# 源码目录与分发范围

仓库保留 BatteryMonitor 的目录结构，并增加本分支适配、测试和发布材料。

## 源码与资源

- src/、util/、main.cpp、mainwindow.*、CMakeLists.txt、cmake/：应用源码与构建配置。
- res/、lang/、image/：界面资源、翻译及上游说明图片。
- external/quickjs/：JS 引擎源码。
- external/hidapi/：必要头文件、hidapi.dll 和 hidapi.lib。
- plugins/：原有插件和新增 GM3323D 只读插件。
- tests/：插件测试和 S87Pro 真实设备验证程序。
- docs/、scripts/：使用、构建与发布材料。
- LICENSE、UPSTREAM.md、MODIFICATIONS.md、licenses/：上游来源、修改声明及完整许可。

## 不进入源码仓库的内容

| 排除规则 | 内容 |
| --- | --- |
| dist/、bin/、build/、build-*/、out/ | 发布附件、编译输出和打包暂存文件 |
| upstream/、tools/ | 下载副本、工具链和依赖缓存 |
| research/、backups/ | 设备采样、诊断、截图和安装备份 |
| *.obj、*.pdb、*.ilk、*.exp、*.log | 中间文件、调试符号和日志 |
| __pycache__/、*.pyc、.vs/、.idea/、.vscode/ | 缓存和个人开发环境配置 |
| CMakeUserPresets.json、*.user、*.suo | 个人构建与 IDE 设置 |
| *.exe、*.dll、*.lib | 散落二进制；external/hidapi/hidapi.dll 和 hidapi.lib 是明确保留的构建依赖 |
| *.zip、*.7z、*.tmp、*.bak | 压缩包、临时文件和备份 |
| .env*、凭据文件、私钥文件 | 本地环境和敏感配置；无敏感值的 .env.example 可保留 |

Release 附件通过独立发布目录生成，不将整个工作目录打包。Git 的 upstream 远程地址仅表示上游来源，不是需要上传的目录。
