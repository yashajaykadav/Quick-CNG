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

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          appBar(context),

          SliverToBoxAdapter(child: _header()),

          requestsAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),

            error: (err, _) => _errorState(err.toString()),

            data: (requests) {
              if (requests.isEmpty) {
                return const SliverFillRemaining(child: EmptyStateWidget());
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final request = requests[index];
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
}

Widget _header() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
    child: Row(
      children: [
        const Icon(Icons.pending_actions, color: Colors.blueGrey, size: 28),
        const SizedBox(width: 12),
        Text(
          'Pending Verifications',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
          ),
        ),
      ],
    ),
  );
}

Widget _errorState(String error) {
  return SliverFillRemaining(
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, color: Colors.red, size: 56),
            const SizedBox(height: 16),
            const Text(
              'Failed to load requests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.contains('FAILED_PRECONDITION') || error.contains('index')
                  ? 'A Firestore index is required. Check the debug console for a link to create it.'
                  : error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ],
        ),
      ),
    ),
  );
}
