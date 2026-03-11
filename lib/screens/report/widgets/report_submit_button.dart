import 'package:flutter/material.dart';

class ReportSubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final bool isDisabled;
  final VoidCallback onPressed;

  const ReportSubmitButton({
    super.key,
    required this.isSubmitting,
    required this.isDisabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = !isSubmitting && !isDisabled;

    return SizedBox(
      width: double.infinity,
      height: 56, // Sleeker height
      child: FilledButton(
        onPressed: active ? onPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF1FAF5A), // Premium green
          disabledBackgroundColor: Colors.grey.shade200,
          disabledForegroundColor: Colors.grey.shade500,
          elevation: active ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5, // Thinner, cleaner spinner
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Submit Report',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600, // Semi-bold is cleaner
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}