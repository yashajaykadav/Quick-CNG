import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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

// Add a state to manage if we have more stations to load
final hasMoreStationsProvider = StateProvider<bool>((ref) => true);

class StationListNotifier extends AsyncNotifier<List<Station>> {
  DocumentSnapshot? _lastVisible;
  bool _hasMore = true;

  @override
  Future<List<Station>> build() async {
    return _fetchStations(limit: 20);
  }

  Future<List<Station>> _fetchStations({required int limit}) async {
    var query = FirebaseFirestore.instance
        .collection('cng_stations')
        .orderBy('updatedAt', descending: true)
        .limit(limit);

    if (_lastVisible != null) {
      query = query.startAfterDocument(_lastVisible!);
    }

    final snapshot = await query.get();

    if (snapshot.docs.isNotEmpty) {
      _lastVisible = snapshot.docs.last;
    }

    if (snapshot.docs.length < limit) {
      _hasMore = false;
    }
    
    // Update the provider state asynchronously so the UI can know if it can load more
    ref.read(hasMoreStationsProvider.notifier).state = _hasMore;

    return snapshot.docs
        .map((doc) => Station.fromMap(doc.id, doc.data()))
        .toList();
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    final currentList = state.value ?? [];

    try {
      final newStations = await _fetchStations(limit: 20);
      state = AsyncValue.data([...currentList, ...newStations]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final stationListProvider =
    AsyncNotifierProvider<StationListNotifier, List<Station>>(() {
  return StationListNotifier();
});

// Helper for compute to calculate distances off the main thread
List<Station> _calculateDistances(Map<String, dynamic> params) {
  final stations = params['stations'] as List<Station>;
  final latitude = params['latitude'] as double;
  final longitude = params['longitude'] as double;

  return stations.map((station) {
    final distance = Geolocator.distanceBetween(
      latitude,
      longitude,
      station.latitude,
      station.longitude,
    ) / 1000; // Convert to km

    return station.copyWith(distance: distance);
  }).toList();
}

// Stations with distance calculated
final stationsWithDistanceProvider = FutureProvider<List<Station>>((ref) async {
  final stationsAsync = ref.watch(stationListProvider);
  final locationAsync = ref.watch(userLocationProvider);

  if (stationsAsync.value == null || locationAsync.value == null) {
    // If we're loading or have no data yet, returning what we have via AsyncValue handling
    if (stationsAsync.value != null) return stationsAsync.value!;
    return [];
  }

  final stations = stationsAsync.value!;
  final position = locationAsync.value!;

  // Offload heavy math to a background isolate
  return await compute(_calculateDistances, {
    'stations': stations,
    'latitude': position.latitude,
    'longitude': position.longitude,
  });
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
    error: (error, stack) => [],
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