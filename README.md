> **上游声明：本项目基于 [JKWTCN/BatteryMonitor](https://github.com/JKWTCN/BatteryMonitor) 修改，并非从零开发，也不是上游官方发行版。原作者为 [JKWTCN](https://github.com/JKWTCN)（GitHub 公开显示名称：浮云战争）。原项目采用 MIT License，原版权与完整许可保留在 [LICENSE](LICENSE)。本适配由 [worlt](https://github.com/worlt) 整理维护；不代表原作者认可或为本版本提供支持。**

# BatteryMonitor 外设适配版

在原 BatteryMonitor 的基础上，为戴记 GM3323D 鼠标增加只读 HID 输入插件，并让狼蛛 S87Pro 在蓝牙模式下优先使用 Windows PnP 电量属性。上游 UI、托盘、提醒及其他设备 Provider 保留。

- 上游固定基线：[`50f628c1ae1ced004e9fa03737cee9d6a561d80e`](https://github.com/JKWTCN/BatteryMonitor/tree/50f628c1ae1ced004e9fa03737cee9d6a561d80e)。
- 保留原说明：[中文上游 README](README.upstream.md)、[英文上游 README](README.upstream.en.md)。上游已验证设备列表不等于本分支重新验证过全部设备。
- 发布标识：`v1.5.0-peripheral.1`；程序内部仍沿用上游版本编号格式。请以本分支 Release 标识和 SHA256 区分，不要仅看 EXE 内部版本号。

## 下载与使用

在本仓库的 GitHub **Releases** 页面下载 `BatteryMonitor-v1.5.0-peripheral.1-win-x64-portable.zip`，完整解压后运行 `bin/BatteryMonitor.exe`。不要只复制 EXE，不需要管理员权限或额外安装外设驱动。Windows 10/11 x64。

`dist/` 不进入 Git；运行包、源码包、插件包和校验文件只作为 Release 附件。具体打包与上传步骤见 [发布指南](docs/fork/RELEASE.md)。源码构建见 [构建指南](docs/fork/BUILD.md)。

## 本分支适配与限制

| 设备 | 本分支读取方式 | 已验证范围与限制 |
| --- | --- | --- |
| 戴记 GM3323D，VID `1D57` / PID `FA60` | 指定纯输入 HID 集合，5 字节报告末尾档位 × 10 | 单台设备读到 `08`/`09`；显示约 80%/90%。映射未完成充放电校准，不是精确百分比，不推断充电状态 |
| 狼蛛 AULA S87Pro | 蓝牙设备名称、地址与 ContainerId 匹配后，优先读 Windows PnP 电量属性；不可用时回退原 GATT 路径 | 单台设备验证。Windows 属性属于系统/驱动缓存；不是强制实时读取，不保证永远与键盘显示屏一致。未验证 2.4G/USB 模式 |

验证时 S87Pro 的 Windows 属性为 99%，GATT 的 Cached/Uncached 均为 94%；99% 没有写死，也不能据此证明哪条来源绝对准确。未完成物理拔插、长期休眠恢复和全程放电测试。

README 中上游已验证的 **F87ProV2D + Dongle** 是特定型号的 2.4G HID 路径，不等于所有 AULA 型号和蓝牙模式都得到相同验证。

## 为什么不只写插件

- 鼠标：上游宿主会跳过没有 Output/Feature 报告的接口；本分支仅为 GM3323D 指定纯输入接口放行，再由 JS 插件读取、解析设备上报的数据。
- 键盘：现有 JS 沙箱只开放 HID 等 `device` API，没有 Windows PnP 属性查询 API，因此在原生蓝牙 Provider 接入读取逻辑。
- 插件包不包含修正后的宿主；放进未修改的官方 EXE，不足以实现完整适配。

## 更新注意事项

上游主程序更新可能覆盖本分支改动。插件更新可能重新安装旧 GM3323D 插件；不要同时启用旧 `gm3323d/gm3323d-1d57-fa60.js` 和新 `peripheral-battery/gm3323d-readonly.js`。

建议在单独目录使用便携包，不要同时运行两个 BatteryMonitor 进程。新增适配只读外设；宿主仍保留上游的设置存储、插件更新和可选 WebSocket 功能。

## 目录

保留上游根目录结构：`src/`、`util/`、`res/`、`lang/`、`external/`、`plugins/`、`cmake/`、`scripts/`。新增适配文档位于 `docs/fork/`，插件和验证脚本分别在 `plugins/peripheral-battery/`、`tests/`。

编译产物、工具缓存和设备采样记录不进入源码仓库；发布包作为 Release 附件分发。详细范围见 [源码目录与分发范围](docs/fork/REPOSITORY-CONTENTS.md)。

## 许可与鸣谢

本项目应用源码及本分支新增适配采用 MIT，与上游保持一致；原 [LICENSE](LICENSE) 未替换原作者信息。本分支范围说明见 [MODIFICATIONS.md](MODIFICATIONS.md)，来源与变更见 [UPSTREAM.md](UPSTREAM.md)。

GM3323D 协议解释参考 [Evan816Z/GM3323D-MouseLight](https://github.com/Evan816Z/GM3323D-MouseLight)，其 MIT 版权声明为 `Copyright (c) 2026 tongz`，已完整保留。也保留 hidapi 与 quickjs-ng 的许可。

**MIT 不覆盖 Qt 或其他第三方运行库。**完整便携包的 Qt 6.8.3 动态库按适用 LGPL 条款及其第三方许可分发，包含许可证、Qt 官方 SBOM、源码获取说明与动态库替换说明；Microsoft 运行库适用其自己的许可。详情见 [第三方声明](THIRD-PARTY-NOTICES.md) 与 [运行库源码及许可说明](docs/fork/RUNTIME-SOURCES.md)。
