import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final double size; // Add a size parameter
  const LoadingWidget({super.key, this.size = 36.0});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: const CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      ),
    );
  }
}