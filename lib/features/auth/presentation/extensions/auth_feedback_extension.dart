import 'package:flutter/material.dart';

extension AuthFeedbackExtension on BuildContext {
  void showAuthMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
