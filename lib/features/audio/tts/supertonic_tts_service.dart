import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/constants/tts_config.dart';

class SupertonicTTSService {
  static const String _baseUrl = 'https://voices.codelessai.in';
  static const int _maxChunkLength = 500; // Max characters per API call
  
  final Dio _dio = Dio();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isStopped = false;
  
  Future<void> speak(String text, {String voice = TTSConfig.defaultVoice, double speed = TTSConfig.defaultSpeed}) async {
    try {
      // Split long text into chunks
      final chunks = _splitTextIntoChunks(text, _maxChunkLength);
      
      for (var chunk in chunks) {
        if (_isStopped) break;
        
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
            'text': chunk,
            'voice': voice,
            'lang': 'en',
            'speed': speed,
            'total_step': TTSConfig.defaultQuality,
          },
        );

        final audioBytes = Uint8List.fromList(response.data);
        await _audioPlayer.play(BytesSource(audioBytes));
        
        // Wait for audio to complete before next chunk
        await _audioPlayer.onPlayerComplete.first;
      }
    } catch (e) {
      throw Exception('TTS Error: $e');
    }
  }

  List<String> _splitTextIntoChunks(String text, int maxLength) {
    if (text.length <= maxLength) return [text];
    
    final chunks = <String>[];
    var currentChunk = '';
    final sentences = text.split(RegExp(r'[.!?]\s*'));
    
    for (var sentence in sentences) {
      if (sentence.isEmpty) continue;
      
      if ((currentChunk + sentence).length <= maxLength) {
        currentChunk += '$sentence. ';
      } else {
        if (currentChunk.isNotEmpty) chunks.add(currentChunk.trim());
        currentChunk = '$sentence. ';
      }
    }
    
    if (currentChunk.isNotEmpty) chunks.add(currentChunk.trim());
    return chunks;
  }

  Future<void> stop() async {
    _isStopped = true;
    await _audioPlayer.stop();
  }
  
  void resetStopFlag() {
    _isStopped = false;
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
