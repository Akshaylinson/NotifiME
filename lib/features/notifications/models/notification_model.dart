enum NotificationPriority { low, medium, high }

class NotificationModel {
  final int? id;
  final int appId;
  final String sender;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final NotificationPriority priority;

  NotificationModel({
    this.id,
    required this.appId,
    required this.sender,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.priority = NotificationPriority.medium,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'app_id': appId,
      'sender': sender,
      'title': title,
      'message': message,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'read_status': isRead ? 1 : 0,
      'priority': priority.index,
    };
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    // Handle priority - can be either String or int
    NotificationPriority parsedPriority;
    final priorityValue = map['priority'];
    
    if (priorityValue is int) {
      parsedPriority = NotificationPriority.values[priorityValue];
    } else if (priorityValue is String) {
      // Convert string to enum (from Kotlin database)
      switch (priorityValue.toLowerCase()) {
        case 'high':
          parsedPriority = NotificationPriority.high;
          break;
        case 'low':
          parsedPriority = NotificationPriority.low;
          break;
        default:
          parsedPriority = NotificationPriority.medium;
      }
    } else {
      parsedPriority = NotificationPriority.medium;
    }
    
    return NotificationModel(
      id: map['id'],
      appId: map['app_id'],
      sender: map['sender'],
      title: map['title'],
      message: map['message'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp']),
      isRead: map['read_status'] == 1,
      priority: parsedPriority,
    );
  }
}
