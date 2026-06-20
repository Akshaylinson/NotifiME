import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'supertonic_tts_service.dart';
import '../../notifications/models/notification_model.dart';
import '../../notifications/repository/notification_provider.dart';

final ttsServiceProvider = Provider((ref) => SupertonicTTSService());

final ttsControllerProvider = Provider((ref) => TTSController(ref));

class TTSController {
  final Ref ref;
  
  TTSController(this.ref);

  Future<void> readLatest(int appId) async {
    final repo = ref.read(notificationRepositoryProvider);
    final notifications = await repo.getNotificationsByApp(appId);
    
    if (notifications.isNotEmpty) {
      final latest = notifications.first;
      await _speakNotification(latest);
    }
  }

  Future<void> readAllFromApp(int appId) async {
    final repo = ref.read(notificationRepositoryProvider);
    final notifications = await repo.getNotificationsByApp(appId);
    
    for (var notification in notifications) {
      await _speakNotification(notification);
    }
  }

  Future<void> readImportant(int appId) async {
    final repo = ref.read(notificationRepositoryProvider);
    final notifications = await repo.getNotificationsByApp(appId);
    final important = notifications.where((n) => n.priority == 'high').toList();
    
    for (var notification in important) {
      await _speakNotification(notification);
    }
  }

  Future<void> readAll() async {
    final repo = ref.read(notificationRepositoryProvider);
    final apps = await repo.getAllApps();
    
    for (var app in apps) {
      final notifications = await repo.getNotificationsByApp(app.id!);
      for (var notification in notifications) {
        await _speakNotification(notification);
      }
    }
  }

  Future<void> _speakNotification(NotificationModel notification) async {
    final tts = ref.read(ttsServiceProvider);
    final text = '${notification.title}. ${notification.message}';
    await tts.speak(text);
  }

  Future<void> stop() async {
    final tts = ref.read(ttsServiceProvider);
    await tts.stop();
  }
}
