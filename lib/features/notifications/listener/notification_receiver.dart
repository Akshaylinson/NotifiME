import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/notification_repository.dart';
import '../repository/notification_provider.dart';
import '../models/notification_model.dart';
import '../models/app_model.dart';
import '../processors/priority_processor.dart';
import '../processors/privacy_processor.dart';
import '../../../core/constants/app_constants.dart';
import 'dart:developer' as developer;

class NotificationReceiver {
  static const MethodChannel _channel = MethodChannel('com.example.notifime/notifications');
  final NotificationRepository _repository;
  final ProviderContainer _container;
  final PrivacyProcessor _privacyProcessor = PrivacyProcessor();

  NotificationReceiver(this._repository, this._container);

  void startListening() {
    developer.log('NotificationReceiver: Starting to listen');
    _channel.setMethodCallHandler((call) async {
      developer.log('NotificationReceiver: Received method call: ${call.method}');
      if (call.method == 'onNotificationReceived') {
        final Map<dynamic, dynamic> data = call.arguments;
        developer.log('NotificationReceiver: Data received: $data');
        await _handleIncomingNotification(data);
      }
    });
  }

  Future<void> _handleIncomingNotification(Map<dynamic, dynamic> data) async {
    try {
      final String packageName = data['packageName'] ?? 'unknown';
      final String appName = data['appName'] ?? 'Unknown App';
      final String title = data['title'] ?? '';
      final String message = data['message'] ?? '';

      developer.log('Processing notification from: $appName');

      // 1. Get or Create App
      final apps = await _repository.getAllApps();
      var app = apps.firstWhere(
        (a) => a.packageName == packageName,
        orElse: () => AppModel(appName: appName, packageName: packageName),
      );

      if (app.id == null) {
        final id = await _repository.insertApp(app);
        app = AppModel(id: id, appName: appName, packageName: packageName);
        developer.log('Created new app entry with ID: $id');
      }

      // 2. Privacy Masking
      final maskedMessage = _privacyProcessor.maskSensitiveInfo(message);

      // 3. Priority Detection
      final priority = PriorityProcessor.detectPriority(title, maskedMessage);

      // 4. Check for duplicates
      final duplicate = await _repository.findRecentDuplicate(
        app.id!,
        title,
        maskedMessage,
      );

      if (duplicate != null) {
        developer.log(
          'Duplicate notification ignored (within deduplication window): '
          'App: $appName, Title: $title',
        );
        return;
      }

      // 5. Save Notification
      final notification = NotificationModel(
        appId: app.id!,
        sender: title,
        title: title,
        message: maskedMessage,
        timestamp: DateTime.now(),
        priority: priority,
      );

      await _repository.insertNotification(notification);
      developer.log('Notification saved successfully!');

      // 6. Refresh UI - Dashboard
      _container.read(appListProvider.notifier).refresh();
      
      // 7. Refresh UI - App Detail if viewing
      try {
        _container.read(notificationsByAppProvider(app.id!).notifier).refresh();
      } catch (e) {
        // Provider might not be initialized yet, ignore
      }
      
      developer.log('UI refreshed');
    } catch (e) {
      developer.log('Error handling notification: $e', error: e);
    }
  }
}
