import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(Icons.auto_awesome_rounded, size: 18, color: Colors.white),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(widget.title, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
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
                          child: const Icon(Icons.summarize_rounded, color: AppColors.primary, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            'AI-generated summary',
                            style: AppTypography.headingSmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      widget.summaryText,
                      style: AppTypography.bodyMedium.copyWith(height: 1.65),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Icon(Icons.access_time_rounded, size: 14, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          'Generated at ${_formatTime(DateTime.now())}',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () => _ttsService.speak(widget.summaryText),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play Audio'),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                        label: const Text('Close'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
