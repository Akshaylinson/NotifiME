import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/constants/tts_config.dart';

class SupertonicTTSService {
  static const String _baseUrl = 'https://voices.codelessai.in';
  static const int _maxChunkLength = 500;
  
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 30),
  ));
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isStopped = false;
  
  bool get isStopped => _isStopped;
  
  SupertonicTTSService() {
    _initializeLocalTTS();
  }
  
  void _initializeLocalTTS() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setVolume(1.0);
  }
  
  Future<void> speak(String text, {String? voice, double speed = 1.0}) async {
    try {
      _isStopped = false;
      await _speakWithCloudTTS(text, voice: voice, speed: speed);
    } catch (e) {
      print('Cloud TTS failed: $e, falling back to local TTS');
      await _speakWithLocalTTS(text, speed: speed);
    }
  }
  
  Future<void> _speakWithCloudTTS(String text, {String? voice, double speed = 1.0}) async {
    final chunks = _splitTextIntoChunks(text, _maxChunkLength);
    
    for (var chunk in chunks) {
      if (_isStopped) break;
      
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
            'text': chunk,
            'voice': voice ?? TTSConfig.defaultVoice,
            'lang': 'en',
            'speed': speed,
            'total_step': TTSConfig.defaultQuality,
          },
        );

        if (response.statusCode == 200 && response.data != null) {
          final audioBytes = Uint8List.fromList(response.data);
          await _audioPlayer.play(BytesSource(audioBytes));
          await _audioPlayer.onPlayerComplete.first;
        } else {
          throw Exception('Invalid response: status ${response.statusCode}');
        }
      } on DioException catch (e) {
        if (e.response?.statusCode == 401) {
          throw Exception('Invalid API key');
        } else if (e.response?.statusCode == 429) {
          throw Exception('Daily limit exceeded');
        } else if (e.response?.statusCode == 403) {
          throw Exception('Voice not allowed for this project');
        } else if (e.response?.statusCode == 503) {
          throw Exception('TTS service temporarily unavailable');
        } else {
          throw Exception('TTS API error: ${e.message}');
        }
      }
    }
  }
  
  Future<void> _speakWithLocalTTS(String text, {double speed = 1.0}) async {
    // Convert speed: user 0.5-2.0 -> flutter_tts 0.25-1.0
    double ttsSpeed = (speed * 0.5).clamp(0.25, 1.0);
    await _flutterTts.setSpeechRate(ttsSpeed);
    await _flutterTts.speak(text);
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
    await _flutterTts.stop();
  }
  
  void resetStopFlag() {
    _isStopped = false;
  }

  void dispose() {
    _audioPlayer.dispose();
    _flutterTts.stop();
  }
}
