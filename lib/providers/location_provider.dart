import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

// Location permission status
final locationPermissionProvider = FutureProvider<LocationPermission>((ref) async {
  return await Geolocator.checkPermission();
});

// User's current position
final userLocationProvider = FutureProvider<Position>((ref) async {
  // Check if location services are enabled
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw LocationException('Location services are disabled');
  }

  // Check permission
  LocationPermission permission = await Geolocator.checkPermission();

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      throw LocationException('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    throw LocationException('Location permissions are permanently denied');
  }

  // Get current position
  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
});

// Custom exception for location errors
class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => message;
}