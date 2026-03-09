import 'package:cloud_firestore/cloud_firestore.dart';
import 'enums.dart';

class AppUser {
  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final String? stationId;
  final String? photoURL;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final bool setupComplete;

  const AppUser({
    required this.uid,
    required this.email,
    required this.name,
    this.role = UserRole.user,
    this.stationId,
    this.photoURL,
    this.createdAt,
    this.updatedAt,
    this.setupComplete = false,
  });

  /// -------------------------
  /// Computed properties
  /// -------------------------

  bool get isVerified => role.isVerified;

  bool get isStationStaff => role.isStationStaff;

  bool get isAdmin => role == UserRole.admin;

  /// -------------------------
  /// Firestore factory
  /// -------------------------

  factory AppUser.fromMap(Map<String, dynamic> data) {
    return AppUser(
      uid: data['uid'] ?? '',
      email: data['email'] ?? '',
      name: data['displayName'] ?? 'Anonymous',

      role: _parseRole(data['role']),

      stationId: data['stationId'],
      photoURL: data['photoURL'],

      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),

      setupComplete: data['setupComplete'] ?? false,
    );
  }

  /// -------------------------
  /// Enum parsing
  /// -------------------------

  static UserRole _parseRole(dynamic value) {
    if (value == null) return UserRole.user;

    try {
      return UserRole.values.firstWhere(
            (e) => e.name.toLowerCase() == value.toString().toLowerCase(),
      );
    } catch (_) {
      return UserRole.user;
    }
  }

  /// -------------------------
  /// Firestore Map
  /// -------------------------

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': name,
      'photoURL': photoURL,
      'role': role.name,
      'stationId': stationId,
      'setupComplete': setupComplete,

      /// createdAt should only be set once
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),

      /// always update
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// -------------------------
  /// Copy With
  /// -------------------------

  AppUser copyWith({
    String? uid,
    String? email,
    String? name,
    UserRole? role,
    String? stationId,
    String? photoURL,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? setupComplete,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      stationId: stationId ?? this.stationId,
      photoURL: photoURL ?? this.photoURL,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      setupComplete: setupComplete ?? this.setupComplete,
    );
  }

  /// -------------------------
  /// Debug
  /// -------------------------

  @override
  String toString() {
    return 'AppUser('
        'uid: $uid, '
        'email: $email, '
        'name: $name, '
        'role: ${role.name}, '
        'stationId: $stationId, '
        'setupComplete: $setupComplete'
        ')';
  }
}