import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/notifications/listener/notification_receiver.dart';
import 'features/notifications/repository/notification_provider.dart';

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
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
