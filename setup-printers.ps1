# Setup home printers via IPP (driverless)
# Run as: Right-click -> Run with PowerShell

Write-Host "Setting up printers from printserver..." -ForegroundColor Cyan
Write-Host ""

# Deskjet (color)
$deskjetName = "HP Deskjet 1050 J410 @ printserver"
$deskjetUrl = "http://printserver.local:631/printers/Deskjet_1050_J410"

if (Get-Printer -Name $deskjetName -ErrorAction SilentlyContinue) {
    Write-Host "[OK] $deskjetName already configured" -ForegroundColor Green
} else {
    # Remove old generic entries for Deskjet
    Get-Printer | Where-Object { $_.Name -match "Deskjet.*1050" -and $_.Name -ne $deskjetName } | ForEach-Object {
        Remove-Printer -Name $_.Name
        Write-Host "[X]  Removed old entry: $($_.Name)" -ForegroundColor Yellow
    }
    Add-Printer -Name $deskjetName -DriverName "Microsoft IPP Class Driver" -PortName $deskjetUrl -ErrorAction SilentlyContinue
    if (-not $?) {
        Add-PrinterPort -Name $deskjetUrl -PrinterHostAddress "printserver.local" -PortNumber 631 -ErrorAction SilentlyContinue
        Add-Printer -Name $deskjetName -DriverName "Microsoft IPP Class Driver" -PortName $deskjetUrl
    }
    Write-Host "[OK] $deskjetName added" -ForegroundColor Green
}

# LaserJet (B&W)
$laserjetName = "HP LaserJet P1505 @ printserver"
$laserjetUrl = "http://printserver.local:631/printers/HP_LaserJet_P1505"

if (Get-Printer -Name $laserjetName -ErrorAction SilentlyContinue) {
    Write-Host "[OK] $laserjetName already configured" -ForegroundColor Green
} else {
    # Remove old generic entries for LaserJet
    Get-Printer | Where-Object { $_.Name -match "LaserJet.*P1505" -and $_.Name -ne $laserjetName } | ForEach-Object {
        Remove-Printer -Name $_.Name
        Write-Host "[X]  Removed old entry: $($_.Name)" -ForegroundColor Yellow
    }
    Add-Printer -Name $laserjetName -DriverName "Microsoft IPP Class Driver" -PortName $laserjetUrl -ErrorAction SilentlyContinue
    if (-not $?) {
        Add-PrinterPort -Name $laserjetUrl -PrinterHostAddress "printserver.local" -PortNumber 631 -ErrorAction SilentlyContinue
        Add-Printer -Name $laserjetName -DriverName "Microsoft IPP Class Driver" -PortName $laserjetUrl
    }
    Write-Host "[OK] $laserjetName added" -ForegroundColor Green
}

Write-Host ""
Write-Host "Done! Printers are ready to use." -ForegroundColor Cyan
Write-Host ""
Read-Host "Press Enter to close"
