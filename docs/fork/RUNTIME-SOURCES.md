# 运行库源码、许可与替换

本发行版应用源码采用 MIT；Qt 及 Microsoft 运行库不因此改为 MIT。以下说明针对便携包的 Qt **6.8.3**，不代表用户原安装目录中的其他 Qt 版本。

## Qt 动态库

本包动态链接、未修改 Qt 官方 MSVC x64 库。应用与 Qt DLL 分离；不禁止为调试 Qt 修改而进行的逆向工程，不加入阻止用户替换 DLL 的校验或加密。遵守 LGPLv3，阅读随包 licenses/Qt-LGPL-3.0.txt 与 licenses/GPL-3.0.txt。第三方版权与许可文本在 licenses/Qt-6.8.3/，各模块官方 SPDX JSON 包含嵌入第三方代码与 ExtractedLicensingInfo。

### 与运行库对应的源码下载

Qt 官方归档服务器提供源码、许可、构建系统；下列为本包使用的 6.8.3 模块。它们是实际源码下载地址，不是只给一个项目主页。发布时应将本说明与二进制放在一起，使用户获得等价的源码访问：

| 模块 | 官方完整模块源码 | 官方 SHA256 |
| --- | --- | --- |
| QtBase：Core/Gui/Widgets/Network/Sql、平台和图片插件等 | https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qtbase-everywhere-src-6.8.3.tar.xz | 56001b905601bb9023d399f3ba780d7fa940f3e4861e496a7c490331f49e0b80 |
| QtSvg | https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qtsvg-everywhere-src-6.8.3.tar.xz | 35eb516460f00f264eb504baa253432384351cf23fb9980a5857190e8deef438 |
| QtWebSockets | https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qtwebsockets-everywhere-src-6.8.3.tar.xz | fc6310c1b12d6e22a31062727aa6574ed69239d036c8a4247b3b089902709b11 |
| QtTools：构建时用 LinguistTools，提供其来源，未部署完整开发工具 | https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qttools-everywhere-src-6.8.3.tar.xz | 02a4e219248b94f1333df843d25763f35251c1074cdc4fb5bda67d340f8c8b3a |
| QtTranslations | https://download.qt.io/archive/qt/6.8/6.8.3/submodules/qttranslations-everywhere-src-6.8.3.tar.xz | c3c61d79c3d8fe316a20b3617c64673ce5b5519b2e45535f49bee313152fa531 |

官方归档索引：https://download.qt.io/archive/qt/6.8/6.8.3/ 。本仓库不上传庞大的 Qt SDK 缓存；提供模块源码地址不等于把对应源码从发行义务中删除。

**分发者责任：**这些源码由第三方服务器托管。发布或继续分发时，核对链接和版本；若链接失效，需要镜像对应源码并更新二进制旁的说明。不要声称源码只需用户自行搜索。若自己修改 Qt，还必须提供修改后的对应源码，而不是继续指向原版归档。

### 替换 / 再链接

用兼容的 MSVC x64 工具链按 Qt 官方构建说明构建同版本 Qt，保留相同的动态库接口。在关闭应用后，用自己的兼容 DLL 替换 bin/ 下 Qt6*.dll 及对应平台插件，或按 BUILD.md 将应用重新构建并部署到你的 Qt 安装。

Qt 源码构建说明：https://doc.qt.io/qt-6.8/build-sources.html 。重新构建应用的完整源码随 source.zip 提供。SHA256SUMS 仅用于下载完整性校验，不限制修改后的软件运行。

## 其他源码与许可

- hidapi 0.15.0：https://github.com/libusb/hidapi/tree/hidapi-0.15.0 。本分发选用其 BSD 许可，完整 notice 保留。
- quickjs-ng：external/quickjs/ 随应用 source.zip 提供，原 MIT 许可保留。
- DirectX Shader Compiler / DXIL：DLL 文件版本 1.8.2502.11；源码/许可基线 https://github.com/microsoft/DirectXShaderCompiler/tree/v1.8.2502 ，完整 LICENSE.TXT 在 licenses/DirectXShaderCompiler-LICENSE.txt。
- Microsoft Visual C++ / UCRT / D3DCompiler 运行库：来自合法 MSVC/Windows SDK 的再分发目录和 Qt 官方部署输出，未修改。适用 Microsoft 许可与再分发资格，不以 MIT 重新授权。相关官方条款和清单见 licenses/Microsoft-runtime-NOTICE.txt。

本说明是项目的分发材料与责任提示，不替代适用许可证或法律意见。
