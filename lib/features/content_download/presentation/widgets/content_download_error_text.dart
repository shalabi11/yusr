import 'package:flutter/material.dart';

class ContentDownloadErrorText extends StatelessWidget {
  const ContentDownloadErrorText({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(message, style: const TextStyle(color: Color(0xFFFCA5A5)));
  }
}
