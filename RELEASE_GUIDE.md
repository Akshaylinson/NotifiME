# Notiva AI - Production Release Guide

## Prerequisites
- Flutter SDK installed
- Android Studio with SDK tools
- Java JDK 17+

## Step 1: Generate Signing Key

```bash
# Generate upload keystore (do this ONCE and keep it secure!)
keytool -genkey -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload

# Answer the prompts:
# - Enter keystore password (SAVE THIS!)
# - Re-enter keystore password
# - Enter your details (name, organization, etc.)
# - Enter key password (SAVE THIS!)
```

**IMPORTANT**: 
- Store the keystore file (`upload-keystore.jks`) securely
- Never commit it to version control
- Keep a backup in a safe location
- Save all passwords in a secure password manager

## Step 2: Configure Signing

1. Copy `android/key.properties.template` to `android/key.properties`
2. Edit `android/key.properties` with your actual values:
   ```
   storeFile=../upload-keystore.jks
   storePassword=YOUR_KEYSTORE_PASSWORD
   keyAlias=upload
   keyPassword=YOUR_KEY_PASSWORD
   ```

## Step 3: Update App Icon

1. Create app icon (1024x1024px)
2. Use Android Studio's Image Asset tool or online generator
3. Replace files in `android/app/src/main/res/drawable-*/`

## Step 4: Build Release APK

```bash
# Clean previous builds
flutter clean

# Get dependencies
flutter pub get

# Build release APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

## Step 5: Build App Bundle (for Play Store)

```bash
# Build release bundle
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

## Step 6: Test Release Build

```bash
# Install APK on connected device
flutter install --release

# OR manually install
adb install build/app/outputs/flutter-apk/app-release.apk
```

## Distribution Options

### Option 1: Google Play Store
1. Create Google Play Developer account ($25 one-time fee)
2. Upload `app-release.aab` file
3. Complete store listing (screenshots, description, etc.)
4. Submit for review

### Option 2: Direct Distribution
1. Share `app-release.apk` file directly
2. Users need to enable "Install from unknown sources"
3. Can host on your website or file-sharing platforms

### Option 3: Alternative App Stores
- Amazon Appstore
- Samsung Galaxy Store
- Huawei AppGallery
- F-Droid (for open-source)

## File Sizes (Approximate)
- APK: 45-60 MB
- AAB: 40-55 MB

## Version Management

Update version in `pubspec.yaml`:
```yaml
version: 1.0.0+1  # version_name+version_code
```

For updates:
- Increment version code (the number after +)
- Update version name (semantic versioning)
- Example: 1.0.1+2, 1.1.0+3, etc.

## Security Checklist
- ✅ Removed all debug code
- ✅ Removed all console logs with sensitive data
- ✅ API keys secured (if any)
- ✅ ProGuard/R8 enabled
- ✅ Signed with release keystore
- ✅ Tested on multiple devices
- ✅ Permissions properly documented

## Pre-Release Testing
- [ ] Test on Android 7.0+ devices
- [ ] Test notification capture
- [ ] Test TTS functionality
- [ ] Test AI summarization
- [ ] Test settings persistence
- [ ] Test database operations
- [ ] Test permission handling
- [ ] Test app restart/background behavior
- [ ] Test on different screen sizes
- [ ] Check for memory leaks

## Post-Release
- Monitor crash reports
- Collect user feedback
- Plan updates and improvements
- Respond to reviews

## Troubleshooting

### Build fails with signing error
- Check `key.properties` file exists and is correct
- Verify keystore file path is correct
- Ensure passwords match

### App size too large
- Run: `flutter build apk --release --split-per-abi`
- This creates separate APKs for different CPU architectures

### ProGuard/R8 issues
- Check `proguard-rules.pro` for missing keep rules
- Test release build thoroughly

## Support
For issues, check logs:
```bash
flutter run --release
adb logcat
```
