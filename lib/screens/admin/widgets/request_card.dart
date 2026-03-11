import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quickcng/models/verification_request.dart';
import 'package:quickcng/screens/admin/widgets/confirmation_action.dart';
import 'package:quickcng/screens/admin/widgets/detail_row.dart';

Widget buildRequestCard(
  BuildContext context,
  String requestId,
  VerificationRequest request,
) {
  final String userId = request.userId;
  final String role = request.role.name;
  final String fullName = request.fullName;
  final String stationName = request.stationName;
  final String contact = request.contact;
  final DateTime createdAt = request.createdAt;

  final dateString = DateFormat('MMM d, yyyy • h:mm a').format(createdAt);

  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 3,
    shadowColor: Colors.black12,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
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
              role == 'owner' ? Icons.store_mall_directory : Icons.engineering,
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
              border: Border.all(color: Colors.grey.withAlpha(50)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                detailRow(Icons.phone, 'Contact', contact),
                const SizedBox(height: 12),
                detailRow(
                  Icons.badge,
                  'Requested Role',
                  role.toUpperCase(),
                  valueColor: role == 'owner'
                      ? Colors.purple[700]
                      : Colors.blue[700],
                ),

                if (request.stationId != null) ...[
                  const SizedBox(height: 12),
                  detailRow(
                    Icons.fingerprint,
                    'Station ID',
                    request.stationId!,
                    isMonospace: true,
                  ),
                ],

                if (request.documentUrl != null) ...[
                  const SizedBox(height: 12),
                  detailRow(
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
                        onPressed: () => confirmAction(
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
                        onPressed: () => confirmAction(
                          context,
                          requestId,
                          userId,
                          'approved',
                          fullName,
                          role: role,
                          stationId: request.stationId,
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
