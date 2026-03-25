import 'enums.dart';

class Report {
  final String id;
  final String? stationId;
  final String? stationName;
  final TrafficLevel traffic;
  final bool isAvailable;
  final DateTime createdAt;
  final String? userId;
  final String? userName;
  final UserRole userRole;

  Report({
    required this.id,
    this.stationId,
    this.stationName,
    required this.traffic,
    required this.isAvailable,
    required this.createdAt,
    this.userId,
    this.userName,
    this.userRole = UserRole.guest,
  });

  bool get isVerified => userRole.isVerified;

  double get weight => userRole.weight;

  String get roleDisplayName => userRole.displayName;

  int get ageMinutes => DateTime.now().difference(createdAt).inMinutes;

  bool get isRecent => ageMinutes < 30;

  factory Report.fromMap(String id, Map<String, dynamic> data) {
    final ts = data['createdAt'];

    DateTime created;

    if (ts is int) {
      created = DateTime.fromMillisecondsSinceEpoch(ts);
    } else if (ts is String) {
      created = DateTime.parse(ts);
    } else if (ts != null && ts.runtimeType.toString() == 'Timestamp') {
      // Use dynamic to avoid importing cloud_firestore just for this type check,
      // since it's used in pure dart context but passed from firestore.
      // Alternatively, import cloud_firestore:
      created = (ts as dynamic).toDate();
    } else {
      created = DateTime.now();
    }

    return Report(
      id: id,
      stationId: data['stationId'],
      stationName: data['stationName'],
      traffic: TrafficLevel.values.firstWhere(
        (e) => e.name == (data['traffic'] ?? ''),
        orElse: () => TrafficLevel.normal,
      ),
      isAvailable: (data['isAvailable'] ?? 1) == 1,
      createdAt: created,
      userId: data['userId'],
      userName: data['userName'] ?? 'Anonymous',
      userRole: UserRole.values.firstWhere(
        (e) => e.name == (data['userRole'] ?? ''),
        orElse: () => UserRole.guest,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stationId': stationId ?? '', // Send empty string instead of omitting
      'stationName': stationName ?? 'Unknown Station',
      'traffic': traffic.name,
      'isAvailable': isAvailable, // This sends true/false
      'createdAt': createdAt.millisecondsSinceEpoch,
      'userId': userId ?? '',
      'userName': userName ?? 'Anonymous',
      'userRole': userRole.name,
    };
  }

  Report copyWith({
    String? id,
    String? stationId,
    String? stationName,
    TrafficLevel? traffic,
    bool? isAvailable,
    DateTime? createdAt,
    String? userId,
    String? userName,
    UserRole? userRole,
  }) {
    return Report(
      id: id ?? this.id,
      stationId: stationId ?? this.stationId,
      stationName: stationName ?? this.stationName,
      traffic: traffic ?? this.traffic,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userRole: userRole ?? this.userRole,
    );
  }

  @override
  String toString() {
    return 'Report('
        'id: $id, '
        'stationId: $stationId, '
        'stationName: $stationName, '
        'traffic: ${traffic.name}, '
        'isAvailable: $isAvailable, '
        'userRole: ${userRole.name}, '
        'createdAt: $createdAt'
        ')';
  }
}
