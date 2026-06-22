import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'supertonic_tts_service.dart';
import 'voice_provider.dart';
import '../../notifications/models/notification_model.dart';
import '../../notifications/repository/notification_provider.dart';

final ttsServiceProvider = Provider((ref) => SupertonicTTSService());

final ttsControllerProvider = StateNotifierProvider<TTSController, TTSState>((ref) => TTSController(ref));

class TTSState {
  final bool isPlaying;
  
  TTSState({this.isPlaying = false});
  
  TTSState copyWith({bool? isPlaying}) {
    return TTSState(isPlaying: isPlaying ?? this.isPlaying);
  }
}

class TTSController extends StateNotifier<TTSState> {
  final Ref ref;
  
  TTSController(this.ref) : super(TTSState());

  Future<void> readLatest(int appId) async {
    if (state.isPlaying) return;
    
    state = state.copyWith(isPlaying: true);
    final tts = ref.read(ttsServiceProvider);
    tts.resetStopFlag();
    
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final notifications = await repo.getNotificationsByApp(appId);
      
      if (notifications.isNotEmpty) {
        final latest = notifications.first;
        await _speakNotification(latest);
      }
    } finally {
      state = state.copyWith(isPlaying: false);
    }
  }

  Future<void> readAllFromApp(int appId) async {
    if (state.isPlaying) return;
    
    state = state.copyWith(isPlaying: true);
    final tts = ref.read(ttsServiceProvider);
    tts.resetStopFlag();
    
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final notifications = await repo.getNotificationsByApp(appId);
      
      for (var notification in notifications) {
        if (tts.isStopped) break;
        await _speakNotification(notification);
      }
    } finally {
      state = state.copyWith(isPlaying: false);
    }
  }

  Future<void> readImportant(int appId) async {
    if (state.isPlaying) return;
    
    state = state.copyWith(isPlaying: true);
    final tts = ref.read(ttsServiceProvider);
    tts.resetStopFlag();
    
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final notifications = await repo.getNotificationsByApp(appId);
      final important = notifications.where((n) => n.priority == 'high').toList();
      
      for (var notification in important) {
        if (tts.isStopped) break;
        await _speakNotification(notification);
      }
    } finally {
      state = state.copyWith(isPlaying: false);
    }
  }

  Future<void> readAll() async {
    if (state.isPlaying) return;
    
    state = state.copyWith(isPlaying: true);
    final tts = ref.read(ttsServiceProvider);
    tts.resetStopFlag();
    
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final apps = await repo.getAllApps();
      
      for (var app in apps) {
        if (tts.isStopped) break;
        final notifications = await repo.getNotificationsByApp(app.id!);
        for (var notification in notifications) {
          if (tts.isStopped) break;
          await _speakNotification(notification);
        }
      }
    } finally {
      state = state.copyWith(isPlaying: false);
    }
  }

  Future<void> _speakNotification(NotificationModel notification) async {
    final tts = ref.read(ttsServiceProvider);
    final selectedVoice = ref.read(selectedVoiceProvider);
    final text = '${notification.title}. ${notification.message}';
    await tts.speak(text, voice: selectedVoice);
  }

  Future<void> stop() async {
    final tts = ref.read(ttsServiceProvider);
    await tts.stop();
    state = state.copyWith(isPlaying: false);
  }
}
