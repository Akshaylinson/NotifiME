class SummaryPrompts {
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
