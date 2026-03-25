import 'package:flutter/material.dart';
import 'package:quickcng/screens/report/report_state.dart';

class ReportDialogs {
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  static Future<bool> showConfirm(
    BuildContext context,
    ReportState state,
  ) async {
    final queueText = state.isAvailable
        ? 'Queue: ${state.selectedTraffic?.displayName}\n'
        : '';
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirm Report'),
            content: Text(
              'Availability: ${state.isAvailable ? "Available" : "Not Available"}\n$queueText',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Edit'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  static Future<bool> showDistanceWarning(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Location Warning'),
            content: const Text('You appear far from this station. Proceed?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Proceed'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
