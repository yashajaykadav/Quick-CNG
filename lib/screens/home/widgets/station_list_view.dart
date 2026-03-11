import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcng/models/station.dart';
import 'package:quickcng/screens/home/widgets/station_card.dart';
import 'package:quickcng/providers/station_provider.dart';

class StationListView extends ConsumerStatefulWidget {
  final List<Station> stations;

  /// Callback when navigating to station details
  final void Function(String stationId) onNavigateToDetail;

  /// Callback when navigating to report screen
  final void Function(Station station) onNavigateToReport;

  const StationListView({
    super.key,
    required this.stations,
    required this.onNavigateToDetail,
    required this.onNavigateToReport,
  });

  @override
  ConsumerState<StationListView> createState() => _StationListViewState();
}

class _StationListViewState extends ConsumerState<StationListView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Load more when user scrolls near the bottom edge
    if (currentScroll >= maxScroll - 200) {
      final hasMore = ref.read(hasMoreStationsProvider);
      if (hasMore) {
        ref.read(stationListProvider.notifier).loadMore();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stations.isEmpty) {
      return const Center(child: Text("No stations found in range."));
    }

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      // Add +1 for the optional loading indicator at the bottom
      itemCount: widget.stations.length + 1, 
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == widget.stations.length) {
          // Bottom loading indicator logic
          final hasMore = ref.watch(hasMoreStationsProvider);
          final isLoading = ref.watch(stationListProvider).isLoading;
          
          if (hasMore || isLoading) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(color: Colors.green, strokeWidth: 2),
                ),
              ),
            );
          } else {
            // Reached the end of the Firestore database query entirely!
            return const SizedBox.shrink(); 
          }
        }

        final station = widget.stations[index];

        return StationCard(
          station: station,
          onTap: () => widget.onNavigateToDetail(station.id),
          onReport: () => widget.onNavigateToReport(station),
        );
      },
    );
  }
}
