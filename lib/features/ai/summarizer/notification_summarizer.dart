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
      final summary = await _gemmaService.summarize(prompt);
      return summary;
    } catch (e) {
      // Fallback to basic summary if AI fails
      return _generateFallbackSummary(appName, todayNotifications);
    }
  }

  /// Fallback summary without AI
  String _generateFallbackSummary(String appName, List<NotificationModel> notifications) {
    final count = notifications.length;
    
    if (appName.toLowerCase().contains('whatsapp')) {
      final senders = <String>{};
      for (var n in notifications) {
        senders.add(n.sender);
      }
      if (senders.length == 1) {
        return '${senders.first} sent you $count messages on WhatsApp.';
      } else {
        return 'You have $count messages from ${senders.length} contacts on WhatsApp.';
      }
    } else if (appName.toLowerCase().contains('phone') || appName.toLowerCase().contains('dialer')) {
      return 'You have $count missed calls.';
    } else if (appName.toLowerCase().contains('youtube')) {
      return 'You have $count YouTube notifications today.';
    } else {
      return 'You have $count notifications from $appName.';
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

  Future<String> summarizeImportantNotifications(List<NotificationModel> notifications) async {
    final important = notifications.where((n) => n.priority == NotificationPriority.high).toList();
    if (important.isEmpty) return "No high-priority notifications found.";

    final messages = important.map((n) => "${n.title}: ${n.message}").toList();
    final prompt = SummaryPrompts.importantSummary(messages);

    return await _gemmaService.summarize(prompt);
  }
}
