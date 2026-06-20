@echo off
echo ============================================
echo   NotifiME - Quick Run Script
echo ============================================
echo.

echo Step 1: Checking Flutter installation...
flutter doctor --version
if errorlevel 1 (
    echo ERROR: Flutter not found! Please install Flutter first.
    pause
    exit /b 1
)
echo.

echo Step 2: Installing dependencies...
flutter pub get
if errorlevel 1 (
    echo ERROR: Failed to install dependencies!
    pause
    exit /b 1
)
echo.

echo Step 3: Checking connected devices...
flutter devices
echo.

echo Step 4: Starting the app...
echo.
echo Choose run mode:
echo 1. Debug mode (hot reload enabled)
echo 2. Release mode (optimized performance)
echo.
set /p choice="Enter choice (1 or 2): "

if "%choice%"=="2" (
    echo Running in RELEASE mode...
    flutter run --release
) else (
    echo Running in DEBUG mode...
    flutter run
)
