import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/database/database_helper.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/retention_policy_service.dart';
import '../../notifications/repository/notification_provider.dart';
import '../../notifications/repository/notification_repository.dart';

class AppSettings {
  final int? id;
  final String voice;
  final double speechRate;
  final double pitch;
  final bool autoRead;
  final int retentionDays;

  AppSettings({
    this.id,
    required this.voice,
    required this.speechRate,
    required this.pitch,
    required this.autoRead,
    required this.retentionDays,
  });

  AppSettings copyWith({
    int? id,
    String? voice,
    double? speechRate,
    double? pitch,
    bool? autoRead,
    int? retentionDays,
  }) {
    return AppSettings(
      id: id ?? this.id,
      voice: voice ?? this.voice,
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      autoRead: autoRead ?? this.autoRead,
      retentionDays: retentionDays ?? this.retentionDays,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'voice': voice,
      'speech_rate': speechRate,
      'pitch': pitch,
      'auto_read': autoRead ? 1 : 0,
      'retention_days': retentionDays,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      id: map['id'] as int?,
      voice: map['voice'] as String,
      speechRate: map['speech_rate'] as double,
      pitch: map['pitch'] as double,
      autoRead: (map['auto_read'] as int) == 1,
      retentionDays: map['retention_days'] as int,
    );
  }

  factory AppSettings.defaultSettings() {
    return AppSettings(
      voice: 'F2',
      speechRate: 1.0,
      pitch: 1.0,
      autoRead: false,
      retentionDays: 7,
    );
  }
}

class SettingsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<AppSettings> getSettings() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableSettings,
      limit: 1,
    );

    if (maps.isEmpty) {
      // Create default settings
      final defaultSettings = AppSettings.defaultSettings();
      await _saveSettings(defaultSettings);
      return defaultSettings;
    }

    return AppSettings.fromMap(maps.first);
  }

  Future<void> _saveSettings(AppSettings settings) async {
    final db = await _dbHelper.database;
    
    if (settings.id == null) {
      await db.insert(AppConstants.tableSettings, settings.toMap());
    } else {
      await db.update(
        AppConstants.tableSettings,
        settings.toMap(),
        where: 'id = ?',
        whereArgs: [settings.id],
      );
    }
  }

  Future<void> updateSettings(AppSettings settings) async {
    await _saveSettings(settings);
  }
}

final settingsRepositoryProvider = Provider((ref) => SettingsRepository());

final appSettingsProvider = StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  return AppSettingsNotifier(
    ref.read(settingsRepositoryProvider),
    ref.read(notificationRepositoryProvider),
  );
});

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final SettingsRepository _repository;
  final NotificationRepository _notificationRepository;

  AppSettingsNotifier(this._repository, this._notificationRepository)
      : super(AppSettings.defaultSettings());

  Future<void> initializeAndCleanup() async {
    await _loadSettings();
    await _cleanupOldNotifications();
  }

  Future<void> _loadSettings() async {
    final settings = await _repository.getSettings();
    state = settings;
  }

  Future<void> _cleanupOldNotifications() async {
    await _notificationRepository.deleteOldNotifications(state.retentionDays);
  }

  Future<void> setVoice(String voice) async {
    final updated = state.copyWith(voice: voice);
    await _repository.updateSettings(updated);
    state = updated;
  }

  Future<void> setSpeechRate(double rate) async {
    final updated = state.copyWith(speechRate: rate);
    await _repository.updateSettings(updated);
    state = updated;
  }

  Future<void> setPitch(double pitch) async {
    final updated = state.copyWith(pitch: pitch);
    await _repository.updateSettings(updated);
    state = updated;
  }

  Future<void> setAutoRead(bool autoRead) async {
    final updated = state.copyWith(autoRead: autoRead);
    await _repository.updateSettings(updated);
    state = updated;
  }

  Future<void> setRetentionDays(int days) async {
    final updated = state.copyWith(retentionDays: days);
    await _repository.updateSettings(updated);
    state = updated;
    // Cleanup when retention period changes
    await _cleanupOldNotifications();
    // Reschedule background cleanup with new settings
    await _rescheduleCleanup();
  }

  Future<void> _rescheduleCleanup() async {
    try {
      final retentionService = RetentionPolicyService();
      await retentionService.schedulePeriodicCleanup();
    } catch (e) {
      // Ignore if workmanager not initialized yet
    }
  }
}
