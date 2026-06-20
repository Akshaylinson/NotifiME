import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/constants/tts_config.dart';

class SupertonicTTSService {
  static const String _baseUrl = 'https://voices.codelessai.in';
  
  final Dio _dio = Dio();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  Future<void> speak(String text, {String voice = TTSConfig.defaultVoice, double speed = TTSConfig.defaultSpeed}) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/supertonic/v1/tts',
        options: Options(
          headers: {
            'X-API-Key': TTSConfig.apiKey,
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.bytes,
        ),
        data: {
          'text': text,
          'voice': voice,
          'lang': 'en',
          'speed': speed,
          'total_step': TTSConfig.defaultQuality,
        },
      );

      final audioBytes = Uint8List.fromList(response.data);
      await _audioPlayer.play(BytesSource(audioBytes));
    } catch (e) {
      throw Exception('TTS Error: $e');
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
