import 'package:flutter/material.dart';
import 'package:yusr_app/core/theme/app_colors.dart';

class ContentProgressWidget extends StatelessWidget {
  const ContentProgressWidget({
    required this.progress,
    required this.downloadedBytes,
    required this.totalBytes,
    required this.currentFileName,
    required this.completedFiles,
    required this.totalFiles,
    super.key,
  });

  final double progress;
  final int downloadedBytes;
  final int totalBytes;
  final String? currentFileName;
  final int completedFiles;
  final int totalFiles;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'جاري تنزيل المحتوى',
            style: TextStyle(
              color: AppColors.textWhite,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: AppColors.textSecondary.withValues(alpha: 0.25),
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(999),
          ),
          const SizedBox(height: 10),
          Text(
            '${(progress * 100).toStringAsFixed(1)}% • ${_formatBytes(downloadedBytes)} / ${_formatBytes(totalBytes)}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            'الملف الحالي: ${currentFileName ?? '-'}',
            style: const TextStyle(color: AppColors.textWhite),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            'الملفات المكتملة: $completedFiles / $totalFiles',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';
    const units = ['B', 'KB', 'MB', 'GB'];
    var value = bytes.toDouble();
    var unitIndex = 0;
    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024;
      unitIndex++;
    }
    return '${value.toStringAsFixed(unitIndex == 0 ? 0 : 1)} ${units[unitIndex]}';
  }
}
