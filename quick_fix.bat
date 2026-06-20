@echo off
echo ============================================
echo   Quick Build Fix
echo ============================================
echo.

echo Cleaning Flutter cache...
flutter clean

echo.
echo Removing Gradle cache...
if exist "android\.gradle" rmdir /s /q "android\.gradle"
if exist "android\app\build" rmdir /s /q "android\app\build"

echo.
echo Getting dependencies...
flutter pub get

echo.
echo ============================================
echo   Ready! Now run: flutter run
echo ============================================
pause
