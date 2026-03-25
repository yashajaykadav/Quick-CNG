import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcng/models/station.dart';
import 'package:quickcng/screens/report/helper/_availability_section.dart';
import 'package:quickcng/screens/report/helper/report_dialogs.dart';
import 'package:quickcng/screens/report/report_controller.dart';
import 'package:quickcng/screens/report/widgets/report_submit_button.dart';
import 'package:quickcng/screens/report/widgets/traffic_selector.dart';

class ReportScreen extends ConsumerWidget {
  final Station station;
  const ReportScreen({super.key, required this.station});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportControllerProvider);
    final controller = ref.read(reportControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Report Status')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            station.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          AvailabilitySection(state: state, controller: controller),
          if (state.isAvailable)
            TrafficSelector(
              selectedTraffic: state.selectedTraffic,
              onTrafficSelected: controller.updateTraffic,
            ),
          const SizedBox(height: 40),
          ReportSubmitButton(
            isSubmitting: state.isSubmitting,
            isDisabled: state.isAvailable && state.selectedTraffic == null,
            onPressed: () => controller.submitReport(
              station: station,
              onNotify: (msg, {isError = false}) =>
                  ReportDialogs.showSnackBar(context, msg, isError: isError),
              onConfirm: () => ReportDialogs.showConfirm(context, state),
              onDistanceWarning: () =>
                  ReportDialogs.showDistanceWarning(context),
              onSuccess: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
