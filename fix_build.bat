@echo off
echo ============================================
echo   Fixing Build Issues
echo ============================================
echo.

echo Step 1: Cleaning Flutter cache...
flutter clean
echo.

echo Step 2: Cleaning Gradle cache...
cd android
call gradlew clean
cd ..
echo.

echo Step 3: Removing build directories...
if exist build rmdir /s /q build
if exist android\.gradle rmdir /s /q android\.gradle
if exist android\app\build rmdir /s /q android\app\build
echo.

echo Step 4: Getting Flutter dependencies...
flutter pub get
echo.

echo Step 5: Rebuilding...
echo This may take a few minutes...
flutter run
