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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      // ✅ Adaptive Background (Pure black for AMOLED)
      backgroundColor: theme.scaffoldBackgroundColor,
      body: stationAsync.when(
        loading: () => const Center(child: LoadingWidget()),
        error: (err, _) =>
            Center(child: ErrorStateWidget(error: err.toString())),
        data: (station) {
          if (station == null) {
            return const StationNotFoundWidget();
          }

          return CustomScrollView(
            slivers: [
              // ✅ Adaptive SliverAppBar
              SliverAppBar(
                expandedHeight: 0,
                pinned: true,
                backgroundColor: theme.appBarTheme.backgroundColor,
                foregroundColor: theme.appBarTheme.foregroundColor,
                elevation: 0,
                title: const Text(
                  "Station Details",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                centerTitle: true,
              ),

              // Content body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HeaderCard(station: station),
                      const SizedBox(height: 16),
                      VisualWaitMeter(traffic: station.traffic),
                      const SizedBox(height: 16),
                      AddressSection(station: station),
                      const SizedBox(height: 24),
                      const ReportsHeader(),
                      const SizedBox(height: 8),

                      // Loading state for reports
                      reportsAsync.maybeWhen(
                        data: (reports) => ReportsList(reports: reports),
                        orElse: () => Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: CircularProgressIndicator(
                              color: isDark
                                  ? Colors.green[400]
                                  : const Color(0xFF1FAF5A),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),

      // ✅ Adaptive Fixed Bottom Bar
      bottomNavigationBar: stationAsync.maybeWhen(
        data: (station) {
          if (station == null) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withAlpha(20)
                      : Colors.grey.shade200,
                ),
              ),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 10,
                        offset: const Offset(0, -4),
                      ),
                    ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReportScreen(station: station),
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE07B00), // Action orange
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.edit_note_rounded, size: 22),
                  label: const Text(
                    "Submit Update",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          );
        },
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }
}

class StationNotFoundWidget extends StatelessWidget {
  const StationNotFoundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Station Not Found"), elevation: 0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.hintColor.withAlpha(20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.local_gas_station_outlined,
                  size: 64,
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Station Missing',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'This station may have been removed or the link is invalid.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Go Back'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
