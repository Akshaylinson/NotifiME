import 'package:flutter/material.dart';
import '../gemma/model_manager_service.dart';

class ModelManagementScreen extends StatefulWidget {
  const ModelManagementScreen({super.key});

  @override
  State<ModelManagementScreen> createState() => _ModelManagementScreenState();
}

class _ModelManagementScreenState extends State<ModelManagementScreen> {
  final ModelManagerService _modelManager = ModelManagerService();
  bool _isDownloading = false;
  double _progress = 0;
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    final status = await _modelManager.isModelDownloaded();
    setState(() => _isDownloaded = status);
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _progress = 0;
    });

    try {
      await _modelManager.downloadModel((p) {
        setState(() => _progress = p);
      });
      setState(() {
        _isDownloaded = true;
        _isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gemma Model downloaded successfully!')),
      );
    } catch (e) {
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Model Management')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.psychology, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 24),
            Text(
              'Gemma AI Model',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'This model enables 100% offline notification summarization. It requires approximately 1.2 GB of space.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            if (_isDownloading) ...[
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 16),
              Text('${(_progress * 100).toStringAsFixed(1)}%'),
            ] else if (_isDownloaded) ...[
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Model is ready offline'),
                ],
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () { /* Logic to delete model */ },
                child: const Text('Delete Model'),
              ),
            ] else ...[
              ElevatedButton.icon(
                onPressed: _startDownload,
                icon: const Icon(Icons.download),
                label: const Text('Download Gemma Model (1.2 GB)'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
