class SummaryPrompts {
  static String intelligentAppSummary(String appName, List<Map<String, String>> notificationData) {
    final notificationsText = notificationData
        .map((n) => 'From: ${n['sender']}, Title: ${n['title']}, Message: ${n['message']}')
        .join('\n');
    
    return '''
You are summarizing notifications ONLY from the app: $appName

IMPORTANT: All these notifications are from $appName app. Do NOT mention other apps like WhatsApp unless the app name IS WhatsApp.

App Context: $appName
Notifications:
$notificationsText

Instructions:
- These are ALL from $appName - summarize accordingly
- For Truecaller/Phone: mention missed calls
- For WhatsApp: mention messages and senders
- For YouTube: mention video/music notifications
- Be natural and concise
- Group by sender when possible

Summary:''';
  }

  static String appSummary(String appName, List<String> messages) {
    final joined = messages.join('\n- ');
    return 'Summarize the following $appName notifications concisely:\n- $joined';
  }

  static String globalSummary(List<String> messages) {
    final joined = messages.join('\n- ');
    return 'You are an AI assistant. Provide a brief overview of these various notifications received:\n- $joined';
  }

  static String importantSummary(List<String> messages) {
    final joined = messages.join('\n- ');
    return 'These are high-priority notifications. Summarize them urgently:\n- $joined';
  }
}
