import 'package:flutter/material.dart';
import 'package:quickcng/screens/report/report_controller.dart';
import 'package:quickcng/screens/report/report_state.dart';
import 'package:quickcng/screens/report/widgets/availability_button.dart';

class AvailabilitySection extends StatelessWidget {
  final ReportState state;
  final ReportController controller;

  const AvailabilitySection({
    super.key,
    required this.state,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CNG Availability',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: AvailabilityButton(
                label: 'Available',
                icon: Icons.check_circle,
                color: Colors.green,
                isSelected: state.isAvailable,
                onTap: () => controller.updateAvailability(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AvailabilityButton(
                label: 'Not Available',
                icon: Icons.cancel,
                color: Colors.red,
                isSelected: !state.isAvailable,
                onTap: () => controller.updateAvailability(false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
