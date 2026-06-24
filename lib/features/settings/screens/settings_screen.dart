import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../notifications/repository/notification_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../audio/tts/voice_provider.dart';
import '../../audio/tts/voice_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedVoice = ref.watch(selectedVoiceProvider);
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ).createShader(bounds),
          child: const Text(
            'Settings',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          children: [
            _heroCard(context, settings, selectedVoice),
            const SizedBox(height: 24),
            _sectionHeader(context, 'Voice'),
            const SizedBox(height: 12),
            _tile(
              context,
              title: 'Voice selection',
              subtitle: selectedVoice,
              icon: Icons.record_voice_over_rounded,
              onTap: () => _showVoiceSelectionDialog(context, ref),
            ),
            const SizedBox(height: 24),
            _sectionHeader(context, 'Audio'),
            const SizedBox(height: 12),
            _switchTile(
              context,
              title: 'Auto-read notifications',
              subtitle: 'Automatically speak new notifications when they arrive',
              icon: Icons.volume_up_rounded,
              value: settings.autoRead,
              onChanged: (val) => ref.read(appSettingsProvider.notifier).setAutoRead(val),
            ),
            const SizedBox(height: 12),
            _sliderTile(
              context,
              title: 'Speech speed',
              subtitle: 'Adjust how fast summaries are spoken',
              icon: Icons.speed_rounded,
              value: settings.speechRate,
              valueLabel: '${settings.speechRate.toStringAsFixed(2)}x',
              min: 0.5,
              max: 2.0,
              divisions: 15,
              onChanged: (val) => ref.read(appSettingsProvider.notifier).setSpeechRate(val),
            ),
            const SizedBox(height: 12),
            _sliderTile(
              context,
              title: 'Voice pitch',
              subtitle: 'Tune the tone of spoken notifications',
              icon: Icons.graphic_eq_rounded,
              value: settings.pitch,
              valueLabel: settings.pitch.toStringAsFixed(2),
              min: 0.5,
              max: 2.0,
              divisions: 15,
              onChanged: (val) => ref.read(appSettingsProvider.notifier).setPitch(val),
            ),
            const SizedBox(height: 24),
            _sectionHeader(context, 'Storage'),
            const SizedBox(height: 12),
            _tile(
              context,
              title: 'Retention period',
              subtitle: '${settings.retentionDays} days',
              icon: Icons.calendar_month_rounded,
              onTap: () => _showRetentionDialog(context, ref, settings.retentionDays),
            ),
            const SizedBox(height: 12),
            _tile(
              context,
              title: 'Run cleanup now',
              subtitle: 'Delete notifications older than the selected retention period',
              icon: Icons.cleaning_services_rounded,
              onTap: () => _runManualCleanup(context, ref),
            ),
            const SizedBox(height: 12),
            _tile(
              context,
              title: 'Clear all notifications',
              subtitle: 'Remove every stored notification from the database',
              icon: Icons.delete_forever_rounded,
              iconColor: Theme.of(context).colorScheme.error,
              titleColor: Theme.of(context).colorScheme.error,
              trailing: Icon(Icons.chevron_right_rounded, color: Theme.of(context).colorScheme.error),
              onTap: () => _showClearConfirmationDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroCard(BuildContext context, AppSettings settings, String selectedVoice) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.tune_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personalize your assistant',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Voice, speech, and storage options for Notiva AI',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _chip('Voice: $selectedVoice'),
                        _chip('Auto-read: ${settings.autoRead ? 'On' : 'Off'}'),
                        _chip('Retention: ${settings.retentionDays}d'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
    Color? iconColor,
    Color? titleColor,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: (iconColor ?? primaryColor).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor ?? primaryColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: titleColor ?? Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                trailing ?? Icon(
                  Icons.chevron_right_rounded,
                  color: Theme.of(context).colorScheme.outline,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _switchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: primaryColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Switch.adaptive(
                  value: value,
                  activeColor: primaryColor,
                  onChanged: onChanged,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sliderTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required double value,
    required String valueLabel,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: primaryColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.secondaryContainer,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      valueLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: primaryColor,
                  inactiveTrackColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  thumbColor: primaryColor,
                  overlayColor: primaryColor.withOpacity(0.12),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVoiceSelectionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => const VoiceSelectionDialog(),
    );
  }

  void _showRetentionDialog(BuildContext context, WidgetRef ref, int currentDays) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Retention period'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications older than the chosen period will be automatically deleted.',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              value: currentDays,
              decoration: const InputDecoration(border: OutlineInputBorder(), isDense: true),
              items: const [
                DropdownMenuItem(value: 7, child: Text('7 days')),
                DropdownMenuItem(value: 14, child: Text('14 days')),
                DropdownMenuItem(value: 30, child: Text('30 days')),
                DropdownMenuItem(value: 60, child: Text('60 days')),
                DropdownMenuItem(value: 90, child: Text('90 days')),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(appSettingsProvider.notifier).setRetentionDays(value);
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Future<void> _runManualCleanup(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(Icons.cleaning_services_rounded, color: Theme.of(context).colorScheme.primary, size: 48),
        title: const Text('Run cleanup now'),
        content: Text(
          'This will delete all notifications older than ${ref.read(appSettingsProvider).retentionDays} days.\n\nDo you want to continue?',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
            child: const Text('Run Cleanup'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              const Text('Running cleanup...'),
            ],
          ),
        ),
      ),
    );

    try {
      final settings = ref.read(appSettingsProvider);
      final repository = ref.read(notificationRepositoryProvider);
      await repository.deleteOldNotifications(settings.retentionDays);
      ref.read(appListProvider.notifier).refresh();

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Cleanup completed successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cleanup failed: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _showClearConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Icon(Icons.warning_amber_rounded, color: Theme.of(context).colorScheme.error, size: 48),
        title: const Text('Clear all notifications'),
        content: Text(
          'This will permanently delete all notifications from the database. This action cannot be undone.\n\nAre you sure you want to continue?',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllNotifications(context, ref);
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  Future<void> _clearAllNotifications(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 16),
              const Text('Clearing notifications...'),
            ],
          ),
        ),
      ),
    );

    try {
      final repository = ref.read(notificationRepositoryProvider);
      final apps = await repository.getAllApps();
      for (var app in apps) {
        await repository.deleteNotificationsByApp(app.id!);
      }
      ref.read(appListProvider.notifier).refresh();

      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('All notifications cleared successfully'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing notifications: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
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
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8, maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary,
                          Theme.of(context).colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.record_voice_over_rounded, size: 22, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select voice', style: Theme.of(context).textTheme.titleLarge),
                        Text(
                          'Choose the voice used for spoken summaries',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                ],
              ),
            ),
            Divider(height: 1, color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
            Expanded(
              child: voicesAsync.when(
                data: (voices) {
                  if (voices.isEmpty) {
                    return const Center(child: Text('No voices available'));
                  }

                  final maleVoices = voices.where((v) => v.gender == 'Male').toList();
                  final femaleVoices = voices.where((v) => v.gender == 'Female').toList();
                  final otherVoices = voices.where((v) => v.gender != 'Male' && v.gender != 'Female').toList();

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (maleVoices.isNotEmpty) ...[
                        const _VoiceGroupHeader('Male voices'),
                        const SizedBox(height: 8),
                        ...maleVoices.map((voice) => _VoiceTile(voice: voice, selectedVoice: selectedVoice)),
                        const SizedBox(height: 20),
                      ],
                      if (femaleVoices.isNotEmpty) ...[
                        const _VoiceGroupHeader('Female voices'),
                        const SizedBox(height: 8),
                        ...femaleVoices.map((voice) => _VoiceTile(voice: voice, selectedVoice: selectedVoice)),
                        const SizedBox(height: 20),
                      ],
                      if (otherVoices.isNotEmpty) ...[
                        const _VoiceGroupHeader('Other voices'),
                        const SizedBox(height: 8),
                        ...otherVoices.map((voice) => _VoiceTile(voice: voice, selectedVoice: selectedVoice)),
                      ],
                    ],
                  );
                },
                loading: () => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded, size: 48, color: Theme.of(context).colorScheme.error),
                        const SizedBox(height: 16),
                        Text('Failed to load voices', style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(
                          'Using default voices',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
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
}

class _VoiceTile extends ConsumerWidget {
  final VoiceModel voice;
  final String selectedVoice;

  const _VoiceTile({required this.voice, required this.selectedVoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = voice.id == selectedVoice;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: isSelected ? primaryColor : Theme.of(context).colorScheme.outline.withOpacity(0.1),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: InkWell(
          onTap: () async {
            await ref.read(appSettingsProvider.notifier).setVoice(voice.id);
            if (context.mounted) Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor.withOpacity(0.12) : Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                    color: isSelected ? primaryColor : Theme.of(context).colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voice.name.isNotEmpty ? voice.name : voice.id,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${voice.id}  ${voice.gender}  ${voice.language}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.secondaryContainer,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Selected',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VoiceGroupHeader extends StatelessWidget {
  final String label;

  const _VoiceGroupHeader(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}