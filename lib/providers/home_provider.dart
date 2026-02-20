import 'package:flutter_riverpod/legacy.dart';
import '../viewmodels/home_notifier.dart';
import '../models/station.dart';

final homeProvider = StateNotifierProvider<HomeNotifier, List<Station>>((ref) {
  return HomeNotifier();
});