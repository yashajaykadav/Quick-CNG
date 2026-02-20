import '../models/station.dart';
import '../models/report.dart';

class StationDetailViewModel {

  void addReport(Station station, Report report) {
    station.reports.insert(0, report);
  }

  List<Report> getRecentReports(Station station) {
    return station.reports.take(3).toList();
  }

  String timeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);

    if (diff.inMinutes < 60) {
      return "${diff.inMinutes} min ago";
    } else if (diff.inHours < 24) {
      return "${diff.inHours} hr ago";
    } else {
      return "${diff.inDays} days ago";
    }
  }
}