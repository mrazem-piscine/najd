#!/usr/bin/env bash
set -e

echo "Setting up ADB..."

if ! command -v adb >/dev/null 2>&1; then
  echo "adb is not installed in the container. Skipping ADB setup."
  exit 0
fi

if timeout 3 adb devices >/dev/null 2>&1; then
  echo "ADB is available."
else
  echo "ADB server/device not reachable right now. Skipping ADB setup."
fi

echo "ADB setup script finished."
exit 0