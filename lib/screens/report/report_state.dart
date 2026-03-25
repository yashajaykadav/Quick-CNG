import '../../models/enums.dart';

class ReportState {
  final TrafficLevel? selectedTraffic;
  final bool isAvailable;
  final bool isSubmitting;

  ReportState({
    this.selectedTraffic,
    this.isAvailable = true,
    this.isSubmitting = false,
  });

  ReportState copyWith({
    TrafficLevel? selectedTraffic,
    bool? isAvailable,
    bool? isSubmitting,
  }) {
    return ReportState(
      selectedTraffic: selectedTraffic ?? this.selectedTraffic,
      isAvailable: isAvailable ?? this.isAvailable,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}
