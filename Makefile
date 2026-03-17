.PHONY: help dev run run-web run-android run-linux run-ios run-macos run-windows \
        build build-apk build-web build-linux analyze test clean

help:
	@echo "Najd Volunteer — Flutter App"
	@echo ""
	@echo "Run targets:"
	@echo "  make run          Auto-detect device and run"
	@echo "  make run-web      Web server on http://localhost:8080  (container / any host)"
	@echo "  make run-android  Connected Android device              (USB or WiFi ADB)"
	@echo "  make run-linux    Linux desktop app                     (container / Linux host)"
	@echo "  make run-ios      iOS device / simulator                (macOS host only)"
	@echo "  make run-macos    macOS desktop app                     (macOS host only)"
	@echo "  make run-windows  Windows desktop app                   (Windows host only)"
	@echo ""
	@echo "Build targets:"
	@echo "  make build-apk    Android APK"
	@echo "  make build-web    Web release"
	@echo "  make build-linux  Linux desktop"
	@echo ""
	@echo "Dev targets:"
	@echo "  make dev          Install dependencies (flutter pub get)"
	@echo "  make analyze      Dart static analysis"
	@echo "  make test         Run unit/widget tests"
	@echo "  make clean        Remove build artifacts"

# ── Setup ──────────────────────────────────────────────────────────────────
dev:
	@echo "Setting up Flutter dev environment..."
	flutter pub get
	@echo "✓ Ready to develop"

# ── Run ───────────────────────────────────────────────────────────────────
run:
	@bash scripts/run.sh

run-web:
	flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0

run-android:
	flutter run -d android

run-linux:
	@if [ -z "$$DISPLAY" ]; then \
		echo "No DISPLAY set — starting Xvfb on :99"; \
		Xvfb :99 -screen 0 1280x800x24 & sleep 1; \
		DISPLAY=:99 flutter run -d linux; \
	else \
		flutter run -d linux; \
	fi

run-ios:
	@echo "iOS builds require macOS + Xcode."
	@echo "Open a terminal on your Mac (outside the container) and run:"
	@echo "  cd <project-path> && flutter run -d ios"

run-macos:
	@echo "macOS builds require a Mac host."
	@echo "Open a terminal on your Mac (outside the container) and run:"
	@echo "  cd <project-path> && flutter run -d macos"

run-windows:
	@echo "Windows builds require a Windows host."
	@echo "Open PowerShell / Terminal on Windows and run:"
	@echo "  flutter run -d windows"

# ── Build ─────────────────────────────────────────────────────────────────
build-apk:
	flutter build apk

build-web:
	flutter build web

build-linux:
	flutter build linux

build: build-apk

# ── Quality ───────────────────────────────────────────────────────────────
analyze:
	flutter analyze

test:
	flutter test

clean:
	flutter clean
