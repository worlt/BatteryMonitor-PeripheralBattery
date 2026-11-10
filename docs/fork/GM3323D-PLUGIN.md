# GM3323D 插件包

基于 JKWTCN/BatteryMonitor 的 JS 插件 API，电量档位解释参考 Evan816Z/GM3323D-MouseLight。原作者与 MIT 完整声明随包保留。

把 plugins/peripheral-battery/gm3323d-readonly.js 放到兼容版 BatteryMonitor.exe 同级的 plugins/peripheral-battery/。

**需要包含本分支 HidProbe 修正的宿主。**上游旧宿主会过滤纯输入接口，单独安装 JS 无法修复。推荐使用本分支完整便携包。

停用旧 gm3323d/gm3323d-1d57-fa60.js；不要同时启用两份鼠标插件。

只读取 VID 1D57 / PID FA60、UsagePage 000A 的 5 字节报告；每次最多 8 次读取、每次 500ms，验证签名与档位范围。`03 00 40 01 <step>` 为观察到的电池供电报告，`03 01 40 01 <step>` 为观察到的充电报告；第二字节解析为 `charging`，不再因充电而丢弃报告。`step` 必须为 0–10 的整数，未校准的 10% 档位只作为约数。充电标志不用于推断连接方式。无 HID 写入。

此插件包不包含 S87Pro 的 Windows PnP 原生适配或 Qt 运行库。
