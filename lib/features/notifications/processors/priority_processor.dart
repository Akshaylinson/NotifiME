import '../models/notification_model.dart';

class PriorityProcessor {
  static NotificationPriority detectPriority(String title, String message) {
    final combined = '$title $message'.toLowerCase();

    // High Priority
    if (combined.contains('otp') ||
        combined.contains('verification') ||
        combined.contains('code') ||
        combined.contains('bank') ||
        combined.contains('transaction') ||
        combined.contains('missed call') ||
        combined.contains('calendar') ||
        combined.contains('interview')) {
      return NotificationPriority.high;
    }

    // Low Priority
    if (combined.contains('like') ||
        combined.contains('reacted') ||
        combined.contains('promotion') ||
        combined.contains('offer') ||
        combined.contains('discount') ||
        combined.contains('subscribe')) {
      return NotificationPriority.low;
    }

    // Default
    return NotificationPriority.medium;
  }
}
