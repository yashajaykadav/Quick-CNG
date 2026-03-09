import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/firestore_services.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});