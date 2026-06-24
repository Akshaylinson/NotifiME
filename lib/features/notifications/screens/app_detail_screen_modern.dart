import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/app_model.dart';
import '../models/notification_model.dart';
import '../repository/notification_provider.dart';
import '../../audio/tts/tts_provider.dart';
import '../../ai/summarizer/notification_summarizer.dart';
import '../../ai/gemma/gemma_service.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../widgets/app_icon_widget.dart';

class AppDetailScreenModern extends ConsumerStatefulWidget {
  final AppModel app;

  const AppDetailScreenModern({super.key, required this.app});

  @override
  ConsumerState<AppDetailScreenModern> createState() => _AppDetailScreenModernState();
}

class _AppDetailScreenModernState extends ConsumerState<AppDetailScreenModern> 
    with SingleTickerProviderStateMixin {
  int? _expandedNotificationId;
  int? _playingNotificationId;
  late final NotificationSummarizer _summarizer;
  bool _isSummarizing = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _summarizer = NotificationSummarizer(GemmaServiceImpl());
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    ref.read(ttsControllerProvider.notifier).stop();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsyncValue = ref.watch(notificationsByAppProvider(widget.app.id!));
    final connectivityAsync = ref.watch(connectivityProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: notificationsAsyncValue.when(
                data: (notifications) => notifications.isEmpty
                    ? _buildEmptyState()
                    : _buildNotificationList(notifications),
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
      bottomNavigationBar: connectivityAsync.when(
        data: (hasInternet) => _buildSummarizeButton(context, hasInternet),
        loading: () => _buildSummarizeButton(context, true),
        error: (_, __) => _buildSummarizeButton(context, false),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Row(
        children: [
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          AppIconWidget(
            iconPath: widget.app.iconPath,
            appName: widget.app.appName,
            size: 40,
            borderRadius: AppSpacing.radiusMd,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.app.appName,
                  style: AppTypography.headingMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${widget.app.notificationCount} notifications',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildHeaderButton(
            icon: Icons.refresh_rounded,
            onTap: () {
              ref.read(notificationsByAppProvider(widget.app.id!).notifier).refresh();
            },
          ),
          const SizedBox(width: AppSpacing.sm),
          _buildHeaderButton(
            icon: Icons.delete_sweep_rounded,
            onTap: () => _showDeleteDialog(context),
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

  Widget _buildNotificationList(List<NotificationModel> notifications) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenPadding,
        AppSpacing.sm,
        AppSpacing.screenPadding,
        100,
      ),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        final isExpanded = _expandedNotificationId == notification.id;
        final isPlaying = _playingNotificationId == notification.id;
        return _buildNotificationCard(notification, isExpanded, isPlaying);
      },
    );
  }

  Widget _buildNotificationCard(
    NotificationModel notification,
    bool isExpanded,
    bool isPlaying,
  ) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: AppSpacing.cardGap),
      decoration: BoxDecoration(
        color: isPlaying
            ? AppColors.primary.withOpacity(0.05)
            : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isPlaying ? AppColors.primary.withOpacity(0.3) : AppColors.border,
          width: isPlaying ? 1.5 : 1,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await ref.read(ttsControllerProvider.notifier).stop();
            
            setState(() {
              if (_expandedNotificationId == notification.id) {
                _expandedNotificationId = null;
                _playingNotificationId = null;
              } else {
                _expandedNotificationId = notification.id;
                _playingNotificationId = notification.id;
              }
            });

            if (_playingNotificationId == notification.id) {
              await ref.read(ttsControllerProvider.notifier).readSingleNotification(notification);
              if (mounted) {
                setState(() {
                  _playingNotificationId = null;
                });
              }
            }
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: isExpanded ? null : 1,
                        overflow: isExpanded ? null : TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (isPlaying)
                      _buildPlayingIndicator()
                    else
                      Icon(
                        isExpanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        color: AppColors.textSecondary,
                        size: 24,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  notification.message,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  maxLines: isExpanded ? null : 2,
                  overflow: isExpanded ? null : TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatTimestamp(notification.timestamp),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const Spacer(),
                    _buildPriorityBadge(notification.priority),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.volume_up_rounded,
            size: 14,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityBadge(NotificationPriority priority) {
    Color color;
    String label;
    
    switch (priority) {
      case NotificationPriority.high:
        color = AppColors.priorityHigh;
        label = 'High';
        break;
      case NotificationPriority.low:
        color = AppColors.priorityLow;
        label = 'Low';
        break;
      default:
        color = AppColors.priorityMedium;
        label = 'Medium';
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(timestamp);
    }
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
              'Notifications from ${widget.app.appName}\nwill appear here',
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

  Widget _buildSummarizeButton(BuildContext context, bool hasInternet) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!hasInternet)
            Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 16, color: AppColors.warning),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'No internet - TTS unavailable',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              gradient: (_isSummarizing || !hasInternet)
                  ? null
                  : AppColors.primaryGradient,
              color: (_isSummarizing || !hasInternet)
                  ? AppColors.divider
                  : null,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              boxShadow: (_isSummarizing || !hasInternet)
                  ? null
                  : [
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
                onTap: (_isSummarizing || !hasInternet)
                    ? null
                    : () => _handleSummarize(context),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                child: Center(
                  child: _isSummarizing
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
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: (_isSummarizing || !hasInternet)
                                  ? AppColors.textTertiary
                                  : Colors.white,
                              size: 22,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Text(
                              'Summarize Today',
                              style: AppTypography.button.copyWith(
                                color: (_isSummarizing || !hasInternet)
                                    ? AppColors.textTertiary
                                    : Colors.white,
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
    );
  }

  Future<void> _handleSummarize(BuildContext context) async {
    final notificationsAsyncValue = ref.read(notificationsByAppProvider(widget.app.id!));
    
    await notificationsAsyncValue.whenData((notifications) async {
      if (notifications.isEmpty) {
        _showSnackBar(context, 'No notifications to summarize');
        return;
      }

      setState(() => _isSummarizing = true);

      try {
        await ref.read(ttsControllerProvider.notifier).stop();
        
        final summary = await _summarizer.summarizeAppNotificationsIntelligent(
          widget.app.appName,
          notifications,
        );

        await ref.read(ttsControllerProvider.notifier).readSummary(
          summary,
          context: 'app_summary_${widget.app.id}',
        );
      } catch (e) {
        if (mounted) {
          _showSnackBar(context, 'Error: ${e.toString()}', isError: true);
        }
      } finally {
        if (mounted) {
          setState(() => _isSummarizing = false);
        }
      }
    });
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete all notifications?', style: AppTypography.headingMedium),
        content: Text(
          'This will permanently delete all notifications from ${widget.app.appName}.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTypography.labelLarge),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).deleteNotificationsByApp(widget.app.id!);
              ref.read(appListProvider.notifier).refresh();
              ref.read(notificationsByAppProvider(widget.app.id!).notifier).refresh();
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: Text('Delete', style: AppTypography.button),
          ),
        ],
      ),
    );
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
}
