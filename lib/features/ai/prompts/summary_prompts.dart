class SummaryPrompts {
  static String intelligentAppSummary(String appName, List<Map<String, String>> notificationData) {
    final notificationsText = notificationData
        .map((n) => 'From: ${n['sender']}, Title: ${n['title']}, Message: ${n['message']}')
        .join('\n');
    
    return '''
You are a helpful AI assistant summarizing notifications from $appName.

Instructions:
- Analyze the notifications and provide a natural, conversational summary
- Group similar notifications (e.g., "Alwyn messaged you 3 times")
- Extract key information and context
- For WhatsApp: mention who messaged and about what
- For Phone/Dialer: mention missed calls from whom
- For YouTube Music: mention songs played
- Be concise but informative
- Speak as if talking to a friend

Notifications from $appName today:
$notificationsText

Provide a natural summary:''';
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
