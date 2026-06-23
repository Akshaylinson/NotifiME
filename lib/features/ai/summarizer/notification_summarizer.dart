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

  Future<String> summarizeGlobalByAppPlain(
    Map<String, List<NotificationModel>> notificationsByApp,
  ) async {
    if (notificationsByApp.isEmpty) {
      return "You have no notifications.";
    }

    final summaries = <String>[];
    int totalCount = 0;

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

      totalCount += todayNotifications.length;
      final summary = _generateAppSummaryPlain(appName, todayNotifications);
      summaries.add(summary);
    }

    if (summaries.isEmpty) {
      return "You have no notifications from today.";
    }

    // Create a natural greeting based on time of day
    final hour = DateTime.now().hour;
    String greeting = '';
    if (hour >= 5 && hour < 12) {
      greeting = 'Good morning. ';
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Good afternoon. ';
    } else if (hour >= 17 && hour < 21) {
      greeting = 'Good evening. ';
    }

    // Build natural summary
    String intro = '';
    if (totalCount == 1) {
      intro = "Here's your notification. ";
    } else if (totalCount <= 5) {
      intro = "Here's what you missed. ";
    } else if (totalCount <= 10) {
      intro = "You've got quite a few updates. ";
    } else {
      intro = "You've been busy! Here's your summary. ";
    }

    return greeting + intro + summaries.join('. ') + '.';
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

  String _generateAppSummaryPlain(String appName, List<NotificationModel> notifications) {
    final count = notifications.length;
    final senders = notifications.map((n) => n.sender).where((s) => s.isNotEmpty).toSet();
    final highPriority = notifications.where((n) => n.priority == NotificationPriority.high).length;

    final appLower = appName.toLowerCase();

    // Truecaller/Phone/Dialer - Use actual caller names
    if (appLower.contains('truecaller') || appLower.contains('phone') ||
        appLower.contains('dialer') || appLower.contains('call')) {
      if (senders.isEmpty) {
        return count == 1 ? 'One missed call' : '$count missed calls';
      }
      if (senders.length == 1) {
        final caller = senders.first;
        return count == 1 
            ? '$caller called you'
            : '$caller called you $count times';
      }
      // Multiple callers
      final callerList = senders.take(3).toList();
      if (callerList.length == 2) {
        return '${callerList[0]} and ${callerList[1]} called you';
      } else if (callerList.length == 3) {
        return '${callerList[0]}, ${callerList[1]}, and ${callerList[2]} called you';
      }
      return '$count missed calls from ${senders.length} people';
    }
    
    // WhatsApp - Use sender names and message counts
    else if (appLower.contains('whatsapp')) {
      if (senders.isEmpty) {
        return count == 1 ? 'One WhatsApp message' : '$count WhatsApp messages';
      }
      if (senders.length == 1) {
        final sender = senders.first;
        final msgCount = notifications.where((n) => n.sender == sender).length;
        return msgCount == 1
            ? '$sender messaged you on WhatsApp'
            : '$sender sent you $msgCount messages on WhatsApp';
      }
      // Multiple senders
      final senderList = senders.take(3).toList();
      if (senderList.length == 2) {
        final count1 = notifications.where((n) => n.sender == senderList[0]).length;
        final count2 = notifications.where((n) => n.sender == senderList[1]).length;
        return '${senderList[0]} sent you $count1 message${count1 > 1 ? 's' : ''}, and ${senderList[1]} sent you $count2 message${count2 > 1 ? 's' : ''} on WhatsApp';
      } else if (senderList.length == 3) {
        return '${senderList[0]}, ${senderList[1]}, and ${senderList[2]} messaged you on WhatsApp';
      }
      return '$count WhatsApp messages from ${senders.length} contacts';
    }
    
    // YouTube - More natural
    else if (appLower.contains('youtube')) {
      if (count == 1) return 'One YouTube notification';
      if (count <= 3) return '$count YouTube notifications';
      return 'Several YouTube notifications';
    }
    
    // Gmail/Email - Use sender names if available
    else if (appLower.contains('gmail') || appLower.contains('mail')) {
      if (senders.isEmpty) {
        if (highPriority > 0) {
          return count == 1 ? 'One important email' : '$highPriority important emails';
        }
        return count == 1 ? 'One new email' : '$count new emails';
      }
      if (senders.length == 1) {
        final sender = senders.first;
        if (highPriority > 0) {
          return 'Important email from $sender';
        }
        return count == 1 ? 'Email from $sender' : '$count emails from $sender';
      }
      // Multiple senders
      if (highPriority > 0) {
        return '$count emails, including $highPriority important';
      }
      final senderList = senders.take(2).toList();
      if (senderList.length == 2) {
        return 'Emails from ${senderList[0]} and ${senderList[1]}';
      }
      return '$count emails from ${senders.length} senders';
    }
    
    // Instagram - More personal
    else if (appLower.contains('instagram')) {
      if (senders.isNotEmpty && senders.length <= 2) {
        final people = senders.join(' and ');
        return 'Instagram activity from $people';
      }
      return count == 1 ? 'One Instagram notification' : '$count Instagram notifications';
    }
    
    // SMS/Messages - Use sender names
    else if (appLower.contains('message') || appLower.contains('sms')) {
      if (senders.isEmpty) {
        return count == 1 ? 'One text message' : '$count text messages';
      }
      if (senders.length == 1) {
        final sender = senders.first;
        return count == 1 
            ? '$sender texted you'
            : '$sender sent you $count text messages';
      }
      // Multiple senders
      final senderList = senders.take(2).toList();
      if (senderList.length == 2) {
        return '${senderList[0]} and ${senderList[1]} texted you';
      }
      return '$count text messages from ${senders.length} people';
    }
    
    // Generic apps - More conversational
    else {
      if (senders.isNotEmpty && senders.length == 1) {
        return count == 1
            ? 'Notification from ${senders.first} on $appName'
            : '$count notifications from ${senders.first} on $appName';
      }
      return count == 1 
          ? '$appName notification' 
          : '$count $appName notifications';
    }
  }

  Future<String> summarizeImportantNotifications(List<NotificationModel> notifications) async {
    final important = notifications.where((n) => n.priority == NotificationPriority.high).toList();
    if (important.isEmpty) return "No high-priority notifications found.";

    final messages = important.map((n) => "${n.title}: ${n.message}").toList();
    final prompt = SummaryPrompts.importantSummary(messages);

    return await _gemmaService.summarize(prompt);
  }
}
