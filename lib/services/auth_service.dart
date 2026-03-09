import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart'; // Required for debugPrint

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Getter for current User ID
  String? get userId => _auth.currentUser?.uid;

  /// Main Google Sign-In Method
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Synchronize profile data to Firestore
      if (userCredential.user != null) {
        await _syncUserProfile(userCredential.user!);
      }

      return userCredential;
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      rethrow;
    }
  }

  /// Synchronize Firebase Auth data with Firestore Users collection
  Future<void> _syncUserProfile(User user) async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    // Update basic info while preserving existing data (like roles)
    await userDoc.set({
      'uid': user.uid,
      'email': user.email ?? '',
      'photoURL': user.photoURL ?? '',
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Check if a role exists, if not, set to default 'guest'
    final doc = await userDoc.get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data() as Map<String, dynamic>;
      if (!data.containsKey('role')) {
        await userDoc.update({
          'role': 'guest',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  /// Clean Logout from both Google and Firebase
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
    }
  }
}