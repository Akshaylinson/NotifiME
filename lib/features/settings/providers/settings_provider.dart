import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings {
  final bool autoReadNotifications;
  final double speechSpeed;

  AppSettings({
    required this.autoReadNotifications,
    required this.speechSpeed,
  });

  AppSettings copyWith({
    bool? autoReadNotifications,
    double? speechSpeed,
  }) {
    return AppSettings(
      autoReadNotifications: autoReadNotifications ?? this.autoReadNotifications,
      speechSpeed: speechSpeed ?? this.speechSpeed,
    );
  }
}

final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier();
});

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  AppSettingsNotifier()
      : super(AppSettings(
          autoReadNotifications: false,
          speechSpeed: 1.0,
        )) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = AppSettings(
      autoReadNotifications: prefs.getBool('auto_read_notifications') ?? false,
      speechSpeed: prefs.getDouble('speech_speed') ?? 1.0,
    );
  }

  Future<void> setAutoRead(bool value) async {
    state = state.copyWith(autoReadNotifications: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_read_notifications', value);
  }

  Future<void> setSpeechSpeed(double value) async {
    state = state.copyWith(speechSpeed: value);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('speech_speed', value);
  }
}
