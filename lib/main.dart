import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/notifications/listener/notification_receiver.dart';
import 'features/notifications/repository/notification_provider.dart';
import 'features/notifications/screens/permission_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final container = ProviderContainer();
  final repository = container.read(notificationRepositoryProvider);
  final receiver = NotificationReceiver(repository);
  receiver.startListening();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const AINotificationAssistant(),
    ),
  );
}

class AINotificationAssistant extends StatelessWidget {
  const AINotificationAssistant({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      home: const AppInitializer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> with WidgetsBindingObserver {
  bool _showPermissionScreen = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // When user comes back from settings, go to dashboard
      setState(() {
        _showPermissionScreen = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _showPermissionScreen
        ? PermissionScreen()
        : const DashboardScreen();
  }
}
