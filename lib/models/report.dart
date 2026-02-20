class Report {
  final String traffic;
  final bool isAvailable;
  final DateTime time;
  final String? userId; // Optional

  Report({
    required this.traffic,
    required this.isAvailable,
    required this.time,
    this.userId,
  });

  // Factory constructor from Firestore
  factory Report.fromMap(Map<String, dynamic> data) {
    return Report(
      traffic: data['traffic'] ?? 'Unknown',
      isAvailable: data['isAvailable'] ?? true,
      time: (data['createdAt'] as dynamic).toDate(),
      userId: data['userId'],
    );
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'traffic': traffic,
      'isAvailable': isAvailable,
      'createdAt': time,
      'userId': userId,
    };
  }
}