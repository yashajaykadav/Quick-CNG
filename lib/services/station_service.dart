import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:quickcng/models/station.dart';

class StationService {
  static const String baseUrl = "https://backend.yashkadav52.workers.dev";

  Future<void> updateStationStatus(String stationId) async {
    final response = await http.get(Uri.parse("$baseUrl/stations/$stationId"));

    if (response.statusCode != 200) {
      throw Exception("Failed to sync station status from Worker");
    }
  }

  Future<List<Station>> fetchStationsWithDistance(Position userPosition) async {
    final response = await http.get(Uri.parse("$baseUrl/stations"));

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch stations from API");
    }

    final List data = jsonDecode(response.body);

    return data.map((json) {
      final station = Station.fromJson(json);

      final distanceKm =
          Geolocator.distanceBetween(
            userPosition.latitude,
            userPosition.longitude,
            station.latitude,
            station.longitude,
          ) /
          1000;

      return station.copyWith(distance: distanceKm);
    }).toList();
  }
}
