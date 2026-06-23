import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/observers/audio_lifecycle_observer.dart';
import 'core/services/retention_policy_service.dart';
import 'features/audio/tts/tts_provider.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/notifications/listener/notification_receiver.dart';
import 'features/notifications/repository/notification_provider.dart';
import 'features/notifications/screens/permission_screen.dart';
import 'features/settings/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  final repository = container.read(notificationRepositoryProvider);
  final receiver = NotificationReceiver(repository, container);
  receiver.startListening();

  // Load settings and cleanup old notifications
  await container.read(appSettingsProvider.notifier).initializeAndCleanup();

  // Initialize retention policy background service
  final retentionService = RetentionPolicyService();
  await retentionService.initialize();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AINotificationAssistant(),
    ),
  );
}

class AINotificationAssistant extends ConsumerWidget {
  const AINotificationAssistant({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      navigatorObservers: [
        AudioLifecycleObserver(
          onNavigateBack: () => ref.read(ttsControllerProvider.notifier).stop(),
        ),
      ],
      home: const AppInitializer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppInitializer extends ConsumerStatefulWidget {
  const AppInitializer({super.key});

  @override
  ConsumerState<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends ConsumerState<AppInitializer> with WidgetsBindingObserver {
  bool _showPermissionScreen = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    ref.read(ttsControllerProvider.notifier).stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _showPermissionScreen = false;
      });
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      ref.read(ttsControllerProvider.notifier).stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _showPermissionScreen
        ? PermissionScreen()
        : const DashboardScreen();
  }
}
