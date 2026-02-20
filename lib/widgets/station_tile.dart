import 'package:flutter/material.dart';
import '../models/station.dart';

class StationTile extends StatelessWidget {
  final Station station;
  final VoidCallback onTap;

  const StationTile({
    super.key,
    required this.station,
    required this.onTap,
  });

  Color getStatusColor() {
    return station.status == "Available" ? Colors.green : Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        title: Text(station.name),
        subtitle: Text(
          station.status,
          style: TextStyle(color: getStatusColor()),
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}