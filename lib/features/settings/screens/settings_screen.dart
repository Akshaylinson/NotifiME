import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../notifications/repository/notification_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../audio/tts/voice_provider.dart';
import '../../audio/tts/voice_service.dart';

// Mapping voice model IDs to human-readable names
const Map<String, String> voiceHumanNames = {
  // Female voices
  'F1': 'Emma - Warm & Friendly',
  'F2': 'Sarah - Natural & Clear',
  'F3': 'Rachel - Professional',
  'F4': 'Jenny - Casual',
  'F5': 'Amy - Expressive',
  'F6': 'Ada - Modern',
  'F7': 'Bella - Soft Spoken',
  'F8': 'Grace - Elegant',
  // Male voices  
  'M1': 'James - Deep & Authoritative',
  'M2': 'John - Natural & Clear',
  'M3': 'Michael - Professional',
  'M4': 'David - Conversational',
  'M5': 'Robert - Confident',
  'M6': 'William - Warm',
  'M7': 'Thomas - Mature',
  'M8': 'Charles - Dynamic',
  // Additional voices
  'F9': 'Lily - Cheerful',
  'F10': 'Victoria - Sophisticated',
  'M9': 'Alexander - Bold',
  'M10': 'Benjamin - Friendly',
};

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedVoice = ref.watch(selectedVoiceProvider);
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: Text(
          'Settings',
          style: AppTypography.headingMedium.copyWith(
            color: AppColors.primary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenPadding,
            AppSpacing.md,
            AppSpacing.screenPadding,
            100,
          ),
          children: [
            _heroCard(settings, selectedVoice),
            const SizedBox(height: AppSpacing.sectionGap),
            _sectionHeader('Voice'),
            const SizedBox(height: AppSpacing.sm),
            _tile(
              title: 'Voice selection',
              subtitle: selectedVoice,
              icon: Icons.record_voice_over_rounded,
              onTap: () => _showVoiceSelectionDialog(context, ref),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            _sectionHeader('Audio'),
            const SizedBox(height: AppSpacing.sm),
            _switchTile(
              title: 'Auto-read notifications',
              subtitle: 'Automatically speak new notifications when they arrive',
              icon: Icons.volume_up_rounded,
              value: settings.autoRead,
              onChanged: (val) => ref.read(appSettingsProvider.notifier).setAutoRead(val),
            ),
            const SizedBox(height: AppSpacing.cardGap),
            _sliderTile(
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
            const SizedBox(height: AppSpacing.cardGap),
            _sliderTile(
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
            const SizedBox(height: AppSpacing.sectionGap),
            _sectionHeader('Storage'),
            const SizedBox(height: AppSpacing.sm),
            _tile(
              title: 'Retention period',
              subtitle: '${settings.retentionDays} days',
              icon: Icons.calendar_month_rounded,
              onTap: () => _showRetentionDialog(context, ref, settings.retentionDays),
            ),
            const SizedBox(height: AppSpacing.cardGap),
            _tile(
              title: 'Run cleanup now',
              subtitle: 'Delete notifications older than the selected retention period',
              icon: Icons.cleaning_services_rounded,
              onTap: () => _runManualCleanup(context, ref),
            ),
            const SizedBox(height: AppSpacing.cardGap),
            _tile(
              title: 'Clear all notifications',
              subtitle: 'Remove every stored notification from the database',
              icon: Icons.delete_forever_rounded,
              iconColor: AppColors.error,
              titleColor: AppColors.error,
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.error),
              onTap: () => _showClearConfirmationDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroCard(AppSettings settings, String selectedVoice) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Customize Notiva AI',
                  style: AppTypography.headingMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Configure voice, speech, and storage settings',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.xs),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(
          letterSpacing: 1.2,
          color: AppColors.textTertiary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _tile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Widget? trailing,
    Color? iconColor,
    Color? titleColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: (iconColor ?? AppColors.primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: titleColor ?? AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                trailing ?? const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return _tile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      trailing: Switch.adaptive(
        value: value,
        activeColor: AppColors.primary,
        activeTrackColor: AppColors.primary.withOpacity(0.5),
        onChanged: onChanged,
      ),
      onTap: () => onChanged(!value),
    );
  }

  Widget _sliderTile({
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
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                ),
                child: Text(
                  valueLabel,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: AppColors.divider,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.12),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text('Retention period', style: AppTypography.headingMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications older than the chosen period will be automatically deleted.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<int>(
              value: currentDays,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                isDense: true,
              ),
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _runManualCleanup(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        icon: const Icon(
          Icons.cleaning_services_rounded,
          color: AppColors.primary,
          size: 48,
        ),
        title: Text('Run cleanup now', style: AppTypography.headingMedium),
        content: Text(
          'This will delete all notifications older than ${ref.read(appSettingsProvider).retentionDays} days.\n\nDo you want to continue?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: const Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: AppSpacing.md),
              Text('Running cleanup...'),
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
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            margin: const EdgeInsets.all(AppSpacing.lg),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cleanup failed: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            margin: const EdgeInsets.all(AppSpacing.lg),
          ),
        );
      }
    }
  }

  void _showClearConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        icon: const Icon(
          Icons.warning_amber_rounded,
          color: AppColors.warning,
          size: 48,
        ),
        title: Text('Clear all notifications', style: AppTypography.headingMedium),
        content: Text(
          'This will permanently delete all notifications from the database. This action cannot be undone.\n\nAre you sure you want to continue?',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
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
              backgroundColor: AppColors.error,
            ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: const Padding(
          padding: EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(height: AppSpacing.md),
              Text('Clearing notifications...'),
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
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            margin: const EdgeInsets.all(AppSpacing.lg),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error clearing notifications: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            margin: const EdgeInsets.all(AppSpacing.lg),
          ),
        );
      }
    }
  }
}

