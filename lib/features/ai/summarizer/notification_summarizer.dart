import '../../notifications/models/notification_model.dart';
import '../gemma/gemma_service.dart';
import '../prompts/summary_prompts.dart';

class NotificationSummarizer {
  final GemmaService _gemmaService;

  NotificationSummarizer(this._gemmaService);

  /// Intelligent summarization that understands app context
  Future<String> summarizeAppNotificationsIntelligent(
    String appName,
    List<NotificationModel> notifications,
  ) async {
    if (notifications.isEmpty) return "No notifications to summarize.";

    // Filter today's notifications
    final today = DateTime.now();
    final todayNotifications = notifications.where((n) {
      return n.timestamp.year == today.year &&
          n.timestamp.month == today.month &&
          n.timestamp.day == today.day;
    }).toList();

    if (todayNotifications.isEmpty) {
      return "You have no notifications from $appName today.";
    }

    // Prepare structured data for AI
    final notificationData = todayNotifications.map((n) => {
      'sender': n.sender,
      'title': n.title,
      'message': n.message,
    }).toList();

    final prompt = SummaryPrompts.intelligentAppSummary(appName, notificationData);

    try {
      final summary = await _gemmaService.summarize(prompt, appName: appName);
      return summary;
    } catch (e) {
      // Fallback to basic summary if AI fails
      return _generateFallbackSummary(appName, todayNotifications);
    }
  }

  /// Fallback summary without AI
  String _generateFallbackSummary(String appName, List<NotificationModel> notifications) {
    final count = notifications.length;
    final senders = <String>{};
    
    for (var n in notifications) {
      senders.add(n.sender);
    }
    
    final appLower = appName.toLowerCase();
    
    // Truecaller/Phone/Dialer - prioritize call-related apps
    if (appLower.contains('truecaller') || appLower.contains('phone') || appLower.contains('dialer') || appLower.contains('call')) {
      if (senders.length == 1) {
        return '${senders.first} called you $count time${count > 1 ? 's' : ''}.';
      } else {
        return 'You have $count missed call${count > 1 ? 's' : ''} from ${senders.length} contact${senders.length > 1 ? 's' : ''}.';
      }
    }
    // WhatsApp
    else if (appLower.contains('whatsapp')) {
      if (senders.length == 1) {
        return '${senders.first} sent you $count message${count > 1 ? 's' : ''} on WhatsApp.';
      } else {
        return 'You have $count messages from ${senders.length} contacts on WhatsApp.';
      }
    }
    // YouTube
    else if (appLower.contains('youtube')) {
      return 'You have $count YouTube notification${count > 1 ? 's' : ''} today.';
    }
    // Email
    else if (appLower.contains('gmail') || appLower.contains('mail')) {
      return 'You have $count new email${count > 1 ? 's' : ''}.';
    }
    // Instagram
    else if (appLower.contains('instagram')) {
      return 'You have $count Instagram notification${count > 1 ? 's' : ''}.';
    }
    // SMS
    else if (appLower.contains('message') || appLower.contains('sms')) {
      return 'You have $count text message${count > 1 ? 's' : ''}.';
    }
    // Generic
    else {
      return 'You have $count notification${count > 1 ? 's' : ''} from $appName.';
    }
  }

  Future<String> summarizeAppNotifications(String appName, List<NotificationModel> notifications) async {
    if (notifications.isEmpty) return "No notifications to summarize.";

    final messages = notifications.map((n) => "${n.title}: ${n.message}").toList();
    final prompt = SummaryPrompts.appSummary(appName, messages);

    return await _gemmaService.summarize(prompt);
  }

  Future<String> summarizeGlobalNotifications(List<NotificationModel> notifications) async {
    if (notifications.isEmpty) return "No unread notifications to summarize.";

    final messages = notifications.map((n) => "${n.title}: ${n.message}").toList();
    final prompt = SummaryPrompts.globalSummary(messages);

    return await _gemmaService.summarize(prompt);
  }

  Future<String> summarizeGlobalByApp(
    Map<String, List<NotificationModel>> notificationsByApp,
  ) async {
    if (notificationsByApp.isEmpty) {
      return "No notifications to summarize.";
    }

    final summaries = <String>[];

    for (var entry in notificationsByApp.entries) {
      final appName = entry.key;
      final notifications = entry.value;

      if (notifications.isEmpty) continue;

      // Filter today's notifications for each app
      final today = DateTime.now();
      final todayNotifications = notifications.where((n) {
        return n.timestamp.year == today.year &&
            n.timestamp.month == today.month &&
            n.timestamp.day == today.day;
      }).toList();

      if (todayNotifications.isEmpty) continue;

      final summary = _generateAppSummary(appName, todayNotifications);
      summaries.add(summary);
    }

    if (summaries.isEmpty) {
      return "You have no notifications from today to summarize.";
    }

    return summaries.join('\n\n');
  }

  String _generateAppSummary(String appName, List<NotificationModel> notifications) {
    final count = notifications.length;
    final senders = notifications.map((n) => n.sender).toSet();
    final highPriority = notifications.where((n) => n.priority == NotificationPriority.high).length;

    final appLower = appName.toLowerCase();
    final emoji = _getAppEmoji(appLower);

    // Truecaller/Phone/Dialer
    if (appLower.contains('truecaller') || appLower.contains('phone') ||
        appLower.contains('dialer') || appLower.contains('call')) {
      if (count == 1) {
        return '$emoji ${senders.first} called you once.';
      }
      return '$emoji You have $count missed call${count > 1 ? 's' : ''} from ${senders.length} contact${senders.length > 1 ? 's' : ''}.';
    }
    // WhatsApp
    else if (appLower.contains('whatsapp')) {
      if (senders.length == 1) {
        return '$emoji ${senders.first} sent you $count message${count > 1 ? 's' : ''}.';
      }
      return '$emoji You have $count messages from ${senders.length} contacts on WhatsApp.';
    }
    // YouTube
    else if (appLower.contains('youtube')) {
      return '$emoji You have $count YouTube notification${count > 1 ? 's' : ''}.';
    }
    // Email
    else if (appLower.contains('gmail') || appLower.contains('mail')) {
      return '$emoji You have $count new email${count > 1 ? 's' : ''}${highPriority > 0 ? ' ($highPriority important)' : ''}.';
    }
    // Instagram
    else if (appLower.contains('instagram')) {
      return '$emoji You have $count Instagram notification${count > 1 ? 's' : ''}.';
    }
    // SMS
    else if (appLower.contains('message') || appLower.contains('sms')) {
      return '$emoji You have $count text message${count > 1 ? 's' : ''}.';
    }
    // Generic
    else {
      return '$emoji $appName: $count notification${count > 1 ? 's' : ''}.';
    }
  }

  String _getAppEmoji(String appLower) {
    if (appLower.contains('whatsapp')) return '💬';
    if (appLower.contains('call') || appLower.contains('phone') || appLower.contains('truecaller')) return '📞';
    if (appLower.contains('gmail') || appLower.contains('mail')) return '📧';
    if (appLower.contains('youtube')) return '🎥';
    if (appLower.contains('instagram')) return '📸';
    if (appLower.contains('message') || appLower.contains('sms')) return '💬';
    return '🔔';
  }

  Future<String> summarizeImportantNotifications(List<NotificationModel> notifications) async {
    final important = notifications.where((n) => n.priority == NotificationPriority.high).toList();
    if (important.isEmpty) return "No high-priority notifications found.";

    final messages = important.map((n) => "${n.title}: ${n.message}").toList();
    final prompt = SummaryPrompts.importantSummary(messages);

    return await _gemmaService.summarize(prompt);
  }
}
