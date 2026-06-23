import '../../../shared/database/database_helper.dart';
import '../models/notification_model.dart';
import '../models/app_model.dart';
import '../../../core/constants/app_constants.dart';
import 'package:sqflite/sqflite.dart';

class NotificationRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<int> insertApp(AppModel app) async {
    final db = await _dbHelper.database;
    return await db.insert(
      AppConstants.tableApps,
      app.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<List<AppModel>> getAllApps() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(AppConstants.tableApps);
    return List.generate(maps.length, (i) => AppModel.fromMap(maps[i]));
  }

  Future<NotificationModel?> findRecentDuplicate(
      int appId, String title, String message) async {
    final db = await _dbHelper.database;
    final windowStart = DateTime.now()
        .subtract(Duration(seconds: AppConstants.deduplicationWindowSeconds))
        .millisecondsSinceEpoch;

    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableNotifications,
      where: 'app_id = ? AND title = ? AND message = ? AND timestamp >= ?',
      whereArgs: [appId, title, message, windowStart],
      orderBy: 'timestamp DESC',
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return NotificationModel.fromMap(maps.first);
  }

  Future<int> insertNotification(NotificationModel notification) async {
    final db = await _dbHelper.database;

    // Increment notification count for the app
    await db.rawUpdate(
      'UPDATE ${AppConstants.tableApps} SET notification_count = notification_count + 1 WHERE id = ?',
      [notification.appId],
    );

    return await db.insert(AppConstants.tableNotifications, notification.toMap());
  }

  Future<List<NotificationModel>> getNotificationsByApp(int appId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableNotifications,
      where: 'app_id = ?',
      whereArgs: [appId],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => NotificationModel.fromMap(maps[i]));
  }

  Future<List<NotificationModel>> getNotificationsByRange(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableNotifications,
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => NotificationModel.fromMap(maps[i]));
  }

  Future<List<NotificationModel>> getUnreadNotifications() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableNotifications,
      where: 'read_status = 0',
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => NotificationModel.fromMap(maps[i]));
  }

  Future<List<NotificationModel>> getAllNotifications() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppConstants.tableNotifications,
      orderBy: 'timestamp DESC',
    );
    return List.generate(maps.length, (i) => NotificationModel.fromMap(maps[i]));
  }

  Future<void> markAllAsRead(int appId) async {
    final db = await _dbHelper.database;
    await db.update(
      AppConstants.tableNotifications,
      {'read_status': 1},
      where: 'app_id = ?',
      whereArgs: [appId],
    );
  }

  Future<void> deleteNotificationsByApp(int appId) async {
    final db = await _dbHelper.database;
    await db.delete(
      AppConstants.tableNotifications,
      where: 'app_id = ?',
      whereArgs: [appId],
    );
    await db.update(
      AppConstants.tableApps,
      {'notification_count': 0},
      where: 'id = ?',
      whereArgs: [appId],
    );
  }

  Future<void> deleteOldNotifications(int retentionDays) async {
    final db = await _dbHelper.database;
    final cutoffTime = DateTime.now()
        .subtract(Duration(days: retentionDays))
        .millisecondsSinceEpoch;

    // Get apps with old notifications
    final oldNotifications = await db.query(
      AppConstants.tableNotifications,
      where: 'timestamp < ?',
      whereArgs: [cutoffTime],
      columns: ['app_id'],
    );

    // Delete old notifications
    await db.delete(
      AppConstants.tableNotifications,
      where: 'timestamp < ?',
      whereArgs: [cutoffTime],
    );

    // Recalculate notification counts for affected apps
    final affectedAppIds = oldNotifications
        .map((row) => row['app_id'] as int)
        .toSet();

    for (var appId in affectedAppIds) {
      final countResult = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${AppConstants.tableNotifications} WHERE app_id = ?',
        [appId],
      );
      final count = countResult.first['count'] as int;
      
      await db.update(
        AppConstants.tableApps,
        {'notification_count': count},
        where: 'id = ?',
        whereArgs: [appId],
      );
    }
  }
}
