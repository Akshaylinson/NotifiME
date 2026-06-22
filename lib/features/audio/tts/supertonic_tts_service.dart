import 'package:flutter_tts/flutter_tts.dart';

class SupertonicTTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isStopped = false;
  
  bool get isStopped => _isStopped;
  
  SupertonicTTSService() {
    _initializeTts();
  }
  
  void _initializeTts() {
    _flutterTts.setLanguage('en-US');
    _flutterTts.setPitch(1.0);
  }
  
  Future<void> speak(String text, {String? voice, double speed = 1.0}) async {
    try {
      _isStopped = false;
      await _flutterTts.setSpeechRate(speed);
      await _flutterTts.speak(text);
    } catch (e) {
      throw Exception('TTS Error: $e');
    }
  }

  Future<void> stop() async {
    _isStopped = true;
    await _flutterTts.stop();
  }
  
  void resetStopFlag() {
    _isStopped = false;
  }

  void dispose() {
    _flutterTts.stop();
  }
}
