class ActivityLogModel {
  final String activity;
  final DateTime timestamp;
  final String ipAddress;
  final String deviceInfo;

  ActivityLogModel({
    required this.activity,
    required this.timestamp,
    required this.ipAddress,
    required this.deviceInfo,
  });

  factory ActivityLogModel.fromJson(Map<String, dynamic> json) {
    return ActivityLogModel(
      activity: json['activity'] ?? 'Unknown Activity',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      ipAddress: json['ip_address'] ?? 'N/A',
      deviceInfo: json['device_info'] ?? 'Unknown Device',
    );
  }
}