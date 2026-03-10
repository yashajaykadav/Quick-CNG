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

  // Use LocationSettings to resolve the deprecation warning
  const LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100, // Minimum distance (in meters) before an update is triggered
  );

  return await Geolocator.getCurrentPosition(locationSettings: locationSettings);
});

// Custom exception for location errors
class LocationException implements Exception {
  final String message;
  LocationException(this.message);

  @override
  String toString() => message;
}