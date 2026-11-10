# 本分支修改声明

原 BatteryMonitor：Copyright (c) 2026 JKWTCN。原项目许可文本在 LICENSE 中完整保留。

本分支新增适配、测试和发布文档：Copyright (c) 2026 worlt，采用同一 MIT License。此声明仅涉及本分支新增或修改部分，不转移上游及第三方版权。

2026-10-30，基于上游提交 `50f628c1ae1ced004e9fa03737cee9d6a561d80e`：

1. 新增 `src/providers/bluetooth/S87ProWindowsBattery.{h,cpp}`：读取 Windows PnP 属性，按运行时设备名称、地址及 ContainerId 关联连接状态。
2. 修改 `BluetoothProvider.cpp`：S87Pro 优先使用上述属性，不可用时沿用 GATT。
3. 修改 `src/scripting/HidProbe.cpp`：仅允许 GM3323D 指定纯输入集合通过筛选。
4. 修改 `CMakeLists.txt`：增加新键盘实现到构建；Release 关闭 WinRT 源位置诊断，避免嵌入编译环境路径。
5. 新增 `plugins/peripheral-battery/gm3323d-readonly.js`：只读输入报告、验证格式、输出未校准的 10% 档位约数。
6. 增加测试、上游声明、第三方许可、发布文档与打包脚本；没有改变上游应用的产品版权声明或假冒官方版本。

GM3323D 协议参考与其他依赖的许可见 THIRD-PARTY-NOTICES.md；本分支新增适配没有引入其他 GPL 蓝牙工具的实现代码。

2026-11-10，`v1.5.0-peripheral.2`：

1. 修正 GM3323D 充电报告解析，保留纯输入只读方式与约数说明。
2. 在设备模型、UI、设置、中文翻译与 RPC 中增加充电未知及手动来源；注释只应用于发布副本，不写入原始设备缓存。
3. Windows S87Pro 与标准 GATT 电量路径标记充电状态未知，保留原设备匹配逻辑。
4. 增加充电来源回归测试、可选 CMake 测试目标和更新后的发布材料；本版本不宣称 S87Pro 自动充电检测已实现。
