# 🚀 NotifiME - Setup & Run Guide

## Prerequisites

### Required Software
- **Flutter SDK** (3.0.0 or higher) - [Download](https://flutter.dev/docs/get-started/install)
- **Android Studio** or **VS Code** with Flutter extension
- **Android SDK** (API level 33 or higher)
- **Java JDK** 11 or higher
- **Git**

### Check Installation
```bash
flutter doctor -v
```

---

## 📦 Installation Steps

### 1. Clone & Navigate
```bash
cd e:\NotifiME
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Clean Previous Builds
```bash
flutter clean
flutter pub get
```

### 4. Check Connected Devices
```bash
flutter devices
```

---

## 📱 Running on Android Device/Emulator

### Option A: Using Android Physical Device

1. **Enable Developer Options on your phone:**
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings > Developer Options
   - Enable "USB Debugging"

2. **Connect phone via USB**

3. **Verify connection:**
   ```bash
   flutter devices
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

### Option B: Using Android Emulator

1. **Open Android Studio > Device Manager**

2. **Create a new Virtual Device:**
   - Choose Pixel 6 or similar
   - Select Android 13 (API 33) or higher
   - Click Finish

3. **Start the emulator**

4. **Run the app:**
   ```bash
   flutter run
   ```

---

## 🔧 Development Mode

### Hot Reload (while app is running)
- Press `r` in terminal for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Debug Mode with Logs
```bash
flutter run -v
```

### Release Mode (faster performance)
```bash
flutter run --release
```

---

## 🛠️ Build APK for Installation

### Debug APK
```bash
flutter build apk --debug
```
Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Release APK (optimized)
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Install APK on Device
```bash
flutter install
```

---

## ⚙️ Post-Installation Setup

### 1. Grant Notification Access
When you first launch the app:
1. Click "Grant Permission" button
2. Find "AI Notification Assistant" in the list
3. Toggle "Allow notification access" ON
4. Confirm the permission

### 2. (Optional) Download Gemma Model
Since the Gemma model (1.3 GB) is not included:
1. Download from: [Add your source here]
2. Place the file in: `assets/models/gemma.bin`
3. Rebuild the app:
   ```bash
   flutter run
   ```

**Note:** AI summarization won't work without the Gemma model file.

---

## 🐛 Troubleshooting

### Issue: "No devices found"
```bash
# Check ADB connection
adb devices

# Restart ADB
adb kill-server
adb start-server
```

### Issue: "Gradle build failed"
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Issue: "SDK version mismatch"
Edit `android/app/build.gradle`:
```gradle
compileSdkVersion 34
minSdkVersion 24
targetSdkVersion 34
```

### Issue: "App crashes on launch"
Check logs:
```bash
flutter logs
```

### Issue: "Notification listener not working"
1. Go to Settings > Apps > AI Notification Assistant
2. Permissions > Notification access
3. Manually enable

---

## 📋 Quick Commands Cheat Sheet

```bash
# Setup
flutter pub get                    # Install dependencies
flutter clean                      # Clean build cache

# Run
flutter run                        # Run in debug mode
flutter run --release             # Run in release mode
flutter run -d <device-id>        # Run on specific device

# Build
flutter build apk                 # Build debug APK
flutter build apk --release       # Build release APK
flutter build appbundle           # Build for Play Store

# Debug
flutter logs                      # View logs
flutter doctor                    # Check setup
flutter devices                   # List devices

# Code Quality
flutter analyze                   # Static analysis
dart format lib/                  # Format code
```

---

## 🎯 Testing the App

### Test Notification Capture
1. Send yourself a WhatsApp message
2. Receive a Gmail notification
3. Get an OTP code
4. Open the app and check Dashboard

### Test Features
- ✅ Notifications grouped by app
- ✅ Priority detection (High/Medium/Low)
- ✅ Text-to-Speech (tap Read button)
- ✅ Privacy filtering (OTP codes masked)
- ✅ Mark as read
- ✅ Delete notifications

### Test AI Summary (requires Gemma model)
- Tap "Summarize" on any app
- Listen to AI-generated summary via TTS

---

## 📝 Project Structure Quick Reference

```
lib/
├── main.dart                          # App entry point
├── features/
│   ├── notifications/
│   │   ├── models/                    # Data models
│   │   ├── repository/                # Database operations
│   │   ├── screens/                   # UI screens
│   │   └── listener/                  # Native bridge
│   ├── ai/                            # AI summarization
│   ├── audio/                         # Text-to-Speech
│   └── dashboard/                     # Main UI
└── shared/database/                   # SQLite helper
```

---

## 🚀 Next Steps

1. **Grant notification permission** in app
2. **Test with real notifications**
3. **(Optional) Add Gemma model** for AI features
4. **Customize settings** (voice, speech rate, retention)

---

## 📞 Need Help?

- Check `flutter doctor` for environment issues
- Review logs with `flutter logs`
- Ensure Android SDK is properly installed
- Verify notification permission is granted

Happy coding! 🎉
