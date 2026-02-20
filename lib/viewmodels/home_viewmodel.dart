import '../models/station.dart';
import '../models/report.dart';

class HomeViewModel {

  double userLat = 28.60;
  double userLng = 77.20;

  List<Station> stations = [
    Station(
      id: "1",
      name: "Main CNG Station",
      lat: 28.6139,
      lng: 77.2090,
      status: "Available",
      traffic: "Medium",
      updatedAt: DateTime.now(),
      reports: [
        Report(
          traffic: "High",
          isAvailable: true,
          time: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
      ],
    ),
  ];

  List<Station> getAllStations() {
    return stations;
  }

  List<Station> searchStations(String query) {
    return stations
        .where((station) =>
            station.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void sortByNearest(List<Station> list) {
    list.sort((a, b) {
      double distA = _calculateDistance(userLat, userLng, a.lat, a.lng);
      double distB = _calculateDistance(userLat, userLng, b.lat, b.lng);
      return distA.compareTo(distB);
    });
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    return ((lat1 - lat2) * (lat1 - lat2) +
        (lon1 - lon2) * (lon1 - lon2));
  }
}