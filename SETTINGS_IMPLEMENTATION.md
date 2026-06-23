# Settings Persistence Implementation

## Changes Summary

### ✅ Implemented Features

#### 1. **Database-Backed Settings Persistence**
- Replaced SharedPreferences with SQLite database storage
- All settings now persist in the `settings` table
- Auto-loads on app startup

#### 2. **Default Voice Changed to F2 (Female)**
- Changed default voice from `M1` to `F2` in `tts_config.dart`
- All audio generation now uses the configured voice from settings
- Voice persists across app restarts

#### 3. **Complete Settings Model**
```dart
- voice: String (default: 'F2')
- speechRate: double (default: 1.0)
- pitch: double (default: 1.0)
- autoRead: bool (default: false)
- retentionDays: int (default: 7)
```

#### 4. **Retention Policy Auto-Cleanup**
- Old notifications automatically deleted based on retention days
- Cleanup runs on:
  - App startup
  - When retention period is changed in settings
- Notification counts automatically recalculated after cleanup

#### 5. **Voice Integration Fix**
- `selectedVoiceProvider` now reads from settings database
- TTS service uses settings.voice for all audio generation
- No more male voice on first launch - always uses F2 (female) by default

#### 6. **Retention Days Selector**
- Added functional dropdown in settings
- Options: 7, 14, 30, 60, 90 days
- Persists to database immediately

---

## Modified Files

### 1. `lib/core/constants/tts_config.dart`
- Changed `defaultVoice = 'F2'` (was M1)

### 2. `lib/features/settings/providers/settings_provider.dart`
**Complete rewrite:**
- Added full AppSettings model with all fields
- Created SettingsRepository for database operations
- Implements `initializeAndCleanup()` for startup
- All settings persist to SQLite database
- Added retention cleanup trigger

### 3. `lib/features/audio/tts/voice_provider.dart`
- Removed StateNotifierProvider for selectedVoice
- Now uses computed Provider that reads from appSettingsProvider
- Voice changes immediately reflected in all audio operations

### 4. `lib/features/audio/tts/tts_provider.dart`
- Updated `readSummary()` to use `settings.voice` and `settings.speechRate`
- Updated `_speakNotification()` to use settings directly
- Removed redundant selectedVoiceProvider references

### 5. `lib/features/settings/screens/settings_screen.dart`
- Changed `autoReadNotifications` → `autoRead`
- Changed `speechSpeed` → `speechRate`
- Added functional retention days dropdown dialog
- Voice selection now updates settings database
- Display shows current retention days value

### 6. `lib/features/notifications/repository/notification_repository.dart`
- Added `deleteOldNotifications(int retentionDays)` method
- Automatically recalculates notification counts after cleanup
- Handles cleanup for all apps efficiently

### 7. `lib/main.dart`
- Added `await container.read(appSettingsProvider.notifier).initializeAndCleanup()`
- Ensures settings loaded and old notifications cleaned before app starts

---

## How It Works

### On App First Launch:
1. Settings table is empty
2. `getSettings()` creates default settings: `{ voice: 'F2', speechRate: 1.0, retentionDays: 7, autoRead: false }`
3. Settings inserted into database
4. All audio uses F2 voice

### On App Restart:
1. `initializeAndCleanup()` called in main()
2. Settings loaded from database
3. Old notifications deleted based on retention days
4. UI shows correct settings
5. Audio uses persisted voice

### When User Changes Voice:
1. User selects voice in settings
2. `appSettingsProvider.notifier.setVoice(newVoice)` called
3. Database updated immediately
4. State updated
5. Next audio generation uses new voice

### When Retention Period Changes:
1. User selects new retention period
2. Database updated
3. `_cleanupOldNotifications()` triggered automatically
4. Old notifications deleted
5. Notification counts recalculated

---

## Testing Checklist

- [x] Settings persist after app restart
- [x] Default voice is F2 (female)
- [x] Voice changes apply to all audio (summaries + notifications)
- [x] Auto-read toggle persists
- [x] Speech rate persists and applies
- [x] Retention days selector works
- [x] Old notifications deleted automatically
- [x] Notification counts update after cleanup
- [x] Settings UI reflects actual database values

---

## Database Schema

```sql
CREATE TABLE settings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  voice TEXT,
  speech_rate REAL,
  pitch REAL,
  auto_read INTEGER DEFAULT 0,
  retention_days INTEGER DEFAULT 7
)
```

Only 1 row exists in this table at any time.

---

## Benefits

✅ **Consistent Voice**: F2 female voice from first launch  
✅ **True Persistence**: Database-backed, survives app uninstall (if backup enabled)  
✅ **Automatic Cleanup**: No manual intervention needed for old notifications  
✅ **Single Source of Truth**: Settings model drives all features  
✅ **Immediate Updates**: Changes apply instantly to all components  
✅ **Production Ready**: Error handling, default values, atomic updates  

---

## Notes

- Retention cleanup is efficient (single query + batch updates)
- Settings load asynchronously but provide defaults immediately
- Voice provider is now computed from settings (no separate state)
- All TTS operations respect the persisted settings
