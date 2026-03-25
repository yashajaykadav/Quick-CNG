import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcng/models/report.dart';
import 'package:quickcng/providers/report_provider.dart';
import 'package:quickcng/utils/helpers.dart';

class MyReportsScreen extends ConsumerWidget {
  const MyReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(userReportsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'My Reports',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      // ✅ Wrap the body in RefreshIndicator
      body: RefreshIndicator(
        // AMOLED Styling for the spinner
        color: Colors.green,
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        onRefresh: () async {
          // ✅ This tells Riverpod to re-fetch the data
          return ref.refresh(userReportsProvider);
        },
        child: reportsAsync.when(
          data: (reports) {
            if (reports.isEmpty) {
              // Note: Empty state must be scrollable for Pull-to-Refresh to work
              return const _EmptyReportsScrollable();
            }

            return ListView.builder(
              // AlwaysScrollableScrollPhysics ensures pull-to-refresh works
              // even if the list doesn't fill the screen.
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: reports.length,
              itemBuilder: (context, index) =>
                  _ReportCard(report: reports[index]),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Center(child: Text('Error: $error')),
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends ConsumerWidget {
  final Report report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ✅ AMOLED Card Background
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        // ✅ Border definition for AMOLED depth
        border: isDark
            ? Border.all(color: Colors.white.withAlpha(20), width: 1)
            : Border.all(color: Colors.black.withAlpha(5), width: 1),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.stationName ?? 'Unknown Station',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatTimestamp(report.createdAt),
                      style: TextStyle(fontSize: 12, color: theme.hintColor),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red[isDark ? 300 : 700],
                  size: 22,
                ),
                onPressed: () => _showDeleteDialog(context, ref, isDark),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: theme.dividerColor.withAlpha(50)),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatusBadge(
                label: report.isAvailable ? 'Available' : 'Unavailable',
                color: report.isAvailable
                    ? (isDark ? Colors.green[300]! : Colors.green[700]!)
                    : (isDark ? Colors.red[300]! : Colors.red[700]!),
                icon: report.isAvailable ? Icons.check_circle : Icons.cancel,
              ),
              const SizedBox(width: 8),
              _StatusBadge(
                label: report.traffic.displayName,
                color: isDark
                    ? _getDarkTrafficColor(report.traffic)
                    : report.traffic.color,
                icon: Icons.traffic,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isDark
              ? BorderSide(color: Colors.white.withAlpha(20))
              : BorderSide.none,
        ),
        title: const Text('Delete Report'),
        content: const Text('Are you sure you want to delete this report?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(deleteReportProvider)(report.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Color _getDarkTrafficColor(dynamic traffic) {
    // Logic to return [300] variants for dark mode
    return Colors.green[300]!;
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(isDark ? 40 : 25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyReportsScrollable extends StatelessWidget {
  const _EmptyReportsScrollable();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      // This is the secret sauce to make it pullable
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7, // Fill most of screen
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_late_outlined,
              size: 64,
              color: theme.hintColor.withAlpha(100),
            ),
            const SizedBox(height: 16),
            const Text(
              'No reports yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Pull down to refresh or submit a report.',
              style: TextStyle(color: theme.hintColor),
            ),
          ],
        ),
      ),
    );
  }
}
