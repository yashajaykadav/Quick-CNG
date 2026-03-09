import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:quickcng/providers/station_provider.dart';
import 'package:quickcng/screens/home/widgets/home_header.dart';
import 'package:quickcng/screens/home/widgets/home_states.dart';
import 'package:quickcng/screens/home/widgets/station_list_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers
    final stationsAsync = ref.watch(stationsWithDistanceProvider);
    final filteredStations = ref.watch(filteredStationsProvider);
    final selectedFilter = ref.watch(stationFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(
              onSearch: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),

            // Filter chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: StationFilter.values.map((filter) {
                  final isSelected = selectedFilter == filter;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(_getFilterLabel(filter)),
                      selected: isSelected,
                      selectedColor: Colors.green.withAlpha(35),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.green : Colors.grey[700],
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(stationFilterProvider.notifier).state =
                              filter;
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),

            // Station list
            Expanded(
              child: stationsAsync.when(
                loading: () => const HomeLoadingState(),
                error: (err, stack) => HomeErrorState(
                  error: err.toString(),
                  onRetry: () {
                    ref.invalidate(stationsWithDistanceProvider);
                  },
                ),
                data: (_) {
                  if (filteredStations.isEmpty) {
                    return HomeEmptyState(
                      searchQuery: ref.watch(searchQueryProvider),
                      onClearSearch: () {
                        ref.read(searchQueryProvider.notifier).state = '';
                        ref.read(stationFilterProvider.notifier).state =
                            StationFilter.all;
                      },
                    );
                  }

                  return StationListView(
                    stations: filteredStations,
                    onNavigateToDetail: (id) {
                      context.pushNamed('details', pathParameters: {'id': id});
                    },
                    onNavigateToReport: (station) {
                      context.pushNamed('report', extra: station);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper to get filter display labels
  String _getFilterLabel(StationFilter filter) {
    switch (filter) {
      case StationFilter.all:
        return 'All';
      case StationFilter.radius1km:
        return '1 km';
      case StationFilter.radius3km:
        return '3 km';
      case StationFilter.radius5km:
        return '5 km';
      case StationFilter.radius10km:
        return '10 km';
    }
  }
}
