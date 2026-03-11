import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quickcng/models/enums.dart';

class VerificationRequest {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String stationName;
  final String? stationId;
  final String contact;

  final UserRole role;
  final VerificationStatus status;

  final DateTime createdAt;
  final DateTime? processedAt;

  final String? processedBy;
  final String? rejectionReason;
  final String? documentUrl;

  const VerificationRequest({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.stationName,
    this.stationId,
    required this.contact,
    required this.role,
    this.status = VerificationStatus.pending,
    required this.createdAt,
    this.processedAt,
    this.processedBy,
    this.rejectionReason,
    this.documentUrl,
  });

  bool get isPending => status == VerificationStatus.pending;
  bool get isApproved => status == VerificationStatus.approved;
  bool get isRejected => status == VerificationStatus.rejected;
  bool get isProcessed => isApproved || isRejected;

  String get statusDisplay => status.displayName;
  String get roleDisplay => role.displayName;

  factory VerificationRequest.fromMap(String id, Map<String, dynamic> data) {
    return VerificationRequest(
      id: id,
      userId: data['userId'] ?? '',
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      stationName: data['stationName'] ?? '',
      stationId: data['stationId'],
      contact: data['contact'] ?? '',
      role: _parseRole(data['role']),
      status: _parseStatus(data['status']),
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      processedAt:
          (data['processedAt'] as Timestamp?)?.toDate(),
      processedBy: data['processedBy'],
      rejectionReason: data['rejectionReason'],
      documentUrl: data['documentUrl'],
    );
  }

  static UserRole _parseRole(dynamic value) {
    if (value == null) return UserRole.guest;

    try {
      return UserRole.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toString().toLowerCase(),
      );
    } catch (_) {
      return UserRole.guest;
    }
  }

  static VerificationStatus _parseStatus(dynamic value) {
    if (value == null) return VerificationStatus.pending;

    try {
      return VerificationStatus.values.firstWhere(
        (e) => e.name.toLowerCase() == value.toString().toLowerCase(),
      );
    } catch (_) {
      return VerificationStatus.pending;
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'fullName': fullName,
      'email': email,
      'stationName': stationName,
      'stationId': stationId,
      'contact': contact,
      'role': role.name,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'processedAt': processedAt != null
          ? Timestamp.fromDate(processedAt!)
          : null,
      'processedBy': processedBy,
      'rejectionReason': rejectionReason,
      'documentUrl': documentUrl,
    };
  }

  VerificationRequest copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? email,
    String? stationName,
    String? stationId,
    String? contact,
    UserRole? role,
    VerificationStatus? status,
    DateTime? createdAt,
    DateTime? processedAt,
    String? processedBy,
    String? rejectionReason,
    String? documentUrl,
  }) {
    return VerificationRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      stationName: stationName ?? this.stationName,
      stationId: stationId ?? this.stationId,
      contact: contact ?? this.contact,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      processedAt: processedAt ?? this.processedAt,
      processedBy: processedBy ?? this.processedBy,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      documentUrl: documentUrl ?? this.documentUrl,
    );
  }

  @override
  String toString() {
    return 'VerificationRequest(id: $id, fullName: $fullName, role: ${role.name}, status: ${status.name})';
  }
}