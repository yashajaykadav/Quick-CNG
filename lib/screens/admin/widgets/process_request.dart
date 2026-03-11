import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


  Future<void> processRequest(
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