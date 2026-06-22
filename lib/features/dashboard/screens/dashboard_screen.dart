import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../notifications/repository/notification_provider.dart';
import '../../notifications/screens/app_detail_screen.dart';
import '../../notifications/screens/permission_screen.dart';
import '../../settings/screens/settings_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsyncValue = ref.watch(appListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notiva'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(appListProvider.notifier).refresh();
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
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
            icon: const Icon(Icons.settings),
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
            ? const Center(child: Text('No notifications captured yet.'))
            : ListView.builder(
                itemCount: apps.length,
                itemBuilder: (context, index) {
                  final app = apps[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(app.appName[0]),
                    ),
                    title: Text(app.appName),
                    subtitle: Text('Notifications: ${app.notificationCount}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AppDetailScreen(app: app),
                        ),
                      );
                    },
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Global Summary Action
        },
        label: const Text('Global Summary'),
        icon: const Icon(Icons.summarize),
      ),
    );
  }
}
