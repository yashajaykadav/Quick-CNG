import 'dart:convert';
import 'package:http/http.dart' as http;

class WorkerService {

  static const String apiUrl =
      "https://calculate-station-status.yashkadav52.workers.dev";

  static Future<Map<String, dynamic>> getStationStatus(String stationId) async {

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "stationId": stationId
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Worker API failed");
    }

    return jsonDecode(response.body);
  }
}