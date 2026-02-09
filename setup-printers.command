#!/bin/bash
# Setup home printers via IPP Everywhere (driverless)
# Just double-click this file to add printers

echo "Setting up printers from printserver..."
echo ""

# Remove old generic/broken printer entries (skip scanner and already correct ones)
for printer in $(lpstat -v 2>/dev/null | grep -i "printserver" | grep -v "_printserver" | grep -v "mdns://" | awk -F'[ :]' '{print $4}'); do
    lpadmin -x "$printer" 2>/dev/null && echo "✗ Removed old entry: $printer"
done

# Add Deskjet (color)
if lpstat -v 2>/dev/null | grep -q "Deskjet_1050_J410_printserver"; then
    echo "✓ HP Deskjet 1050 J410 already configured"
else
    lpadmin -p Deskjet_1050_J410_printserver -E \
        -v ipp://printserver.local:631/printers/Deskjet_1050_J410 \
        -m everywhere \
        -D "HP Deskjet 1050 J410 @ printserver" \
        -L "Living Room"
    echo "✓ HP Deskjet 1050 J410 added"
fi

# Add LaserJet (B&W)
if lpstat -v 2>/dev/null | grep -q "HP_LaserJet_P1505_printserver"; then
    echo "✓ HP LaserJet P1505 already configured"
else
    lpadmin -p HP_LaserJet_P1505_printserver -E \
        -v ipp://printserver.local:631/printers/HP_LaserJet_P1505 \
        -m everywhere \
        -D "HP LaserJet P1505 @ printserver" \
        -L "Living Room"
    echo "✓ HP LaserJet P1505 added"
fi

echo ""
echo "Done! Printers are ready to use."
echo ""
read -n 1 -s -r -p "Press any key to close..."
