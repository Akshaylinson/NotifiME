# Manual Testing Guide (No ADB Required)

## 🎯 Quick Visual Tests - No ADB Needed

### ✅ Test 1: Permission Detection (30 seconds)

1. **Uninstall app** (if previously installed)
2. **Install and open app**
3. **Expected:** Permission screen appears with "Enable Notification Access" button
4. **Click** "Enable Notification Access"
5. **Enable** NotifiME in notification access settings
6. **Press back** to return to app
7. **Expected:** App automatically shows Dashboard (not stuck on permission screen)

**✅ PASS if:** App navigates to Dashboard automatically after granting permission
**❌ FAIL if:** Stuck on permission screen or crashes

---

### ✅ Test 2: Background Notification Capture (1 minute)

1. **Open NotifiME app** → Should see Dashboard
2. **Close app completely** (swipe away from recent apps)
3. **Send yourself a WhatsApp message** from another device
4. **Wait 5 seconds**
5. **Reopen NotifiME**
6. **Expected:** WhatsApp appears in app list with notification count

**✅ PASS if:** Notification captured while app was closed
**❌ FAIL if:** No notifications appear

---

### ✅ Test 3: Full Message Text (No Truncation) (1 minute)

1. **Send long message** to yourself via WhatsApp (150+ characters):
   ```
   This is a very long test message to verify that the bigText extraction fix is working correctly. The previous implementation only captured about 50 characters, but now it should capture the complete message content without any truncation issues.
   ```

2. **Open NotifiME**
3. **Tap on WhatsApp** in dashboard
4. **View the notification details**
5. **Expected:** Full message visible (all 150+ characters)

**✅ PASS if:** Complete message displayed
**❌ FAIL if:** Message cut off at ~50 characters ("...This is a very long test message to verify that the...")

---

### ✅ Test 4: Real-time Capture (30 seconds)

1. **Open NotifiME** → Dashboard visible
2. **Keep app open** (don't close)
3. **Send notification** from another app (WhatsApp/Gmail/SMS)
4. **Wait 2 seconds**
5. **Pull down to refresh** dashboard (or it auto-refreshes)
6. **Expected:** New notification appears immediately

**✅ PASS if:** Notification shows up within 2 seconds
**❌ FAIL if:** Need to restart app to see notification

---

### ✅ Test 5: Multiple Apps (1 minute)

1. **Open NotifiME**
2. **Send notifications** from different apps:
   - WhatsApp message
   - Gmail email
   - SMS text
   - Any other app
3. **Check dashboard**
4. **Expected:** Each app listed separately with correct icon/name and count

**✅ PASS if:** All apps appear with their notifications
**❌ FAIL if:** Notifications missing or grouped incorrectly

---

## 🔍 Visual Indicators of Success

### ✅ What You Should See:

**Dashboard Screen:**
```
┌─────────────────────────────────┐
│  Notiva AI          🔄  ⚙️       │
├─────────────────────────────────┤
│                                  │
│  📱 WhatsApp                     │
│     5 notifications         →   │
│                                  │
│  📧 Gmail                        │
│     3 notifications         →   │
│                                  │
│  💬 Messages                     │
│     1 notification          →   │
│                                  │
│         [🌟 Global Summary]     │
└─────────────────────────────────┘
```

**App Detail Screen:**
```
┌─────────────────────────────────┐
│  ← WhatsApp             🔄  ⚙️   │
├─────────────────────────────────┤
│  👤 John Doe                HIGH │
│     Hey, how are you doing?      │
│     Just now                     │
│                                  │
│  👤 Jane Smith            MEDIUM │
│     This is a very long message  │
│     that should display complete │
│     ly without truncation...     │
│     2 minutes ago                │
└─────────────────────────────────┘
```

---

## ❌ Common Failure Symptoms

### Problem: "No notifications appearing"
**Cause:** Permission not granted
**Fix:** 
1. Settings → Apps → NotifiME → Permissions
2. Or open app → should show permission screen
3. Grant "Notification access"

### Problem: "Messages truncated at 50 chars"
**Cause:** bigText fix not applied
**Fix:** 
1. Verify `NotificationListener.kt` line 36-38 has bigText code
2. Rebuild app: `flutter clean && flutter build apk`
3. Reinstall

### Problem: "Only captures when app is open"
**Cause:** staticChannel not set
**Fix:**
1. Verify `MainActivity.kt` line 19 has `NotificationListener.staticChannel = channel`
2. Rebuild and reinstall

### Problem: "Permission screen won't go away"
**Cause:** Permission check not working
**Fix:**
1. Force close app
2. Reopen
3. If still stuck, clear app data and reinstall

---

## 🎓 Expected Behavior Summary

| Scenario | Expected Result | Test Duration |
|----------|----------------|---------------|
| Fresh install | Permission screen shown | Instant |
| Permission granted | Auto-navigate to Dashboard | Instant |
| App closed, notification arrives | Captured and stored | 1-2 seconds |
| App open, notification arrives | Appears in dashboard | 1-2 seconds |
| Long message (150+ chars) | Full text visible | N/A |
| Multiple app notifications | Each app listed separately | N/A |
| Reopen after grant | Dashboard (not permission) | Instant |

---

## 📱 Quick Test Sequence (5 minutes total)

```
1. Install app                              → See permission screen (10s)
2. Grant permission                         → Auto-navigate to dashboard (5s)
3. Close app completely                     → (2s)
4. Send WhatsApp message (long text)        → (10s)
5. Reopen app                               → See WhatsApp with notification (5s)
6. Tap WhatsApp                             → See full message text (5s)
7. Go back, send Gmail notification         → (10s)
8. Pull to refresh                          → See Gmail appear (2s)
9. Check notification counts                → Accurate counts shown (5s)
10. Open Settings                           → All settings accessible (5s)

Total: ~1 minute of actual testing
```

---

## ✅ If All Tests Pass:

**Your fixes are working correctly!** 

The app is now:
- ✅ Capturing full message text (bigText)
- ✅ Working in background (staticChannel)
- ✅ Detecting and requesting permissions
- ✅ Storing notifications in local database
- ✅ Displaying notifications organized by app
- ✅ Ready for AI summarization and TTS features

---

## 📞 Need ADB for Detailed Logs?

If you want to see technical logs, you need to set up ADB:

**Option 1: Install Android Studio**
- Includes SDK Platform Tools with ADB
- Located at: `C:\Users\[YourName]\AppData\Local\Android\Sdk\platform-tools`

**Option 2: Download Platform Tools**
- https://developer.android.com/studio/releases/platform-tools
- Extract and add to PATH
- Run: `test_fixes.ps1`

But for basic validation, the manual tests above are sufficient!
