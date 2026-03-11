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
      backgroundColor: const Color(0xFFF2F4F7), // Light grey background
      body: stationAsync.when(
        loading: () => const Center(child: LoadingWidget()),
        error: (err, _) => Center(child: ErrorStateWidget(error: err.toString())),
        data: (station) {
          if (station == null) {
            return const StationNotFoundWidget();
          }

          return CustomScrollView(
            slivers: [
              // Modern App Bar
              SliverAppBar(
                expandedHeight: 0,
                pinned: true,
                backgroundColor: Colors.white,
                elevation: 0,
                iconTheme: const IconThemeData(color: Colors.black87),
                title: const Text(
                  "Station Details",
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                centerTitle: true,
              ),

              // Content body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Header (Name, Status, Distance)
                      HeaderCard(station: station),
                      const SizedBox(height: 16),

                      // 2. Wait Time / Traffic
                      VisualWaitMeter(traffic: station.traffic),
                      const SizedBox(height: 16),

                      // 3. Location & Directions
                      AddressSection(station: station),
                      const SizedBox(height: 24),

                      // 4. Community Reports
                      const ReportsHeader(),
                      const SizedBox(height: 8),

                      reportsAsync.maybeWhen(
                        data: (reports) => ReportsList(reports: reports),
                        orElse: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(color: Color(0xFF1FAF5A)),
                          ),
                        ),
                      ),

                      // Bottom padding for FAB
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),

      // FAB for Reporting
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: stationAsync.maybeWhen(
        data: (station) {
          if (station == null) return null;

          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReportScreen(station: station),
                  ),
                );
              },
              backgroundColor: const Color(0xFFE07B00), // Orange for action
              elevation: 4,
              icon: const Icon(
                Icons.edit_note_rounded,
                size: 26,
                color: Colors.white,
              ),
              label: const Text(
                "Submit Update",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Station Not Found"),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_gas_station_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Station Missing',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'This station may have been removed or the link is invalid.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF888888),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text(
                    'Go Back',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1FAF5A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}