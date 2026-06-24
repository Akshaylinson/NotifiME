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
  'F1': 'Emma',
  'F2': 'Sarah',
  'F3': 'Rachel',
  'F4': 'Jenny',
  'F5': 'Amy',
  'F6': 'Ada',
  'F7': 'Bella',
  'F8': 'Grace',
  'M1': 'James',
  'M2': 'John',
  'M3': 'Michael',
  'M4': 'David',
  'M5': 'Robert',
  'M6': 'William',
  'M7': 'Thomas',
  'M8': 'Charles',
  'F9': 'Lily',
  'F10': 'Victoria',
  'M9': 'Alexander',
  'M10': 'Benjamin',
};

String getHumanName(String voiceId) {
  return voiceHumanNames[voiceId] ?? voiceId;
}

String getVoiceLabel(VoiceModel voice) {
  return voiceHumanNames[voice.id] ?? voice.name;
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  String _getVoiceDescription(String voiceId) {
    if (voiceId.startsWith('F')) {
      return 'Female voice - Clear and natural';
    } else if (voiceId.startsWith('M')) {
      return 'Male voice - Deep and resonant';
    }
    return 'Standard voice model';
  }

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
            _heroCard(settings),
            const SizedBox(height: AppSpacing.sectionGap),
            _sectionHeader('Voice'),
            const SizedBox(height: AppSpacing.sm),
            _voiceDropdown(context, ref, selectedVoice),
            const SizedBox(height: AppSpacing.sectionGap),
            _sectionHeader('Audio'),
            const SizedBox(height: AppSpacing.sm),
            _switchTile(
              context,
              title: 'Auto-read notifications',
              subtitle: 'Automatically speak new notifications when they arrive',
              icon: Icons.volume_up_rounded,
              value: settings.autoRead,
              onChanged: (val) => ref.read(appSettingsProvider.notifier).setAutoRead(val),
            ),
            const SizedBox(height: AppSpacing.cardGap),
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
            const SizedBox(height: AppSpacing.cardGap),
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
            const SizedBox(height: AppSpacing.sectionGap),
            _sectionHeader('Storage'),
            const SizedBox(height: AppSpacing.sm),
            _tile(
              context,
              title: 'Retention period',
              subtitle: '${settings.retentionDays} days',
              icon: Icons.calendar_month_rounded,
              onTap: () => _showRetentionDialog(context, ref, settings.retentionDays),
            ),
            const SizedBox(height: AppSpacing.cardGap),
            _tile(
              context,
              title: 'Run cleanup now',
              subtitle: 'Delete notifications older than the selected retention period',
              icon: Icons.cleaning_services_rounded,
              onTap: () => _runManualCleanup(context, ref),
            ),
            const SizedBox(height: AppSpacing.cardGap),
            _tile(
              context,
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

  Widget _heroCard(AppSettings settings) {
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
            child: const Icon(Icons.tune_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Customize Notiva AI', style: AppTypography.headingMedium.copyWith(color: Colors.white)),
                const SizedBox(height: 4),
                Text('Configure voice, speech, and storage settings', style: AppTypography.bodySmall.copyWith(color: Colors.white.withOpacity(0.9))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.xs),
      child: Text(title.toUpperCase(), style: AppTypography.labelSmall.copyWith(letterSpacing: 1.2, color: AppColors.textTertiary, fontWeight: FontWeight.w700)),
    );
  }

  Widget _voiceDropdown(BuildContext context, WidgetRef ref, String currentVoiceId) {
    final voicesAsync = ref.watch(availableVoicesProvider);
    final currentName = getHumanName(currentVoiceId);
    final description = _getVoiceDescription(currentVoiceId);

    return voicesAsync.when(
      data: (voices) {
        return _tile(
          context,
          title: 'Voice selection',
          subtitle: '$currentName - $description',
          icon: Icons.record_voice_over_rounded,
          onTap: () => _showVoiceSelectionDialog(context, ref, voices, currentVoiceId),
        );
      },
      loading: () => _tile(
        context,
        title: 'Voice selection',
        subtitle: 'Loading available voices...',
        icon: Icons.record_voice_over_rounded,
        onTap: () {},
      ),
      error: (_, __) => _tile(
        context,
        title: 'Voice selection',
        subtitle: '$currentName - $description',
        icon: Icons.record_voice_over_rounded,
        onTap: () {},
      ),
    );
  }

  void _showVoiceSelectionDialog(BuildContext context, WidgetRef ref, List<VoiceModel> voices, String currentVoiceId) {
    final sortedVoices = voices.toList()
      ..sort((a, b) => getVoiceLabel(a).compareTo(getVoiceLabel(b)));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(Icons.record_voice_over_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Text('Select Voice', style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary)),
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: sortedVoices.length,
            separatorBuilder: (context, index) => Divider(color: AppColors.divider, height: 1),
            itemBuilder: (context, index) {
              final voice = sortedVoices[index];
              final isSelected = voice.id == currentVoiceId;
              final voiceName = getVoiceLabel(voice);
              final voiceDesc = _getVoiceDescription(voice.id);
              
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ref.read(appSettingsProvider.notifier).setVoice(voice.id);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                voiceName,
                                style: AppTypography.bodyLarge.copyWith(
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                voiceDesc,
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 16),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }


  Widget _tile(BuildContext context, {required String title, required String subtitle, required IconData icon, required VoidCallback onTap, Widget? trailing, Color? iconColor, Color? titleColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
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
                  decoration: BoxDecoration(color: (iconColor ?? AppColors.primary).withOpacity(0.1), borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                  child: Icon(icon, color: iconColor ?? AppColors.primary, size: 20),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600, color: titleColor ?? AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                trailing ?? const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _switchTile(BuildContext context, {required String title, required String subtitle, required IconData icon, required bool value, required ValueChanged<bool> onChanged}) {
    return _tile(
      context,
      title: title,
      subtitle: subtitle,
      icon: icon,
      trailing: Switch.adaptive(value: value, activeColor: AppColors.primary, activeTrackColor: AppColors.primary.withOpacity(0.5), onChanged: onChanged),
      onTap: () => onChanged(!value),
    );
  }

  Widget _sliderTile(BuildContext context, {required String title, required String subtitle, required IconData icon, required double value, required String valueLabel, required double min, required double max, required int divisions, required ValueChanged<double> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                child: Icon(icon, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(AppSpacing.radiusXs)),
                child: Text(valueLabel, style: AppTypography.labelMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SliderTheme(
            data: SliderThemeData(activeTrackColor: AppColors.primary, inactiveTrackColor: AppColors.divider, thumbColor: AppColors.primary, overlayColor: AppColors.primary.withOpacity(0.12), trackHeight: 4),
            child: Slider(value: value, min: min, max: max, divisions: divisions, onChanged: onChanged),
          ),
        ],
      ),
    );
  }

  void _showRetentionDialog(BuildContext context, WidgetRef ref, int currentDays) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Text('Retention Period', style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notifications older than the chosen period will be automatically deleted.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            ...[7, 14, 30, 60, 90].map((days) {
              final isSelected = days == currentDays;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    ref.read(appSettingsProvider.notifier).setRetentionDays(days);
                    Navigator.pop(context);
                  },
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$days days',
                            style: AppTypography.bodyLarge.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 16),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _runManualCleanup(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(Icons.cleaning_services_rounded, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text('Run Cleanup Now', style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will delete all notifications older than ${ref.read(appSettingsProvider).retentionDays} days.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'This action cannot be undone.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
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
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Running cleanup...',
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
              ),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Cleanup completed successfully'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)), margin: const EdgeInsets.all(AppSpacing.lg)));
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cleanup failed: $e'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)), margin: const EdgeInsets.all(AppSpacing.lg)));
      }
    }
  }

  void _showClearConfirmationDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text('Clear All Notifications', style: AppTypography.headingMedium.copyWith(color: AppColors.textPrimary)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will permanently delete all notifications from the database.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.05),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: AppColors.error.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'This action cannot be undone.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.error, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
            ),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _clearAllNotifications(context, ref);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
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
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusLg)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Clearing notifications...',
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
              ),
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('All notifications cleared successfully'), backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)), margin: const EdgeInsets.all(AppSpacing.lg)));
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error clearing notifications: $e'), backgroundColor: AppColors.error, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)), margin: const EdgeInsets.all(AppSpacing.lg)));
      }
    }
  }
}