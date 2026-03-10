@echo off
cd /d "%~dp0"

echo Checking for Flutter...
where flutter >nul 2>&1
if errorlevel 1 (
    echo Flutter not found in PATH. Please install Flutter and add it to PATH.
    echo https://docs.flutter.dev/get-started/install/windows
    pause
    exit /b 1
)

if not exist "android" (
    echo Adding Android and iOS platform folders...
    flutter create . --project-name najd_volunteer
)

echo Getting dependencies...
flutter pub get

echo Running the app...
echo (Pick a device when prompted. Use Android if Windows says "Visual Studio toolchain" missing.)
flutter run

pause
