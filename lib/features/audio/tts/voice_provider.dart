import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'voice_service.dart';
import '../../../core/constants/tts_config.dart';

final voiceServiceProvider = Provider((ref) => VoiceService());

final availableVoicesProvider = FutureProvider<List<VoiceModel>>((ref) async {
  final service = ref.read(voiceServiceProvider);
  return await service.fetchAvailableVoices();
});

final selectedVoiceProvider = StateNotifierProvider<SelectedVoiceNotifier, String>((ref) {
  return SelectedVoiceNotifier();
});

class SelectedVoiceNotifier extends StateNotifier<String> {
  SelectedVoiceNotifier() : super(TTSConfig.defaultVoice) {
    _loadSelectedVoice();
  }

  Future<void> _loadSelectedVoice() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('selected_voice') ?? TTSConfig.defaultVoice;
  }

  Future<void> setVoice(String voiceId) async {
    state = voiceId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_voice', voiceId);
  }
}
