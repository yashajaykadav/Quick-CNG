import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcng/models/station.dart';
import 'package:quickcng/screens/home/widgets/station_card.dart';
import 'package:quickcng/providers/station_provider.dart';

class StationListView extends ConsumerStatefulWidget {
  final List<Station> stations;
  final void Function(String stationId) onNavigateToDetail;
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
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (currentScroll >= maxScroll - 200) {
      final hasMore = ref.read(hasMoreStationsProvider);
      final state = ref.read(stationListProvider);

      // Only load more if we aren't already loading
      if (hasMore && !state.isLoading) {
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ✅ Adaptive Empty State
    if (widget.stations.isEmpty) {
      return Center(
        child: Text(
          "No stations found in range.",
          style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(stationListProvider.notifier).refresh(),
      // Use the theme's primary color for the refresh spinner
      color: Colors.green,
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          100,
        ), // Extra bottom padding
        physics: const BouncingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: widget.stations.length + 1,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          // Bottom loading indicator
          if (index == widget.stations.length) {
            final isLoading = ref.watch(stationListProvider).isLoading;
            if (isLoading) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.green,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }

          final station = widget.stations[index];
          return StationCard(
            station: station,
            onTap: () => widget.onNavigateToDetail(station.id),
            onReport: () => widget.onNavigateToReport(station),
          );
        },
      ),
    );
  }
}
