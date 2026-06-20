class AppModel {
  final int? id;
  final String appName;
  final String packageName;
  final String? iconPath;
  final int notificationCount;

  AppModel({
    this.id,
    required this.appName,
    required this.packageName,
    this.iconPath,
    this.notificationCount = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'app_name': appName,
      'package_name': packageName,
      'icon_path': iconPath,
      'notification_count': notificationCount,
    };
  }

  factory AppModel.fromMap(Map<String, dynamic> map) {
    return AppModel(
      id: map['id'],
      appName: map['app_name'],
      packageName: map['package_name'],
      iconPath: map['icon_path'],
      notificationCount: map['notification_count'],
    );
  }
}
