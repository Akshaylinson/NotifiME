class AppConstants {
  static const String appName = 'NotifiME';

  // Database Constants
  static const String dbName = 'notifications.db';
  static const int dbVersion = 1;

  // Table Names
  static const String tableApps = 'apps';
  static const String tableNotifications = 'notifications';
  static const String tableSettings = 'settings';

  // Deduplication Configuration
  static const int deduplicationWindowSeconds = 30;
}
