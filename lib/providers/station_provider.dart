import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quickcng/models/station.dart';
import 'package:quickcng/providers/location_provider.dart';
import 'package:quickcng/services/station_api_service.dart';

/// ----------------------------
/// Filter options
/// ----------------------------
enum StationFilter { all, radius1km, radius3km, radius5km, radius10km }

/// ----------------------------
/// Search query
/// ----------------------------
final searchQueryProvider = StateProvider<String>((ref) => '');

/// ----------------------------
/// Radius filter
/// ----------------------------
final stationFilterProvider =
    StateProvider<StationFilter>((ref) => StationFilter.all);

/// ----------------------------
/// Pagination state
/// ----------------------------
final hasMoreStationsProvider = StateProvider<bool>((ref) => true);

/// ----------------------------
/// API Provider
/// ----------------------------
final stationApiProvider = Provider((ref) => StationApiService());

/// ----------------------------
/// Station List Notifier
/// ----------------------------
class StationListNotifier extends AsyncNotifier<List<Station>> {
  int _offset = 0;
  bool _hasMore = true;

  @override
  Future<List<Station>> build() async {
    return _fetchStations(limit: 20);
  }

  Future<List<Station>> _fetchStations({required int limit}) async {
    final api = ref.read(stationApiProvider);

    final stations = await api.getStations(limit, _offset);

    _offset += limit;

    if (stations.length < limit) {
      _hasMore = false;
    }

    ref.read(hasMoreStationsProvider.notifier).state = _hasMore;

    return stations;
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading) return;

    final currentStations = state.value ?? [];

    try {
      final newStations = await _fetchStations(limit: 20);

      state = AsyncValue.data([
        ...currentStations,
        ...newStations,
      ]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  /// Pull-to-refresh support
  Future<void> refresh() async {
    _offset = 0;
    _hasMore = true;
    state = const AsyncLoading();
    state = AsyncValue.data(await _fetchStations(limit: 20));
  }
}

/// ----------------------------
/// Station List Provider
/// ----------------------------
final stationListProvider =
    AsyncNotifierProvider<StationListNotifier, List<Station>>(
        StationListNotifier.new);

/// ----------------------------------------------------------
/// Background isolate distance calculation
/// ----------------------------------------------------------
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
        ) /
        1000;

    return station.copyWith(distance: distance);
  }).toList();
}

/// ----------------------------------------------------------
/// Stations with distance
/// ----------------------------------------------------------
final stationsWithDistanceProvider = FutureProvider<List<Station>>((ref) async {
  final stationsAsync = ref.watch(stationListProvider);
  final locationAsync = ref.watch(userLocationProvider);

  if (stationsAsync.value == null || locationAsync.value == null) {
    if (stationsAsync.value != null) return stationsAsync.value!;
    return [];
  }

  final stations = stationsAsync.value!;
  final position = locationAsync.value!;

  return compute(_calculateDistances, {
    'stations': stations,
    'latitude': position.latitude,
    'longitude': position.longitude,
  });
});

/// ----------------------------------------------------------
/// Search + Radius Filtering
/// ----------------------------------------------------------
final filteredStationsProvider = Provider<List<Station>>((ref) {
  final filter = ref.watch(stationFilterProvider);
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();
  final stationsAsync = ref.watch(stationsWithDistanceProvider);

  return stationsAsync.when(
    data: (stations) {
      List<Station> filtered = stations.where((station) {
        if (query.isEmpty) return true;

        return station.name.toLowerCase().contains(query) ||
            station.address.toLowerCase().contains(query) ||
            station.provider.toLowerCase().contains(query) ||
            station.city.toLowerCase().contains(query) ||
            station.district.toLowerCase().contains(query);
      }).toList();

      double maxDistance = double.infinity;

      switch (filter) {
        case StationFilter.radius1km:
          maxDistance = 1;
          break;
        case StationFilter.radius3km:
          maxDistance = 3;
          break;
        case StationFilter.radius5km:
          maxDistance = 5;
          break;
        case StationFilter.radius10km:
          maxDistance = 10;
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

      filtered.sort((a, b) =>
          (a.distance ?? double.infinity).compareTo(b.distance ?? double.infinity));

      return filtered;
    },
    loading: () => [],
    error: (_, _) => [],
  );
});

/// ----------------------------------------------------------
/// Station by ID
/// ----------------------------------------------------------
final stationByIdProvider =
    FutureProvider.family<Station?, String>((ref, stationId) async {
  final api = ref.read(stationApiProvider);
  return api.getStation(stationId);
});