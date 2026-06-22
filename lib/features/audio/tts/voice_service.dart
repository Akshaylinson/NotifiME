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
    String id = json['id'] ?? json['voice_id'] ?? json['voice'] ?? '';
    String name = json['name'] ?? json['voice_name'] ?? id;
    
    String gender = 'Unknown';
    if (id.startsWith('M')) {
      gender = 'Male';
    } else if (id.startsWith('F')) {
      gender = 'Female';
    }
    
    return VoiceModel(
      id: id,
      name: name,
      gender: gender,
      language: json['language'] ?? json['lang'] ?? 'en',
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
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map && response.data['voices'] != null) {
          final voicesList = response.data['voices'] as List;
          return voicesList
              .map((voice) => VoiceModel.fromJson(voice as Map<String, dynamic>))
              .toList();
        } else if (response.data is List) {
          return (response.data as List)
              .map((voice) => VoiceModel.fromJson(voice as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      print('Error fetching voices from API: $e');
    }

    return _getDefaultVoices();
  }

  List<VoiceModel> _getDefaultVoices() {
    final voices = <VoiceModel>[];
    
    for (var voice in TTSConfig.maleVoices) {
      voices.add(VoiceModel(
        id: voice,
        name: 'Male Voice $voice',
        gender: 'Male',
        language: 'en',
      ));
    }
    
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
