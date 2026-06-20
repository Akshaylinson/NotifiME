import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_model.dart';
import '../models/notification_model.dart';
import 'notification_repository.dart';

final notificationRepositoryProvider = Provider((ref) => NotificationRepository());

final appListProvider = StateNotifierProvider<AppListNotifier, AsyncValue<List<AppModel>>>((ref) {
  return AppListNotifier(ref.watch(notificationRepositoryProvider));
});

class AppListNotifier extends StateNotifier<AsyncValue<List<AppModel>>> {
  final NotificationRepository _repository;

  AppListNotifier(this._repository) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final apps = await _repository.getAllApps();
      state = AsyncValue.data(apps);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final notificationsByAppProvider = StateNotifierProvider.family<NotificationsByAppNotifier, AsyncValue<List<NotificationModel>>, int>((ref, appId) {
  return NotificationsByAppNotifier(ref.watch(notificationRepositoryProvider), appId);
});

class NotificationsByAppNotifier extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationRepository _repository;
  final int _appId;

  NotificationsByAppNotifier(this._repository, this._appId) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final notifications = await _repository.getNotificationsByApp(_appId);
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
