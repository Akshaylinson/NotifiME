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

final notificationsByAppProvider = FutureProvider.family<List<NotificationModel>, int>((ref, appId) async {
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.getNotificationsByApp(appId);
});
