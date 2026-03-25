import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quickcng/models/report.dart';

const String baseUrl = "https://backend.yashkadav52.workers.dev";

// Reports submitted by the current user
final userReportsProvider = FutureProvider<List<Report>>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];

  final response = await http.get(
    Uri.parse("$baseUrl/users/${user.uid}/reports"),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to load user reports");
  }

  final List data = jsonDecode(response.body);
  return data.map((e) => Report.fromMap(e["id"], e)).toList();
});

/// Delete report
final deleteReportProvider = Provider((ref) {
  Future<void> deleteReport(String reportId) async {
    final response = await http.delete(Uri.parse("$baseUrl/reports/$reportId"));

    if (response.statusCode != 200) {
      throw Exception("Report deletion failed");
    }

    // Refresh user reports after deletion
    ref.invalidate(userReportsProvider);
  }

  return deleteReport;
});

/// Reports for a specific station
final stationReportsProvider = FutureProvider.family<List<Report>, String>((
  ref,
  stationId,
) async {
  final response = await http.get(
    Uri.parse("$baseUrl/stations/$stationId/reports"),
  );

  if (response.statusCode != 200) {
    throw Exception("Failed to load reports");
  }

  final List data = jsonDecode(response.body);

  return data.map((e) => Report.fromMap(e["id"], e)).toList();
});

/// Submit report
final submitReportProvider = Provider((ref) {
  Future<void> submitReport(String stationId, Report report) async {
    final response = await http.post(
      Uri.parse("$baseUrl/stations/$stationId/reports"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(report.toMap()),
    );

    if (response.statusCode != 200) {
    
      throw Exception("Report submission failed: ${response.body}");
    }
  }

  return submitReport;
});
