# Supplemental Setup.exe plan — peripheral.3

Acceptance: add a per-user Windows 10/11 x64 Setup.exe to the existing release, installing the exact verified portable payload, Start menu shortcuts and uninstall registration without elevation/autostart. Uninstall removes only manifest-listed files and retains user settings/history/unrelated files. Keep existing ZIPs/tag/source unchanged. Include NSIS notices and installer scripts source separately; update release notes/checksums.

Tasks: package the installer; verify silent install/uninstall into a checked workspace path and payload hashes; review/commit installer scripts; upload setup and supplemental installer source, update notes/hash assets, verify public release.

Rollback: existing portable ZIP and application source commit remain unchanged. Delete only the new installation via its uninstaller; retain user state.

Verification before upload:
- Final setup silent install/uninstall passed; all 133 original portable files match byte-for-byte.
- Start menu/uninstall registration verified; locked EXE upgrade rejected without changing payload.
- Uninstall preserves unrelated sentinel files and application settings/history locations.
- Corrupt portable SHA256 and ZIP traversal input rejected before extraction outside staging.
- Installer is unsigned; disclosed in installed guide and release docs.
- Upload/publish verification follows the packaging-source commit; existing release tag and application archives are preserved.
