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
    final stationsAsync = ref.watch(stationsWithDistanceProvider);
    final filteredStations = ref.watch(filteredStationsProvider);
    final selectedFilter = ref.watch(stationFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ── HEADER ──
            HomeHeader(
              onSearch: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),

            /// ── FILTER CHIPS (distance radius) ──
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Show stations within:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF888888),
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: StationFilter.values.map((filter) {
                        final isSelected = selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _FilterChip(
                            label: _getFilterLabel(filter),
                            icon: _getFilterIcon(filter),
                            isSelected: isSelected,
                            onTap: () {
                              ref.read(stationFilterProvider.notifier).state =
                                  filter;
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            /// ── RESULT COUNT ──
            stationsAsync.whenData((_) {
              if (filteredStations.isNotEmpty) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    '${filteredStations.length} station${filteredStations.length == 1 ? '' : 's'} found',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF555555),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }).value ??
                const SizedBox.shrink(),

            /// ── STATION LIST ──
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
                      context.pushNamed('details',
                          pathParameters: {'id': id});
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

  IconData _getFilterIcon(StationFilter filter) {
    switch (filter) {
      case StationFilter.all:
        return Icons.public;
      case StationFilter.radius1km:
        return Icons.near_me;
      case StationFilter.radius3km:
        return Icons.near_me;
      case StationFilter.radius5km:
        return Icons.near_me;
      case StationFilter.radius10km:
        return Icons.near_me;
    }
  }
}

// ── Custom Filter Chip ──

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1FAF5A) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1FAF5A)
                : const Color(0xFFDDDDDD),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF1FAF5A).withAlpha(60),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : const Color(0xFF888888),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
                color:
                    isSelected ? Colors.white : const Color(0xFF555555),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
