# Esc-to-tray release plan — v1.5.0-peripheral.3

## Scope and acceptance criteria
- Unmodified Esc in the main window (including focused child controls) hides it to the existing tray without exiting; tray activation restores it.
- Reuse closeEvent so saved window size and the one-time tray hint remain consistent. Do not change polling, charging or device protocols.
- Dialogs and open dropdowns keep their normal Esc cancellation behavior. Other keys/modifiers do not hide the main window; no visible tray means Esc must not close it.
- Build Windows x64 Release, run isolated regressions and smoke-test the deployed runtime. Package portable/source/plugin ZIPs with licenses and SHA256; non-force push master and an annotated new tag, then publish a verified GitHub Release. Keep previous releases for rollback.

## Implementation decisions
Use MainWindow::keyPressEvent rather than an application-wide shortcut: ordinary Qt event propagation lets child controls, popup menus and dialogs consume Esc first. Only handle plain Esc with a visible tray, delegating everything else to QMainWindow.
Add an opt-in Qt Widgets/Test regression executable using the real window and isolated temporary settings; never include tests in deployed packages.

## Ordered tasks
1. Add failing Esc regression and test target.
2. Implement the guarded key handler; run focused and full tests.
3. Update documentation, review diff, commit, deploy and validate packages.
4. Push commit/tag, upload draft attachments, verify hashes, publish Latest.

## Risks and rollback
Child controls may consume Esc: test edit/spin/table/button/dropdown paths. Packaging must use the exact committed source and newly built runtime. If verification fails, do not publish. After release, exit the new app and use the retained peripheral.2 portable directory; no settings migration is introduced.
