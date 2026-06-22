import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'model_manager_service.dart';

abstract class GemmaService {
  Future<void> initialize();
  Future<String> summarize(String text);
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
  Future<String> summarize(String text) async {
    if (!_isInitialized) await initialize();

    // Use intelligent local summarization
    return _generateLocalSummary(text);
  }

  String _generateLocalSummary(String text) {
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

    // WhatsApp summarization
    if (text.toLowerCase().contains('whatsapp')) {
      if (senders.isEmpty) {
        return 'You have WhatsApp notifications today.';
      }
      
      if (senders.length == 1) {
        final sender = senders.first;
        final count = messages.length;
        
        if (count > 3) {
          return '$sender messaged you a lot today with $count messages.';
        } else if (messages.isNotEmpty) {
          final firstMsg = messages.first.toLowerCase();
          if (firstMsg.contains('?')) {
            return '$sender messaged you asking about something.';
          } else {
            return '$sender sent you $count messages on WhatsApp.';
          }
        }
        return '$sender sent you messages on WhatsApp.';
      } else {
        return 'You have messages from ${senders.length} people on WhatsApp: ${senders.take(3).join(", ")}${senders.length > 3 ? ", and others" : ""}.';
      }
    }
    
    // Phone/Dialer summarization
    if (text.toLowerCase().contains('phone') || text.toLowerCase().contains('dialer') || text.toLowerCase().contains('call')) {
      final count = senders.length;
      if (count == 0) {
        return 'You have missed calls today.';
      }
      
      final unknownCount = senders.where((s) => s.toLowerCase().contains('unknown') || s.contains('+')).length;
      final knownSenders = senders.where((s) => !s.toLowerCase().contains('unknown') && !s.contains('+')).toSet();
      
      if (knownSenders.isEmpty && unknownCount > 0) {
        return 'You have $unknownCount missed calls from unknown numbers.';
      } else if (knownSenders.isNotEmpty && unknownCount == 0) {
        if (knownSenders.length == 1) {
          return '${knownSenders.first} called you $count time${count > 1 ? "s" : ""}.';
        }
        return 'You have missed calls from ${knownSenders.join(", ")}.';
      } else {
        return 'You have $unknownCount calls from unknown numbers and calls from ${knownSenders.join(", ")}.';
      }
    }
    
    // YouTube summarization
    if (text.toLowerCase().contains('youtube')) {
      final count = messages.length;
      if (count > 5) {
        return 'You got a bunch of songs and videos on YouTube today.';
      } else if (count > 0) {
        return 'You have $count YouTube notifications today.';
      }
      return 'You have YouTube activity today.';
    }
    
    // Gmail/Email summarization
    if (text.toLowerCase().contains('gmail') || text.toLowerCase().contains('mail')) {
      final count = senders.length;
      if (count > 0) {
        return 'You have $count new emails from ${senders.take(2).join(", ")}${count > 2 ? " and others" : ""}.';
      }
      return 'You have new emails.';
    }

    // Generic fallback
    if (senders.isNotEmpty) {
      return 'You have ${messages.length} notifications from ${senders.take(2).join(", ")}.';
    }
    
    return 'You have several notifications today.';
  }
}
