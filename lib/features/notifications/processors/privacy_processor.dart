class PrivacyProcessor {
  // Simple regex for sensitive patterns
  static final RegExp _otpRegex = RegExp(r'\b\d{4,6}\b');
  static final RegExp _cardRegex = RegExp(r'\b(?:\d[ -]*?){13,16}\b');
  static final RegExp _emailRegex = RegExp(r'\b[\w\.-]+@[\w\.-]+\.\w{2,}\b');

  String maskSensitiveInfo(String text) {
    String masked = text;
    masked = masked.replaceAll(_otpRegex, '[OTP]');
    masked = masked.replaceAll(_cardRegex, '[CARD INFO]');
    masked = masked.replaceAll(_emailRegex, '[EMAIL]');
    return masked;
  }
}
