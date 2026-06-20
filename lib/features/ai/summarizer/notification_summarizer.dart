import '../../notifications/models/notification_model.dart';
import '../gemma/gemma_service.dart';
import '../prompts/summary_prompts.dart';

class NotificationSummarizer {
  final GemmaService _gemmaService;

  NotificationSummarizer(this._gemmaService);

  Future<String> summarizeAppNotifications(String appName, List<NotificationModel> notifications) async {
    if (notifications.isEmpty) return "No notifications to summarize.";

    final messages = notifications.map((n) => "\${n.title}: \${n.message}").toList();
    final prompt = SummaryPrompts.appSummary(appName, messages);

    return await _gemmaService.summarize(prompt);
  }

  Future<String> summarizeGlobalNotifications(List<NotificationModel> notifications) async {
    if (notifications.isEmpty) return "No unread notifications to summarize.";

    final messages = notifications.map((n) => "\${n.title}: \${n.message}").toList();
    final prompt = SummaryPrompts.globalSummary(messages);

    return await _gemmaService.summarize(prompt);
  }

  Future<String> summarizeImportantNotifications(List<NotificationModel> notifications) async {
    final important = notifications.where((n) => n.priority == NotificationPriority.high).toList();
    if (important.isEmpty) return "No high-priority notifications found.";

    final messages = important.map((n) => "\${n.title}: \${n.message}").toList();
    final prompt = SummaryPrompts.importantSummary(messages);

    return await _gemmaService.summarize(prompt);
  }
}
