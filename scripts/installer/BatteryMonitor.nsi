Unicode true
!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "x64.nsh"
!include "WinVer.nsh"
!ifndef VERSION
!error "Build with scripts/package-installer.ps1"
!endif
!define APP_NAME "BatteryMonitor 外设适配版"
!define APP_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\BatteryMonitor-PeripheralBattery"
Name "${APP_NAME} ${VERSION}"
OutFile "${OUT_FILE}"
InstallDir "$LOCALAPPDATA\Programs\BatteryMonitor-PeripheralBattery"
InstallDirRegKey HKCU "${APP_KEY}" "InstallLocation"
RequestExecutionLevel user
ManifestDPIAware true
ManifestSupportedOS all
SetCompressor zlib
VIProductVersion "${VERSION_FILE}"
VIAddVersionKey /LANG=1033 "ProductName" "BatteryMonitor Peripheral Edition Setup"
VIAddVersionKey /LANG=1033 "FileDescription" "Per-user installer for BatteryMonitor"
VIAddVersionKey /LANG=1033 "FileVersion" "${VERSION}"
VIAddVersionKey /LANG=1033 "LegalCopyright" "Application: JKWTCN; adaptations and installer: worlt"
!define MUI_ICON "${PAYLOAD}\res-installer.ico"
!define MUI_UNICON "${PAYLOAD}\res-installer.ico"
!define MUI_ABORTWARNING
!define MUI_FINISHPAGE_RUN "$INSTDIR\bin\BatteryMonitor.exe"
!define MUI_FINISHPAGE_RUN_NOTCHECKED
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "${PAYLOAD}\LICENSE"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH
!insertmacro MUI_LANGUAGE "SimpChinese"
!insertmacro MUI_LANGUAGE "English"

!macro CheckWritable PREFIX
Function ${PREFIX}CheckWritable
    IfFileExists "$INSTDIR\bin\BatteryMonitor.exe" 0 done
    ; Opening for write without writing detects a running/locked destination EXE.
    System::Call 'kernel32::CreateFileW(w "$INSTDIR\bin\BatteryMonitor.exe", i 0x40000000, i 7, p 0, i 3, i 0, p 0) p.r0'
    ${If} $0 == -1
        IfSilent +2
        MessageBox MB_OK|MB_ICONSTOP "请先从托盘退出此安装目录中的 BatteryMonitor，然后重试。 / Exit BatteryMonitor in this installation directory before continuing."
        SetErrorLevel 2
        Abort
    ${EndIf}
    System::Call 'kernel32::CloseHandle(p r0)'
    done:
FunctionEnd
!macroend
!insertmacro CheckWritable ""
!insertmacro CheckWritable "un."

Function .onInit
    ${IfNot} ${RunningX64}
        MessageBox MB_OK|MB_ICONSTOP "需要 Windows 10/11 x64。 / Windows 10/11 x64 is required."
        SetErrorLevel 3
        Abort
    ${EndIf}
    ${IfNot} ${AtLeastWin10}
        MessageBox MB_OK|MB_ICONSTOP "需要 Windows 10 或更高版本。 / Windows 10 or later is required."
        SetErrorLevel 3
        Abort
    ${EndIf}
    SetRegView 64
    SetShellVarContext current
FunctionEnd

Function un.onInit
    SetRegView 64
    SetShellVarContext current
    Call un.CheckWritable
FunctionEnd

Section "Install"
    Call CheckWritable
    SetOverwrite on
    !include "${MANIFEST_DIR}\InstallFiles.nsh"
    WriteUninstaller "$INSTDIR\Uninstall.exe"
    CreateDirectory "$SMPROGRAMS\${APP_NAME}"
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\BatteryMonitor.lnk" "$INSTDIR\bin\BatteryMonitor.exe"
    CreateShortCut "$SMPROGRAMS\${APP_NAME}\卸载 Uninstall.lnk" "$INSTDIR\Uninstall.exe"
    WriteRegStr HKCU "${APP_KEY}" "DisplayName" "${APP_NAME}"
    WriteRegStr HKCU "${APP_KEY}" "DisplayVersion" "${VERSION}"
    WriteRegStr HKCU "${APP_KEY}" "Publisher" "worlt (based on JKWTCN/BatteryMonitor)"
    WriteRegStr HKCU "${APP_KEY}" "InstallLocation" "$INSTDIR"
    WriteRegStr HKCU "${APP_KEY}" "DisplayIcon" "$INSTDIR\bin\BatteryMonitor.exe"
    WriteRegStr HKCU "${APP_KEY}" "UninstallString" '$\"$INSTDIR\Uninstall.exe$\"'
    WriteRegStr HKCU "${APP_KEY}" "QuietUninstallString" '$\"$INSTDIR\Uninstall.exe$\" /S'
    WriteRegStr HKCU "${APP_KEY}" "URLInfoAbout" "https://github.com/worlt/BatteryMonitor-PeripheralBattery"
    WriteRegDWORD HKCU "${APP_KEY}" "NoModify" 1
    WriteRegDWORD HKCU "${APP_KEY}" "NoRepair" 1
    WriteRegDWORD HKCU "${APP_KEY}" "EstimatedSize" ${INSTALL_KB}
SectionEnd

Section "Uninstall"
    !include "${MANIFEST_DIR}\UninstallFiles.nsh"
    Delete "$INSTDIR\Uninstall.exe"
    ; Never recursively remove user-chosen directories or user-created files.
    RMDir "$INSTDIR"
    Delete "$SMPROGRAMS\${APP_NAME}\BatteryMonitor.lnk"
    Delete "$SMPROGRAMS\${APP_NAME}\卸载 Uninstall.lnk"
    RMDir "$SMPROGRAMS\${APP_NAME}"
    DeleteRegKey HKCU "${APP_KEY}"
    ; Application settings/history under AppData and QSettings are preserved.
SectionEnd
