import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_model.dart';
import '../models/notification_model.dart';
import '../repository/notification_provider.dart';
import 'package:intl/intl.dart';
import '../../audio/tts/tts_provider.dart';
import '../../ai/summarizer/notification_summarizer.dart';
import '../../ai/gemma/gemma_service.dart';
import '../../../core/providers/connectivity_provider.dart';

class AppDetailScreen extends ConsumerStatefulWidget {
  final AppModel app;

  const AppDetailScreen({super.key, required this.app});

  @override
  ConsumerState<AppDetailScreen> createState() => _AppDetailScreenState();
}

class _AppDetailScreenState extends ConsumerState<AppDetailScreen> {
  int? _expandedNotificationId;
  int? _playingNotificationId;
  late final NotificationSummarizer _summarizer;
  bool _isSummarizing = false;

  @override
  void initState() {
    super.initState();
    _summarizer = NotificationSummarizer(GemmaServiceImpl());
  }

  @override
  void dispose() {
    ref.read(ttsControllerProvider.notifier).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsyncValue = ref.watch(notificationsByAppProvider(widget.app.id!));
    final ttsState = ref.watch(ttsControllerProvider);
    final connectivityAsync = ref.watch(connectivityProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.app.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(notificationsByAppProvider(widget.app.id!).notifier).refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).deleteNotificationsByApp(widget.app.id!);
              ref.read(appListProvider.notifier).refresh();
              ref.read(notificationsByAppProvider(widget.app.id!).notifier).refresh();
            },
          ),
        ],
      ),
      body: notificationsAsyncValue.when(
        data: (notifications) => notifications.isEmpty
            ? const Center(child: Text('No notifications for this app.'))
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final isExpanded = _expandedNotificationId == notification.id;
                  final isPlaying = _playingNotificationId == notification.id;

                  return _buildNotificationCard(
                    notification,
                    isExpanded,
                    isPlaying,
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      bottomNavigationBar: connectivityAsync.when(
        data: (hasInternet) => _buildSummarizeButton(context, hasInternet),
        loading: () => _buildSummarizeButton(context, true),
        error: (_, __) => _buildSummarizeButton(context, false),
      ),
    );
  }

  Widget _buildSummarizeButton(BuildContext context, bool hasInternet) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!hasInternet)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off_rounded, size: 16, color: Colors.orange[700]),
                  const SizedBox(width: 8),
                  Text(
                    'No internet - TTS unavailable',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: (_isSummarizing || !hasInternet)
                  ? null
                  : () async {
                      final notificationsAsyncValue =
                          ref.read(notificationsByAppProvider(widget.app.id!));
                      
                      notificationsAsyncValue.whenData((notifications) async {
                        if (notifications.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('No notifications to summarize'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _isSummarizing = true;
                        });

                        try {
                          // Stop any currently playing audio first
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: ${e.toString()}'),
                                backgroundColor: Theme.of(context).colorScheme.error,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isSummarizing = false;
                            });
                          }
                        }
                      });
                    },
              icon: _isSummarizing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome_rounded, color: Colors.white),
              label: Text(
                _isSummarizing ? 'Summarizing...' : 'Summarize Today',
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: _isSummarizing ? 0 : 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationModel notification,
    bool isExpanded,
    bool isPlaying,
  ) {
    final ttsState = ref.watch(ttsControllerProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: isExpanded ? 2 : 0,
      color: isPlaying
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.15)
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isPlaying
            ? BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () async {
          // Stop any currently playing audio
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
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: isExpanded ? MainAxisSize.min : MainAxisSize.max,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      notification.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: isExpanded ? null : 1,
                      overflow: isExpanded ? null : TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isPlaying)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.volume_up_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    )
                  else
                    Icon(
                      isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                      color: Theme.of(context).iconTheme.color,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                notification.message,
                maxLines: isExpanded ? null : 2,
                overflow: isExpanded ? null : TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM d, h:mm a').format(notification.timestamp),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSecondaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
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
}
