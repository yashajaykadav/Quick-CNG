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
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: (isSubmitting || isDisabled) ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          disabledBackgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Submit Report',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
