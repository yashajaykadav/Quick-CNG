import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:quickcng/services/auth_service.dart';

final authLoadingProvider = StateProvider<bool>((ref) => false);

// Auth Service instance
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Stream of Firebase Auth state changes
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Current user (nullable)
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

// Check if user is logged in
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});
