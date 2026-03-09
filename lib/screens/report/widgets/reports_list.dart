import 'package:flutter/material.dart';
import 'package:quickcng/models/report.dart';
import 'package:quickcng/screens/report/widgets/report_tile.dart';

class ReportsList extends StatelessWidget {
  final List<Report> reports;

  const ReportsList({
    super.key,
    required this.reports,
  });

  @override
  Widget build(BuildContext context) {
    if (reports.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 48,
                color: Colors.grey,
              ),
              SizedBox(height: 12),
              Text(
                'No reports yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Be the first to report!',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final sortedReports = [...reports]
      ..sort((a, b) => (b.isVerified ? 1 : 0).compareTo(a.isVerified ? 1 : 0));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: sortedReports
            .map((report) => ReportTile(report: report))
            .toList(),
      ),
    );
  }
}