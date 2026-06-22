import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../audio/tts/voice_provider.dart';
import '../../audio/tts/voice_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedVoice = ref.watch(selectedVoiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Voice Selection'),
            subtitle: Text(selectedVoice),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () => _showVoiceSelectionDialog(context, ref),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('Audio Settings', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: const Text('Auto-read Notifications'),
            value: false,
            onChanged: (val) {},
          ),
          ListTile(
            title: const Text('Speech Speed'),
            subtitle: Slider(value: 0.5, onChanged: (val) {}),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('Storage', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('Retention Period'),
            subtitle: const Text('7 Days'),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Clear All Notifications'),
            trailing: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () {},
          ),
        ],
      ),
    );
  }

  void _showVoiceSelectionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const VoiceSelectionDialog(),
    );
  }
}

class VoiceSelectionDialog extends ConsumerWidget {
  const VoiceSelectionDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voicesAsync = ref.watch(availableVoicesProvider);
    final selectedVoice = ref.watch(selectedVoiceProvider);

    return Dialog(
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.record_voice_over, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Select Voice',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: voicesAsync.when(
                data: (voices) {
                  if (voices.isEmpty) {
                    return const Center(child: Text('No voices available'));
                  }

                  // Group voices by gender
                  final maleVoices = voices.where((v) => v.gender == 'Male').toList();
                  final femaleVoices = voices.where((v) => v.gender == 'Female').toList();

                  return ListView(
                    children: [
                      if (maleVoices.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            'Male Voices',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        ...maleVoices.map((voice) => _buildVoiceOption(
                          context,
                          ref,
                          voice,
                          selectedVoice,
                        )),
                      ],
                      if (femaleVoices.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            'Female Voices',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        ...femaleVoices.map((voice) => _buildVoiceOption(
                          context,
                          ref,
                          voice,
                          selectedVoice,
                        )),
                      ],
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load voices',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Using default voices',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceOption(
    BuildContext context,
    WidgetRef ref,
    VoiceModel voice,
    String selectedVoice,
  ) {
    final isSelected = voice.id == selectedVoice;
    final displayText = '${voice.id} (${voice.gender.toLowerCase()})';

    return RadioListTile<String>(
      value: voice.id,
      groupValue: selectedVoice,
      title: Text(
        displayText,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      activeColor: Theme.of(context).colorScheme.primary,
      onChanged: (value) {
        if (value != null) {
          ref.read(selectedVoiceProvider.notifier).setVoice(value);
          Navigator.pop(context);
        }
      },
    );
  }
}
