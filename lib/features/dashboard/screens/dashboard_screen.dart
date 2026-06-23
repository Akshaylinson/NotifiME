import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../notifications/repository/notification_provider.dart';
import '../../notifications/repository/notification_repository.dart';
import '../../notifications/screens/app_detail_screen.dart';
import '../../notifications/screens/permission_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../ai/screens/summary_screen.dart';
import '../../ai/summarizer/notification_summarizer.dart';
import '../../ai/gemma/gemma_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _generateGlobalSummary(BuildContext context, WidgetRef ref) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  'Generating global summary...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // Get all apps and their notifications
      final repository = NotificationRepository();
      final apps = await repository.getAllApps();
      
      if (apps.isEmpty) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No notifications to summarize')),
          );
        }
        return;
      }

      // Group notifications by app
      final notificationsByApp = <String, List<dynamic>>{};
      
      for (var app in apps) {
        final notifications = await repository.getNotificationsByApp(app.id!);
        if (notifications.isNotEmpty) {
          notificationsByApp[app.appName] = notifications;
        }
      }

      if (notificationsByApp.isEmpty) {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No notifications to summarize')),
          );
        }
        return;
      }

      // Generate summary using AI
      final gemmaService = GemmaServiceImpl();
      await gemmaService.initialize();
      
      final summarizer = NotificationSummarizer(gemmaService);
      
      // Generate global summary
      final globalSummary = await summarizer.summarizeGlobalByApp(
        notificationsByApp.map((key, value) => MapEntry(key, value.cast())),
      );

      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        
        // Navigate to summary screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SummaryScreen(
              summaryText: globalSummary,
              title: 'Global Summary',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating summary: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsyncValue = ref.watch(appListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.notifications_active, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Notiva'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              ref.read(appListProvider.notifier).refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PermissionScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
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
      body: appsAsyncValue.when(
        data: (apps) => apps.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_off_outlined,
                      size: 80,
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No notifications yet',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your notifications will appear here',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 100),
                itemCount: apps.length,
                itemBuilder: (context, index) {
                  final app = apps[index];
                  return Card(
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AppDetailScreen(app: app),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                                    Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  app.appName[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    app.appName,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${app.notificationCount} notifications',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Theme.of(context).colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 18,
                              color: Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text('Error: $err', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
      floatingActionButton: appsAsyncValue.when(
        data: (apps) => apps.isEmpty
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _generateGlobalSummary(context, ref),
                label: const Text('Global Summary', style: TextStyle(fontWeight: FontWeight.w600)),
                icon: const Icon(Icons.auto_awesome_rounded),
              ),
        loading: () => null,
        error: (_, __) => null,
      ),
    );
  }
}