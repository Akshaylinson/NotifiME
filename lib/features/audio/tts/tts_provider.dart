import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'supertonic_tts_service.dart';
import 'voice_provider.dart';
import '../../notifications/models/notification_model.dart';
import '../../notifications/repository/notification_provider.dart';
import '../../settings/providers/settings_provider.dart';

// Single global TTS service instance
final ttsServiceProvider = Provider((ref) {
  final service = SupertonicTTSService();
  ref.onDispose(() => service.dispose());
  return service;
});

final ttsControllerProvider = StateNotifierProvider<TTSController, TTSState>((ref) {
  return TTSController(ref);
});

class TTSState {
  final bool isPlaying;
  final String? currentContext;
  
  TTSState({this.isPlaying = false, this.currentContext});
  
  TTSState copyWith({bool? isPlaying, String? currentContext}) {
    return TTSState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentContext: currentContext ?? this.currentContext,
    );
  }
}

class TTSController extends StateNotifier<TTSState> {
  final Ref ref;
  
  TTSController(this.ref) : super(TTSState());

  Future<void> _stopCurrentAndStart(String context) async {
    // Always stop any currently playing audio first
    final tts = ref.read(ttsServiceProvider);
    await tts.stop();
    state = TTSState(isPlaying: true, currentContext: context);
    tts.resetStopFlag();
  }

  Future<void> readSummary(String summaryText, {String context = 'summary'}) async {
    await _stopCurrentAndStart(context);
    final tts = ref.read(ttsServiceProvider);
    final settings = ref.read(appSettingsProvider);
    
    try {
      await tts.speak(summaryText, voice: settings.voice, speed: settings.speechRate);
    } finally {
      if (state.currentContext == context) {
        state = TTSState(isPlaying: false);
      }
    }
  }

  Future<void> readSingleNotification(NotificationModel notification) async {
    await _stopCurrentAndStart('notification_${notification.id}');
    final tts = ref.read(ttsServiceProvider);
    
    try {
      await _speakNotification(notification);
    } finally {
      if (state.currentContext == 'notification_${notification.id}') {
        state = TTSState(isPlaying: false);
      }
    }
  }

  Future<void> readLatest(int appId) async {
    await _stopCurrentAndStart('latest_$appId');
    final tts = ref.read(ttsServiceProvider);
    
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final notifications = await repo.getNotificationsByApp(appId);
      
      if (notifications.isNotEmpty) {
        final latest = notifications.first;
        await _speakNotification(latest);
      }
    } finally {
      if (state.currentContext == 'latest_$appId') {
        state = TTSState(isPlaying: false);
      }
    }
  }

  Future<void> readAllFromApp(int appId) async {
    await _stopCurrentAndStart('all_$appId');
    final tts = ref.read(ttsServiceProvider);
    
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final notifications = await repo.getNotificationsByApp(appId);
      
      for (var notification in notifications) {
        if (tts.isStopped || state.currentContext != 'all_$appId') break;
        await _speakNotification(notification);
      }
    } finally {
      if (state.currentContext == 'all_$appId') {
        state = TTSState(isPlaying: false);
      }
    }
  }

  Future<void> readImportant(int appId) async {
    await _stopCurrentAndStart('important_$appId');
    final tts = ref.read(ttsServiceProvider);
    
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final notifications = await repo.getNotificationsByApp(appId);
      final important = notifications.where((n) => n.priority == 'high').toList();
      
      for (var notification in important) {
        if (tts.isStopped || state.currentContext != 'important_$appId') break;
        await _speakNotification(notification);
      }
    } finally {
      if (state.currentContext == 'important_$appId') {
        state = TTSState(isPlaying: false);
      }
    }
  }

  Future<void> readAll() async {
    await _stopCurrentAndStart('all_global');
    final tts = ref.read(ttsServiceProvider);
    
    try {
      final repo = ref.read(notificationRepositoryProvider);
      final apps = await repo.getAllApps();
      
      for (var app in apps) {
        if (tts.isStopped || state.currentContext != 'all_global') break;
        final notifications = await repo.getNotificationsByApp(app.id!);
        for (var notification in notifications) {
          if (tts.isStopped || state.currentContext != 'all_global') break;
          await _speakNotification(notification);
        }
      }
    } finally {
      if (state.currentContext == 'all_global') {
        state = TTSState(isPlaying: false);
      }
    }
  }

  Future<void> _speakNotification(NotificationModel notification) async {
    final tts = ref.read(ttsServiceProvider);
    final settings = ref.read(appSettingsProvider);
    final text = '${notification.title}. ${notification.message}';
    await tts.speak(text, voice: settings.voice, speed: settings.speechRate);
  }

  Future<void> stop() async {
    final tts = ref.read(ttsServiceProvider);
    await tts.stop();
    state = TTSState(isPlaying: false);
  }
}
