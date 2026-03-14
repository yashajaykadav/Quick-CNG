import 'package:cloud_firestore/cloud_firestore.dart';
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

  int get ageMinutes =>
      DateTime.now().difference(createdAt).inMinutes;

  bool get isRecent => ageMinutes < 30;

  factory Report.fromMap(String id, Map<String, dynamic> data) {
    final ts = data['createdAt'];
    final created =
    ts is Timestamp ? ts.toDate() : DateTime.now();

    return Report(
      id: id,
      stationId: data['stationId'],
      stationName: data['stationName'],
      traffic: TrafficLevel.values.firstWhere(
            (e) => e.name == (data['traffic'] ?? ''),
        orElse: () => TrafficLevel.normal,
      ),
      isAvailable: data['isAvailable'] ?? true,
      createdAt: created,
      userId: data['userId'],
      userName: data['userName'] ?? 'Anonymous',
      userRole: UserRole.values.firstWhere(
            (e) => e.name == (data['userRole'] ?? ''),
        orElse: () => UserRole.guest,
      ),
    );
  }

  factory Report.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Report.fromMap(doc.id, data);
  }

  Map<String, dynamic> toMap() {
    return {
      if (stationId != null) 'stationId': stationId,
      if (stationName != null) 'stationName': stationName,
      'traffic': traffic.name,
      'isAvailable': isAvailable,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': userId,
      'userName': userName,
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