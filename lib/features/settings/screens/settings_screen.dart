import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../audio/tts/voice_provider.dart';
import '../../audio/tts/voice_service.dart';
import '../../notifications/repository/notification_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedVoice = ref.watch(selectedVoiceProvider);
    final settings = ref.watch(appSettingsProvider);

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
            subtitle: const Text('Automatically read new notifications'),
            value: settings.autoReadNotifications,
            onChanged: (val) {
              ref.read(appSettingsProvider.notifier).setAutoRead(val);
            },
          ),
          ListTile(
            title: const Text('Speech Speed'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${settings.speechSpeed.toStringAsFixed(2)}x'),
                Slider(
                  value: settings.speechSpeed,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  label: '${settings.speechSpeed.toStringAsFixed(2)}x',
                  onChanged: (val) {
                    ref.read(appSettingsProvider.notifier).setSpeechSpeed(val);
                  },
                ),
              ],
            ),
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
            onTap: () => _showClearConfirmationDialog(context, ref),
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

  void _showClearConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
        title: const Text('Clear All Notifications'),
        content: const Text(
          'This will permanently delete all notifications from the database. This action cannot be undone.\n\nAre you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllNotifications(context, ref);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllNotifications(BuildContext context, WidgetRef ref) async {
    try {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Clearing notifications...'),
                ],
              ),
            ),
          ),
        ),
      );

      final repository = ref.read(notificationRepositoryProvider);
      final apps = await repository.getAllApps();
      
      for (var app in apps) {
        await repository.deleteNotificationsByApp(app.id!);
      }

      // Refresh UI
      ref.read(appListProvider.notifier).refresh();

      // Close loading
      if (context.mounted) Navigator.pop(context);

      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All notifications cleared successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close loading
      if (context.mounted) Navigator.pop(context);
      
      // Show error message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
