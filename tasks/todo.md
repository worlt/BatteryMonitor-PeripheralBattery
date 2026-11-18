# Esc-to-tray release tasks

- [x] Add failing regression using the real MainWindow and temporary settings (no hardware).
- [x] Implement guarded plain-Esc close-to-tray; verify focused controls, restore, popup/dialog cancellation, no-tray fallback and full CTest.
- [ ] Update docs, review and commit; build/deploy Windows x64 Release and package portable/source/plugin ZIPs with verified hashes/licenses.
- [ ] Non-force push master and annotated v1.5.0-peripheral.3 tag; verify draft attachments before publishing Latest.

## Verification evidence before packaging

- Initial Esc test failed on the unchanged window; guarded handler passes.
- All three CTest suites pass in Windows x64 Release.
- The same real-window regression passes with the deployed Qt DLLs and native Windows platform (temporary settings; running user app untouched).
- A deliberate temporary Esc -> app.quit() mutation fails the main-loop liveness assertion; mutation removed and clean Release rebuilt/retested.
- Debug test target now copies its hidapi.dll dependency. Full Debug execution was not part of this release validation.
- Existing closeEvent/showTrayHintOnce code is unchanged; notification count is statically reviewed, not an automated assertion. Native Explorer/tray installation failure recovery remains upstream behavior.
