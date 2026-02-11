# Changelog

## 2026-02-09
- Initial setup of CUPS print server on Raspberry Pi (Ubuntu 24.04 LTS)
- Configured two printers: HP Deskjet 1050 J410 (color) and HP LaserJet P1505 (B&W)
- Diagnosed and fixed macOS printing issue — Ghostscript crash on PostScript, switched to IPP Everywhere (driverless)
- Created `setup-printers.command` (macOS) and `setup-printers.ps1` (Windows) client setup scripts
- Configured Samba printer sharing with custom `samba-bgqd` systemd service
- Configured WS-Discovery (`wsdd`) for Windows network discovery
- Created project documentation (`CLAUDE.md`)
- Pushed to GitHub (bubenkoff/printserver)

## 2026-02-11
- Checked ink levels — both cartridges ~20%
- Ran printhead cleaning (hp-clean level 1, x3) for streaking black cartridge
- Made GitHub repo public
