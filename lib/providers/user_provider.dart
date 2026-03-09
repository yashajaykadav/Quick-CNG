import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:quickcng/models/enums.dart';
import 'package:quickcng/providers/auth_provider.dart';

import '../models/user.dart';

// Stream of user profile from Firestore
final userProfileProvider = StreamProvider<AppUser?>((ref) {
  final user = ref.watch(currentUserProvider);

  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
    if (!doc.exists || doc.data() == null) return null;
    return AppUser.fromMap(doc.data()!);
  });
});

// Current user profile (nullable)
final currentUserProfileProvider = Provider<AppUser?>((ref) {
  return ref.watch(userProfileProvider).value;
});

// User role
final userRoleProvider = Provider<UserRole>((ref) {
  final user = ref.watch(currentUserProfileProvider);
  return user?.role ?? UserRole.guest;
});

// Check if user is verified (owner/worker/admin)
final isVerifiedUserProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role.isVerified;
});

// Check if user is admin
final isAdminProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role == UserRole.admin;
});

// Check if user is station staff
final isStationStaffProvider = Provider<bool>((ref) {
  final role = ref.watch(userRoleProvider);
  return role.isStationStaff;
});

// Get user's station ID (for owner/worker)
final userStationIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProfileProvider);
  return user?.stationId;
});

// Stream of workers for a specific station
final stationWorkersProvider = StreamProvider.family<List<AppUser>, String>((ref, stationId) {
  return FirebaseFirestore.instance
      .collection('users')
      .where('stationId', isEqualTo: stationId)
      .where('role', isEqualTo: UserRole.worker.name)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => AppUser.fromMap(doc.data())).toList());
});