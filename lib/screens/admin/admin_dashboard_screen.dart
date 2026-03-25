import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcng/providers/verification_provider.dart';
import 'package:quickcng/screens/admin/widgets/app_bar.dart';
import 'package:quickcng/screens/admin/widgets/request_card.dart';
import 'package:quickcng/widgets/common/empty_state_widget.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(pendingVerificationRequestsProvider);
    final theme = Theme.of(context);
    // final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // ✅ Adaptive Background (Pure Black for AMOLED)
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          appBar(
            context,
          ), // Assuming appBar widget is updated to be theme-aware

          SliverToBoxAdapter(child: _header(theme)),

          requestsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),

            error: (err, _) => _errorState(err.toString(), theme),

            data: (requests) {
              if (requests.isEmpty) {
                return const SliverFillRemaining(child: EmptyStateWidget());
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final request = requests[index];
                    // Ensure buildRequestCard uses theme.cardTheme.color inside
                    return buildRequestCard(context, request.id, request);
                  }, childCount: requests.length),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _header(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        children: [
          Icon(
            Icons.pending_actions,
            color: theme.brightness == Brightness.dark
                ? Colors.blueGrey[200]
                : Colors.blueGrey,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'Pending Verifications',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _errorState(String error, ThemeData theme) {
    return SliverFillRemaining(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, color: Colors.red[400], size: 56),
              const SizedBox(height: 16),
              Text(
                'Failed to load requests',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.contains('FAILED_PRECONDITION') || error.contains('index')
                    ? 'A Firestore index is required. Check the debug console for a link to create it.'
                    : error,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
