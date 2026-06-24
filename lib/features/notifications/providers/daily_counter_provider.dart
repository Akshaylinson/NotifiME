import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyNotificationCounter extends StateNotifier<int> {
  DailyNotificationCounter() : super(0) {
    _loadCount();
    _checkAndResetDaily();
  }

  static const String _countKey = 'daily_notification_count';
  static const String _dateKey = 'last_reset_date';

  Future<void> _loadCount() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getInt(_countKey) ?? 0;
  }

  Future<void> _checkAndResetDaily() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayString();
    final lastResetDate = prefs.getString(_dateKey);

    if (lastResetDate != today) {
      // It's a new day, reset the counter
      await prefs.setInt(_countKey, 0);
      await prefs.setString(_dateKey, today);
      state = 0;
    }
  }

  Future<void> increment() async {
    // Check if we need to reset first
    await _checkAndResetDaily();
    
    final prefs = await SharedPreferences.getInstance();
    state = state + 1;
    await prefs.setInt(_countKey, state);
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    state = 0;
    await prefs.setInt(_countKey, 0);
    await prefs.setString(_dateKey, _getTodayString());
  }

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

final dailyNotificationCounterProvider =
    StateNotifierProvider<DailyNotificationCounter, int>((ref) {
  return DailyNotificationCounter();
});
