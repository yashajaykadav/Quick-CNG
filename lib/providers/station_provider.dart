import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quickcng/models/station.dart';
import 'package:quickcng/providers/location_provider.dart';

// Filter options
enum StationFilter { all, radius1km, radius3km, radius5km, radius10km }

// Search query state
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filter state
final stationFilterProvider = StateProvider<StationFilter>((ref) {
  return StationFilter.all;
});

// Add a state to manage how many stations we've lazy-loaded
final stationFetchLimitProvider = StateProvider<int>((ref) => 20);

// All stations stream from Firestore (Lazy Loaded)
final stationsStreamProvider = StreamProvider<List<Station>>((ref) {
  final fetchLimit = ref.watch(stationFetchLimitProvider);
  
  return FirebaseFirestore.instance
      .collection('cng_stations')
      .orderBy('updatedAt', descending: true)
      .limit(fetchLimit)
      .snapshots()
      .map((snapshot) => snapshot.docs
      .map((doc) => Station.fromMap(doc.id, doc.data()))
      .toList());
});

// Stations with distance calculated
final stationsWithDistanceProvider = Provider<AsyncValue<List<Station>>>((ref) {
  final stationsAsync = ref.watch(stationsStreamProvider);
  final locationAsync = ref.watch(userLocationProvider);

  return stationsAsync.when(
    data: (stations) {
      return locationAsync.when(
        data: (position) {
          // Calculate distance for each station
          final stationsWithDistance = stations.map((station) {
            final distance = Geolocator.distanceBetween(
              position.latitude,
              position.longitude,
              station.latitude,  // Fixed: was station.lat
              station.longitude, // Fixed: was station.lng
            ) / 1000; // Convert to km

            return station.copyWith(distance: distance);
          }).toList();

          return AsyncValue.data(stationsWithDistance);
        },
        loading: () => AsyncValue.data(stations),
        error: (error, stack) => AsyncValue.data(stations), // Fixed: was (_, _)
      );
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Filtered stations based on search and filter
final filteredStationsProvider = Provider<List<Station>>((ref) {
  final filter = ref.watch(stationFilterProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final stationsAsync = ref.watch(stationsWithDistanceProvider);

  return stationsAsync.when(
    data: (stations) {
      // Apply search filter
      List<Station> filtered = stations.where((station) {
        if (query.isEmpty) return true;

        return station.name.toLowerCase().contains(query) ||
            station.address.toLowerCase().contains(query) ||
            station.provider.toLowerCase().contains(query) ||
            station.city.toLowerCase().contains(query) ||
            station.district.toLowerCase().contains(query);
      }).toList();

      // Apply distance filter and sorting
      double maxDistance = double.infinity;
      switch (filter) {
        case StationFilter.radius1km:
          maxDistance = 1.0;
          break;
        case StationFilter.radius3km:
          maxDistance = 3.0;
          break;
        case StationFilter.radius5km:
          maxDistance = 5.0;
          break;
        case StationFilter.radius10km:
          maxDistance = 10.0;
          break;
        case StationFilter.all:
          maxDistance = double.infinity;
          break;
      }

      if (filter != StationFilter.all) {
        filtered = filtered
            .where((s) => (s.distance ?? double.infinity) <= maxDistance)
            .toList();
      }

      // Always sort by distance
      filtered.sort((a, b) => (a.distance ?? double.infinity)
          .compareTo(b.distance ?? double.infinity));

      return filtered;
    },
    loading: () => [],
    error: (error, stack) => [], // Fixed: was (_, _)
  );
});

// Single station by ID
final stationByIdProvider = StreamProvider.family<Station?, String>((ref, stationId) {
  return FirebaseFirestore.instance
      .collection('cng_stations')
      .doc(stationId)
      .snapshots()
      .map((doc) {
    if (!doc.exists || doc.data() == null) return null;
    return Station.fromMap(doc.id, doc.data()!);
  });
});

// // Stations count
// final stationsCountProvider = Provider<int>((ref) {
//   final stations = ref.watch(filteredStationsProvider);
//   return stations.length;
// });

// // Available stations count
// final availableStationsCountProvider = Provider<int>((ref) {
//   final stationsAsync = ref.watch(stationsStreamProvider);

//   return stationsAsync.when(
//     data: (stations) => stations
//         .where((s) => s.status == StationStatus.available)
//         .length,
//     loading: () => 0,
//     error: (error, stack) => 0, // Fixed: was (_, _)
//   );
// });

// // Provider to get calculated status for a station
// final stationCalculatedStatusProvider = Provider.family<StationStatusResult, String>(
//       (ref, stationId) {
//     final reports = ref.watch(stationReportsProvider(stationId)).value ?? [];
//     return ReportEngine.calculateStatus(reports);
//   },
// );

// // Stations by city
// final stationsByCityProvider = StreamProvider.family<List<Station>, String>(
//       (ref, city) {
//     return FirebaseFirestore.instance
//         .collection('cng_stations')
//         .where('city', isEqualTo: city)
//         .orderBy('updatedAt', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//         .map((doc) => Station.fromMap(doc.id, doc.data()))
//         .toList());
//   },
// );

// // Stations by state
// final stationsByStateProvider = StreamProvider.family<List<Station>, String>(
//       (ref, state) {
//     return FirebaseFirestore.instance
//         .collection('cng_stations')
//         .where('state', isEqualTo: state)
//         .orderBy('updatedAt', descending: true)
//         .snapshots()
//         .map((snapshot) => snapshot.docs
//         .map((doc) => Station.fromMap(doc.id, doc.data()))
//         .toList());
//   },
// );

// // Get unique cities from stations
// final availableCitiesProvider = Provider<List<String>>((ref) {
//   final stationsAsync = ref.watch(stationsStreamProvider);

//   return stationsAsync.when(
//     data: (stations) {
//       final cities = stations.map((s) => s.city).toSet().toList();
//       cities.sort();
//       return cities;
//     },
//     loading: () => [],
//     error: (error, stack) => [],
//   );
// });

// Get unique states from stations
// final availableStatesProvider = Provider<List<String>>((ref) {
//   final stationsAsync = ref.watch(stationsStreamProvider);

//   return stationsAsync.when(
//     data: (stations) {
//       final states = stations.map((s) => s.state).toSet().toList();
//       states.sort();
//       return states;
//     },
//     loading: () => [],
//     error: (error, stack) => [],
//   );
// });