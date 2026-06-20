import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModelManagerService {
  static const String _modelKey = 'gemma_model_downloaded';
  static const String _modelUrl = 'https://storage.googleapis.com/example-gemma-models/gemma-2b-it-gpu-int4.bin'; // Replace with actual URL

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/gemma.bin');
  }

  Future<bool> isModelDownloaded() async {
    final file = await _localFile;
    return await file.exists();
  }

  Future<void> downloadModel(Function(double) onProgress) async {
    final file = await _localFile;
    final dio = Dio();

    try {
      await dio.download(
        _modelUrl,
        file.path,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            onProgress(received / total);
          }
        },
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_modelKey, true);
    } catch (e) {
      print("Download Error: $e");
      rethrow;
    }
  }

  Future<String> getModelPath() async {
    final file = await _localFile;
    return file.path;
  }
}
