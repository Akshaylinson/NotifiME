import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'model_manager_service.dart';

abstract class GemmaService {
  Future<void> initialize();
  Future<String> summarize(String text, {String? appName});
}

class GemmaServiceImpl implements GemmaService {
  final ModelManagerService _modelManager = ModelManagerService();
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;
  }

  @override
  Future<String> summarize(String text, {String? appName}) async {
    if (!_isInitialized) await initialize();

    // Use intelligent local summarization
    return _generateLocalSummary(text, appName: appName ?? '');
  }

  String _generateLocalSummary(String text, {required String appName}) {
    final lines = text.split('\n');
    final senders = <String>{};
    final messages = <String>[];
    
    for (var line in lines) {
      if (line.contains('From:')) {
        final parts = line.split('From:');
        if (parts.length > 1) {
          final senderPart = parts[1].split(',')[0].trim();
          senders.add(senderPart);
        }
      }
      
      if (line.contains('Message:')) {
        final parts = line.split('Message:');
        if (parts.length > 1) {
          messages.add(parts[1].trim());
        }
      }
    }

    final appLower = appName.toLowerCase();
    
    // WhatsApp summarization
    if (appLower.contains('whatsapp')) {
      if (senders.isEmpty) {
        return 'You have WhatsApp notifications today.';
      }
      
      if (senders.length == 1) {
        final sender = senders.first;
        final count = messages.length;
        
        if (count > 3) {
          return '$sender messaged you a lot today with $count messages on WhatsApp.';
        } else if (messages.isNotEmpty) {
          final firstMsg = messages.first.toLowerCase();
          if (firstMsg.contains('?')) {
            return '$sender messaged you asking about something on WhatsApp.';
          } else {
            return '$sender sent you $count message${count > 1 ? 's' : ''} on WhatsApp.';
          }
        }
        return '$sender sent you messages on WhatsApp.';
      } else {
        return 'You have messages from ${senders.length} people on WhatsApp: ${senders.take(3).join(", ")}${senders.length > 3 ? ", and others" : ""}.';
      }
    }
    
    // Phone/Dialer/Truecaller summarization
    if (appLower.contains('phone') || appLower.contains('dialer') || appLower.contains('truecaller') || appLower.contains('call')) {
      final count = senders.length;
      if (count == 0) {
        return 'You have missed calls today.';
      }
      
      final unknownCount = senders.where((s) => s.toLowerCase().contains('unknown') || s.contains('+')).length;
      final knownSenders = senders.where((s) => !s.toLowerCase().contains('unknown') && !s.contains('+')).toSet();
      
      if (knownSenders.isEmpty && unknownCount > 0) {
        return 'You have $unknownCount missed call${unknownCount > 1 ? 's' : ''} from unknown numbers.';
      } else if (knownSenders.isNotEmpty && unknownCount == 0) {
        if (knownSenders.length == 1) {
          return '${knownSenders.first} called you $count time${count > 1 ? "s" : ""}.';
        }
        return 'You have missed calls from ${knownSenders.join(", ")}.';
      } else {
        return 'You have $unknownCount call${unknownCount > 1 ? 's' : ''} from unknown numbers and calls from ${knownSenders.join(", ")}.';
      }
    }
    
    // YouTube summarization
    if (appLower.contains('youtube')) {
      final count = messages.length;
      if (count > 5) {
        return 'You got a bunch of songs and videos on YouTube today.';
      } else if (count > 0) {
        return 'You have $count YouTube notification${count > 1 ? 's' : ''} today.';
      }
      return 'You have YouTube activity today.';
    }
    
    // Gmail/Email summarization
    if (appLower.contains('gmail') || appLower.contains('mail')) {
      final count = senders.length;
      if (count > 0) {
        return 'You have $count new email${count > 1 ? 's' : ''} from ${senders.take(2).join(", ")}${count > 2 ? " and others" : ""}.';
      }
      return 'You have new emails.';
    }
    
    // Instagram summarization
    if (appLower.contains('instagram')) {
      if (senders.isEmpty) {
        return 'You have ${messages.length} notification${messages.length > 1 ? 's' : ''} on Instagram.';
      }
      return 'You have Instagram activity from ${senders.take(3).join(", ")}${senders.length > 3 ? " and others" : ""}.';
    }
    
    // SMS/Messages summarization
    if (appLower.contains('message') || appLower.contains('sms')) {
      if (senders.length == 1) {
        return '${senders.first} sent you ${messages.length} text message${messages.length > 1 ? 's' : ''}.';
      } else if (senders.length > 1) {
        return 'You have ${messages.length} text messages from ${senders.length} contacts.';
      }
      return 'You have new text messages.';
    }

    // Generic fallback with app name
    if (senders.isNotEmpty) {
      if (senders.length == 1) {
        return 'You have ${messages.length} notification${messages.length > 1 ? 's' : ''} from ${senders.first} on $appName.';
      }
      return 'You have ${messages.length} notification${messages.length > 1 ? 's' : ''} from ${senders.take(2).join(", ")} on $appName.';
    }
    
    return 'You have ${messages.length} notification${messages.length > 1 ? 's' : ''} from $appName today.';
  }
}
