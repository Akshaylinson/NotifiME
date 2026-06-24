import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
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
    if (!mounted) return;
    setState(() => _isDownloaded = status);
  }

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _progress = 0;
    });

    try {
      await _modelManager.downloadModel((p) {
        if (mounted) {
          setState(() => _progress = p);
        }
      });
      if (!mounted) return;
      setState(() {
        _isDownloaded = true;
        _isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gemma model downloaded successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isDownloading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Model Management')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Gemma AI model', style: AppTypography.headingMedium.copyWith(color: Colors.white)),
                        const SizedBox(height: 4),
                        Text(
                          'Offline summarization for notifications. Requires about 1.2 GB of storage.',
                          style: AppTypography.bodySmall.copyWith(color: Colors.white.withOpacity(0.9)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
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
                          color: _isDownloaded ? AppColors.success.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Icon(
                          _isDownloaded ? Icons.check_circle_rounded : Icons.download_rounded,
                          color: _isDownloaded ? AppColors.success : AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Model status', style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(
                              _isDownloaded ? 'Ready for offline use' : 'Not downloaded yet',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_isDownloading) ...[
                    const SizedBox(height: AppSpacing.lg),
                    LinearProgressIndicator(
                      value: _progress,
                      minHeight: 6,
                      backgroundColor: AppColors.divider,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text('${(_progress * 100).toStringAsFixed(1)}%', style: AppTypography.labelMedium),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  if (_isDownloaded) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: AppColors.success.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.success),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'The model is available offline and ready for summarization.',
                              style: AppTypography.bodySmall.copyWith(color: AppColors.success),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // Placeholder until delete flow is wired up.
                        },
                        icon: const Icon(Icons.delete_outline_rounded),
                        label: const Text('Delete Model'),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isDownloading ? null : _startDownload,
                        icon: _isDownloading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.download_rounded),
                        label: Text(_isDownloading ? 'Downloading...' : 'Download Gemma model'),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
