import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/station.dart';

class StationApiService {
  // Replace with your actual Cloudflare Worker URL
  final String baseUrl = "https://backend.yashkadav52.workers.dev";

  /// Fetch list of stations with pagination
  Future<List<Station>> getStations(int limit, int offset) async {
    final response = await http.get(
      Uri.parse('$baseUrl/stations?limit=$limit&offset=$offset'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Station.fromJson(json)).toList();
    } else {
      throw Exception("Cloudflare API Error: ${response.statusCode}");
    }
  }

  /// Fetch a single station by ID
  Future<Station?> getStation(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/stations/$id'));

    if (response.statusCode == 200) {
      return Station.fromJson(json.decode(response.body));
    } else if (response.statusCode == 404) {
      return null;
    } else {
      throw Exception("Failed to fetch station details");
    }
  }
}
