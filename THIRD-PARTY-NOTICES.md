# 第三方许可与来源

应用的 MIT License 不为下列组件重新授权。分发源码、插件或二进制时保留对应版权、许可及免责条款。

| 组件 | 来源 / 版本 | 许可与随附文件 |
| --- | --- | --- |
| BatteryMonitor | JKWTCN/BatteryMonitor；固定提交见 UPSTREAM.md | 原 MIT：LICENSE、licenses/BatteryMonitor-MIT.txt |
| GM3323D 协议参考 | Evan816Z/GM3323D-MouseLight | MIT：licenses/GM3323D-MouseLight-MIT.txt；保留 tongz 署名 |
| hidapi | https://github.com/libusb/hidapi ，0.15.0 | 上游允许三选一；本分发选择 BSD 条款。licenses/hidapi-LICENSE.txt、licenses/hidapi-BSD.txt；构建所需 DLL/LIB/头文件在 external/hidapi/ |
| quickjs-ng | https://github.com/quickjs-ng/quickjs ，随 BatteryMonitor 基线的源码 | MIT：external/quickjs/LICENSE 与 licenses/quickjs-ng-MIT.txt |
| Qt | https://www.qt.io/ ，便携包动态库 6.8.3 | 适用 LGPLv3 与组件内第三方条款；licenses/Qt-LGPL-3.0.txt、licenses/GPL-3.0.txt、licenses/Qt-6.8.3/ 下的许可文本及官方 SPDX SBOM |
| DirectX Shader Compiler / DXIL | Microsoft，Qt 部署运行库中的原始 DLL | licenses/DirectXShaderCompiler-LICENSE.txt，包含第三方声明；未修改二进制 |
| MSVC/UCRT、D3DCompiler | Microsoft 官方工具链可再分发运行库 | 适用 Microsoft 工具链 / SDK 条款，不是本项目 MIT；只从合法工具链的可再分发目录或 Qt 官方部署输出获取，不从用户系统随意复制 DLL |

Qt 动态库源代码位置、再链接/替换方法及分发者的责任见 docs/fork/RUNTIME-SOURCES.md。SBOM 中保留了官方记录的 Qt 组件和嵌入第三方代码信息；包含 QtTools 元数据不表示部署了全部 QtTools 程序。

本项目没有给原作者、Qt 或 Microsoft 背书关系；不可移除第三方许可后把整个便携包标成“全部 MIT”。
