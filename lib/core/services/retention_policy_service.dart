import 'package:workmanager/workmanager.dart';
import '../../features/notifications/repository/notification_repository.dart';
import '../../features/settings/providers/settings_provider.dart';
import 'dart:developer' as developer;

class RetentionPolicyService {
  static const String cleanupTaskName = 'notification_cleanup';
  static const String cleanupTaskTag = 'cleanup_old_notifications';

  // Singleton pattern
  static final RetentionPolicyService _instance = RetentionPolicyService._internal();
  factory RetentionPolicyService() => _instance;
  RetentionPolicyService._internal();

  /// Initialize background cleanup service
  Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    // Schedule periodic cleanup (daily at 3 AM)
    await schedulePeriodicCleanup();
  }

  /// Schedule periodic cleanup task
  Future<void> schedulePeriodicCleanup() async {
    await Workmanager().registerPeriodicTask(
      cleanupTaskName,
      cleanupTaskTag,
      frequency: const Duration(hours: 24),
      initialDelay: _calculateInitialDelay(),
      constraints: Constraints(
        networkType: NetworkType.notRequired,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
      ),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
    
    developer.log('RetentionPolicy: Scheduled periodic cleanup (daily)');
  }

  /// Calculate delay to run at 3 AM
  Duration _calculateInitialDelay() {
    final now = DateTime.now();
    var targetTime = DateTime(now.year, now.month, now.day, 3, 0); // 3 AM today
    
    // If it's already past 3 AM, schedule for tomorrow
    if (now.isAfter(targetTime)) {
      targetTime = targetTime.add(const Duration(days: 1));
    }
    
    return targetTime.difference(now);
  }

  /// Run cleanup immediately (for testing or manual trigger)
  Future<void> runCleanupNow() async {
    await Workmanager().registerOneOffTask(
      'cleanup_now',
      cleanupTaskTag,
      initialDelay: Duration.zero,
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
    
    developer.log('RetentionPolicy: Manual cleanup triggered');
  }

  /// Cancel all cleanup tasks
  Future<void> cancelCleanup() async {
    await Workmanager().cancelByTag(cleanupTaskTag);
    developer.log('RetentionPolicy: Cleanup tasks cancelled');
  }
}

/// Background callback for Workmanager
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      developer.log('RetentionPolicy: Background cleanup started');
      
      // Get settings and repository
      final settingsRepo = SettingsRepository();
      final settings = await settingsRepo.getSettings();
      
      final notificationRepo = NotificationRepository();
      
      // Delete old notifications
      await notificationRepo.deleteOldNotifications(settings.retentionDays);
      
      developer.log('RetentionPolicy: Cleanup completed (retention: ${settings.retentionDays} days)');
      
      return Future.value(true);
    } catch (e) {
      developer.log('RetentionPolicy: Cleanup failed - $e', error: e);
      return Future.value(false);
    }
  });
}

