import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_model.dart';
import '../models/notification_model.dart';
import '../repository/notification_provider.dart';
import 'package:intl/intl.dart';
import '../../audio/tts/tts_provider.dart';

class AppDetailScreen extends ConsumerStatefulWidget {
  final AppModel app;

  const AppDetailScreen({super.key, required this.app});

  @override
  ConsumerState<AppDetailScreen> createState() => _AppDetailScreenState();
}

class _AppDetailScreenState extends ConsumerState<AppDetailScreen> {
  int? _expandedNotificationId;
  int? _playingNotificationId;

  @override
  void dispose() {
    ref.read(ttsControllerProvider.notifier).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsyncValue = ref.watch(notificationsByAppProvider(widget.app.id!));
    final ttsState = ref.watch(ttsControllerProvider);

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
      bottomNavigationBar: Container(
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
        child: ElevatedButton.icon(
          onPressed: () {
            // TODO: Implement summarize functionality
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Summarize feature coming soon')),
            );
          },
          icon: const Icon(Icons.auto_awesome, color: Colors.white),
          label: const Text(
            'Summarize',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            foregroundColor: Colors.white,
          ),
        ),
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
