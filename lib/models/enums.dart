import 'package:flutter/material.dart';

/// User roles in the system
enum UserRole {
  admin,
  owner,
  worker,
  user,
  guest;

  /// Weight used when calculating traffic reliability
  double get weight {
    switch (this) {
      case UserRole.admin:
      case UserRole.owner:
        return 1.0;
      case UserRole.worker:
        return 0.8;
      case UserRole.user:
        return 0.5;
      case UserRole.guest:
        return 0.3;
    }
  }

  /// Verified roles
  bool get isVerified {
    return this == UserRole.admin ||
        this == UserRole.owner ||
        this == UserRole.worker;
  }

  /// Station staff roles
  bool get isStationStaff {
    return this == UserRole.owner || this == UserRole.worker;
  }

  /// Display name
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.owner:
        return 'Station Owner';
      case UserRole.worker:
        return 'Station Worker';
      case UserRole.user:
        return 'User';
      case UserRole.guest:
        return 'Guest';
    }
  }

  /// Badge color for UI
  Color get badgeColor {
    switch (this) {
      case UserRole.admin:
        return Colors.red;
      case UserRole.owner:
        return Colors.amber;
      case UserRole.worker:
        return Colors.green;
      case UserRole.user:
        return Colors.blue;
      case UserRole.guest:
        return Colors.grey;
    }
  }
}

/// Traffic level reported by users
enum TrafficLevel {
  low,
  normal,
  high;

  String get displayName {
    switch (this) {
      case TrafficLevel.low:
        return 'Low Traffic';
      case TrafficLevel.normal:
        return 'Normal Traffic';
      case TrafficLevel.high:
        return 'High Traffic';
    }
  }

  String get shortName {
    switch (this) {
      case TrafficLevel.low:
        return 'Low';
      case TrafficLevel.normal:
        return 'Normal';
      case TrafficLevel.high:
        return 'High';
    }
  }

  Color get color {
    switch (this) {
      case TrafficLevel.low:
        return Colors.green;
      case TrafficLevel.normal:
        return Colors.orange;
      case TrafficLevel.high:
        return Colors.red;
    }
  }
}

/// Station availability status
enum StationStatus {
  available,
  unavailable,
  closed;

  String get displayName {
    switch (this) {
      case StationStatus.available:
        return 'Available';
      case StationStatus.unavailable:
        return 'No CNG Available';
      case StationStatus.closed:
        return 'Closed';
    }
  }

  Color get color {
    switch (this) {
      case StationStatus.available:
        return Colors.green;
      case StationStatus.unavailable:
        return Colors.red;
      case StationStatus.closed:
        return Colors.grey;
    }
  }
}

/// Verification request status
enum VerificationStatus {
  pending,
  approved,
  rejected;

  String get displayName {
    switch (this) {
      case VerificationStatus.pending:
        return 'Pending';
      case VerificationStatus.approved:
        return 'Approved';
      case VerificationStatus.rejected:
        return 'Rejected';
    }
  }

  Color get color {
    switch (this) {
      case VerificationStatus.pending:
        return Colors.orange;
      case VerificationStatus.approved:
        return Colors.green;
      case VerificationStatus.rejected:
        return Colors.red;
    }
  }
}