import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/settings/providers/settings_provider.dart';
import 'voice_service.dart';
import '../../../core/constants/tts_config.dart';

final voiceServiceProvider = Provider((ref) => VoiceService());

final availableVoicesProvider = FutureProvider<List<VoiceModel>>((ref) async {
  final service = ref.read(voiceServiceProvider);
  return await service.fetchAvailableVoices();
});

// Use settings provider as the source of truth for selected voice
final selectedVoiceProvider = Provider<String>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return settings.voice;
});
