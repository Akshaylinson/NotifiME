import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../notifications/repository/notification_provider.dart';
import '../../notifications/repository/notification_repository.dart';
import '../../notifications/screens/app_detail_screen_modern.dart';
import '../../settings/screens/settings_screen.dart';
import '../../ai/summarizer/notification_summarizer.dart';
import '../../ai/gemma/gemma_service.dart';
import '../../audio/tts/tts_provider.dart';
import '../../notifications/widgets/app_icon_widget.dart';

class DashboardScreenModern extends ConsumerStatefulWidget {
  const DashboardScreenModern({super.key});

  @override
  ConsumerState<DashboardScreenModern> createState() => _DashboardScreenModernState();
}

class _DashboardScreenModernState extends ConsumerState<DashboardScreenModern> {
  bool _isGeneratingSummary = false;

  Future<void> _generateGlobalSummary(BuildContext context) async {
    setState(() {
      _isGeneratingSummary = true;
    });

    try {
      final repository = NotificationRepository();
      final apps = await repository.getAllApps();
      
      if (apps.isEmpty) {
        if (context.mounted) {
          _showSnackBar(context, 'No notifications to summarize');
        }
        return;
      }

      final notificationsByApp = <String, List<dynamic>>{};
      
      for (var app in apps) {
        final notifications = await repository.getNotificationsByApp(app.id!);
        if (notifications.isNotEmpty) {
          notificationsByApp[app.appName] = notifications;
        }
      }

      if (notificationsByApp.isEmpty) {
        if (context.mounted) {
          _showSnackBar(context, 'No notifications to summarize');
        }
        return;
      }

      final gemmaService = GemmaServiceImpl();
      await gemmaService.initialize();
      
      final summarizer = NotificationSummarizer(gemmaService);
      final summary = await summarizer.summarizeGlobalByAppPlain(
        notificationsByApp.map((key, value) => MapEntry(key, value.cast())),
      );

      if (context.mounted) {
        _showSnackBar(context, 'Playing global summary...');
        
        await ref.read(ttsControllerProvider.notifier).readSummary(
          summary,
          context: 'global_summary',
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showSnackBar(context, 'Error: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingSummary = false;
        });
      }
    }
  }

  void _showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        margin: const EdgeInsets.all(AppSpacing.lg),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appsAsyncValue = ref.watch(appListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: appsAsyncValue.when(
                data: (apps) => apps.isEmpty
                    ? _buildEmptyState()
                    : _buildAppList(apps),
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                error: (err, stack) => _buildErrorState(err.toString()),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: appsAsyncValue.when(
        data: (apps) => apps.isEmpty ? null : _buildFloatingButton(),
        loading: () => null,
        error: (_, __) => null,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildHeader(BuildContext context) {
    final appsAsyncValue = ref.watch(appListProvider);
    
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.lg,
        AppSpacing.screenPadding,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notiva AI',
                      style: AppTypography.displayMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your intelligent notification assistant',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildHeaderButton(
                    icon: Icons.refresh_rounded,
                    onTap: () {
                      ref.read(appListProvider.notifier).refresh();
                    },
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _buildHeaderButton(
                    icon: Icons.settings_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          appsAsyncValue.when(
            data: (apps) {
              final totalNotifications = apps.fold<int>(
                0,
                (sum, app) => sum + app.notificationCount,
              );
              return _buildSummaryCard(apps.length, totalNotifications);
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(int appCount, int notificationCount) {
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
              Icons.notifications_active_rounded,
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
                  '$notificationCount Notifications',
                  style: AppTypography.headingMedium.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Across $appCount ${appCount == 1 ? 'app' : 'apps'}',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildAppList(List apps) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.read(appListProvider.notifier).refresh();
      },
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.sm,
          AppSpacing.screenPadding,
          100,
        ),
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];
          return _buildAppCard(app);
        },
      ),
    );
  }

  Widget _buildAppCard(app) {
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AppDetailScreenModern(app: app),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              children: [
                AppIconWidget(
                  iconPath: app.iconPath,
                  appName: app.appName,
                  size: 48,
                  borderRadius: AppSpacing.radiusMd,
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app.appName,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
                            ),
                            child: Text(
                              '${app.notificationCount} ${app.notificationCount == 1 ? 'notification' : 'notifications'}',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxxl),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 64,
                color: AppColors.primary.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(
              'No notifications yet',
              style: AppTypography.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your notifications will appear here\nwhen they arrive',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Something went wrong',
              style: AppTypography.headingMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              error,
              style: AppTypography.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isGeneratingSummary ? null : () => _generateGlobalSummary(context),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: Center(
            child: _isGeneratingSummary
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(
                        'Global Summary',
                        style: AppTypography.button,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
