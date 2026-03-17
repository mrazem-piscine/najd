#!/bin/bash
# Connects the container's ADB client to the host machine's ADB server.
# The host ADB server manages USB/wireless device access directly.
# Requires: `adb start-server` running on the host before the container starts.

echo "=== ADB Setup ==="

# Check connectivity to host ADB server
if adb devices 2>/dev/null | grep -q "device"; then
    echo "✓ Android device detected via host ADB server:"
    adb devices
elif adb devices 2>/dev/null; then
    echo "  No Android device connected yet."
    echo "  To connect a device:"
    echo "    USB  → enable USB Debugging, plug in, then run: adb devices (on host)"
    echo "    WiFi → Developer Options → Wireless debugging → pair"
else
    echo "  Could not reach host ADB server."
    echo "  On your host machine run: adb start-server"
fi
echo ""
