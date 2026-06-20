import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_model.dart';
import '../models/notification_model.dart';
import 'notification_repository.dart';

final notificationRepositoryProvider = Provider((ref) => NotificationRepository());

final appListProvider = FutureProvider<List<AppModel>>((ref) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getAllApps();
});

final notificationsByAppProvider = FutureProvider.family<List<NotificationModel>, int>((ref, appId) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getNotificationsByApp(appId);
});
