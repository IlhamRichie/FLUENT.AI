class ActiveSessionModel {
  final String sessionId;
  final String ipAddress;
  final String deviceInfo;
  final DateTime loginTime;
  final DateTime lastSeen;
  final bool isCurrent;

  ActiveSessionModel({
    required this.sessionId,
    required this.ipAddress,
    required this.deviceInfo,
    required this.loginTime,
    required this.lastSeen,
    required this.isCurrent,
  });

  factory ActiveSessionModel.fromJson(Map<String, dynamic> json) {
    return ActiveSessionModel(
      sessionId: json['session_id'] ?? '',
      ipAddress: json['ip_address'] ?? 'N/A',
      deviceInfo: json['device_info'] ?? 'Unknown Device',
      loginTime: DateTime.tryParse(json['login_time'] ?? '') ?? DateTime.now(),
      lastSeen: DateTime.tryParse(json['last_seen'] ?? '') ?? DateTime.now(),
      isCurrent: json['is_current'] ?? false,
    );
  }
}