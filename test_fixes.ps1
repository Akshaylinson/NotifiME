# NotifiME - Critical Fixes Test Suite
# PowerShell Version

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "NotifiME - Critical Fixes Test Suite" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Try to find ADB
$adbPaths = @(
    "adb",
    "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
    "$env:ANDROID_HOME\platform-tools\adb.exe",
    "C:\Program Files (x86)\Android\android-sdk\platform-tools\adb.exe",
    "C:\Android\Sdk\platform-tools\adb.exe"
)

$adb = $null
foreach ($path in $adbPaths) {
    if (Get-Command $path -ErrorAction SilentlyContinue) {
        $adb = $path
        break
    }
}

if (-not $adb) {
    Write-Host "[ERROR] ADB not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install Android SDK Platform Tools or add ADB to PATH" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Common locations:" -ForegroundColor Yellow
    Write-Host "  - $env:LOCALAPPDATA\Android\Sdk\platform-tools" -ForegroundColor Gray
    Write-Host "  - C:\Android\Sdk\platform-tools" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Download: https://developer.android.com/studio/releases/platform-tools" -ForegroundColor Yellow
    Write-Host ""
    pause
    exit
}

Write-Host "[OK] Found ADB at: $adb" -ForegroundColor Green
Write-Host ""

# Check if device is connected
Write-Host "[0] Checking device connection..." -ForegroundColor Yellow
$devices = & $adb devices
if ($devices -match "device$") {
    Write-Host "[OK] Device connected" -ForegroundColor Green
} else {
    Write-Host "[FAILED] No device connected" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please connect your Android device via USB and enable USB debugging" -ForegroundColor Yellow
    Write-Host ""
    pause
    exit
}
Write-Host ""

# Test 1: Check permission
Write-Host "[1] Checking if NotificationListener permission is granted..." -ForegroundColor Yellow
$listeners = & $adb shell settings get secure enabled_notification_listeners
if ($listeners -match "notifime") {
    Write-Host "[OK] Permission granted" -ForegroundColor Green
} else {
    Write-Host "[FAILED] Permission NOT granted" -ForegroundColor Red
    Write-Host "    -> Open app and grant notification access" -ForegroundColor Yellow
}
Write-Host ""

# Test 2: Check service
Write-Host "[2] Checking if NotificationListener service is running..." -ForegroundColor Yellow
$service = & $adb shell dumpsys notification_listener | Select-String "notifime"
if ($service) {
    Write-Host "[OK] Service is running" -ForegroundColor Green
} else {
    Write-Host "[WARNING] Service status unclear" -ForegroundColor Yellow
}
Write-Host ""

# Test 3: Package installed
Write-Host "[3] Checking if app is installed..." -ForegroundColor Yellow
$package = & $adb shell pm list packages | Select-String "notifime"
if ($package) {
    Write-Host "[OK] App installed: $package" -ForegroundColor Green
} else {
    Write-Host "[FAILED] App not installed" -ForegroundColor Red
    Write-Host "    -> Build and install the app first" -ForegroundColor Yellow
}
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "[4] Starting live log monitoring..." -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Send a test notification now (WhatsApp, SMS, etc.)" -ForegroundColor White
Write-Host ""
Write-Host "Expected logs:" -ForegroundColor Cyan
Write-Host "  - Notification from: [package]" -ForegroundColor Gray
Write-Host "  - Title: ..., Text: ..., BigText: ..." -ForegroundColor Gray
Write-Host "  - Sent to Flutter: [AppName]" -ForegroundColor Gray
Write-Host "  - Received method call: onNotificationReceived" -ForegroundColor Gray
Write-Host "  - Notification saved successfully!" -ForegroundColor Gray
Write-Host ""
Write-Host "Press Ctrl+C to stop monitoring" -ForegroundColor Yellow
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

& $adb logcat -c
& $adb logcat -s NotificationListener:D MainActivity:D NotificationReceiver:I
