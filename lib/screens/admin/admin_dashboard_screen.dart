import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.pending_actions,
                    color: Colors.blueGrey,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Pending Verifications',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey[800],
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('verification_requests')
                .where('status', isEqualTo: 'pending')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading requests',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          snapshot.error.toString(),
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.green),
                  ),
                );
              }

              final requests = snapshot.data?.docs ?? [];

              if (requests.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.green.withAlpha(25),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 64,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          "All Caught Up!",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "There are no pending verification requests.",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final doc = requests[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _buildRequestCard(context, doc.id, data);
                  }, childCount: requests.length),
                ),
              );
            },
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: Colors.green[800],
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.go('/home'),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16, right: 20),
        title: const Text(
          'Admin Control Panel',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Colors.green[800]),
            Positioned(
              right: -50,
              top: -50,
              child: Icon(
                Icons.admin_panel_settings,
                size: 200,
                color: Colors.white.withAlpha(25),
              ),
            ),
            Positioned(
              left: 20,
              top: 60,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Super Admin',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestCard(
    BuildContext context,
    String requestId,
    Map<String, dynamic> data,
  ) {
    final String userId = data['userId'] ?? '';
    final String role = data['role'] ?? 'worker';
    final String fullName = data['fullName'] ?? "Unknown Name";
    final String stationName = data['stationName'] ?? "Unknown Station";
    final String contact = data['contact'] ?? "No Contact";
    final Timestamp? createdAt = data['createdAt'] as Timestamp?;

    final dateString = createdAt != null
        ? DateFormat('MMM d, yyyy • h:mm a').format(createdAt.toDate())
        : 'Unknown Date';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
          ),
          leading: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: role == 'owner'
                  ? Colors.purple.withAlpha(25)
                  : Colors.blue.withAlpha(25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                role == 'owner'
                    ? Icons.store_mall_directory
                    : Icons.engineering,
                color: role == 'owner' ? Colors.purple : Colors.blue,
                size: 28,
              ),
            ),
          ),
          title: Text(
            fullName,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      stationName,
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                dateString,
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
            ],
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(Icons.phone, 'Contact', contact),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.badge,
                    'Requested Role',
                    role.toUpperCase(),
                    valueColor: role == 'owner'
                        ? Colors.purple[700]
                        : Colors.blue[700],
                  ),
                  if (data['stationId'] != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.fingerprint,
                      'Station ID',
                      data['stationId'].toString(),
                      isMonospace: true,
                    ),
                  ],
                  if (data['documentsUrl'] != null) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.attach_file,
                      'Documents',
                      'View Attached Documents',
                      isLink: true,
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _confirmAction(
                            context,
                            requestId,
                            userId,
                            'rejected',
                            fullName,
                          ),
                          icon: const Icon(Icons.close, color: Colors.red),
                          label: const Text(
                            "Reject",
                            style: TextStyle(color: Colors.red),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _confirmAction(
                            context,
                            requestId,
                            userId,
                            'approved',
                            fullName,
                            role: role,
                            stationId: data['stationId'],
                          ),
                          icon: const Icon(Icons.check, color: Colors.white),
                          label: const Text(
                            "Approve",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[600],
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    bool isLink = false,
    bool isMonospace = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: isLink ? Colors.blue : (valueColor ?? Colors.black87),
                  fontWeight: isLink ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                  decoration: isLink
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  fontFamily: isMonospace ? 'monospace' : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmAction(
    BuildContext context,
    String requestId,
    String userId,
    String status,
    String userName, {
    String? role,
    String? stationId,
  }) async {
    final isApproval = status == 'approved';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isApproval ? Icons.check_circle : Icons.warning,
              color: isApproval ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              isApproval ? 'Approve Request' : 'Reject Request',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to ${isApproval ? 'approve' : 'reject'} the verification request for $userName?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isApproval ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(isApproval ? 'Yes, Approve' : 'Yes, Reject'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await _processRequest(
        context,
        requestId,
        userId,
        status,
        role: role,
        stationId: stationId,
      );
    }
  }

  // --- LOGIC: Batch update both collections ---
  Future<void> _processRequest(
    BuildContext context,
    String requestId,
    String userId,
    String status, {
    String? role,
    String? stationId,
  }) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final batch = FirebaseFirestore.instance.batch();

      // 1. Update the request document
      final requestRef = FirebaseFirestore.instance
          .collection('verification_requests')
          .doc(requestId);
      batch.update(requestRef, {
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. If approved, update the user's official role and stationId
      if (status == 'approved' && role != null) {
        final userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(userId);

        final Map<String, dynamic> userUpdates = {'role': role};
        if (stationId != null) {
          userUpdates['stationId'] = stationId;
        }

        batch.update(userRef, userUpdates);
      }

      await batch.commit();

      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'approved' ? 'Request verified.' : 'Request rejected.',
            ),
            backgroundColor: status == 'approved' ? Colors.green : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
