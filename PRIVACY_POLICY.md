# Privacy Policy for Notiva AI

**Last Updated:** [Current Date]

## Introduction

Notiva AI ("we," "our," or "the app") is committed to protecting your privacy. This Privacy Policy explains how our notification management application handles your data.

## Our Privacy-First Approach

Notiva AI is designed with privacy as a core principle. We operate on a simple philosophy: **Your data is yours, and it stays on your device.**

## Data Collection and Storage

### What Data We Access
- **Notifications**: We capture notifications from other apps installed on your device to provide our core functionality
- **App Information**: Names and icons of apps that send you notifications
- **User Settings**: Your preferences for voice, speech rate, retention period, etc.

### How Data is Stored
- All data is stored **locally on your device** using SQLite database
- **No cloud storage** - We do not upload, sync, or transmit your data to any servers
- **No analytics** - We do not collect usage statistics or telemetry
- **No third-party services** - No advertising networks or analytics platforms

### Data Processing
- AI summarization is performed **100% offline** using the Gemma model stored on your device
- Text-to-speech processing uses Android's built-in TTS engine
- **No internet connection required** for core functionality (except initial AI model download)

## Privacy Protection Features

### Automatic Data Masking
The app automatically masks sensitive information before processing:
- OTP codes and verification numbers
- Credit/debit card numbers
- Email addresses
- Phone numbers

### Data Retention
- You control how long notifications are stored (7-90 days)
- Old notifications are automatically deleted based on your settings
- You can manually clear all data anytime

## Permissions Required

### Notification Access
- **Why**: To capture and display your notifications
- **Scope**: Read-only access to notification content
- **Usage**: Only used to store and process notifications locally

### Post Notifications (Android 13+)
- **Why**: To show app notifications and alerts
- **Usage**: Only for app-related notifications

### Internet (One-time only)
- **Why**: Initial download of AI model
- **Usage**: Only during first setup; can be disabled afterward

### Wake Lock
- **Why**: To ensure notifications are captured even when device is sleeping
- **Usage**: Minimal battery impact with optimized wake patterns

## Data Sharing

**We do not share, sell, rent, or trade your data with anyone.** Period.

- No data is transmitted to our servers
- No data is shared with third parties
- No advertising networks have access to your data
- No analytics companies receive your information

## Data Security

### Security Measures
- Data encrypted using Android's built-in encryption
- SQLite database secured with Android security model
- No network transmission of personal data
- App uses Android's security sandbox

### User Control
- You can clear all data from Settings
- Uninstalling the app removes all stored data
- No residual data on external servers (we don't have any!)

## Children's Privacy

Notiva AI does not knowingly collect or store information from children under 13. The app is designed for general audiences and contains no age-restricted content.

## Open Source

Notiva AI is open-source software. You can review the source code to verify our privacy claims at: [GitHub Repository URL]

## Changes to Privacy Policy

We may update this Privacy Policy occasionally. Changes will be posted within the app and on our website. Continued use after changes constitutes acceptance of the updated policy.

## Your Rights

Under GDPR and similar regulations, you have the right to:
- Access your data (stored locally on your device)
- Delete your data (via app Settings or uninstallation)
- Export your data (feature coming soon)

## Contact Us

Questions about this Privacy Policy or our data practices?

**Email:** privacy@notivaai.com
**Website:** [Your website]

## Compliance

Notiva AI complies with:
- GDPR (General Data Protection Regulation)
- CCPA (California Consumer Privacy Act)
- Android's privacy guidelines
- Google Play Store privacy requirements

## Third-Party Services

The app uses the following Android system services:
- **NotificationListenerService**: To capture notifications (required by Android)
- **TextToSpeech**: For reading notifications aloud (Android system service)
- **SQLite**: For local data storage (built into Android)

These are Android system components and are subject to Google's privacy policies.

## Data Breach Notification

As we do not collect or store data on our servers, there is no risk of a server-side data breach. Your data remains secure on your device, protected by Android's security features.

## Consent

By using Notiva AI, you consent to this Privacy Policy. You can withdraw consent by uninstalling the app and deleting all data.

---

**Remember:** With Notiva AI, your privacy isn't a feature—it's the foundation.
