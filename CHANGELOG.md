# Changelog

## v1.5.0-peripheral.1 — 2026-10-30

首次整理本分支发布，基于 BatteryMonitor 提交 `50f628c1ae1ced004e9fa03737cee9d6a561d80e`。

- GM3323D 纯输入 HID 接口适配与只读 JS 插件。
- S87Pro 蓝牙电量优先使用 Windows PnP 属性，保留 GATT 回退。
- 增加插件测试、真实设备验证程序、上游署名与完整发布许可材料。
- 源码与 Release 附件分离；排除工具、调研、缓存和构建产物。

限制：单台设备验证；鼠标电量映射未完整校准；Windows 电量可能缓存；未验证 S87Pro 2.4G/USB 与长期休眠、物理拔插。
