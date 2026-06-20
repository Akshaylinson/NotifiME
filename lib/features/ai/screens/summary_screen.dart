import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../audio/tts/tts_service.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  final String summaryText;
  final String title;

  const SummaryScreen({super.key, required this.summaryText, required this.title});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  late TTSService _ttsService;

  @override
  void initState() {
    super.initState();
    _ttsService = TTSService();
    _ttsService.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      widget.summaryText,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Generated at: ${DateTime.now().hour}:${DateTime.now().minute}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _ttsService.speak(widget.summaryText),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Play Audio'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    // Logic to regenerate
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Regenerate'),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
