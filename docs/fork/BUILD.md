# 从源码构建

Windows 10/11 x64，Visual Studio 2022 / Build Tools 的 Desktop development with C++，Windows SDK（含 C++/WinRT）、CMake >= 3.25、Qt 6.x MSVC x64（上游最低 6.5；本次发行使用 6.8.3，需 Core/Widgets/Network/WebSockets/Sql/LinguistTools）。可使用 Ninja。

在 x64 Native Tools / Developer PowerShell 中，从仓库根目录执行，Qt 路径改成自己的安装位置：

```powershell
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="C:/Qt/6.8.3/msvc2022_64"
cmake --build build --parallel 4
cmake --install build --prefix "$((Get-Location).Path)/dist/runtime"
```

CMake 会部署 Qt、hidapi、插件及适用的 MSVC/UCRT 运行库。external/hidapi/ 保留了构建所需的 DLL、LIB 和头文件；Qt 与编译工具需在开发环境中单独安装。

如果 Windows SDK 未被识别，请在开发终端确认 WindowsSdkDir 指向已安装的 SDK。

Release 构建关闭 C++/WinRT 的源位置诊断，避免把开发环境的绝对路径嵌入程序；Debug 构建保留诊断信息。这不改变设备识别和电量读取逻辑。

## 测试

插件测试需要 Node.js（仅开发测试使用，不随应用发布）：

```powershell
node tests/gm3323d-plugin.test.mjs
```

自动回归测试不需要外设，设置写入独立临时目录。在 Qt 的 bin 目录已加入 PATH 的开发终端中执行：

```powershell
cmake -S . -B build -DBATTERYMONITOR_BUILD_TESTS=ON
cmake --build build --parallel 4
ctest --test-dir build --output-on-failure
```

`charging-state` 验证设备/未知/手动来源、断开和过期状态、UI/RPC 变化检测及设置隔离。安装 Node.js 后还会注册 `gm3323d-plugin`，覆盖充/放电全档位、无效报告、超时和拔插异常。测试程序不安装进运行包。

S87Pro 验证需要实际设备；设备 ID 和预期电量通过命令行传入。可选测试构建会生成 `build/tests/s87pro-windows-test.exe`；也可在开发终端中编译，输出到 build/：

```powershell
cl /nologo /std:c++20 /Zc:__cplusplus /EHsc /utf-8 /MD /DQT_NO_VERSION_TAGGING /I. /I"C:/Qt/6.8.3/msvc2022_64/include" /I"C:/Qt/6.8.3/msvc2022_64/include/QtCore" tests/s87pro-windows-test.cpp src/providers/bluetooth/S87ProWindowsBattery.cpp /Fobuild/ /link setupapi.lib /OUT:build/s87pro-windows-test.exe
build/s87pro-windows-test.exe "你的 S87Pro BluetoothLE 设备 ID" 当前Windows属性百分比
```

测试需要键盘已连接，不能作为无设备 CI 的模拟测试。设备采样输出不属于发布内容。

## 部署检查

Qt 部署需要绝对安装路径，以上安装命令已展开为绝对路径。使用独立工具链时，应设置 VCINSTALLDIR / WindowsSdkDir；若 windeployqt 提示缺少 dxcompiler.dll 或 dxil.dll，从相同 Windows SDK 的 Redist/D3D/x64 目录部署这两个文件，保留随包许可。MSVC 运行库由 CMake 的 InstallRequiredSystemLibraries 收集。
