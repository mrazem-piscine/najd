#!/bin/bash
# Quick dev setup script
set -e

echo "=== Najd Volunteer Dev Setup ==="
echo "Installing dependencies..."
flutter pub get

echo "Running Flutter analysis..."
flutter analyze

echo "✓ Dev environment ready!"
echo ""
echo "To run the app:"
echo "  flutter run"
echo ""
echo "To run tests:"
echo "  flutter test"
