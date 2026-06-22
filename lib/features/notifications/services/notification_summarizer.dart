import '../models/notification_model.dart';

class NotificationSummarizer {
  String summarizeNotifications(List<NotificationModel> notifications) {
    if (notifications.isEmpty) {
      return "You have no notifications today.";
    }

    final today = DateTime.now();
    final todayNotifications = notifications.where((n) {
      return n.timestamp.year == today.year &&
          n.timestamp.month == today.month &&
          n.timestamp.day == today.day;
    }).toList();

    if (todayNotifications.isEmpty) {
      return "You have no notifications today.";
    }

    final highPriority = todayNotifications
        .where((n) => n.priority == NotificationPriority.high)
        .toList();
    final mediumPriority = todayNotifications
        .where((n) => n.priority == NotificationPriority.medium)
        .toList();
    final lowPriority = todayNotifications
        .where((n) => n.priority == NotificationPriority.low)
        .toList();

    StringBuffer summary = StringBuffer();

    summary.write("Here's your notification summary for today. ");
    summary.write("You have ${todayNotifications.length} notifications in total. ");

    if (highPriority.isNotEmpty) {
      summary.write("${highPriority.length} high priority notifications. ");
      if (highPriority.length <= 3) {
        for (var notification in highPriority) {
          summary.write("${notification.title}. ");
        }
      } else {
        summary.write("Including ${highPriority.first.title}, and ${highPriority.length - 1} more important items. ");
      }
    }

    if (mediumPriority.isNotEmpty) {
      summary.write("${mediumPriority.length} regular notifications. ");
      if (mediumPriority.length <= 2) {
        for (var notification in mediumPriority) {
          summary.write("${notification.title}. ");
        }
      }
    }

    if (lowPriority.isNotEmpty) {
      summary.write("And ${lowPriority.length} low priority notifications. ");
    }

    summary.write("That's all for now.");

    return summary.toString();
  }
}
