import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Voice Selection'),
            subtitle: const Text('Default (en-US)'),
            onTap: () {},
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('Audio Settings', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          SwitchListTile(
            title: const Text('Auto-read Notifications'),
            value: false,
            onChanged: (val) {},
          ),
          ListTile(
            title: const Text('Speech Speed'),
            subtitle: Slider(value: 0.5, onChanged: (val) {}),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text('AI & Storage', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ListTile(
            title: const Text('Model Management'),
            subtitle: const Text('Gemma (1.2 GB) - Downloaded'),
            trailing: const Icon(Icons.cloud_done),
            onTap: () {},
          ),
          ListTile(
            title: const Text('Retention Period'),
            subtitle: const Text('7 Days'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
