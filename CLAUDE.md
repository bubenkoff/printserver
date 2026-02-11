# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

**At the start of every session**: run `git pull` to sync with remote, then read `CHANGELOG.md`.

## Project Overview

Configuration and maintenance of a CUPS print server running on a Raspberry Pi (Ubuntu 24.04 LTS, aarch64).

## Target System

- **Host**: `printserver.local` (Raspberry Pi), IP `192.168.88.31`
- **OS**: Ubuntu 24.04.3 LTS (noble), aarch64
- **Access**: `ssh ubuntu@printserver.local`
- **CUPS**: 2.4.7, cups-filters 2.0.0, Ghostscript 10.02.1, HPLIP 3.23.12
- **Samba**: 4.19.5

## Printers

| Printer | Connection | Location |
|---------|-----------|----------|
| HP Deskjet 1050 J410 (color, inkjet, combo with scanner) | USB via HPLIP (`hp:/usb/...`) | Living Room |
| HP LaserJet P1505 (mono, laser) | USB via HPLIP (`hp:/usb/...`) | Living Room |

## Services

- **CUPS** (`cups.service`) — print server, port 631, shares printers via IPP/IPPS
- **Avahi** (`avahi-daemon.service`) — mDNS/DNS-SD discovery (Bonjour)
- **cups-browsed** (`cups-browsed.service`) — remote printer browsing
- **Samba** (`smbd.service`, `nmbd.service`) — SMB/CIFS printer sharing for Windows
- **samba-bgqd** (`samba-bgqd.service`) — Samba background queue daemon, loads CUPS printers into Samba (custom unit, required for `[printers]` auto-share to work)
- **wsdd** (`wsdd.service`) — WS-Discovery daemon for Windows 10/11 network discovery (custom unit)
- **AirSane** — scanner sharing for Deskjet 1050 (combo device, do NOT remove scanner entries on clients)

## Client Setup

### macOS (Sequoia 15.x)
macOS Sequoia no longer auto-detects CUPS-shared printers as AirPrint due to self-signed TLS certificate. Printers must be added via IPP Everywhere (driverless).

**Automated**: run `setup-printers.command` (double-click) — removes old generic entries, adds both printers via IPP Everywhere.

**Manual** (per printer): System Settings → Printers & Scanners → Add Printer → **IP tab**:
- Address: `printserver.local`
- Protocol: IPP
- Queue: `printers/Deskjet_1050_J410` or `printers/HP_LaserJet_P1505`
- Use: should auto-select "IPP Everywhere"

**CLI**:
```bash
lpadmin -p Deskjet_1050_J410_printserver -E \
  -v ipp://printserver.local:631/printers/Deskjet_1050_J410 \
  -m everywhere \
  -D "HP Deskjet 1050 J410 @ printserver" \
  -L "Living Room"
```

### Windows
**Automated**: run `setup-printers.ps1` (right-click → Run with PowerShell) — uses Microsoft IPP Class Driver.

**Manual**: Add printer → `\\printserver\Deskjet_1050_J410` or `\\printserver\HP_LaserJet_P1505`.

### iPhone/Android
Auto-discovery via AirPrint/Mopria — works without configuration.

## Known Issues & Solutions

### macOS prints show as completed but nothing prints
**Root cause**: macOS adds CUPS-shared printers as "Generic PostScript", converting PDF→PostScript via `cgpdftops`. Ghostscript 10.02.1 on aarch64 crashes with `rangecheck; OffendingCommand: get` on macOS-generated PostScript.

**Fix**: Add printer via IPP Everywhere (see Client Setup above). This makes macOS send PDF directly instead of PostScript.

### macOS only shows "Generic PostScript Printer" when adding printers
**Root cause**: CUPS uses a self-signed TLS cert. macOS Sequoia rejects it during AirPrint auto-detection via IPPS, falls back to Generic PostScript. Apple also removed third-party HP drivers from macOS.

**Workaround**: Add printers manually via IP tab or `setup-printers.command` script. No server-side fix available — Apple requires trusted CA certificates for AirPrint auto-detection.

### macOS "Windows" tab empty when adding printers
**Root cause**: macOS Sequoia requires SMB signing for network browsing. Guest/anonymous connections can't satisfy this. SMB shares work from terminal (`smbutil view //guest@printserver.local`) but not from GUI.

**Workaround**: Use IP tab or `setup-printers.command` script instead.

### Samba `[printers]` auto-share not loading printers
**Root cause**: `samba-bgqd` (background queue daemon) was not starting automatically. Without it, `printer_list.tdb` stays empty and `pcap cache not loaded`.

**Fix**: Custom systemd unit `/etc/systemd/system/samba-bgqd.service` created and enabled.

### Deskjet scanner entry on macOS
The Deskjet 1050 is a combo printer/scanner. On macOS, the scanner appears as a separate entry (`Hewlett_Packard_Deskjet_1050_J410_series`) with `APScannerOnly: True` via AirSane. **Do NOT delete this entry** — it's the scanner, not a broken printer.

### Locale warning
`setlocale: LC_ALL: cannot change locale (en_GB.UTF-8)` — cosmetic, fix with `sudo locale-gen en_GB.UTF-8`.

## Common Commands

```bash
# Remote command execution
ssh ubuntu@printserver.local '<command>'

# Printer status
ssh ubuntu@printserver.local 'lpstat -t'

# Print queue (completed / pending)
ssh ubuntu@printserver.local 'lpstat -W completed -o'
ssh ubuntu@printserver.local 'lpstat -W not-completed -o'

# Ink levels (Deskjet)
ssh ubuntu@printserver.local 'hp-levels -d hp:/usb/Deskjet_1050_J410_series?serial=CN1AK1N3Y805QT'

# CUPS logs
ssh ubuntu@printserver.local 'sudo tail -f /var/log/cups/error_log'

# Enable debug logging (temporary)
ssh ubuntu@printserver.local 'sudo sed -i "s/^LogLevel warn/LogLevel debug/" /etc/cups/cupsd.conf && sudo systemctl restart cups'

# Restore normal logging
ssh ubuntu@printserver.local 'sudo sed -i "s/^LogLevel debug/LogLevel warn/" /etc/cups/cupsd.conf && sudo systemctl restart cups'

# Test print
ssh ubuntu@printserver.local 'lp -d Deskjet_1050_J410 /usr/share/cups/data/testprint'

# Samba shares
ssh ubuntu@printserver.local 'smbclient -L localhost -N'

# Check Samba printer list
ssh ubuntu@printserver.local 'sudo tdbdump /run/samba/printer_list.tdb'

# Restart all print-related services
ssh ubuntu@printserver.local 'sudo systemctl restart cups smbd nmbd samba-bgqd wsdd avahi-daemon'
```

## Changelog

All changes are tracked in `CHANGELOG.md`. **Always read it at the start of a session and append new entries when making changes.**

## Project Files

- `setup-printers.command` — macOS script to configure printers (double-click)
- `setup-printers.ps1` — Windows PowerShell script to configure printers
- `CHANGELOG.md` — changelog (always read and update)
- `CLAUDE.md` — this file
