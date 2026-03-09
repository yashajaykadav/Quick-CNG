import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickcng/providers/report_provider.dart';
import 'package:quickcng/providers/station_provider.dart';
import 'package:quickcng/screens/report/report_screen.dart';
import 'package:quickcng/screens/report/widgets/report_header.dart';
import 'package:quickcng/screens/report/widgets/reports_list.dart';
import 'package:quickcng/screens/station_detail/widgets/header_card.dart';
import 'package:quickcng/screens/station_detail/widgets/visual_meter.dart';
import 'package:quickcng/widgets/common/error_widget.dart';
import 'package:quickcng/widgets/common/loading_widget.dart';
import 'package:quickcng/screens/station_detail/widgets/address_section.dart';

class StationDetailScreen extends ConsumerWidget {
  final String stationId;

  const StationDetailScreen({super.key, required this.stationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stationAsync = ref.watch(stationByIdProvider(stationId));
    final reportsAsync = ref.watch(stationReportsProvider(stationId));

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text("Station Details"),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone),
            onPressed: () {},
          ),
        ],
      ),

      body: stationAsync.when(
        loading: () => const LoadingWidget(),

        error: (err, _) =>
            ErrorStateWidget(error: err.toString()),

        data: (station) {
          if (station == null) {
            return const StationNotFoundWidget();
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                HeaderCard(station: station),

                const Divider(height: 1),

                VisualWaitMeter(traffic: station.traffic),

                const SizedBox(height: 12),

                AddressSection(station: station),

                const SizedBox(height: 20),

                const ReportsHeader(),

                reportsAsync.maybeWhen(
                  data: (reports) =>
                      ReportsList(reports: reports),

                  orElse: () =>
                  const CircularProgressIndicator(),
                ),

                const SizedBox(height: 120),
              ],
            ),
          );
        },
      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerFloat,

      floatingActionButton: stationAsync.maybeWhen(
        data: (station) {
          if (station == null) return null;

          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ReportScreen(station: station),
                ),
              );
            },
            backgroundColor: Colors.green[700],
            icon: const Icon(
              Icons.mark_unread_chat_alt_outlined,
              size: 28,
            ),
            label: const Text(
              "Report",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        },
        orElse: () => null,
      ),
    );
  }
  }
// Station Not Found Widget
class StationNotFoundWidget extends StatelessWidget {
  const StationNotFoundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.local_gas_station_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'Station Not Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This station may have been removed or doesn\'t exist',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}