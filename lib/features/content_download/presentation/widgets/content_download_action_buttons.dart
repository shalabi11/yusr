import 'package:flutter/material.dart';
import 'package:yusr_app/features/content_download/presentation/cubit/content_download_state.dart';

class ContentDownloadActionButtons extends StatelessWidget {
  const ContentDownloadActionButtons({
    required this.state,
    required this.hasSelection,
    required this.onStart,
    required this.onPause,
    required this.onResume,
    super.key,
  });

  final ContentDownloadState state;
  final bool hasSelection;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    if (state.isDownloading) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onPause,
          icon: const Icon(Icons.pause_circle_outline),
          label: const Text('إيقاف مؤقت'),
        ),
      );
    }

    if (state.isPaused) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: onResume,
          icon: const Icon(Icons.play_arrow),
          label: const Text('استكمال التنزيل'),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: hasSelection ? onStart : null,
        child: const Text('بدء التنزيل'),
      ),
    );
  }
}
