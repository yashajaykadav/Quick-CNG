import 'package:flutter/material.dart';
import 'package:quickcng/screens/admin/widgets/process_request.dart';

Future<void> confirmAction(
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
    await processRequest(
      context,
      requestId,
      userId,
      status,
      role: role,
      stationId: stationId,
    );
  }
}
