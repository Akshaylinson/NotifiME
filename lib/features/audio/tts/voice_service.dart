import 'package:dio/dio.dart';
import '../../../core/constants/tts_config.dart';

class VoiceModel {
  final String id;
  final String name;
  final String gender;
  final String language;

  VoiceModel({
    required this.id,
    required this.name,
    required this.gender,
    required this.language,
  });

  factory VoiceModel.fromJson(Map<String, dynamic> json) {
    return VoiceModel(
      id: json['id'] ?? json['voice_id'] ?? '',
      name: json['name'] ?? json['voice_name'] ?? '',
      gender: json['gender'] ?? '',
      language: json['language'] ?? 'en',
    );
  }
}

class VoiceService {
  static const String _baseUrl = 'https://voices.codelessai.in';
  final Dio _dio = Dio();

  Future<List<VoiceModel>> fetchAvailableVoices() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/supertonic/v1/voices',
        options: Options(
          headers: {
            'X-API-Key': TTSConfig.apiKey,
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is List) {
          return (response.data as List)
              .map((voice) => VoiceModel.fromJson(voice))
              .toList();
        } else if (response.data is Map && response.data['voices'] != null) {
          return (response.data['voices'] as List)
              .map((voice) => VoiceModel.fromJson(voice))
              .toList();
        }
      }
    } catch (e) {
      // If API fails, return hardcoded voices
      return _getDefaultVoices();
    }

    return _getDefaultVoices();
  }

  List<VoiceModel> _getDefaultVoices() {
    final voices = <VoiceModel>[];
    
    // Male voices
    for (var voice in TTSConfig.maleVoices) {
      voices.add(VoiceModel(
        id: voice,
        name: 'Male Voice $voice',
        gender: 'Male',
        language: 'en',
      ));
    }
    
    // Female voices
    for (var voice in TTSConfig.femaleVoices) {
      voices.add(VoiceModel(
        id: voice,
        name: 'Female Voice $voice',
        gender: 'Female',
        language: 'en',
      ));
    }
    
    return voices;
  }
}
