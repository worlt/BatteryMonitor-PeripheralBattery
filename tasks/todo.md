# Esc-to-tray release tasks

- [x] Add failing regression using the real MainWindow and temporary settings (no hardware).
- [x] Implement guarded plain-Esc close-to-tray; verify focused controls, restore, popup/dialog cancellation, no-tray fallback and full CTest.
- [x] Update docs, review and commit; build/deploy Windows x64 Release and package portable/source/plugin ZIPs with verified hashes/licenses.
- [x] Non-force push master and annotated v1.5.0-peripheral.3 tag; verify draft attachments before publishing Latest.

## Verification evidence before packaging

- Initial Esc test failed on the unchanged window; guarded handler passes.
- All three CTest suites pass in Windows x64 Release.
- The same real-window regression passes with the deployed Qt DLLs and native Windows platform (temporary settings; running user app untouched).
- A deliberate temporary Esc -> app.quit() mutation fails the main-loop liveness assertion; mutation removed and clean Release rebuilt/retested.
- Debug test target now copies its hidapi.dll dependency. Full Debug execution was not part of this release validation.
- Existing closeEvent/showTrayHintOnce code is unchanged; notification count is statically reviewed, not an automated assertion. Native Explorer/tray installation failure recovery remains upstream behavior.

## Published release verification

- Release/tag source commit: `d4169b201c50ce1f9aeb6466c454e4f90f2bc201`.
- Portable/source/plugin ZIPs, release notes and SHA256 manifest uploaded; all five GitHub asset SHA256 digests match local files.
- Portable archive extracted and real-window/native Windows regression passed with its runtime DLLs.
- Source ZIP matches all 377 tracked files byte-for-byte at the tagged commit; portable EXE SHA256: `7340ffddcbed892da78a2dc9c7702a7f09d3756a2fe2d14851acdfff8abfbf21`.
- Published as non-prerelease Latest: https://github.com/worlt/BatteryMonitor-PeripheralBattery/releases/tag/v1.5.0-peripheral.3 . Previous releases retained.
- This completion-record update is documentation-only after the tagged source snapshot; no packaged code or binary changed.
