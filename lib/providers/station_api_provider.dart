import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcng/services/station_api_service.dart';

final stationApiProvider = Provider((ref) {
  return StationApiService();
});
