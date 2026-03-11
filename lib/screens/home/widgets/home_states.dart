import 'package:flutter/material.dart';

// ─────────────────────────────────────────
//  Loading State — Skeleton cards
// ─────────────────────────────────────────
class HomeLoadingState extends StatefulWidget {
  const HomeLoadingState({super.key});

  @override
  State<HomeLoadingState> createState() => _HomeLoadingStateState();
}

class _HomeLoadingStateState extends State<HomeLoadingState>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 4,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => AnimatedBuilder(
        animation: _animation,
        builder: (_, _) =>
            Opacity(opacity: _animation.value, child: _SkeletonCard()),
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status banner skeleton
          _SkeletonBox(height: 44, radius: 12, width: double.infinity),
          const SizedBox(height: 12),
          // Name row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(height: 16, radius: 6, width: 200),
                    const SizedBox(height: 6),
                    _SkeletonBox(height: 12, radius: 6, width: 130),
                  ],
                ),
              ),
              _SkeletonBox(height: 48, radius: 10, width: 56),
            ],
          ),
          const SizedBox(height: 14),
          // Pill row
          Row(
            children: [
              _SkeletonBox(height: 28, radius: 20, width: 110),
              const SizedBox(width: 8),
              _SkeletonBox(height: 28, radius: 20, width: 120),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),
          // Bottom row
          Row(
            children: [
              _SkeletonBox(height: 12, radius: 6, width: 100),
              const Spacer(),
              _SkeletonBox(height: 34, radius: 10, width: 100),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double radius;
  final double width;

  const _SkeletonBox({
    required this.height,
    required this.radius,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Error State
// ─────────────────────────────────────────
class HomeErrorState extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;

  const HomeErrorState({super.key, required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withAlpha(18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 52,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Couldn't load stations",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please check your internet connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1FAF5A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  Empty State
// ─────────────────────────────────────────
class HomeEmptyState extends StatelessWidget {
  final String? searchQuery;
  final VoidCallback? onClearSearch;

  const HomeEmptyState({super.key, this.searchQuery, this.onClearSearch});

  @override
  Widget build(BuildContext context) {
    final hasSearch = searchQuery != null && searchQuery!.isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasSearch
                    ? Icons.search_off_rounded
                    : Icons.local_gas_station_outlined,
                size: 52,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              hasSearch ? 'No stations found' : 'No stations nearby',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasSearch
                  ? 'We couldn\'t find "${searchQuery!}". Try a different station name or city.'
                  : 'Try increasing the search distance using the filter above.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF888888)),
            ),
            if (hasSearch && onClearSearch != null) ...[
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onClearSearch,
                  icon: const Icon(Icons.clear_rounded),
                  label: const Text(
                    'Clear Search',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1FAF5A),
                    side: const BorderSide(
                      color: Color(0xFF1FAF5A),
                      width: 1.5,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
