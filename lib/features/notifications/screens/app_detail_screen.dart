import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_model.dart';
import '../repository/notification_provider.dart';
import 'package:intl/intl.dart';
import '../../audio/tts/tts_provider.dart';

class AppDetailScreen extends ConsumerWidget {
  final AppModel app;

  const AppDetailScreen({super.key, required this.app});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsyncValue = ref.watch(notificationsByAppProvider(app.id!));

    return Scaffold(
      appBar: AppBar(
        title: Text(app.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(notificationsByAppProvider(app.id!).notifier).refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () async {
              await ref.read(notificationRepositoryProvider).deleteNotificationsByApp(app.id!);
              ref.read(appListProvider.notifier).refresh();
              ref.read(notificationsByAppProvider(app.id!).notifier).refresh();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    final controller = ref.read(ttsControllerProvider);
                    switch (value) {
                      case 'latest':
                        controller.readLatest(app.id!);
                        break;
                      case 'all':
                        controller.readAllFromApp(app.id!);
                        break;
                      case 'important':
                        controller.readImportant(app.id!);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: 'latest', child: Text('Read Latest')),
                    const PopupMenuItem(value: 'all', child: Text('Read All')),
                    const PopupMenuItem(value: 'important', child: Text('Read Important')),
                  ],
                  child: ElevatedButton.icon(
                    onPressed: null,
                    icon: const Icon(Icons.volume_up),
                    label: const Text('Read'),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Logic to generate summary
                  },
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Summarize'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: notificationsAsyncValue.when(
              data: (notifications) => notifications.isEmpty
                  ? const Center(child: Text('No notifications for this app.'))
                  : ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return ListTile(
                          title: Text(notification.title),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notification.message),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM d, h:mm a').format(notification.timestamp),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          isThreeLine: true,
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
