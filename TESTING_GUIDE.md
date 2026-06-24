# Testing Guide - Notification System Fixes

## ✅ All Critical Issues Fixed

### 1. ✅ bigText Extraction (Line 37 in NotificationListener.kt)
```kotlin
val bigText = extras.getCharSequence("android.bigText")?.toString()
val message = bigText ?: text  // Full text now captured
```

### 2. ✅ MethodChannel Background Communication (Line 20 in NotificationListener.kt)
```kotlin
companion object {
    var staticChannel: MethodChannel? = null
}
```
Set in MainActivity.kt (Line 19):
```kotlin
NotificationListener.staticChannel = channel
```

### 3. ✅ Permission Verification (MainActivity.kt Line 28-31)
```kotlin
"isNotificationListenerEnabled" -> {
    result.success(isNotificationListenerEnabled())
}
```
Used in main.dart (Line 76-83) to show permission screen when needed.

## 🧪 Testing Steps

### Step 1: Check Logcat
```bash
adb logcat -s NotificationListener MainActivity NotificationReceiver
```

**Expected output when notification arrives:**
```
NotificationListener: Notification from: com.whatsapp
NotificationListener: Title: John, Text: Hey there, BigText: Hey there, how are you doing today?
NotificationListener: Sent to Flutter: WhatsApp
NotificationReceiver: Received method call: onNotificationReceived
NotificationReceiver: Data received: {...}
NotificationReceiver: Processing notification from: WhatsApp
NotificationReceiver: Notification saved successfully!
```

### Step 2: Verify Permission
```bash
adb shell settings get secure enabled_notification_listeners
```
Should contain: `com.example.notifime`

### Step 3: Test Notification Capture
1. Open app - should see permission screen if not granted
2. Grant notification access
3. App automatically navigates to dashboard
4. Send test notification from WhatsApp/any app
5. Check dashboard - notification should appear immediately
6. Open app details - verify full message text (not truncated)

### Step 4: Test Background Capture
1. Close app completely (swipe from recent apps)
2. Send multiple notifications
3. Reopen app
4. All notifications should be captured and displayed

### Step 5: Verify Full Text
1. Send long message (>100 characters) via WhatsApp
2. Check in app - should show complete message
3. If truncated, check logcat for "BigText: null"

## 🔍 Debugging Commands

**Check if service is running:**
```bash
adb shell dumpsys notification_listener
```

**Force stop and restart:**
```bash
adb shell am force-stop com.example.notifime
adb shell am start -n com.example.notifime/.MainActivity
```

**Clear app data:**
```bash
adb shell pm clear com.example.notifime
```

**Monitor real-time logs:**
```bash
adb logcat | grep -E "NotificationListener|NotificationReceiver|MainActivity"
```

## ✅ Success Criteria

- [ ] Permission screen appears when permission not granted
- [ ] App navigates to dashboard automatically after granting
- [ ] Notifications captured while app is in background
- [ ] Full message text displayed (not truncated at ~50 chars)
- [ ] No "MethodChannel is null" errors in logcat
- [ ] Notifications appear in dashboard within 1 second
- [ ] App icon/name displays correctly for each notification

## 🐛 Common Issues

**Issue: "MethodChannel is null"**
- Fixed by using static companion object
- Verify MainActivity configures channel in configureFlutterEngine()

**Issue: Truncated messages**
- Fixed by reading android.bigText extras
- Check logcat to confirm bigText is being extracted

**Issue: Permission not detected**
- Fixed by isNotificationListenerEnabled() check
- App now shows permission screen when needed
- Auto-refresh when returning from settings
