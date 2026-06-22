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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!hasInternet)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, size: 16, color: Colors.orange[700]),
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
          Opacity(
            opacity: (hasInternet && !_isSummarizing) ? 1.0 : 0.5,
            child: ElevatedButton.icon(
              onPressed: (_isSummarizing || !hasInternet)
                  ? null
                  : () async {
                      final notificationsAsyncValue =
                          ref.read(notificationsByAppProvider(widget.app.id!));
                      
                      notificationsAsyncValue.whenData((notifications) async {
                        if (notifications.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No notifications to summarize')),
                          );
                          return;
                        }

                        setState(() {
                          _isSummarizing = true;
                        });

                        try {
                          // Generate AI-powered intelligent summary (offline)
                          final summary = await _summarizer.summarizeAppNotificationsIntelligent(
                            widget.app.appName,
                            notifications,
                          );

                          // Play summary as audio (requires internet)
                          await ref.read(ttsControllerProvider.notifier).readSummary(summary);
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: ${e.toString()}')),
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
                  : const Icon(Icons.auto_awesome, color: Colors.white),
              label: Text(
                _isSummarizing ? 'Summarizing...' : 'Summarize',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Colors.white,
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
      elevation: isExpanded ? 4 : 1,
      color: isPlaying
          ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
          : null,
      child: InkWell(
        onTap: () async {
          setState(() {
            if (_expandedNotificationId == notification.id) {
              // Collapse if already expanded
              _expandedNotificationId = null;
              ref.read(ttsControllerProvider.notifier).stop();
              _playingNotificationId = null;
            } else {
              // Expand and read
              _expandedNotificationId = notification.id;
              _playingNotificationId = notification.id;
            }
          });

          if (_playingNotificationId == notification.id) {
            // Read the notification
            await ref.read(ttsControllerProvider.notifier).readSingleNotification(notification);
            if (mounted) {
              setState(() {
                _playingNotificationId = null;
              });
            }
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          height: isExpanded ? null : 110,
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
                            fontWeight: isExpanded ? FontWeight.bold : FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isPlaying)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.volume_up,
                            size: 16,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ],
                      ),
                    ),
                  if (!isPlaying)
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.grey,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (isExpanded)
                Text(
                  notification.message,
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                Expanded(
                  child: Text(
                    notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, h:mm a').format(notification.timestamp),
                    style: Theme.of(context).textTheme.bodySmall,
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
