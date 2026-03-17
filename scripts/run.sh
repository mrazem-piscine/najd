#!/bin/bash
# Smart Flutter runner — detects connected devices and picks the best target.
# Run from inside the devcontainer or directly on your host machine.
set -e

echo "=== Najd Volunteer — Flutter Runner ==="
echo "Detecting devices..."
echo ""

DEVICES=$(flutter devices 2>/dev/null || echo "")

run_web() {
    echo "▶ Launching web server on http://localhost:8080"
    flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
}

run_android() {
    echo "▶ Launching on Android device"
    flutter run -d android
}

run_ios() {
    echo "▶ Launching on iOS device / simulator"
    flutter run -d ios
}

run_linux() {
    echo "▶ Launching Linux desktop"
    if [ -z "$DISPLAY" ]; then
        Xvfb :99 -screen 0 1280x800x24 &
        sleep 1
        DISPLAY=:99 flutter run -d linux
    else
        flutter run -d linux
    fi
}

run_macos() {
    echo "▶ Launching macOS desktop"
    flutter run -d macos
}

run_windows() {
    echo "▶ Launching Windows desktop"
    flutter run -d windows
}

# ── Priority: Android > iOS > platform-native > web ────────────────────────
if echo "$DEVICES" | grep -qi "android"; then
    run_android
elif echo "$DEVICES" | grep -qi "ios\|iphone\|ipad"; then
    run_ios
else
    HOST_OS=$(uname -s)
    case "$HOST_OS" in
        Darwin)
            # On Mac: prefer macOS desktop if no mobile device connected
            if flutter devices 2>/dev/null | grep -qi "macos"; then
                run_macos
            else
                run_web
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*|Windows_NT)
            run_windows
            ;;
        Linux)
            # Inside container → web is most reliable; linux works with Xvfb
            if [ -n "$REMOTE_CONTAINERS" ] || [ -f "/.dockerenv" ]; then
                run_web
            else
                run_linux
            fi
            ;;
        *)
            run_web
            ;;
    esac
fi