class VoiceSelectionDialog extends ConsumerWidget {
  const VoiceSelectionDialog({super.key});

  String _getHumanName(String voiceId) {
    return voiceHumanNames[voiceId] ?? voiceId;
  }

  Widget _buildVoiceGroup(String title, List<VoiceModel> voices, String selectedVoice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _VoiceGroupHeader(title),
        const SizedBox(height: AppSpacing.sm),
        ...voices.map((voice) => _VoiceTile(
          voice: voice, 
          selectedVoice: selectedVoice,
          humanName: _getHumanName(voice.id),
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final voicesAsync = ref.watch(availableVoicesProvider);
    final selectedVoice = ref.watch(selectedVoiceProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Container(
        width: screenWidth * 0.95,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: 700,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: const Icon(
                      Icons.record_voice_over_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select voice', style: AppTypography.headingMedium),
                        Text(
                          'Choose the voice used for spoken summaries',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              color: AppColors.border,
            ),
            Expanded(
              child: voicesAsync.when(
                data: (voices) {
                  if (voices.isEmpty) {
                    return const Center(
                      child: Text('No voices available'),
                    );
                  }

                  final maleVoices = voices.where((v) => v.gender == 'Male').toList();
                  final femaleVoices = voices.where((v) => v.gender == 'Female').toList();
                  final otherVoices = voices
                      .where((v) => v.gender != 'Male' && v.gender != 'Female')
                      .toList();

                  return ListView(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    children: [
                      if (femaleVoices.isNotEmpty) ...[
                        _buildVoiceGroup('Female Voices', femaleVoices, selectedVoice),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      if (maleVoices.isNotEmpty) ...[
                        _buildVoiceGroup('Male Voices', maleVoices, selectedVoice),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      if (otherVoices.isNotEmpty) ...[
                        _buildVoiceGroup('Other Voices', otherVoices, selectedVoice),
                      ],
                    ],
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: AppColors.error,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Failed to load voices',
                          style: AppTypography.headingSmall,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Using default voices',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
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
  final String? humanName;

  const _VoiceTile({
    required this.voice, 
    required this.selectedVoice,
    this.humanName,
  });

  String _getHumanName(String voiceId) {
    return voiceHumanNames[voiceId] ?? voiceId;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = voice.id == selectedVoice;
    final displayName = humanName ?? _getHumanName(voice.id);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await ref.read(appSettingsProvider.notifier).setVoice(voice.id);
            if (context.mounted) Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Icon(
                    Icons.record_voice_over_rounded,
                    color: isSelected ? AppColors.primary : AppColors.textTertiary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        voice.id,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: isSelected ? AppColors.primary : AppColors.textTertiary,
                  size: 24,
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
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}