import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  static const MethodChannel _channel = MethodChannel('com.example.notifime/notifications');

  Future<void> _requestPermission() async {
    try {
      await _channel.invokeMethod('openNotificationSettings');
    } catch (e) {
      debugPrint('Error opening settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Setup Required')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.notifications_active_rounded, size: 64, color: Colors.white),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'Notification access required',
                      style: AppTypography.headingLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Notiva AI needs notification access to capture, organize, and summarize your alerts.',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _requestPermission,
                        icon: const Icon(Icons.settings_rounded),
                        label: const Text('Grant Permission'),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Skip for now',
                        style: AppTypography.labelLarge.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
