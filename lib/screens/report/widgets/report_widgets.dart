import 'package:flutter/material.dart';

import '../../../models/station.dart';

class ReportStationHeader extends StatelessWidget {
  final Station station;
  const ReportStationHeader({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.local_gas_station, color: Colors.green[700], size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Current status: ${station.status}',
                  style: TextStyle(color: Colors.green[600], fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TrafficOptionList extends StatelessWidget {
  final String selectedLabel;
  final Function(String) onChanged;

  const TrafficOptionList({
    super.key,
    required this.selectedLabel,
    required this.onChanged,
  });

  static const List<Map<String, dynamic>> options = [
    {
      'label': 'Low',
      'icon': Icons.sentiment_satisfied_alt,
      'color': Colors.green,
      'desc': 'Quick fill-up',
    },
    {
      'label': 'Normal',
      'icon': Icons.sentiment_neutral,
      'color': Colors.orange,
      'desc': 'Moderate queue',
    },
    {
      'label': 'High',
      'icon': Icons.sentiment_dissatisfied,
      'color': Colors.red,
      'desc': 'Long wait time',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((opt) {
        final isSelected = selectedLabel == opt['label'];
        final color = opt['color'] as Color;
        return GestureDetector(
          onTap: () => onChanged(opt['label']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? color.withAlpha(250) : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? color : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  opt['icon'],
                  color: isSelected ? color : Colors.grey[400],
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opt['label'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isSelected ? color : Colors.grey[700],
                        ),
                      ),
                      Text(
                        opt['desc'],
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? color : Colors.grey[300],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class SubmitReportButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback? onPressed;

  const SubmitReportButton({
    super.key,
    required this.isSubmitting,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isSubmitting ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Submit Report',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}

class TrafficQuestionHeader extends StatelessWidget {
  const TrafficQuestionHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How is the traffic right now?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        Text(
          'Select the current traffic level at this station',
          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
        ),
      ],
    );
  }
}
