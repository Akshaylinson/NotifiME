@echo off
REM Quick Test Script for NotifiME Critical Fixes
echo ========================================
echo NotifiME - Critical Fixes Test Suite
echo ========================================
echo.

echo [1] Checking if NotificationListener permission is granted...
adb shell settings get secure enabled_notification_listeners | findstr "notifime"
if %errorlevel% equ 0 (
    echo [OK] Permission granted
) else (
    echo [FAILED] Permission NOT granted - open app and grant access
)
echo.

echo [2] Checking if NotificationListener service is running...
adb shell dumpsys notification_listener | findstr "notifime"
if %errorlevel% equ 0 (
    echo [OK] Service is running
) else (
    echo [FAILED] Service not running
)
echo.

echo [3] Starting live log monitoring...
echo Watching for: NotificationListener, MainActivity, NotificationReceiver
echo Send a test notification now...
echo.
echo Expected logs:
echo   - "Notification from: [package]"
echo   - "Title: ..., Text: ..., BigText: ..."
echo   - "Sent to Flutter: [AppName]"
echo   - "Received method call: onNotificationReceived"
echo   - "Notification saved successfully!"
echo.
echo Press Ctrl+C to stop monitoring
echo ========================================
adb logcat -s NotificationListener:D MainActivity:D NotificationReceiver:I

pause
