import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  static const MethodChannel _channel = MethodChannel('com.example.notifime/notifications');

  Future<void> _requestPermission() async {
    try {
      await _channel.invokeMethod('openNotificationSettings');
    } catch (e) {
      print('Error opening settings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Required')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.notifications_active, size: 100, color: Colors.deepPurple),
              const SizedBox(height: 24),
              const Text(
                'Notification Access Required',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'This app needs notification access to capture and organize your notifications.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _requestPermission,
                icon: const Icon(Icons.settings),
                label: const Text('Grant Permission'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Skip for now'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
